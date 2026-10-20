import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  AppDatabase._(this._db);
  final Database _db;
  static AppDatabase? _instance;
  static Future<AppDatabase>? _opening;

  static Future<AppDatabase> open() async {
    if (_instance != null) return _instance!;
    if (_opening != null) return _opening!;
    _opening = _doOpen();
    return _opening!;
  }

  static Future<AppDatabase> _doOpen() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      join(dir, 'ai_photo.db'),
      version: 1,
      onCreate: (db, v) => db.execute('''
        CREATE TABLE photos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source_path TEXT NOT NULL,
          width INTEGER NOT NULL,
          height INTEGER NOT NULL,
          taken_at TEXT NOT NULL,
          thumbnail_path TEXT,
          feature_key TEXT
        )
      '''),
    );
    return _instance = AppDatabase._(db);
  }

  Database get db => _db;
}
