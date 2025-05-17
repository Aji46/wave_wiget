import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:test_widget/config.dart';
import 'package:test_widget/audio/model/api/audio_entity.dart';
import 'package:test_widget/audio/model/api/tanscriptionSegment.dart';
import 'package:universal_html/html.dart' as html;

// Global variable to store downloaded audio paths
Map<int, String> _audioPathCache = {};

Future<List<AudioEntity>> getAudioFilesBySubFolder() async {
  try {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/FileExplorer/completed-files'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => AudioEntity.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load audio files. Status code: ${response.statusCode}',
      );
    }
  } catch (e) {
    debugPrint('Error fetching audio files: $e');
    return [];
  }
}

Future<AudioTranscription?> getAudioTranscriptionByGuidDemo(guid) async {
  final uri = Uri.parse(
    "${AppConfig.baseUrl}/api/FileExplorer/GetByProcessedGuid/$guid",
  );
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return AudioTranscription.fromJson(data);
  } else {
    return null;
  }
}

// import 'package:http/http.dart' as http;

class AudioDownloader {
  final Map<int, String> _audioPathCache = {};
  final Map<int, String> _webAudioCache = {};

  Future<String?> downloadAudio(int guid, String fileName) async {
    debugPrint('Starting download for GUID: $guid');

    // Check cache first
    if (_audioPathCache.containsKey(guid)) {
      debugPrint('Found in cache: ${_audioPathCache[guid]}');
      return _audioPathCache[guid];
    }
    final uri = '${AppConfig.baseUrl}/api/FileExplorer/DownloadAudio/$guid';
    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/FileExplorer/DownloadAudio/$guid',
    );
    debugPrint('Downloading from: $url');

    if (kIsWeb) {
      return uri;
    }

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (kIsWeb) {
          debugPrint('Processing web download...');
          final webPath = await _handleWebDownload(
            response.bodyBytes,
            fileName,
            guid,
          );
          _audioPathCache[guid] = webPath ?? '';
          _webAudioCache[guid] = webPath ?? '';
          debugPrint(
            'Web download complete. Blob URL: ${webPath?.substring(0, 30)}...',
          );
          return webPath;
        } else {
          debugPrint('Processing mobile/desktop download...');
          final filePath = await _saveAudioFile(
            response.bodyBytes,
            fileName,
            guid,
          );
          _audioPathCache[guid] = filePath ?? '';
          debugPrint('File saved to: $filePath');
          return filePath;
        }
      } else {
        debugPrint('Download failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error downloading audio: $e');
      return null;
    }
  }

  Future<String?> _handleWebDownload(
    Uint8List bytes,
    String fileName,
    int guid,
  ) async {
    try {
      final extension = fileName.split('.').last.toLowerCase();
      final mimeType = _getMimeType(extension);
      debugPrint('Creating blob with MIME type: $mimeType');

      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Optional: Trigger download
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..click();

      return url;
    } catch (e) {
      debugPrint('Web download error: $e');
      return null;
    }
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      case 'm4a':
        return 'audio/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  Future<String?> _saveAudioFile(
    List<int> bytes,
    String fileName,
    int guid,
  ) async {
    try {
      final directory = await _getStorageDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio_downloads'));

      if (!await audioDir.exists()) {
        debugPrint('Creating audio directory: ${audioDir.path}');
        await audioDir.create(recursive: true);
      }

      final extension = fileName.split('.').last;
      final saveName = 'audio_$guid.$extension';
      final filePath = path.join(audioDir.path, saveName);

      debugPrint('Saving file to: $filePath');
      await File(filePath).writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      debugPrint('File save error: $e');
      return null;
    }
  }

  Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }
  }

  Future<String?> getAudioPath(int guid) async {
    if (_audioPathCache.containsKey(guid)) {
      return _audioPathCache[guid];
    }

    if (kIsWeb) {
      return _webAudioCache[guid];
    }

    try {
      final directory = await _getStorageDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio_downloads'));

      if (await audioDir.exists()) {
        final files = await audioDir.list().toList();

        for (var file in files) {
          if (file is File && file.path.contains('audio_$guid')) {
            _audioPathCache[guid] = file.path;
            return file.path;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting audio path: $e');
      return null;
    }
  }

  Future<String> getAudioPathInfo(int guid) async {
    if (kIsWeb) {
      if (_webAudioCache.containsKey(guid)) {
        return "Web Audio Blob (in-memory)";
      }
      return "Audio not downloaded";
    } else {
      final path = await getAudioPath(guid);
      return path ?? "File not found";
    }
  }

  Future<void> dispose() async {
    if (kIsWeb) {
      _webAudioCache.values.forEach(html.Url.revokeObjectUrl);
    }
    _audioPathCache.clear();
    _webAudioCache.clear();
  }

  Future<void> clearDownloadedFiles() async {
    if (kIsWeb) return;

    try {
      final directory = await _getStorageDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio_downloads'));

      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing downloaded files: $e');
    }

    _audioPathCache.clear();
  }
}
