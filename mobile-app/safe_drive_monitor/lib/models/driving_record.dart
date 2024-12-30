class DrivingRecord {
  final int? id;
  final DateTime timestamp;
  final double speed;
  final double latitude;
  final double longitude;
  final double accelerationX;
  final double accelerationY;
  final double accelerationZ;
  final double totalAcceleration;
  final bool isSuddenAcceleration;

  DrivingRecord({
    this.id,
    required this.timestamp,
    required this.speed,
    required this.latitude,
    required this.longitude,
    required this.accelerationX,
    required this.accelerationY,
    required this.accelerationZ,
    required this.totalAcceleration,
    required this.isSuddenAcceleration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'speed': speed,
      'latitude': latitude,
      'longitude': longitude,
      'accelerationX': accelerationX,
      'accelerationY': accelerationY,
      'accelerationZ': accelerationZ,
      'totalAcceleration': totalAcceleration,
      'isSuddenAcceleration': isSuddenAcceleration ? 1 : 0,
    };
  }
} 