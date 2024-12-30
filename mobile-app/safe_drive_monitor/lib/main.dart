import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_drive_monitor/services/sensor_service.dart';
import 'package:safe_drive_monitor/services/database_service.dart';
import 'package:safe_drive_monitor/models/driving_record.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SensorService _sensorService = SensorService();
  final DatabaseService _dbService = DatabaseService();
  String _accelerationStatus = 'Monitoring...';
  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;
  double _totalAcceleration = 0.0;
  double _currentSpeed = 0.0;
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeLocationUpdates();
    _initializeAccelerometer();
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.activityRecognition.request();
    await Permission.sensors.request();
    await Geolocator.requestPermission();
  }

  void _initializeAccelerometer() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
        _totalAcceleration = 
            sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        
        if (_sensorService.isSuddenAcceleration(event, 20.0)) {
          _accelerationStatus = 'Sudden acceleration detected!';
        } else {
          _accelerationStatus = 'Normal movement';
        }
      });
    });
  }

  void _initializeLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      if (_dbService.shouldSample(position.speed * 3.6)) {
        final record = DrivingRecord(
          timestamp: DateTime.now(),
          speed: position.speed * 3.6,
          latitude: position.latitude,
          longitude: position.longitude,
          accelerationX: _x,
          accelerationY: _y,
          accelerationZ: _z,
          totalAcceleration: _totalAcceleration,
          isSuddenAcceleration: _accelerationStatus == 'Sudden acceleration detected!',
        );
        _dbService.insertRecord(record);
      }
      setState(() {
        _currentSpeed = position.speed <= 0 ? 0.0 : (position.speed * 3.6).clamp(0, 200);
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              await _dbService.debugDatabase();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Current Speed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${_currentSpeed.toStringAsFixed(1)} km/h',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Lat: ${_latitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Long: ${_longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              _accelerationStatus,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Accelerometer Data:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('X: ${_x.toStringAsFixed(2)} m/s²'),
            Text('Y: ${_y.toStringAsFixed(2)} m/s²'),
            Text('Z: ${_z.toStringAsFixed(2)} m/s²'),
            const SizedBox(height: 10),
            Text(
              'Total Acceleration: ${_totalAcceleration.toStringAsFixed(2)} m/s²',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
