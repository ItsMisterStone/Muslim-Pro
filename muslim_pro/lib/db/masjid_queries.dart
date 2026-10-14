import 'package:sqflite/sqflite.dart';
import '../models/masjid_model.dart';
import 'database_helper.dart';

class MasjidQueries {
  static const String tableName = 'masjids';

  // Helper for the so table exists and pre-loads sample masjids with different schedules
  static Future<void> ensureTableAndSeed() async {
    final Database db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        area TEXT NOT NULL,
        fajr_adhan INTEGER NOT NULL,
        dhuhr_adhan INTEGER NOT NULL,
        asr_adhan INTEGER NOT NULL,
        maghrib_adhan INTEGER NOT NULL,
        isha_adhan INTEGER NOT NULL,
        fajr_jamaat INTEGER NOT NULL,
        dhuhr_jamaat INTEGER NOT NULL,
        asr_jamaat INTEGER NOT NULL,
        maghrib_jamaat INTEGER NOT NULL,
        isha_jamaat INTEGER NOT NULL
      )
    ''');

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );

    // Seed default masjids if the table is empty
    if (count == 0) {
      final sampleMasjids = [
        Masjid(
          name: 'Central Jame Masjid',
          area: 'Block C, Main Road',
          fajrAdhanOffset: 10,
          dhuhrAdhanOffset: 45,
          asrAdhanOffset: 10,
          maghribAdhanOffset: 2,
          ishaAdhanOffset: 15,
          fajrJamaatDelay: 20,
          dhuhrJamaatDelay: 15,
          asrJamaatDelay: 15,
          maghribJamaatDelay: 5,
          ishaJamaatDelay: 15,
        ),
        Masjid(
          name: 'Baitul Aman Masjid',
          area: 'Sector 4, North Avenue',
          fajrAdhanOffset: 15,
          dhuhrAdhanOffset: 60,
          asrAdhanOffset: 15,
          maghribAdhanOffset: 3,
          ishaAdhanOffset: 25,
          fajrJamaatDelay: 25,
          dhuhrJamaatDelay: 15,
          asrJamaatDelay: 15,
          maghribJamaatDelay: 7,
          ishaJamaatDelay: 20,
        ),
        Masjid(
          name: 'Masjid Al-Noor',
          area: 'University Gate Area',
          fajrAdhanOffset: 5,
          dhuhrAdhanOffset: 50,
          asrAdhanOffset: 5,
          maghribAdhanOffset: 1,
          ishaAdhanOffset: 10,
          fajrJamaatDelay: 15,
          dhuhrJamaatDelay: 20,
          asrJamaatDelay: 10,
          maghribJamaatDelay: 5,
          ishaJamaatDelay: 15,
        ),
      ];

      for (final masjid in sampleMasjids) {
        await db.insert(tableName, masjid.toMap());
      }
    }
  }

  static Future<List<Masjid>> getAllMasjids() async {
    await ensureTableAndSeed();
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'name ASC',
    );
    return maps.map((m) => Masjid.fromMap(m)).toList();
  }

  static Future<int> insertMasjid(Masjid masjid) async {
    final Database db = await DatabaseHelper.instance.database;
    return await db.insert(tableName, masjid.toMap());
  }

  static Future<int> updateMasjid(Masjid masjid) async {
    final Database db = await DatabaseHelper.instance.database;
    return await db.update(
      tableName,
      masjid.toMap(),
      where: 'id = ?',
      whereArgs: [masjid.id],
    );
  }
}