import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/surah.dart';
import '../models/ayah.dart';

class QuranDatabase {
  QuranDatabase._();
  static final QuranDatabase instance = QuranDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'quran.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE surahs (
            number INTEGER PRIMARY KEY,
            name_arabic TEXT NOT NULL,
            name_english TEXT NOT NULL,
            meaning TEXT NOT NULL,
            revelation_type TEXT NOT NULL,
            ayah_count INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE ayahs (
            surah_number INTEGER NOT NULL,
            ayah_number INTEGER NOT NULL,
            text_arabic TEXT NOT NULL,
            text_english TEXT NOT NULL,
            juz INTEGER NOT NULL,
            page INTEGER NOT NULL,
            PRIMARY KEY (surah_number, ayah_number)
          )
        ''');
        await _createUserTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createUserTables(db);
        }
      },
    );
  }

  Future<void> _createUserTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (surah_number, ayah_number)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS last_read (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL
      )
    ''');
  }

  /// Loads the bundled JSON files into SQLite the first time only.
  Future<void> ensureLoaded() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM ayahs')) ??
        0;
    if (count == 6236) return; // already fully loaded

    final arabicJson = jsonDecode(
        await rootBundle.loadString('assets/data/quran_arabic.json'));
    final englishJson = jsonDecode(
        await rootBundle.loadString('assets/data/quran_english.json'));

    final arabicSurahs = arabicJson['data']['surahs'] as List;
    final englishSurahs = englishJson['data']['surahs'] as List;

    await db.transaction((txn) async {
      await txn.delete('ayahs');
      await txn.delete('surahs');
      final batch = txn.batch();

      for (var i = 0; i < arabicSurahs.length; i++) {
        final s = arabicSurahs[i];
        final e = englishSurahs[i];
        final arabicAyahs = s['ayahs'] as List;
        final englishAyahs = e['ayahs'] as List;

        batch.insert(
          'surahs',
          Surah(
            number: s['number'],
            nameArabic: s['name'],
            nameEnglish: s['englishName'],
            meaning: s['englishNameTranslation'],
            revelationType: s['revelationType'],
            ayahCount: arabicAyahs.length,
          ).toMap(),
        );

        for (var j = 0; j < arabicAyahs.length; j++) {
          final a = arabicAyahs[j];
          batch.insert(
            'ayahs',
            Ayah(
              surahNumber: s['number'],
              ayahNumber: a['numberInSurah'],
              textArabic: a['text'],
              textEnglish: englishAyahs[j]['text'],
              juz: a['juz'],
              page: a['page'],
            ).toMap(),
          );
        }
      }
      await batch.commit(noResult: true);
    });
  }

  // ---------- Surahs and ayahs ----------

  Future<List<Surah>> getSurahs() async {
    final db = await database;
    final rows = await db.query('surahs', orderBy: 'number');
    return rows.map(Surah.fromMap).toList();
  }

  Future<Surah> getSurah(int number) async {
    final db = await database;
    final rows =
        await db.query('surahs', where: 'number = ?', whereArgs: [number]);
    return Surah.fromMap(rows.first);
  }

  Future<List<Ayah>> getAyahs(int surahNumber) async {
    final db = await database;
    final rows = await db.query(
      'ayahs',
      where: 'surah_number = ?',
      whereArgs: [surahNumber],
      orderBy: 'ayah_number',
    );
    return rows.map(Ayah.fromMap).toList();
  }

  // ---------- Bookmarks ----------

  /// Returns the ayah numbers bookmarked in this surah.
  Future<Set<int>> getBookmarkedAyahs(int surahNumber) async {
    final db = await database;
    final rows = await db.query(
      'bookmarks',
      columns: ['ayah_number'],
      where: 'surah_number = ?',
      whereArgs: [surahNumber],
    );
    return rows.map((r) => r['ayah_number'] as int).toSet();
  }

  /// Adds or removes a bookmark. Returns true if it is now bookmarked.
  Future<bool> toggleBookmark(int surahNumber, int ayahNumber) async {
    final db = await database;
    final removed = await db.delete(
      'bookmarks',
      where: 'surah_number = ? AND ayah_number = ?',
      whereArgs: [surahNumber, ayahNumber],
    );
    if (removed > 0) return false;
    await db.insert('bookmarks', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'created_at': DateTime.now().toIso8601String(),
    });
    return true;
  }

  /// All bookmarks, newest first, with surah name and English text.
  Future<List<Map<String, dynamic>>> getAllBookmarks() async {
    final db = await database;
    return db.rawQuery('''
      SELECT b.surah_number, b.ayah_number, s.name_english, a.text_english
      FROM bookmarks b
      JOIN surahs s ON s.number = b.surah_number
      JOIN ayahs a ON a.surah_number = b.surah_number
                  AND a.ayah_number = b.ayah_number
      ORDER BY b.created_at DESC
    ''');
  }

  // ---------- Last read ----------

  Future<void> saveLastRead(int surahNumber, int ayahNumber) async {
    final db = await database;
    await db.insert(
      'last_read',
      {'id': 1, 'surah_number': surahNumber, 'ayah_number': ayahNumber},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns {'surah': n, 'ayah': n} or null if nothing read yet.
  Future<Map<String, int>?> getLastRead() async {
    final db = await database;
    final rows = await db.query('last_read', where: 'id = 1');
    if (rows.isEmpty) return null;
    return {
      'surah': rows.first['surah_number'] as int,
      'ayah': rows.first['ayah_number'] as int,
    };
  }
}