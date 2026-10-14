import 'package:flutter/material.dart';
import '../db/quran_database.dart';
import 'reader_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await QuranDatabase.instance.getAllBookmarks();
    if (!mounted) return;
    setState(() {
      _bookmarks = rows;
      _loading = false;
    });
  }

  Future<void> _open(Map<String, dynamic> b) async {
    final surah = await QuranDatabase.instance.getSurah(b['surah_number']);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReaderScreen(surah: surah, initialAyah: b['ayah_number']),
      ),
    );
    _load(); // bookmarks may have changed in the reader
  }

  Future<void> _remove(Map<String, dynamic> b) async {
    await QuranDatabase.instance
        .toggleBookmark(b['surah_number'], b['ayah_number']);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? const Center(child: Text('No bookmarks yet'))
              : ListView.separated(
                  itemCount: _bookmarks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final b = _bookmarks[i];
                    return ListTile(
                      title: Text(
                          '${b['name_english']} • Ayah ${b['ayah_number']}'),
                      subtitle: Text(
                        b['text_english'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _remove(b),
                      ),
                      onTap: () => _open(b),
                    );
                  },
                ),
    );
  }
}