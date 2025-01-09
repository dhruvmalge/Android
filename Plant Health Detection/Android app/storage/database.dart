import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('plant_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return openDatabase(path, version: 2, onCreate: (db, version) {
      return db.execute("""
          CREATE TABLE plant_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            datetime DATETIME,
            confidence REAL,
            predicted_disease TEXT,
            detected_objects TEXT
          )
      """);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // The schema changes should be applied here.
        // Make sure the new columns are added if not already there
        await db.execute('ALTER TABLE plant_data ADD COLUMN datetime DATETIME');
        await db.execute('ALTER TABLE plant_data ADD COLUMN confidence REAL');
        await db.execute('ALTER TABLE plant_data ADD COLUMN predicted_disease TEXT');
        await db.execute('ALTER TABLE plant_data ADD COLUMN detected_objects TEXT');
      }
    });
  }

  Future<void> insertData(DateTime datetime, String confidence, String predictedDisease, String detectedObjects) async {
    final db = await instance.database;
    await db.insert(
      'plant_data',
      {
        'datetime': datetime.toIso8601String(),  // Store datetime as a string
        'confidence': confidence,
        'predicted_disease': predictedDisease,
        'detected_objects': detectedObjects,  // Store as JSON string
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final db = await instance.database;
    return await db.query('plant_data');
  }
}
