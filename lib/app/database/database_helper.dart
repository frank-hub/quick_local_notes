import 'package:notes/app/model/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String tableName = 'notes';
  static final DatabaseHelper _dbHelper = DatabaseHelper._internal();

  Database? _db;

  factory DatabaseHelper() {
    return _dbHelper;
  }

  DatabaseHelper._internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql =
        'CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR, description TEXT, data DATETIME)';
    await db.execute(sql);
  }

  initDB() async {
    final databasePath = await getDatabasesPath();
    final localDatabase = join(databasePath, 'notesDatabase');

    var db = await openDatabase(localDatabase, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> saveNote(Note note) async {
    var dataBase = await db;

    int result = await dataBase.insert(tableName, note.toMap());
    return result;
  }

  recoverNote() async {
    var dataBase = await db;
    String sql = 'SELECT * FROM $tableName ORDER BY data DESC';

    List notes = await dataBase.rawQuery(sql);
    return notes;
  }

  Future<int> removeNote(int id) async {
    var dataBase = await db;
    return await dataBase.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateNote(Note note) async {
    var dataBase = await db;
    return await dataBase.update(
      tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
}
