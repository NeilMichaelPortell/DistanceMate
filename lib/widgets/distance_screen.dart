import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/distance_model.dart';
import '../services/notifi_service.dart';

class DistanceScreen extends StatefulWidget {
  const DistanceScreen({super.key});

  @override
  _DistancePageState createState() => _DistancePageState();
}

class _DistancePageState extends State<DistanceScreen> {
  DistanceModel? _locationA;
  DistanceModel? _locationB;
  double? _distance;
  final NotificationService _notificationService = NotificationService(); 
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _notificationService.initNotification(); // Initialize notifications
  }

  // Check and request location permissions
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return;
    }

    print('Location permission granted.');
  }

  // Show a dialog to prompt the user to enable location permissions
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
            "This app needs location permissions to work. Please allow access in settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Set the location (A or B) and show a notification if Location A is set
  Future<void> _setLocation(bool isLocationA) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      if (isLocationA) {
        _locationA = DistanceModel(latitude: position.latitude, longitude: position.longitude);
        _notificationService.showNotification(
          title: 'Location A Set',
          body: 'Waiting for Location B...',
        ); // Show notification
      } else {
        _locationB = DistanceModel(latitude: position.latitude, longitude: position.longitude);
      }
    });
  }

  // Show a dialog to prompt the user to enable location services 
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Services Disabled"),
        content: const Text("Please enable GPS to get your location."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Calculate the distance between Location A and Location B 
  void _calculateDistance() {
    if (_locationA != null && _locationB != null) {
      setState(() {
        _distance = _locationA!.calculateDistance(_locationB!);
      });
    }
  }

  // Save the coordinates and distance to Firebase Realtime Database
  Future<void> _saveToFirebase() async {
    if (_locationA != null && _locationB != null && _distance != null) {
      await _database.child('distances').push().set({
        'locationA': {'latitude': _locationA!.latitude, 'longitude': _locationA!.longitude},
        'locationB': {'latitude': _locationB!.latitude, 'longitude': _locationB!.longitude},
        'distance': _distance,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Show a notification to indicate success
      _notificationService.showNotification(
        title: 'Success',
        body: 'Data saved successfully',
      );
    } else {
      // Show a notification to indicate failure
      _notificationService.showNotification(
        title: 'Error',
        body: 'Please set both locations and calculate the distance',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Distance Calculator"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _setLocation(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Set Location A"),
            ),
            const SizedBox(height: 10),
            Text(
              _locationA == null
                  ? "Location A: Not set"
                  : "Location A: (${_locationA!.latitude}, ${_locationA!.longitude})",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => _setLocation(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Set Location B"),
            ),
            const SizedBox(height: 10),
            Text(
              _locationB == null
                  ? "Location B: Not set"
                  : "Location B: (${_locationB!.latitude}, ${_locationB!.longitude})",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _calculateDistance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Calculate Distance"),
            ),
            const SizedBox(height: 20),
            Text(
              _distance == null
                  ? "Distance: Not calculated"
                  : "Distance: ${_distance!.toStringAsFixed(2)} km",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saveToFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Save to Firebase"),
            ),
          ],
        ),
      ),
    );
  }
}