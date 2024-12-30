class AppConfig {
  // Database configs
  static const String dbName = 'safe_drive_monitor.db';
  static const String recordsTable = 'driving_records';
  static const String drivesTable = 'drives';
  static const int batchSize = 10;
  static const int retentionDays = 90;

  // Sampling rate configs
  static const double minRecordingSpeed = 10.0; // km/h
  static const Map<int, Duration> speedSamplingRates = {
    10: Duration(seconds: 5),  // 10-30 km/h: every 5s
    30: Duration(seconds: 2),  // 30-60 km/h: every 2s
    60: Duration(seconds: 1),  // >60 km/h: every 1s
  };

  // Drive detection configs
  static const double driveStartSpeed = 10.0; // km/h
  static const int driveStartDuration = 60; // seconds
  static const double driveEndSpeed = 10.0; // km/h
  static const int driveEndDuration = 1800; // seconds
  
  // Speed monitoring
  static const double speedThreshold = 110.0; // km/h
  
  // Acceleration monitoring
  static const double suddenAccelerationThreshold = 20.0; // m/s²
  static const int suddenAccGroupInterval = 10; // seconds

  // UI configs
  static const int warningDisplaySeconds = 5;
  static const double speedWarningThreshold = 110.0; // km/h
} 