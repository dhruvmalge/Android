import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sensor_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE sensor_data(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT,
          temperature REAL,
          humidity REAL,
          ldrValue REAL
        )
      ''');
    });
  }

  Future<void> insertData(double ldrValue, double temperature, double humidity) async {
    final db = await instance.database;
    await db.insert('sensor_data', {
      'timestamp': DateTime.now().toString(),
      'temperature': temperature,
      'humidity': humidity,
      'ldrValue': ldrValue,
    });
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final db = await instance.database;
    return await db.query('sensor_data');
  }
}

