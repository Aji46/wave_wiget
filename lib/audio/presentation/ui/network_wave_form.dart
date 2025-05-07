import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';
import 'package:test_widget/audio/presentation/ui/apicalss.dart';

import 'widgets/painter.dart';

class WavedAudioPlayer extends StatefulWidget {
  Source source;
  Color playedColor;
  Color unplayedColor;
  Color iconColor;
  Color iconBackgoundColor;
  double barWidth;
  double spacing;
  double waveHeight;
  double buttonSize;
  bool showTiming;
  TextStyle? timingStyle;
  void Function(WavedAudioPlayerError)? onError;
  final Function(String)? onTranscriptionReceived;
  final String guid;

  WavedAudioPlayer({
    super.key,
    required this.source,
    this.playedColor = Colors.blue,
    this.unplayedColor = Colors.grey,
    this.iconColor = Colors.blue,
    this.iconBackgoundColor = Colors.white,
    this.barWidth = 2,
    this.spacing = 4,
    this.buttonSize = 40,
    this.showTiming = true,
    this.timingStyle,
    this.onError,
    this.onTranscriptionReceived,
    this.waveHeight = 35,
    required this.guid,
  });

  @override
  WavedAudioPlayerState createState() => WavedAudioPlayerState();
}

class WavedAudioPlayerState extends State<WavedAudioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<double> waveformData = [];
  Duration audioDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  bool isPlaying = false;
  bool isPausing = true;
  Uint8List? _audioBytes;
  double waveWidth = 0;

  List<TranscriptionSegment> transcriptionSegments =
      []; // Store transcription segments
  TranscriptionSegment? selectedSegment; // Track the selected segment

  String _highlightedTranscription = "";
  String _fullTranscription = "";

  // Getters for external access
  List<TranscriptionSegment> get segments => transcriptionSegments;
  Duration get duration => audioDuration;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _loadWaveform();
    _playAudio();
    _fetchTranscription();
  }

  Future<void> _loadWaveform() async {
    try {
      if (_audioBytes == null) {
        if (widget.source is AssetSource) {
          _audioBytes = await _loadAssetAudioWaveform(
            (widget.source as AssetSource).path,
          );
        } else if (widget.source is UrlSource) {
          _audioBytes = await _loadRemoteAudioWaveform(
            (widget.source as UrlSource).url,
          );
        } else if (widget.source is DeviceFileSource) {
          _audioBytes = await _loadDeviceFileAudioWaveform(
            (widget.source as DeviceFileSource).path,
          );
        } else if (widget.source is BytesSource) {
          _audioBytes = (widget.source as BytesSource).bytes;
        }
      }

      if (_audioBytes != null) {
        waveformData = _extractWaveformData(_audioBytes!);
        await _audioPlayer.setSource(
          BytesSource(_audioBytes!, mimeType: widget.source.mimeType),
        );
        setState(() {});
      }
    } catch (e) {
      _callOnError(WavedAudioPlayerError("Error loading audio: $e"));
    }
  }

  Future<Uint8List?> _loadDeviceFileAudioWaveform(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.readAsBytes();
    } catch (e) {
      _callOnError(WavedAudioPlayerError("Error loading file audio: $e"));
    }
    return null;
  }

  Future<Uint8List?> _loadAssetAudioWaveform(String path) async {
    try {
      final ByteData bytes = await rootBundle.load(path);
      return bytes.buffer.asUint8List();
    } catch (e) {
      _callOnError(WavedAudioPlayerError("Error loading asset audio: $e"));
    }
    return null;
  }

  Future<Uint8List?> _loadRemoteAudioWaveform(String url) async {
    try {
      final HttpClient httpClient = HttpClient();
      final HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        return await consolidateHttpClientResponseBytes(response);
      } else {
        _callOnError(
          WavedAudioPlayerError("Failed to load audio: ${response.statusCode}"),
        );
      }
    } catch (e) {
      _callOnError(WavedAudioPlayerError("Error loading audio: $e"));
    }
    return null;
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = (state == PlayerState.playing);
      });
    });

  _audioPlayer.onPlayerComplete.listen((event) {
  isPausing = false;
  setState(() {
    isPlaying = false;
  });
});


    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        audioDuration = duration;
        isPausing = true;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
        isPausing = true;
      });

      String matchedTranscription = _findMatchedTranscription(position, transcriptionSegments);
      setState(() {
        _highlightedTranscription = matchedTranscription;
      });

      _checkCurrentSegment(position);
    });
  }

  void _checkCurrentSegment(Duration position) {
    for (var segment in transcriptionSegments) {
      Duration start = _parseDuration(segment.startTime);
      Duration end = _parseDuration(segment.endTime);

      if (position >= start && position <= end) {
        if (selectedSegment != segment) {
          setState(() {
            selectedSegment = segment;

            String matchedText = segment.transcriptText;
            String highlightedTranscription = _highlightTranscriptionSentence(
              matchedText,
              _fullTranscription,
            );

            if (widget.onTranscriptionReceived != null) {
              widget.onTranscriptionReceived!(highlightedTranscription);
            }

            _highlightedTranscription = highlightedTranscription;
          });
        }
        return;
      }
    }

    if (selectedSegment != null) {
      setState(() {
        selectedSegment = null;
      });
    }
  }

  List<double> _extractWaveformData(Uint8List audioBytes) {
    List<double> waveData = [];
    int steps =
        (audioBytes.length / (waveWidth / (widget.barWidth + widget.spacing)))
            .floor();
    for (int i = 0; i < audioBytes.length; i += steps) {
      waveData.add(audioBytes[i] / 100);
    }
    waveData.add(audioBytes[audioBytes.length - 1] / 255);
    return waveData;
  }

Future<void> _fetchTranscription() async {
  try {
    final transcription = await getAudioTranscriptionByGuidDemo(widget.guid);
    if (transcription != null) {
      transcriptionSegments = transcription.srtSegments;
      _fullTranscription = transcription.transcription;
      setState(() {}); // Update UI after fetching transcription
    } else {
      _callOnError(WavedAudioPlayerError("Transcription is null."));
    }
  } catch (e) {
    _callOnError(WavedAudioPlayerError("Failed to fetch transcription: $e"));
  }
}


  void _onWaveformTap(double tapX) async {
    if (waveWidth == 0) return;

    double tapPercent = tapX / waveWidth;
    Duration newPosition = audioDuration * tapPercent;

    // Seek to the tapped position
    _audioPlayer.seek(newPosition);

      if (!isPlaying) {
    await _audioPlayer.resume();
  }

    // Find the segment that contains this position
    TranscriptionSegment? tappedSegment = _findSegmentAtPosition(newPosition);

    setState(() {
      selectedSegment = tappedSegment;
    });

    // Update transcription highlight if we found a segment
    if (tappedSegment != null) {
      String matchedText = tappedSegment.transcriptText;
      String highlightedTranscription = _highlightTranscriptionSentence(
        matchedText,
        _fullTranscription,
      );

      if (widget.onTranscriptionReceived != null) {
        widget.onTranscriptionReceived!(highlightedTranscription);
      }

      setState(() {
        _highlightedTranscription = highlightedTranscription;
      });
    }
  }

  TranscriptionSegment? _findSegmentAtPosition(Duration position) {
    for (var segment in transcriptionSegments) {
      Duration start = _parseDuration(segment.startTime);
      Duration end = _parseDuration(segment.endTime);

      if (position >= start && position <= end) {
        return segment;
      }
    }
    return null;
  }

  String _findMatchedTranscription(
    Duration position,
    List<TranscriptionSegment> segments,
  ) {
    for (var segment in segments) {
      Duration start = _parseDuration(segment.startTime);
      Duration end = _parseDuration(segment.endTime);

      if (position >= start && position <= end) {
        return segment.transcriptText;
      }
    }
    return "No transcription found for this position.";
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

  String _highlightTranscriptionSentence(
    String matchedSentence,
    String fullTranscription,
  ) {
    if (!fullTranscription.contains(matchedSentence)) return fullTranscription;

    String styledSentence =
        '<span style="color: blue; font-weight: bold; font-size: 1.2em;">$matchedSentence</span>';
    return fullTranscription.replaceFirst(
      matchedSentence,
      '**$matchedSentence**',
    );
  }

  void _playAudio() async {
    try {
      if (_audioBytes != null) {
        await _audioPlayer.setSource(BytesSource(_audioBytes!));
        await _audioPlayer.resume();
      } else {
        await _loadWaveform();
        
        if (_audioBytes != null) {
          await _audioPlayer.setSource(BytesSource(_audioBytes!));
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      _callOnError(WavedAudioPlayerError("Error playing audio: $e"));
    }
  }

  void _pauseAudio() async {
    _audioPlayer.pause();
    isPausing = true;
  }

  void _callOnError(WavedAudioPlayerError error) {
    if (widget.onError == null) return;
    print('\x1B[31m${error.message}\x1B[0m');
    widget.onError!(error);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return (hours > 0)
        ? "${twoDigits(hours)}:$minutes:$seconds"
        : "$minutes:$seconds";
  }

  void seekToPosition(double percentage) {
    if (audioDuration != Duration.zero) {
      final position = Duration(
        milliseconds: (audioDuration.inMilliseconds * percentage / 100).round(),
      );
      _audioPlayer.seek(position);
    }
  }

  void setSelectedSegment(TranscriptionSegment segment) {
    setState(() {
      selectedSegment = segment;
    });
  }

    void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    waveWidth = MediaQuery.of(context).size.width;

    return (waveformData.isNotEmpty)
        ? GestureDetector(
          onTapDown: (TapDownDetails details) {
            _onWaveformTap(details.localPosition.dx);
          },
          child: CustomPaint(
            size: Size(waveWidth, widget.waveHeight),
            painter: WaveformPainter(
              waveformData: waveformData,
              progress:
                  currentPosition.inMilliseconds /
                  (audioDuration.inMilliseconds == 0
                      ? 1
                      : audioDuration.inMilliseconds),
              playedColor: widget.playedColor,
              unplayedColor: widget.unplayedColor,
              barWidth: widget.barWidth,
              waveWidth: waveWidth,
              transcriptionSegments: transcriptionSegments,
              audioDuration: audioDuration,
              selectedSegment: selectedSegment,
            ),
          ),
        )
        : SizedBox(
          width: waveWidth,
          height: max(widget.waveHeight, widget.buttonSize),
          child: Center(
            child: LinearProgressIndicator(
              color: widget.playedColor,
              borderRadius: BorderRadius.circular(40),
              value:
                  (audioDuration.inMilliseconds == 0)
                      ? 0
                      : currentPosition.inMilliseconds /
                          audioDuration.inMilliseconds,
            ),
          ),
        );
  }
}

class WavedAudioPlayerError {
  final String message;
  WavedAudioPlayerError(this.message);
}
