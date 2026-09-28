import 'package:flutter/material.dart';
import 'screens/prayer_times_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim Pro',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const PrayerTimesScreen(),
    );
  }
}