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
      version: 1,
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
      },
    );
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

    // One transaction: either everything loads or nothing does.
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

  Future<List<Surah>> getSurahs() async {
    final db = await database;
    final rows = await db.query('surahs', orderBy: 'number');
    return rows.map(Surah.fromMap).toList();
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
}