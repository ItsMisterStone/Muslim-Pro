import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/surah.dart';

class AudioDownloadService {
  AudioDownloadService._();
  static final AudioDownloadService instance = AudioDownloadService._();

  // Per-ayah MP3s are served at: <base>/<reciter>/<SSS><AAA>.mp3
  static const String reciterFolder = 'Alafasy_128kbps';
  static const String _baseUrl = 'https://everyayah.com/data';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // null = idle, 0.0 to 1.0 = downloading. Lives here (not in the screen)
  // so a download keeps going if the user leaves the reader.
  final Map<int, ValueNotifier<double?>> _progress = {};
  final Map<int, CancelToken> _tokens = {};

  ValueNotifier<double?> progressOf(int surah) =>
      _progress.putIfAbsent(surah, () => ValueNotifier<double?>(null));

  bool isDownloading(int surah) => progressOf(surah).value != null;

  String _code(int n) => n.toString().padLeft(3, '0');

  /// Surah 1 has the bismillah as its ayah 1, surah 9 has none.
  bool needsBismillah(int surah) => surah != 1 && surah != 9;

  Future<Directory> _reciterDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'audio', reciterFolder));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _surahDir(int surah) async {
    final reciter = await _reciterDir();
    final dir = Directory(p.join(reciter.path, _code(surah)));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Where a given ayah's audio file lives.
  Future<File> ayahFile(int surah, int ayah) async {
    final dir = await _surahDir(surah);
    return File(p.join(dir.path, '${_code(ayah)}.mp3'));
  }

  /// The shared bismillah recording, used by every surah except 1 and 9.
  /// It lives outside the surah folders, so deleting a surah keeps it.
  Future<File> bismillahFile() async {
    final dir = await _reciterDir();
    return File(p.join(dir.path, 'bismillah.mp3'));
  }

  /// True only when every ayah (and the bismillah, if needed) is on disk.
  Future<bool> isDownloaded(Surah s) async {
    final dir = await _surahDir(s.number);
    final count =
        await dir.list().where((f) => f.path.endsWith('.mp3')).length;
    if (count < s.ayahCount) return false;
    if (needsBismillah(s.number) && !await (await bismillahFile()).exists()) {
      return false;
    }
    return true;
  }

  /// Downloads everything missing. Throws on failure (use friendlyError).
  Future<void> downloadSurah(Surah s) async {
    if (isDownloading(s.number)) return;

    final notifier = progressOf(s.number);
    final token = CancelToken();
    _tokens[s.number] = token;
    notifier.value = 0;

    try {
      if (needsBismillah(s.number)) {
        await _ensureBismillah(token);
      }

      var done = 0;
      final missing = <int>[];
      for (var a = 1; a <= s.ayahCount; a++) {
        if (await (await ayahFile(s.number, a)).exists()) {
          done++;
        } else {
          missing.add(a);
        }
      }
      notifier.value = done / s.ayahCount;

      // 4 files at a time
      const batchSize = 4;
      for (var i = 0; i < missing.length; i += batchSize) {
        final batch = missing.skip(i).take(batchSize);
        await Future.wait(batch.map((a) async {
          await _downloadAyah(s.number, a, token);
          done++;
          notifier.value = done / s.ayahCount;
        }));
      }
    } on DioException catch (e) {
      // User tapped cancel: discard everything downloaded for this surah.
      // Connection errors are not cancels, so those keep their files for resuming.
      if (e.type == DioExceptionType.cancel) {
        await deleteSurah(s.number);
      }
      rethrow;
    } finally {
      notifier.value = null;
      _tokens.remove(s.number);
    }
  }

  Future<void> _ensureBismillah(CancelToken token) async {
    final file = await bismillahFile();
    if (await file.exists()) return;
    final temp = File('${file.path}.part');
    // Al-Fatiha ayah 1 IS the bismillah, recited by the same reciter.
    final url = '$_baseUrl/$reciterFolder/001001.mp3';
    await _dio.download(url, temp.path, cancelToken: token);
    await temp.rename(file.path);
  }

  Future<void> _downloadAyah(int surah, int ayah, CancelToken token) async {
    final file = await ayahFile(surah, ayah);
    final temp = File('${file.path}.part');
    final url = '$_baseUrl/$reciterFolder/${_code(surah)}${_code(ayah)}.mp3';
    await _dio.download(url, temp.path, cancelToken: token);
    await temp.rename(file.path); // only now does it count as downloaded
  }

  void cancel(int surah) => _tokens[surah]?.cancel();

  Future<void> deleteSurah(int surah) async {
    final dir = await _surahDir(surah);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  static String friendlyError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.cancel) return 'Download cancelled';
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'No internet connection. Tap download to resume.';
      }
    }
    return 'Download failed. Tap download to resume.';
  }
}