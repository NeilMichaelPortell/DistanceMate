import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';
import 'widgets/home_screen.dart';
import 'widgets/distance_screen.dart';

void main() async {
  // Ensure that plugin services are initialized before calling runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options from firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the main application
  runApp(const MyApp());
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DistanceMate', //Application title
      theme: ThemeData(
        primarySwatch: Colors.blue, //Application theme color
      ),
      initialRoute: '/', // Initial route of the application
      routes: {
        '/': (context) => const HomeScreen(), //Home screen route
        '/distance': (context) => const DistanceScreen(), //Distance screen route
      }
    );
  }
}