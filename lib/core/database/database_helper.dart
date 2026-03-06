import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local SQLite DB — all data lives on device.
/// No data is sent to any server (Firebase is relay-only).
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'oouzoo.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id           INTEGER PRIMARY KEY,
        uuid         TEXT,
        nickname     TEXT NOT NULL,
        planet_name  TEXT NOT NULL DEFAULT '우리 별',
        fcm_token    TEXT,
        partner_fcm  TEXT,
        partner_uuid TEXT,
        created_at   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE planet (
        id          INTEGER PRIMARY KEY,
        level       INTEGER NOT NULL DEFAULT 1,
        star_shards INTEGER NOT NULL DEFAULT 0,
        mood        INTEGER NOT NULL DEFAULT 3,
        updated_at  TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id     TEXT NOT NULL UNIQUE,
        item_type   TEXT NOT NULL,
        equipped    INTEGER NOT NULL DEFAULT 0,
        obtained_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE diary (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        title      TEXT NOT NULL,
        content    TEXT NOT NULL,
        mood       INTEGER NOT NULL DEFAULT 3,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE anniversary (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        label       TEXT NOT NULL,
        date        TEXT NOT NULL,
        is_couple_start INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE gacha_log (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id     TEXT NOT NULL,
        result_type TEXT NOT NULL,
        created_at  TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE purchases (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id   TEXT NOT NULL UNIQUE,
        purchased_at TEXT NOT NULL
      )
    ''');

    // v2: daily_question table
    await _createDailyQuestionTable(db);

    // Insert default rows
    final now = DateTime.now().toIso8601String();
    await db.insert('planet', {
      'id': 1,
      'level': 1,
      'star_shards': 0,
      'mood': 3,
      'updated_at': now,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createDailyQuestionTable(db);
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE user_profile ADD COLUMN uuid TEXT');
      await db.execute(
          'ALTER TABLE user_profile ADD COLUMN partner_uuid TEXT');
    }
  }

  Future<void> _createDailyQuestionTable(Database db) async {
    await db.execute('''
      CREATE TABLE daily_question (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id         INTEGER NOT NULL,
        question            TEXT NOT NULL,
        my_answer           TEXT,
        partner_answer      TEXT,
        answered_at         TEXT,
        partner_answered_at TEXT,
        date                TEXT NOT NULL UNIQUE
      )
    ''');
  }
}
