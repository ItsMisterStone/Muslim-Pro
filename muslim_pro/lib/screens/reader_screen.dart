import 'package:flutter/material.dart';
import '../db/quran_database.dart';
import '../models/ayah.dart';
import '../models/surah.dart';

class ReaderScreen extends StatefulWidget {
  final Surah surah;
  const ReaderScreen({super.key, required this.surah});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final Future<List<Ayah>> _ayahsFuture;

  static const String _bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ';

  // Surah 1 has the bismillah as ayah 1, surah 9 has none.
  bool get _showBismillahHeader =>
      widget.surah.number != 1 && widget.surah.number != 9;

  @override
  void initState() {
    super.initState();
    _ayahsFuture = QuranDatabase.instance.getAyahs(widget.surah.number);
  }

  // The data source glues the bismillah onto ayah 1 of most surahs.
  // Strip those first 4 words so it can be shown once as a header instead.
  String _cleanArabic(Ayah a) {
    if (_showBismillahHeader && a.ayahNumber == 1) {
      final words = a.textArabic.split(' ');
      if (words.length > 4) return words.skip(4).join(' ');
    }
    return a.textArabic;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surah;
    return Scaffold(
      appBar: AppBar(
        title: Text('${s.number}. ${s.nameEnglish}'),
        backgroundColor: Colors.green.shade100,
      ),
      body: FutureBuilder<List<Ayah>>(
        future: _ayahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ayahs = snapshot.data!;
          final headerCount = _showBismillahHeader ? 1 : 0;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ayahs.length + headerCount,
            itemBuilder: (context, i) {
              if (_showBismillahHeader && i == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    _bismillah,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 28),
                  ),
                );
              }

              final a = ayahs[i - headerCount];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CircleAvatar(
                          radius: 14,
                          child: Text(
                            '${a.ayahNumber}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _cleanArabic(a),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 26, height: 2.0),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        a.textEnglish,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}