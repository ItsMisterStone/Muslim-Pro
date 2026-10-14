import 'package:flutter/material.dart';
import '../db/quran_database.dart';
import '../models/surah.dart';
import 'bookmarks_screen.dart';
import 'reader_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<Surah> _surahs = [];
  Map<String, int>? _lastRead;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await QuranDatabase.instance.ensureLoaded(); // only does work on first run
    final surahs = await QuranDatabase.instance.getSurahs();
    final last = await QuranDatabase.instance.getLastRead();
    if (!mounted) return;
    setState(() {
      _surahs = surahs;
      _lastRead = last;
      _loading = false;
    });
  }

  Future<void> _refreshLastRead() async {
    final last = await QuranDatabase.instance.getLastRead();
    if (!mounted) return;
    setState(() => _lastRead = last);
  }

  Future<void> _open(Surah s, {int? ayah}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderScreen(surah: s, initialAyah: ayah),
      ),
    );
    _refreshLastRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: 'Bookmarks',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing Quran...'),
                ],
              ),
            )
          : Column(
              children: [
                if (_lastRead != null) _buildContinueCard(),
                Expanded(
                  child: ListView.separated(
                    itemCount: _surahs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = _surahs[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${s.number}')),
                        title: Text(s.nameEnglish),
                        subtitle: Text(
                            '${s.meaning} • ${s.revelationType} • ${s.ayahCount} ayahs'),
                        trailing: Text(
                          s.nameArabic,
                          style: const TextStyle(fontSize: 20),
                        ),
                        onTap: () => _open(s),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildContinueCard() {
    final surah = _surahs[_lastRead!['surah']! - 1];
    final ayah = _lastRead!['ayah']!;
    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: const Icon(Icons.menu_book),
        title: const Text('Continue reading'),
        subtitle: Text('${surah.nameEnglish} • Ayah $ayah'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _open(surah, ayah: ayah),
      ),
    );
  }
}