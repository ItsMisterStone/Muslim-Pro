import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaBearing; // degrees clockwise from true north
  String? _error;
    // ---- Dial layout settings: edit these ----
  // Radius: 1.0 = on the ring, smaller = toward the centre, larger = outside the ring
  static const double _nRadius = 0.85;
  static const double _eRadius = 0.85;
  static const double _sRadius = 0.85;
  static const double _wRadius = 0.85;
  static const double _qiblaRadius = 0.65;
  static const double _qiblaIconRotation = 278; // degrees, clockwise is +

  // Extra nudge in pixels (x: right is +, y: down is +)
  static const Offset _nOffset = Offset(0, 0);
  static const Offset _eOffset = Offset(0, 0);
  static const Offset _sOffset = Offset(0, 0);
  static const Offset _wOffset = Offset(0, 0);
  static const Offset _qiblaOffset = Offset(0, 0);


  @override
  void initState() {
    super.initState();
    _loadQibla();
  }

  Future<void> _loadQibla() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _error = 'Please turn on location services.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _error = 'Location permission is required.');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final bearing = Qibla.qibla(coordinates);

      setState(() => _qiblaBearing = bearing);
    } catch (e) {
      setState(() => _error = 'Could not get location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla')),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _qiblaBearing == null
              ? const Center(child: CircularProgressIndicator())
              : _buildCompass(_qiblaBearing!),
    );
  }

  Widget _buildCompass(double qibla) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Compass error.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawHeading = snapshot.data?.heading;
        if (rawHeading == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('This device has no compass sensor.',
                  textAlign: TextAlign.center),
            ),
          );
        }

        final heading = (rawHeading + 360) % 360;
        // How far the phone's top is from the Qibla, in -180..180
        final diff = ((qibla - heading + 540) % 360) - 180;
        final aligned = diff.abs() < 3;
        final color = aligned ? Colors.green : Theme.of(context).colorScheme.primary;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              aligned ? 'You are facing the Qibla' : 'Turn until the mosque is at the top',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 16),
            // fixed pointer showing where the phone is facing
            Icon(Icons.arrow_drop_down, size: 48, color: color),
            SizedBox(
              width: 300,
              height: 300,
              child: Transform.rotate(
                angle: -heading * math.pi / 180,
                child: Stack(
                  children: [
                    // dial circle
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 4),
                      ),
                    ),
                    _dialMarker(
                        0,
                        const Text('N',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                        radius: _nRadius,
                        offset: _nOffset,
                        upright: heading),
                    _dialMarker(
                        90,
                        const Text('E',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        radius: _eRadius,
                        offset: _eOffset,
                        upright: heading),
                    _dialMarker(
                        180,
                        const Text('S',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        radius: _sRadius,
                        offset: _sOffset,
                        upright: heading),
                    _dialMarker(
                        270,
                        const Text('W',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        radius: _wRadius,
                        offset: _wOffset,
                        upright: heading),
                    _dialMarker(
                        qibla,
                        Transform.rotate(
                          angle: _qiblaIconRotation * math.pi / 180,
                          child: Icon(Icons.mosque, size: 44, color: color),
                        ),
                        radius: _qiblaRadius,
                        offset: _qiblaOffset),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Heading: ${heading.toStringAsFixed(0)}°   '
                'Qibla: ${qibla.toStringAsFixed(0)}°'),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Hold the phone flat. If the compass seems off, move it in a figure-8 motion.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  // Places a widget on the dial's edge at the given bearing (0 = top of dial)
      Widget _dialMarker(double bearingDeg, Widget child,
      {double radius = 1.0,
      Offset offset = Offset.zero,
      double upright = 0}) {
    final a = bearingDeg * math.pi / 180;
    return Align(
      alignment: Alignment(radius * math.sin(a), -radius * math.cos(a)),
      child: Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: upright * math.pi / 180, // pass the heading to keep it upright
          child: child,
        ),
      ),
    );
  }
  }