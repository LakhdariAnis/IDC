import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

enum ClipDirection { phoneToPC, pcToPhone }

class ClipboardEntry {
  final int? id;
  final String text;
  final ClipDirection direction;
  final DateTime timestamp;

  ClipboardEntry({
    this.id,
    required this.text,
    required this.direction,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'direction': direction == ClipDirection.phoneToPC ? 0 : 1,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory ClipboardEntry.fromMap(Map<String, dynamic> map) => ClipboardEntry(
        id: map['id'] as int?,
        text: map['text'] as String,
        direction: (map['direction'] as int) == 0
            ? ClipDirection.phoneToPC
            : ClipDirection.pcToPhone,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      );
}

class ClipboardStore {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'clipboard.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            direction INTEGER NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> insert(ClipboardEntry entry) async {
    final database = await db;
    await database.insert('entries', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    // Keep only latest 100 entries
    await database.execute('''
      DELETE FROM entries WHERE id NOT IN (
        SELECT id FROM entries ORDER BY timestamp DESC LIMIT 100
      )
    ''');
  }

  static Future<List<ClipboardEntry>> getAll() async {
    final database = await db;
    final maps = await database.query('entries',
        orderBy: 'timestamp DESC');
    return maps.map(ClipboardEntry.fromMap).toList();
  }

  static Future<void> delete(int id) async {
    final database = await db;
    await database.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clear() async {
    final database = await db;
    await database.delete('entries');
  }
}
