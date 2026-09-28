import 'package:flutter/material.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/morning_athkar_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim Pro',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      // Set the home to our new DashboardScreen
      home: const DashboardScreen(), 
    );
  }
}

// A new Dashboard screen acting as your "Front Page"
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muslim Pro'),
        backgroundColor: Colors.green.shade100,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Makes buttons fill the width
          children: [
            // --- Prayer Times Button ---
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrayerTimesScreen()),
                );
              },
              icon: const Icon(Icons.access_time, size: 28),
              label: const Text(
                'Prayer Times',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            
            const SizedBox(height: 20), // Spacing between buttons
            
            // --- Morning Zikr Button ---
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MorningAthkarScreen()),
                );
              },
              icon: const Icon(Icons.wb_sunny_outlined, size: 28),
              label: const Text(
                'Morning Zikr',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.teal.shade50, // Optional: slightly different color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
