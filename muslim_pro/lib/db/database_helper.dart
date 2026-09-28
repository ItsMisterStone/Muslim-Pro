import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton: the whole app shares one instance
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'muslim_pro.db';
  static const int _dbVersion = 1;

  Database? _database;

  // Opens the DB the first time, then reuses it
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Runs only on a fresh install
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasbeeh_counters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 0,
        target INTEGER NOT NULL DEFAULT 33,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Runs when the installed DB is older than _dbVersion.
  // Future schema changes go here.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Example for later:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE tasbeeh_counters ADD COLUMN notes TEXT');
    // }
  }
}