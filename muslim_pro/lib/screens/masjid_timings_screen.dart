import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../db/masjid_queries.dart';
import '../models/masjid_model.dart';

class MasjidTimingsScreen extends StatefulWidget {
  const MasjidTimingsScreen({super.key});

  @override
  State<MasjidTimingsScreen> createState() => _MasjidTimingsScreenState();
}

class _MasjidTimingsScreenState extends State<MasjidTimingsScreen> {
  List<Masjid> _allMasjids = [];
  List<Masjid> _filteredMasjids = [];
  Masjid? _selectedMasjid;
  PrayerTimes? _basePrayerTimes;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Load Masjids from local SQLite DB
      final masjids = await MasjidQueries.getAllMasjids();

      // 2. Get GPS Location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are turned off. Please enable GPS.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission was denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is permanently denied in settings.');
      }

      final Position position = await Geolocator.getCurrentPosition();

      // 3. Calculate Offline Base Prayer Times (Karachi + Hanafi)
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.karachi();
      params.madhab = Madhab.hanafi;

      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: DateTime.now(),
        calculationParameters: params,
        precision: true,
      );

      setState(() {
        _allMasjids = masjids;
        _filteredMasjids = masjids;
        if (masjids.isNotEmpty && _selectedMasjid == null) {
          _selectedMasjid = masjids.first;
        }
        _basePrayerTimes = prayerTimes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterMasjids(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredMasjids = _allMasjids.where((m) {
        return m.name.toLowerCase().contains(lowerQuery) ||
            m.area.toLowerCase().contains(lowerQuery);
      }).toList();

      if (_filteredMasjids.isNotEmpty &&
          !_filteredMasjids.contains(_selectedMasjid)) {
        _selectedMasjid = _filteredMasjids.first;
      }
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid & Jamaat Timings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Location & Times',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      )
          : Column(
        children: [
          // Search Bar to look for a Masjid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMasjids,
              decoration: InputDecoration(
                hintText: 'Search masjid by name or area...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Masjid Selector
          SizedBox(
            height: 60,
            child: _filteredMasjids.isEmpty
                ? const Center(child: Text('No masjid found matching your search.'))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filteredMasjids.length,
              itemBuilder: (context, index) {
                final masjid = _filteredMasjids[index];
                final isSelected = masjid.id == _selectedMasjid?.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(masjid.name),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedMasjid = masjid;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // selected Masjid Header
          if (_selectedMasjid != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mosque, color: Colors.teal, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedMasjid!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedMasjid!.area,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 4. Prayer List showing Adhan Time & Jamaat Time underneath
          if (_selectedMasjid != null && _basePrayerTimes != null)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildPrayerCard('Fajr', _basePrayerTimes!.fajr!),
                  _buildPrayerCard('Dhuhr', _basePrayerTimes!.dhuhr!),
                  _buildPrayerCard('Asr', _basePrayerTimes!.asr!),
                  _buildPrayerCard('Maghrib', _basePrayerTimes!.maghrib!),
                  _buildPrayerCard('Isha', _basePrayerTimes!.isha!),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(String prayerName, DateTime rawWaqtStart) {
    final localWaqtStart = rawWaqtStart.toLocal();
    final adhanTime = _selectedMasjid!.getAdhanTime(prayerName, localWaqtStart);
    final jamaatTime = _selectedMasjid!.getJamaatTime(prayerName, localWaqtStart);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Prayer Name & Waqt Start
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayerName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Waqt starts: ${_formatTime(localWaqtStart)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            // Right Side: Adhan Time on top, Jamaat Time below
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Adhan Time Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Adhan: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatTime(adhanTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Jamaat Time
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Jamaat: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(jamaatTime),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}