import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:safe_drive_monitor/models/driving_record.dart';
import 'package:safe_drive_monitor/config/app_config.dart';

class DatabaseService {
 static Database? _database;
 final _recordBuffer = <DrivingRecord>[];
 DateTime _lastSampleTime = DateTime.now();
  Future<Database> get database async {
   if (_database != null) return _database!;
   _database = await _initDB();
   return _database!;
 }
  Future<Database> _initDB() async {
   String path = join(await getDatabasesPath(), AppConfig.dbName);
   return await openDatabase(
     path,
     version: 1,
     onCreate: (db, version) async {
       // Create main table
       await db.execute('''
         CREATE TABLE ${AppConfig.tableName}(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           timestamp INTEGER NOT NULL,
           speed REAL NOT NULL,
           latitude REAL NOT NULL,
           longitude REAL NOT NULL,
           accelerationX REAL NOT NULL,
           accelerationY REAL NOT NULL,
           accelerationZ REAL NOT NULL,
           totalAcceleration REAL NOT NULL,
           isSuddenAcceleration INTEGER NOT NULL
         )
       ''');
        // Create indexes
       await db.execute(
         'CREATE INDEX idx_timestamp ON ${AppConfig.tableName}(timestamp)'
       );
       await db.execute(
         'CREATE INDEX idx_speed ON ${AppConfig.tableName}(speed) WHERE speed > ${AppConfig.minRecordingSpeed}'
       );
       await db.execute(
         'CREATE INDEX idx_sudden ON ${AppConfig.tableName}(isSuddenAcceleration) WHERE isSuddenAcceleration = 1'
       );
     },
   );
 }
  bool shouldSample(double speedKmh) {
   print('SDM_LOG: Checking sampling for speed: $speedKmh km/h');
   if (speedKmh < AppConfig.minRecordingSpeed) {
     return false;
   }
    final now = DateTime.now();
   Duration requiredInterval = AppConfig.speedSamplingRates.entries
       .firstWhere(
         (entry) => speedKmh < entry.key,
         orElse: () => AppConfig.speedSamplingRates.entries.last,
       )
       .value;
    if (now.difference(_lastSampleTime) >= requiredInterval) {
     _lastSampleTime = now;
     return true;
   }
   return false;
 }
  Future<void> insertRecord(DrivingRecord record) async {
   print('SDM_LOG: Attempting to insert record: ${record.toMap()}');
   _recordBuffer.add(record);
   
   if (_recordBuffer.length >= AppConfig.batchSize) {
     final db = await database;
     await db.transaction((txn) async {
       final batch = txn.batch();
       for (var record in _recordBuffer) {
         batch.insert(AppConfig.tableName, record.toMap());
       }
       await batch.commit();
     });
     print('SDM_LOG: Batch inserted ${_recordBuffer.length} records');
     _recordBuffer.clear();
      // Clean up old records
     await _cleanOldRecords();
   }
 }
  Future<void> _cleanOldRecords() async {
   final db = await database;
   final cutoffDate = DateTime.now()
       .subtract(Duration(days: AppConfig.retentionDays));
   
   await db.delete(
     AppConfig.tableName,
     where: 'timestamp < ?',
     whereArgs: [cutoffDate.millisecondsSinceEpoch],
   );
 }
  // Method to force write remaining buffer, useful when app is closing
 Future<void> flushBuffer() async {
   if (_recordBuffer.isNotEmpty) {
     final db = await database;
     await db.transaction((txn) async {
       final batch = txn.batch();
       for (var record in _recordBuffer) {
         batch.insert(AppConfig.tableName, record.toMap());
       }
       await batch.commit();
     });
     _recordBuffer.clear();
   }
 }
  Future<void> debugDatabase() async {
    try {
      print('SDM_LOG: Current buffer size: ${_recordBuffer.length}');
      if (_recordBuffer.isNotEmpty) {
        print('SDM_LOG: First buffered record: ${_recordBuffer.first.toMap()}');
      }

      final db = await database;
      final path = await getDatabasesPath();
      print('SDM_LOG: Database path: $path');
      print('SDM_LOG: Database name: ${AppConfig.dbName}');
      
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${AppConfig.tableName}')
      );
      print('SDM_LOG: Total records in DB: $count');

      if (count != null && count > 0) {
        final records = await db.query(
          AppConfig.tableName,
          limit: 5,
          orderBy: 'timestamp DESC'
        );
        print('SDM_LOG: Latest 5 records:');
        records.forEach((record) => print('SDM_LOG: $record'));
      }
    } catch (e) {
      print('SDM_LOG: Database error: $e');
    }
  }
}
