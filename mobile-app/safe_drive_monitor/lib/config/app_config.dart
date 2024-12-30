class AppConfig {
  // Database configs
  static const String dbName = 'safe_drive_monitor.db';
  static const String tableName = 'driving_records';
  static const int batchSize = 10;
  static const int retentionDays = 90;

  // Sampling rate configs
  static const double minRecordingSpeed = 10.0; // km/h
  static const Map<int, Duration> speedSamplingRates = {
    10: Duration(seconds: 5),  // 10-30 km/h: every 5s
    30: Duration(seconds: 2),  // 30-60 km/h: every 2s
    60: Duration(seconds: 1),  // >60 km/h: every 1s
  };
} 