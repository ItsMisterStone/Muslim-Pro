import 'package:flutter/material.dart';
import '../db/quran_database.dart';
import '../models/surah.dart';
import 'reader_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late final Future<List<Surah>> _surahsFuture;

  @override
  void initState() {
    super.initState();
    _surahsFuture = _load();
  }

  Future<List<Surah>> _load() async {
    await QuranDatabase.instance.ensureLoaded(); // only does work on first run
    return QuranDatabase.instance.getSurahs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran')),
      body: FutureBuilder<List<Surah>>(
        future: _surahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing Quran...'),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final surahs = snapshot.data!;
          return ListView.separated(
            itemCount: surahs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = surahs[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${s.number}')),
                title: Text(s.nameEnglish),
                subtitle: Text(
                    '${s.meaning} • ${s.revelationType} • ${s.ayahCount} ayahs'),
                trailing: Text(
                  s.nameArabic,
                  style: const TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReaderScreen(surah: s),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}