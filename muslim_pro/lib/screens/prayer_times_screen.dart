import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final _locationService = LocationService();
  final _prayerService = PrayerTimeService();

  bool _loading = true;
  String? _error;
  String _locationText = '';
  Map<String, DateTime> _times = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      final times = _prayerService.getTodayTimes(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _times = times;
        _locationText =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM y').format(DateTime.now()),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('Location: $_locationText'),
                    const SizedBox(height: 16),
                    ..._times.entries.map(
                      (e) => Card(
                        child: ListTile(
                          title: Text(e.key),
                          trailing: Text(
                            DateFormat.jm().format(e.value),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}