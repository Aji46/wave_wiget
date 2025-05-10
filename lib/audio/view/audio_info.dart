import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_widget/audio/controller/services.dart';
import 'package:test_widget/audio/model/api/audio_entity.dart';
import 'package:test_widget/audio/model/api/tanscriptionSegment.dart';
import 'package:test_widget/audio/view/widgets/network_wave_form.dart';

class AudioInfo extends StatefulWidget {
  final AudioFile audioFile;

  const AudioInfo({required this.audioFile, super.key});

  @override
  _AudioInfoState createState() => _AudioInfoState();
}

class _AudioInfoState extends State<AudioInfo> {
  String _fullTranscription = "";
  String _matchedSentence = "";
  final GlobalKey<WavedAudioPlayerState> _waveformKey = GlobalKey();
  String? _clickedSentence;
  String? _localAudioPath;
  bool _isDownloading = true;
  bool _isAudioLoaded = false;
  bool _isAudioPlayerReady = false;
  late AudioDownloader _audioDownloader;

  @override
  void initState() {
    super.initState();
    _audioDownloader = AudioDownloader();
    _fullTranscription = widget.audioFile.transcription;
    Future.microtask(() {
      _downloadAudio();
    });
  }

  @override
  void dispose() {
    _audioDownloader.dispose();
    super.dispose();
  }

  Future<void> _downloadAudio() async {
    if (!mounted) return;
    
    setState(() {
      _isDownloading = true;
      _isAudioLoaded = false;
      _localAudioPath = null;
      _isAudioPlayerReady = false;
    });

    try {
      // First check if we already have the audio cached
      final cachedPath = await _audioDownloader.getAudioPath(widget.audioFile.guid);
      if (cachedPath != null) {
        if (!mounted) return;
        
        setState(() {
          _localAudioPath = cachedPath;
          _isDownloading = false;
          _isAudioLoaded = true;
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isAudioPlayerReady = true;
            });
          }
        });
        return;
      }

      // If not cached, download it
      final path = await _audioDownloader.downloadAudio(
        widget.audioFile.guid, 
        widget.audioFile.fileName
      );

      if (!mounted) return;

      if (path != null) {
        setState(() {
          _localAudioPath = path;
          _isDownloading = false;
          _isAudioLoaded = true;
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isAudioPlayerReady = true;
            });
          }
        });
      } else {
        setState(() {
          _isDownloading = false;
          _isAudioLoaded = false;
        });
        debugPrint("Failed to download audio file.");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isAudioLoaded = false;
        });
      }
      debugPrint("Error downloading audio: $e");
    }
  }

  Duration _parseDuration(String timeStr) {
    try {
      List<String> parts = timeStr.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      double seconds = double.parse(parts[2]);
      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds.toInt(),
        milliseconds: (seconds * 1000).toInt() % 1000,
      );
    } catch (e) {
      debugPrint("Error parsing duration: $e");
      return Duration.zero;
    }
  }

  void _updateTranscription(String highlightedTranscription) {
    if (!mounted) return;
    
    final regex = RegExp(r'\*\*(.+?)\*\*');
    final match = regex.firstMatch(highlightedTranscription);

    setState(() {
      _fullTranscription = highlightedTranscription.replaceAll('**', '');
      _matchedSentence = match?.group(1) ?? "";
    });
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _fullTranscription));
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transcription copied to clipboard')),
    );
  }
  
  void _handleSegmentTap(TranscriptionSegment segment) {
    if (!_isAudioPlayerReady || _waveformKey.currentState == null) return;
    
    try {
      final startTime = _parseDuration(segment.startTime);
      final totalDuration = _waveformKey.currentState?.duration ?? Duration.zero;

      if (totalDuration != Duration.zero) {
        final position = (startTime.inMilliseconds / totalDuration.inMilliseconds) * 100;
        _waveformKey.currentState?.seekToPosition(position);
        _waveformKey.currentState?.setSelectedSegment(segment);
      }

      setState(() {
        _clickedSentence = segment.transcriptText;
      });
    } catch (e) {
      debugPrint("Error handling segment tap: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.audioFile.fileName),
        backgroundColor: const Color(0xFF87EDED),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_sharp),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const SizedBox(height: 30),
            _buildAudioPlayer(),
            const SizedBox(height: 50),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildHighlightedText(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _copyToClipboard,
        backgroundColor: const Color(0xFF87EDED),
        child: const Icon(Icons.copy),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    if (_isDownloading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Downloading audio file...")
          ],
        ),
      );
    } else if (_isAudioLoaded && _localAudioPath != null) {
      // Platform-specific source handling
      final source = kIsWeb 
          ? UrlSource(_localAudioPath!)
          : DeviceFileSource(_localAudioPath!);

          print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++$_localAudioPath");
          
      return WavedAudioPlayer(
        key: _waveformKey,
        source: source,
        iconColor: Colors.red,
        playedColor: Colors.red,
        unplayedColor: Colors.black,
        barWidth: 2,
        buttonSize: 40,
        showTiming: true,
        guid: widget.audioFile.guid,
        onError: (error) {
          debugPrint('Error occurred: ${error.message}');
        },
        onTranscriptionReceived: _updateTranscription,
      );
    } else {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.red),
            SizedBox(height: 10),
            Text("Failed to load audio. Please try again.")
          ],
        ),
      );
    }
  }

  Widget _buildHighlightedText() {
    const commonStyle = TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      height: 1.5,
      letterSpacing: 1.2,
    );

    final segments = _waveformKey.currentState?.segments ?? [];
    if (segments.isEmpty) {
      // If no segments are available, just return the plain text
      return Text(_fullTranscription, style: commonStyle);
    }
    
    String text = _fullTranscription;
    final textSpans = <TextSpan>[];
    int currentIndex = 0;

    for (var segment in segments) {
      final phrase = segment.transcriptText.trim();
      if (phrase.isEmpty) continue;
      
      final matchIndex = text.indexOf(phrase, currentIndex);

      if (matchIndex != -1) {
        if (matchIndex > currentIndex) {
          textSpans.add(TextSpan(
            text: text.substring(currentIndex, matchIndex),
            style: commonStyle,
          ));
        }

        final isMatched = phrase == _matchedSentence;
        final isClicked = phrase == _clickedSentence;
        Color? backgroundColor;
        if (isMatched) {
          backgroundColor = Colors.yellow.shade100;
        } else if (isClicked) {
          backgroundColor = Colors.lightBlue.shade100;
        }

        textSpans.add(TextSpan(
          text: phrase,
          style: commonStyle.copyWith(backgroundColor: backgroundColor),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _handleSegmentTap(segment),
        ));

        currentIndex = matchIndex + phrase.length;
      }
    }

    if (currentIndex < text.length) {
      textSpans.add(TextSpan(text: text.substring(currentIndex), style: commonStyle));
    }

    return RichText(text: TextSpan(children: textSpans));
  }
}