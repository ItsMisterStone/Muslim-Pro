import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../db/quran_database.dart';
import '../models/ayah.dart';
import '../models/surah.dart';
import '../services/audio_download_service.dart';

class ReaderScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyah; // jump to this ayah on open
  const ReaderScreen({super.key, required this.surah, this.initialAyah});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();
  final AudioDownloadService _audio = AudioDownloadService.instance;
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<ProcessingState>? _stateSub;
  StreamSubscription<bool>? _playingSub;

  List<Ayah> _ayahs = [];
  Set<int> _bookmarked = {};
  bool _loading = true;
  bool _downloaded = false;
  bool _isPlaying = false;
  bool _inBismillah = false; // true while the bismillah audio is playing
  int? _playingAyah; // ayah number currently loaded in the player
  int _topIndex = 0;

  static const String _bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ';

  // Surah 1 has the bismillah as ayah 1, surah 9 has none.
  bool get _showBismillahHeader =>
      widget.surah.number != 1 && widget.surah.number != 9;
  int get _headerCount => _showBismillahHeader ? 1 : 0;

  @override
  void initState() {
    super.initState();
    _positionsListener.itemPositions.addListener(_onPositionsChanged);
    _audio.progressOf(widget.surah.number).addListener(_onDownloadChanged);

    _stateSub = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) _onAudioFinished();
    });
    _playingSub = _player.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });

    _load();
    _checkDownloaded();
  }

  Future<void> _load() async {
    final ayahs = await QuranDatabase.instance.getAyahs(widget.surah.number);
    final marks =
        await QuranDatabase.instance.getBookmarkedAyahs(widget.surah.number);
    if (!mounted) return;
    setState(() {
      _ayahs = ayahs;
      _bookmarked = marks;
      _loading = false;
      if (widget.initialAyah != null && widget.initialAyah! > 1) {
        _topIndex = widget.initialAyah! - 1 + _headerCount;
      }
    });
  }

  Future<void> _checkDownloaded() async {
    final d = await _audio.isDownloaded(widget.surah);
    if (!mounted) return;
    setState(() => _downloaded = d);
  }

  // When a download finishes or is cancelled (progress back to null),
  // re-check what is actually on disk.
  void _onDownloadChanged() {
    if (_audio.progressOf(widget.surah.number).value == null) {
      _checkDownloaded();
    }
  }

  void _onPositionsChanged() {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final visible = positions.where((p) => p.itemTrailingEdge > 0);
    if (visible.isEmpty) return;
    _topIndex = visible.map((p) => p.index).reduce((a, b) => a < b ? a : b);
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onPositionsChanged);
    _audio.progressOf(widget.surah.number).removeListener(_onDownloadChanged);
    _stateSub?.cancel();
    _playingSub?.cancel();
    _player.dispose(); // also stops playback when leaving the screen
    if (_ayahs.isNotEmpty) {
      final index = (_topIndex - _headerCount).clamp(0, _ayahs.length - 1);
      QuranDatabase.instance.saveLastRead(widget.surah.number, index + 1);
    }
    super.dispose();
  }

  // ---------- Playback ----------

  /// The ayah at the top of the screen (where the user is reading).
  int _startAyah() {
    final n = _topIndex - _headerCount + 1;
    return n.clamp(1, _ayahs.length);
  }

  /// Plays an ayah. For ayah 1 of surahs that need it, the bismillah audio
  /// plays first, then _onAudioFinished moves on to the ayah itself.
  Future<void> _playAyah(int ayahNumber, {bool withBismillah = true}) async {
    if (!_downloaded) {
      _snack("Download this surah's audio first to listen.");
      return;
    }
    if (ayahNumber < 1 || ayahNumber > _ayahs.length) return;

    final playBismillah =
        withBismillah && ayahNumber == 1 && _showBismillahHeader;
    final file = playBismillah
        ? await _audio.bismillahFile()
        : await _audio.ayahFile(widget.surah.number, ayahNumber);

    if (!await file.exists()) {
      _snack('Audio file missing. Delete and download the audio again.');
      return;
    }
    if (!mounted) return;

    setState(() {
      _playingAyah = ayahNumber;
      _inBismillah = playBismillah;
    });
    _scrollToIndex(playBismillah ? 0 : ayahNumber - 1 + _headerCount);

    try {
      await _player.setFilePath(file.path);
      _player.play();
    } catch (e) {
      if (e is PlayerInterruptedException) return; // user skipped quickly
      _snack('Could not play this ayah.');
    }
  }

  void _onAudioFinished() {
    final current = _playingAyah;
    if (current == null) return;

    // Bismillah just ended: now play ayah 1 itself.
    if (_inBismillah) {
      _playAyah(1, withBismillah: false);
      return;
    }

    if (current < _ayahs.length) {
      _playAyah(current + 1);
    } else {
      // end of the surah
      _player.stop();
      if (mounted) {
        setState(() {
          _playingAyah = null;
          _inBismillah = false;
          _isPlaying = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_playingAyah == null) {
      _playAyah(_startAyah());
    } else if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _next() {
    final c = _playingAyah;
    if (c != null && c < _ayahs.length) _playAyah(c + 1);
  }

  void _previous() {
    final c = _playingAyah;
    if (c != null && c > 1) _playAyah(c - 1);
  }

  Future<void> _stopPlayback() async {
    await _player.stop();
    if (!mounted) return;
    setState(() {
      _playingAyah = null;
      _inBismillah = false;
      _isPlaying = false;
    });
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.isAttached) return;
    _scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // ---------- Other actions ----------

  // The data source glues the bismillah onto ayah 1 of most surahs.
  String _cleanArabic(Ayah a) {
    if (_showBismillahHeader && a.ayahNumber == 1) {
      final words = a.textArabic.split(' ');
      if (words.length > 4) return words.skip(4).join(' ');
    }
    return a.textArabic;
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final nowOn = await QuranDatabase.instance
        .toggleBookmark(widget.surah.number, ayahNumber);
    setState(() {
      if (nowOn) {
        _bookmarked.add(ayahNumber);
      } else {
        _bookmarked.remove(ayahNumber);
      }
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startDownload() async {
    try {
      await _audio.downloadSurah(widget.surah);
      if (mounted) _snack('Audio downloaded');
    } catch (e) {
      if (mounted) _snack(AudioDownloadService.friendlyError(e));
    }
  }

  Future<void> _deleteAudio() async {
    await _stopPlayback();
    await _audio.deleteSurah(widget.surah.number);
    await _checkDownloaded();
    if (mounted) _snack('Audio deleted');
  }

  // ---------- UI ----------

  Widget _buildAudioButton() {
    return ValueListenableBuilder<double?>(
      valueListenable: _audio.progressOf(widget.surah.number),
      builder: (context, progress, _) {
        if (progress != null) {
          return IconButton(
            tooltip: 'Cancel download',
            onPressed: () => _audio.cancel(widget.surah.number),
            icon: SizedBox(
              width: 26,
              height: 26,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: progress, strokeWidth: 3),
                  const Icon(Icons.close, size: 14),
                ],
              ),
            ),
          );
        }
        if (_downloaded) {
          return PopupMenuButton<String>(
            tooltip: 'Audio downloaded',
            icon: const Icon(Icons.download_done, color: Colors.green),
            onSelected: (v) {
              if (v == 'delete') _deleteAudio();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete audio')),
            ],
          );
        }
        return IconButton(
          icon: const Icon(Icons.download),
          tooltip: 'Download audio',
          onPressed: _startDownload,
        );
      },
    );
  }

  Widget _buildPlayerBar() {
    final hasCurrent = _playingAyah != null;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border(top: BorderSide(color: Colors.green.shade200)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              iconSize: 32,
              onPressed: hasCurrent ? _previous : null,
            ),
            IconButton(
              icon: Icon(_isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled),
              iconSize: 52,
              color: Colors.green,
              onPressed: _togglePlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              iconSize: 32,
              onPressed: hasCurrent ? _next : null,
            ),
            const SizedBox(width: 12),
            Text(hasCurrent
                ? (_inBismillah
                    ? 'Bismillah'
                    : 'Ayah $_playingAyah / ${_ayahs.length}')
                : 'Tap play to listen'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surah;
    return Scaffold(
      appBar: AppBar(
        title: Text('${s.number}. ${s.nameEnglish}'),
        backgroundColor: Colors.green.shade100,
        actions: [_buildAudioButton()],
      ),
      bottomNavigationBar: _downloaded ? _buildPlayerBar() : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              itemPositionsListener: _positionsListener,
              initialScrollIndex: _topIndex,
              padding: const EdgeInsets.all(12),
              itemCount: _ayahs.length + _headerCount,
              itemBuilder: (context, i) {
                if (_showBismillahHeader && i == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      _bismillah,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 28,
                        color: _inBismillah ? Colors.green : null,
                      ),
                    ),
                  );
                }

                final a = _ayahs[i - _headerCount];
                final isMarked = _bookmarked.contains(a.ayahNumber);
                final isPlayingThis =
                    _playingAyah == a.ayahNumber && !_inBismillah;
                return Card(
                  color: isPlayingThis ? Colors.green.shade50 : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isPlayingThis ? Colors.green : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              child: Text(
                                '${a.ayahNumber}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                isPlayingThis && _isPlaying
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                              ),
                              onPressed: () {
                                if (isPlayingThis && _isPlaying) {
                                  _player.pause();
                                } else if (isPlayingThis) {
                                  _player.play();
                                } else {
                                  _playAyah(a.ayahNumber);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isMarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isMarked ? Colors.green : null,
                              ),
                              onPressed: () => _toggleBookmark(a.ayahNumber),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
            ),
    );
  }
}