
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_widget/audio/data/entity/audio_entity.dart';
import 'package:test_widget/audio/presentation/ui/network_wave_form.dart';

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

  void _updateTranscription(String highlightedTranscription) {
    final regex = RegExp(r'\*\*(.+?)\*\*');
    final match = regex.firstMatch(highlightedTranscription);

    setState(() {
      _fullTranscription = highlightedTranscription.replaceAll('**', '');
      _matchedSentence = match?.group(1) ?? "";
    });
  }

  void _handleTranscriptClick(String text) {
    final transcription = _waveformKey.currentState?.segments;
    if (transcription != null) {
      for (var segment in transcription) {
        if (segment.transcriptText == text) {
          final startTime = _parseDuration(segment.startTime);
          final endTime = _parseDuration(segment.endTime);
          final totalDuration =
              _waveformKey.currentState?.duration ?? Duration.zero;
        if (totalDuration != Duration.zero) {
          final position =
            (startTime.inMilliseconds / totalDuration.inMilliseconds) * 100;
            _waveformKey.currentState?.seekToPosition(position);
            _waveformKey.currentState?.setSelectedSegment(segment);
          }
          break;
        }
      }
    }
  }

  Duration _parseDuration(String timeStr) {
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
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _fullTranscription));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transcription copied to clipboard')),
    );
  }

  @override
  void initState() {
    super.initState();
       _fullTranscription = widget.audioFile.transcription;
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
     WavedAudioPlayer(
              key: _waveformKey,
              source: AssetSource(widget.audioFile.folderPath),
              iconColor: Colors.red,
              playedColor: const Color.fromARGB(255, 255, 0, 0),
              unplayedColor: const Color.fromARGB(255, 0, 0, 0),
              barWidth: 2,
              buttonSize: 40,
              showTiming: true,
              onError: (error) {
                print('Error occurred: $error.message');
              },
              onTranscriptionReceived: _updateTranscription, guid: widget.audioFile.guid,
            ),
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

  Widget _buildHighlightedText() {
    const commonStyle = TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      height: 1.5,
      letterSpacing: 1.2,
    );

    final segments = _waveformKey.currentState?.segments ?? [];
    String text = _fullTranscription;
    final textSpans = <TextSpan>[];
    int currentIndex = 0;
    for (var segment in segments) {
      final phrase = segment.transcriptText.trim();
      final matchIndex = text.indexOf(phrase, currentIndex);

      if (matchIndex != -1) {
        if (matchIndex > currentIndex) {
          textSpans.add(
            TextSpan(
              text: text.substring(currentIndex, matchIndex),
              style: commonStyle,
            ),
          );
        }
        final isMatched = phrase == _matchedSentence;
        final isClicked = phrase == _clickedSentence;
        Color? backgroundColor;
        if (isMatched) {
          backgroundColor = Colors.yellow.shade100;
        } else if (isClicked) {
          backgroundColor = Colors.lightBlue.shade100;
        }
        textSpans.add(
          TextSpan(
            text: phrase,
            style: commonStyle.copyWith(backgroundColor: backgroundColor),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    final startTime = _parseDuration(segment.startTime);
                    final totalDuration =
                        _waveformKey.currentState?.duration ?? Duration.zero;
                    if (totalDuration != Duration.zero) {
                      final position =
                          (startTime.inMilliseconds /
                              totalDuration.inMilliseconds) *
                          100;
                      _waveformKey.currentState?.seekToPosition(position);
                      _waveformKey.currentState?.setSelectedSegment(segment);
                    }
                    setState(() {
                      _clickedSentence = phrase;
                    });
                  },
          ),
        );
        currentIndex = matchIndex + phrase.length;
      }
    }
    if (currentIndex < text.length) {
      textSpans.add(
        TextSpan(text: text.substring(currentIndex), style: commonStyle),
      );
    }
    return RichText(text: TextSpan(children: textSpans));
  }
}

