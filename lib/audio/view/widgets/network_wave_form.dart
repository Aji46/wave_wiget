
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_widget/audio/controller/services.dart';
import 'package:test_widget/audio/model/api/tanscriptionSegment.dart';
import 'package:test_widget/audio/view/widgets/painter.dart';

class WavedAudioPlayer extends StatefulWidget {
  final Source source;
  final Color playedColor;
  final Color unplayedColor;
  final Color iconColor;
  final Color iconBackgoundColor;
  final double barWidth;
  final double spacing;
  final double waveHeight;
  final double buttonSize;
  final bool showTiming;
  final TextStyle? timingStyle;
  final void Function(WavedAudioPlayerError)? onError;
  final Function(String)? onTranscriptionReceived;
  final String guid;

  const WavedAudioPlayer({
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

  List<TranscriptionSegment> transcriptionSegments = [];
  TranscriptionSegment? selectedSegment;
  String _highlightedTranscription = "";
  String _fullTranscription = "";
  bool _isAudioSourceSet = false;
  bool _isAudioInitialized = false; // Track if audio is fully initialized

  // Stream subscriptions
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  List<TranscriptionSegment> get segments => transcriptionSegments;
  Duration get duration => audioDuration;

  @override
  void initState() {
    super.initState();
    // Use a small delay to ensure proper widget initialization
    Future.microtask(() {
      _setupAudioPlayer();
      _loadAudioData();
    });
  }

  Future<void> _loadAudioData() async {
    try {
      await _loadWaveform();
      if (_audioBytes != null) {
        await _setAudioSource();
        await _fetchTranscription();
        // Wait for audio to initialize fully before playing
        if (_isAudioSourceSet) {
          await Future.delayed(const Duration(milliseconds: 300));
          await _playAudio();
        }
      }
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error loading audio data: $e"));
    }
  }

  Future<void> _setAudioSource() async {
    try {
      if (_audioBytes == null) {
        _safeCallOnError(WavedAudioPlayerError("Audio bytes not loaded"));
        return;
      }
      
      await _audioPlayer.setSource(
        BytesSource(_audioBytes!, mimeType: widget.source.mimeType),
      );
      
      if (mounted) {
        setState(() {
          _isAudioSourceSet = true;
        });
      }
      
      // Wait for duration to be set before considering audio initialized
      await _audioPlayer.getDuration().then((duration) {
        if (duration != null && mounted) {
          setState(() {
            audioDuration = duration;
            _isAudioInitialized = true;
          });
        }
      });
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error setting audio source: $e"));
    }
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

      if (_audioBytes != null && mounted) {
        setState(() {
          waveformData = _extractWaveformData(_audioBytes!);
        });
      }
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error loading audio for waveform: $e"));
    }
  }

  Future<Uint8List?> _loadDeviceFileAudioWaveform(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.readAsBytes();
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error loading file audio for waveform: $e"));
    }
    return null;
  }

  Future<Uint8List?> _loadAssetAudioWaveform(String path) async {
    try {
      final ByteData bytes = await rootBundle.load(path);
      return bytes.buffer.asUint8List();
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error loading asset audio for waveform: $e"));
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
        _safeCallOnError(
          WavedAudioPlayerError("Failed to load remote audio for waveform: ${response.statusCode}"),
        );
      }
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error loading remote audio for waveform: $e"));
    }
    return null;
  }

  void _setupAudioPlayer() {
    // Cancel any existing subscriptions first
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();

    // Set up new subscriptions
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      // Use Future.microtask to ensure we're on the main thread
      Future.microtask(() {
        if (mounted) {
          setState(() {
            isPlaying = (state == PlayerState.playing);
          });
        }
      });
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            isPlaying = false;
            isPausing = true;
          });
        }
      });
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((Duration duration) {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            audioDuration = duration;
            isPausing = true;
            _isAudioInitialized = true;
          });
        }
      });
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((Duration position) {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            currentPosition = position;
            isPausing = true;
          });

          String matchedTranscription = _findMatchedTranscription(position, transcriptionSegments);
          setState(() {
            _highlightedTranscription = matchedTranscription;
          });

          _checkCurrentSegment(position);
        }
      });
    });
  }

  void _checkCurrentSegment(Duration position) {
    for (var segment in transcriptionSegments) {
      Duration start = _parseDuration(segment.startTime);
      Duration end = _parseDuration(segment.endTime);

      if (position >= start && position <= end) {
        if (selectedSegment != segment) {
          if (mounted) {
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
        }
        return;
      }
    }

    if (selectedSegment != null && mounted) {
      setState(() {
        selectedSegment = null;
      });
    }
  }

  List<double> _extractWaveformData(Uint8List audioBytes) {
    List<double> waveData = [];
    // Default to a reasonable value if waveWidth is not set yet
    double effectiveWidth = waveWidth > 0 ? waveWidth : 300;
    int steps = max(1, (audioBytes.length / (effectiveWidth / (widget.barWidth + widget.spacing))).floor());
    
    for (int i = 0; i < audioBytes.length; i += steps) {
      waveData.add(audioBytes[i % audioBytes.length] / 100);
    }
    waveData.add(audioBytes[audioBytes.length - 1] / 255);
    return waveData;
  }

  Future<void> _fetchTranscription() async {
    try {
      final transcription = await getAudioTranscriptionByGuidDemo(widget.guid);
      if (transcription != null && mounted) {
        setState(() {
          transcriptionSegments = transcription.srtSegments;
          _fullTranscription = transcription.transcription;
        });
      } else {
        _safeCallOnError(WavedAudioPlayerError("Transcription is null."));
      }
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Failed to fetch transcription: $e"));
    }
  }

  void _onWaveformTap(double tapX) async {
    if (!_isAudioInitialized || waveWidth == 0 || audioDuration == Duration.zero) {
      _safeCallOnError(WavedAudioPlayerError("Audio not fully initialized for seeking"));
      return;
    }

    double tapPercent = tapX / waveWidth;
    Duration newPosition = Duration(
      milliseconds: (audioDuration.inMilliseconds * tapPercent).round(),
    );

    try {
      await _audioPlayer.seek(newPosition);
      
      if (!isPlaying) {
        await _audioPlayer.resume();
      }

      TranscriptionSegment? tappedSegment = _findSegmentAtPosition(newPosition);
      if (mounted) {
        setState(() {
          selectedSegment = tappedSegment;
        });
        if (tappedSegment != null && widget.onTranscriptionReceived != null) {
          String highlightedTranscription = _highlightTranscriptionSentence(
            tappedSegment.transcriptText,
            _fullTranscription,
          );
          widget.onTranscriptionReceived!(highlightedTranscription);
          setState(() {
            _highlightedTranscription = highlightedTranscription;
          });
        }
      }
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error seeking or playing audio: $e"));
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
    return "";
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

    return fullTranscription.replaceFirst(
      matchedSentence,
      '**$matchedSentence**',
    );
  }

  Future<void> _playAudio() async {
    try {
      if (!_isAudioSourceSet) {
        _safeCallOnError(WavedAudioPlayerError("Audio source not set yet"));
        return;
      }
      
      await _audioPlayer.resume();
      if (mounted) {
        setState(() {
          isPlaying = true;
        });
      }
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error playing audio: $e"));
    }
  }

  void seekToPosition(double percentage) async {
    if (!_isAudioInitialized || audioDuration == Duration.zero) {
      _safeCallOnError(WavedAudioPlayerError("Audio not fully initialized for seeking"));
      return;
    }

    final position = Duration(
      milliseconds: (audioDuration.inMilliseconds * percentage / 100).round(),
    );
    
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error seeking audio: $e"));
    }
  }

  void setSelectedSegment(TranscriptionSegment segment) {
    if (mounted) {
      setState(() {
        selectedSegment = segment;
      });
    }
  }

  void _safeCallOnError(WavedAudioPlayerError error) {
    // Use microtask to ensure we're on the main thread
    Future.microtask(() {
      if (widget.onError != null) {
        debugPrint('\x1B[31m${error.message}\x1B[0m');
        widget.onError!(error);
      } else {
        // If no error handler is provided, at least print to console
        debugPrint('\x1B[31mAudio Player Error: ${error.message}\x1B[0m');
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    waveWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (TapDownDetails details) {
            if (_isAudioInitialized) {
              _onWaveformTap(details.localPosition.dx);
            }
          },
          child: SizedBox(
            width: constraints.maxWidth,
            height: max(widget.waveHeight, widget.buttonSize),
            child: (_isAudioInitialized && waveformData.isNotEmpty && audioDuration != Duration.zero)
                ? CustomPaint(
                    painter: WaveformPainter(
                      waveformData: waveformData,
                      progress: currentPosition.inMilliseconds /
                          (audioDuration.inMilliseconds == 0
                              ? 1
                              : audioDuration.inMilliseconds),
                      playedColor: widget.playedColor,
                      unplayedColor: widget.unplayedColor,
                      barWidth: widget.barWidth,
                      waveWidth: constraints.maxWidth,
                      transcriptionSegments: transcriptionSegments,
                      audioDuration: audioDuration,
                      selectedSegment: selectedSegment,
                    ),
                  )
                : Center(
                    child: LinearProgressIndicator(
                      color: widget.playedColor,
                      borderRadius: BorderRadius.circular(40),
                      value: (_isAudioSourceSet && audioDuration.inMilliseconds > 0)
                          ? currentPosition.inMilliseconds / audioDuration.inMilliseconds
                          : null, // Use null for indeterminate progress
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class WavedAudioPlayerError {
  final String message;
  const WavedAudioPlayerError(this.message);
}

