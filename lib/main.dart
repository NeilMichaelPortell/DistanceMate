import 'package:flutter/material.dart';
import 'widgets/home_screen.dart';
import 'widgets/distance_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DistanceMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Home page as the first screen
      routes: {
        '/': (context) => const HomeScreen(), // Home page route
        '/distance': (context) => const DistanceScreen(),
      },
    );
  }
}