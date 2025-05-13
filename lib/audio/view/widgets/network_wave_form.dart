// import 'dart:async';
// import 'dart:developer' as dev;
// import 'dart:io';
// import 'dart:math';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:test_widget/audio/controller/services.dart';
// import 'package:test_widget/audio/model/api/tanscriptionSegment.dart';
// import 'package:test_widget/audio/view/widgets/painter.dart';

// class WavedAudioPlayer extends StatefulWidget {
//   final Source source;
//   final Color playedColor;
//   final Color unplayedColor;
//   final Color iconColor;
//   final Color iconBackgoundColor;
//   final double barWidth;
//   final double spacing;
//   final double waveHeight;
//   final double buttonSize;
//   final bool showTiming;
//   final TextStyle? timingStyle;
//   final void Function(WavedAudioPlayerError)? onError;
//   final Function(String)? onTranscriptionReceived;
//   final int guid;

//   const WavedAudioPlayer({
//     super.key,
//     required this.source,
//     this.playedColor = Colors.blue,
//     this.unplayedColor = Colors.grey,
//     this.iconColor = Colors.blue,
//     this.iconBackgoundColor = Colors.white,
//     this.barWidth = 2,
//     this.spacing = 4,
//     this.buttonSize = 40,
//     this.showTiming = true,
//     this.timingStyle,
//     this.onError,
//     this.onTranscriptionReceived,
//     this.waveHeight = 35,
//     required this.guid,
//   });

//   @override
//   WavedAudioPlayerState createState() => WavedAudioPlayerState();
// }

// class WavedAudioPlayerState extends State<WavedAudioPlayer> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   List<double> waveformData = [];
//   Duration audioDuration = Duration.zero;
//   Duration currentPosition = Duration.zero;
//   bool isPlaying = false;
//   bool isPausing = true;
//   Uint8List? _audioBytes;
//   double waveWidth = 0;

//   List<TranscriptionSegment> transcriptionSegments = [];
//   TranscriptionSegment? selectedSegment;
//   String _highlightedTranscription = "";
//   String _fullTranscription = "";
//   bool _isAudioSourceSet = false;
//   bool _isAudioInitialized = false;
//   bool _isPlayingCompleted = false;
//   bool _isDisposed = false;

//   StreamSubscription<PlayerState>? _playerStateSubscription;
//   StreamSubscription<void>? _playerCompleteSubscription;
//   StreamSubscription<Duration>? _durationSubscription;
//   StreamSubscription<Duration>? _positionSubscription;

//   List<TranscriptionSegment> get segments => transcriptionSegments;
//   Duration get duration => audioDuration;

//   @override
//   void initState() {
//     super.initState();
//     _initAudioPlayer();
//   }

//   Future<void> _initAudioPlayer() async {
//     try {
//       await _setupAudioPlayer();
//       await _loadAudioData();
//     } catch (e) {
//       _safeCallOnError(
//         WavedAudioPlayerError("Error initializing audio player: $e"),
//       );
//     }
//   }

//   Future<void> _loadAudioData() async {
//     try {
//       await _loadWaveform();
//       if (_audioBytes != null) {
//         await _setAudioSource();
//         await _fetchTranscription();
//         if (_isAudioSourceSet) {
//           await Future.delayed(const Duration(milliseconds: 300));
//           await _playAudio();
//         }
//       }
//     } catch (e) {
//       _safeCallOnError(WavedAudioPlayerError("Error loading audio data: $e"));
//     }
//   }

//   Future<void> _setAudioSource() async {
//     try {
//       if (_audioBytes == null) {
//         _safeCallOnError(WavedAudioPlayerError("Audio bytes not loaded"));
//         return;
//       }

//       await _audioPlayer.setSource(
//         BytesSource(_audioBytes!, mimeType: widget.source.mimeType),
//       );

//       if (!_isDisposed && mounted) {
//         setState(() {
//           _isAudioSourceSet = true;
//         });
//       }

//       final duration = await _audioPlayer.getDuration();
//       if (duration != null && !_isDisposed && mounted) {
//         setState(() {
//           audioDuration = duration;
//           _isAudioInitialized = true;
//         });
//       }
//     } catch (e) {
//       _safeCallOnError(WavedAudioPlayerError("Error setting audio source: $e"));
//     }
//   }



// Future<void> _loadWaveform() async {
//   try {
//     if (_audioBytes == null) {
//       if (widget.source is AssetSource) {
//         _audioBytes = await rootBundle
//             .load((widget.source as AssetSource).path)
//             .then((byteData) => byteData.buffer.asUint8List());

//       } else if (widget.source is UrlSource) {
//         final url = (widget.source as UrlSource).url;
//         dev.log("Loading audio from URL: $url");

//         if (kIsWeb) {
//           // Flutter Web: use http package
//           final response = await http.get(Uri.parse(url));
//           if (response.statusCode == 200) {
//             _audioBytes = response.bodyBytes;
//           } else {
//             throw Exception("Failed to load audio: ${response.statusCode}");
//           }
//         } else {
//           // Mobile/Desktop: use HttpClient
//           final request = await HttpClient().getUrl(Uri.parse(url));
//           final response = await request.close();
//           _audioBytes = await consolidateHttpClientResponseBytes(response);
//         }

//       } else if (widget.source is DeviceFileSource) {
//         _audioBytes = await File(
//           (widget.source as DeviceFileSource).path,
//         ).readAsBytes();

//       } else if (widget.source is BytesSource) {
//         _audioBytes = (widget.source as BytesSource).bytes;
//       }
//     }

//     if (_audioBytes != null && !_isDisposed && mounted) {
//       setState(() {
//         waveformData = _extractWaveformData(_audioBytes!);
//       });
//     }

//   } catch (e) {
//     _safeCallOnError(
//       WavedAudioPlayerError("Error loading audio for waveform: $e"),
//     );
//   }
// }


//   List<double> _extractWaveformData(Uint8List audioBytes) {
//     List<double> waveData = [];
//     double effectiveWidth = waveWidth > 0 ? waveWidth : 300;
//     int steps = max(
//       1,
//       (audioBytes.length /
//               (effectiveWidth / (widget.barWidth + widget.spacing)))
//           .floor(),
//     );

//     for (int i = 0; i < audioBytes.length; i += steps) {
//       waveData.add(audioBytes[i % audioBytes.length] / 100);
//     }
//     waveData.add(audioBytes[audioBytes.length - 1] / 255);
//     return waveData;
//   }

//   Future<void> _setupAudioPlayer() async {
//     _playerStateSubscription?.cancel();
//     _playerCompleteSubscription?.cancel();
//     _durationSubscription?.cancel();
//     _positionSubscription?.cancel();

//     _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
//       PlayerState state,
//     ) {
//       if (_isDisposed) return;

//       if (mounted) {
//         setState(() {
//           isPlaying = (state == PlayerState.playing);
//           if (state == PlayerState.completed) {
//             _isPlayingCompleted = true;
//           }
//         });
//       }
//     });

//     _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
//       if (_isDisposed) return;

//       if (mounted) {
//         setState(() {
//           isPlaying = false;
//           isPausing = true;
//           _isPlayingCompleted = true;
//         });
//       }
//     });

//     _durationSubscription = _audioPlayer.onDurationChanged.listen((
//       Duration duration,
//     ) {
//       if (_isDisposed) return;

//       if (mounted) {
//         setState(() {
//           audioDuration = duration;
//           isPausing = true;
//           _isAudioInitialized = true;
//         });
//       }
//     });

//     _positionSubscription = _audioPlayer.onPositionChanged.listen((
//       Duration position,
//     ) {
//       if (_isDisposed) return;

//       if (mounted) {
//         setState(() {
//           currentPosition = position;
//           isPausing = true;
//           _isPlayingCompleted = false;
//         });

//         String matchedTranscription = _findMatchedTranscription(
//           position,
//           transcriptionSegments,
//         );
//         setState(() {
//           _highlightedTranscription = matchedTranscription;
//         });

//         _checkCurrentSegment(position);
//       }
//     });
//   }

//   Future<void> _fetchTranscription() async {
//     try {
//       final transcription = await getAudioTranscriptionByGuidDemo(widget.guid);

//       if (transcription != null && !_isDisposed && mounted) {
//         setState(() {
//           transcriptionSegments = transcription.srtSegments;
//           _fullTranscription = transcription.transcription;
//         });
//       } else {
//         _safeCallOnError(WavedAudioPlayerError("Transcription is null."));
//       }
//     } catch (e) {
//       _safeCallOnError(
//         WavedAudioPlayerError("Failed to fetch transcription: $e"),
//       );
//     }
//   }

//   Future<void> _onWaveformTap(double tapX) async {
//     if (!_isAudioInitialized ||
//         waveWidth == 0 ||
//         audioDuration == Duration.zero ||
//         _isDisposed) {
//       _safeCallOnError(
//         WavedAudioPlayerError("Audio not fully initialized for seeking"),
//       );
//       return;
//     }

//     double tapPercent = tapX / waveWidth;
//     Duration newPosition = Duration(
//       milliseconds: (audioDuration.inMilliseconds * tapPercent).round(),
//     );

//     try {
//       // Reset the source to ensure playback works after completion
//       await _audioPlayer.setSource(
//         BytesSource(_audioBytes!, mimeType: widget.source.mimeType),
//       );

//       await _audioPlayer.seek(newPosition);
//       await _audioPlayer.resume();

//       if (!_isDisposed && mounted) {
//         setState(() {
//           _isPlayingCompleted = false;
//           isPlaying = true;
//           _isAudioSourceSet = true;
//         });
//       }

//       TranscriptionSegment? tappedSegment = _findSegmentAtPosition(newPosition);
//       if (!_isDisposed && mounted) {
//         setState(() {
//           selectedSegment = tappedSegment;
//         });
//         if (tappedSegment != null && widget.onTranscriptionReceived != null) {
//           String highlightedTranscription = _highlightTranscriptionSentence(
//             tappedSegment.transcriptText,
//             _fullTranscription,
//           );
//           widget.onTranscriptionReceived!(highlightedTranscription);
//           setState(() {
//             _highlightedTranscription = highlightedTranscription;
//           });
//         }
//       }
//     } catch (e) {
//       _safeCallOnError(
//         WavedAudioPlayerError("Error seeking or playing audio: $e"),
//       );
//     }
//   }

//   Future<void> _playAudio() async {
//     if (_isDisposed) return;

//     try {
//       if (!_isAudioSourceSet) {
//         await _setAudioSource();
//       }

//       await _audioPlayer.resume();
//       if (!_isDisposed && mounted) {
//         setState(() {
//           isPlaying = true;
//           _isPlayingCompleted = false;
//         });
//       }
//     } catch (e) {
//       _safeCallOnError(WavedAudioPlayerError("Error playing audio: $e"));
//     }
//   }

//     Future<void> _pauseAudio() async {
//     if (_isDisposed) return;

//     try {
//       await _audioPlayer.pause();
//       if (!_isDisposed && mounted) {
//         setState(() {
//           isPlaying = false;
//         });
//       }
//     } catch (e) {
//       _safeCallOnError(WavedAudioPlayerError("Error pausing audio: $e"));
//     }
//   }

//   Future<void> _togglePlayPause() async {
//     if (isPlaying) {
//       await _pauseAudio();
//     } else {
//       await _playAudio();
//     }
//   }



//   Future<void> seekToPosition(double percentage) async {
//     if (!_isAudioInitialized || audioDuration == Duration.zero) {
//       _safeCallOnError(
//         WavedAudioPlayerError("Audio not fully initialized for seeking"),
//       );
//       return;
//     }

//     final position = Duration(
//       milliseconds: (audioDuration.inMilliseconds * percentage / 100).round(),
//     );

//     try {
//       await _audioPlayer.seek(position);
//     } catch (e) {
//       _safeCallOnError(WavedAudioPlayerError("Error seeking audio: $e"));
//     }
//   }

//   void setSelectedSegment(TranscriptionSegment segment) {
//     if (!_isDisposed && mounted) {
//       setState(() {
//         selectedSegment = segment;
//       });
//     }
//   }

//   TranscriptionSegment? _findSegmentAtPosition(Duration position) {
//     for (var segment in transcriptionSegments) {
//       Duration start = _parseDuration(segment.startTime);
//       Duration end = _parseDuration(segment.endTime);
//       if (position >= start && position <= end) {
//         return segment;
//       }
//     }
//     return null;
//   }

//   String _findMatchedTranscription(
//     Duration position,
//     List<TranscriptionSegment> segments,
//   ) {
//     for (var segment in segments) {
//       Duration start = _parseDuration(segment.startTime);
//       Duration end = _parseDuration(segment.endTime);
//       if (position >= start && position <= end) {
//         return segment.transcriptText;
//       }
//     }
//     return "";
//   }

//   Duration _parseDuration(String timeStr) {
//     List<String> parts = timeStr.split(':');
//     int hours = int.parse(parts[0]);
//     int minutes = int.parse(parts[1]);
//     double seconds = double.parse(parts[2]);

//     return Duration(
//       hours: hours,
//       minutes: minutes,
//       seconds: seconds.toInt(),
//       milliseconds: (seconds * 1000).toInt() % 1000,
//     );
//   }

//   String _highlightTranscriptionSentence(
//     String matchedSentence,
//     String fullTranscription,
//   ) {
//     if (!fullTranscription.contains(matchedSentence)) return fullTranscription;

//     return fullTranscription.replaceFirst(
//       matchedSentence,
//       '**$matchedSentence**',
//     );
//   }

//   void _checkCurrentSegment(Duration position) {
//     for (var segment in transcriptionSegments) {
//       Duration start = _parseDuration(segment.startTime);
//       Duration end = _parseDuration(segment.endTime);

//       if (position >= start && position <= end) {
//         if (selectedSegment != segment) {
//           if (!_isDisposed && mounted) {
//             setState(() {
//               selectedSegment = segment;

//               String matchedText = segment.transcriptText;
//               String highlightedTranscription = _highlightTranscriptionSentence(
//                 matchedText,
//                 _fullTranscription,
//               );

//               if (widget.onTranscriptionReceived != null) {
//                 widget.onTranscriptionReceived!(highlightedTranscription);
//               }

//               _highlightedTranscription = highlightedTranscription;
//             });
//           }
//         }
//         return;
//       }
//     }

//     if (selectedSegment != null && !_isDisposed && mounted) {
//       setState(() {
//         selectedSegment = null;
//       });
//     }
//   }

//   void _safeCallOnError(WavedAudioPlayerError error) {
//     if (_isDisposed) return;

//     if (widget.onError != null) {
//       widget.onError!(error);
//     }
//     debugPrint('\x1B[31m${error.message}\x1B[0m');
//   }

//   @override
//   Widget build(BuildContext context) {
//     waveWidth = MediaQuery.of(context).size.width;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         LayoutBuilder(
//           builder: (context, constraints) {
//             return GestureDetector(
//               onTapDown: (TapDownDetails details) {
//                 if (_isAudioInitialized && !_isDisposed) {
//                   _onWaveformTap(details.localPosition.dx);
//                 }
//               },
//               child: SizedBox(
//                 width: constraints.maxWidth,
//                 height: max(widget.waveHeight, widget.buttonSize),
//                 child:
//                     (_isAudioInitialized &&
//                             waveformData.isNotEmpty &&
//                             audioDuration != Duration.zero)
//                         ? CustomPaint(
//                             painter: WaveformPainter(
//                               waveformData: waveformData,
//                               progress:
//                                   currentPosition.inMilliseconds /
//                                       (audioDuration.inMilliseconds == 0
//                                           ? 1
//                                           : audioDuration.inMilliseconds),
//                               playedColor: widget.playedColor,
//                               unplayedColor: widget.unplayedColor,
//                               barWidth: widget.barWidth,
//                               waveWidth: constraints.maxWidth,
//                               transcriptionSegments: transcriptionSegments,
//                               audioDuration: audioDuration,
//                               selectedSegment: selectedSegment,
//                             ),
//                           )
//                         : Center(
//                             child: LinearProgressIndicator(
//                               color: widget.playedColor,
//                               borderRadius: BorderRadius.circular(40),
//                               value:
//                                   (_isAudioSourceSet &&
//                                           audioDuration.inMilliseconds > 0)
//                                       ? currentPosition.inMilliseconds /
//                                           audioDuration.inMilliseconds
//                                       : null,
//                             ),
//                           ),
//               ),
//             );
//           },
//         ),

//         SizedBox(height: 50),
//         Center(
//           child: GestureDetector(
//             onTap: _togglePlayPause,
//             child: Container(
//               width: widget.buttonSize,
//               height: widget.buttonSize,
//               decoration: BoxDecoration(
//                 color: widget.iconBackgoundColor,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_fill_rounded,
//                 color: widget.iconColor,
//                 size: widget.buttonSize * 1,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _playerStateSubscription?.cancel();
//     _playerCompleteSubscription?.cancel();
//     _durationSubscription?.cancel();
//     _positionSubscription?.cancel();
//     _audioPlayer.dispose();
//     super.dispose();
//   }
// }

// class WavedAudioPlayerError {
//   final String message;
//   const WavedAudioPlayerError(this.message);
// }


import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
  final int guid;

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
  bool _isAudioInitialized = false;
  bool _isPlayingCompleted = false;
  bool _isDisposed = false;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  List<TranscriptionSegment> get segments => transcriptionSegments;
  Duration get duration => audioDuration;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _setupAudioPlayer();
      await _loadAudioData();
    } catch (e) {
      _safeCallOnError(
        WavedAudioPlayerError("Error initializing audio player: $e"),
      );
    }
  }

  Future<void> _loadAudioData() async {
    try {
      await _loadWaveform();
      if (_audioBytes != null) {
        await _setAudioSource();
        await _fetchTranscription();
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

      if (!_isDisposed && mounted) {
        setState(() {
          _isAudioSourceSet = true;
        });
      }

      final duration = await _audioPlayer.getDuration();
      if (duration != null && !_isDisposed && mounted) {
        setState(() {
          audioDuration = duration;
          _isAudioInitialized = true;
        });
      }
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error setting audio source: $e"));
    }
  }



Future<void> _loadWaveform() async {
  try {
    if (_audioBytes == null) {
      if (widget.source is AssetSource) {
        _audioBytes = await rootBundle
            .load((widget.source as AssetSource).path)
            .then((byteData) => byteData.buffer.asUint8List());

      } else if (widget.source is UrlSource) {
        final url = (widget.source as UrlSource).url;
        dev.log("Loading audio from URL: $url");

        if (kIsWeb) {
          // Flutter Web: use http package
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            _audioBytes = response.bodyBytes;
          } else {
            throw Exception("Failed to load audio: ${response.statusCode}");
          }
        } else {
          // Mobile/Desktop: use HttpClient
          final request = await HttpClient().getUrl(Uri.parse(url));
          final response = await request.close();
          _audioBytes = await consolidateHttpClientResponseBytes(response);
        }

      } else if (widget.source is DeviceFileSource) {
        _audioBytes = await File(
          (widget.source as DeviceFileSource).path,
        ).readAsBytes();

      } else if (widget.source is BytesSource) {
        _audioBytes = (widget.source as BytesSource).bytes;
      }
    }

    if (_audioBytes != null && !_isDisposed && mounted) {
      setState(() {
        waveformData = _extractWaveformData(_audioBytes!);
      });
    }

  } catch (e) {
    _safeCallOnError(
      WavedAudioPlayerError("Error loading audio for waveform: $e"),
    );
  }
}


  List<double> _extractWaveformData(Uint8List audioBytes) {
    List<double> waveData = [];
    double effectiveWidth = waveWidth > 0 ? waveWidth : 300;
    int steps = max(
      1,
      (audioBytes.length /
              (effectiveWidth / (widget.barWidth + widget.spacing)))
          .floor(),
    );

    for (int i = 0; i < audioBytes.length; i += steps) {
      waveData.add(audioBytes[i % audioBytes.length] / 100);
    }
    waveData.add(audioBytes[audioBytes.length - 1] / 255);
    return waveData;
  }

  Future<void> _setupAudioPlayer() async {
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      PlayerState state,
    ) {
      if (_isDisposed) return;

      if (mounted) {
        setState(() {
          isPlaying = (state == PlayerState.playing);
          if (state == PlayerState.completed) {
            _isPlayingCompleted = true;
          }
        });
      }
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (_isDisposed) return;

      if (mounted) {
        setState(() {
          isPlaying = false;
          isPausing = true;
          _isPlayingCompleted = true;
        });
      }
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((
      Duration duration,
    ) {
      if (_isDisposed) return;

      if (mounted) {
        setState(() {
          audioDuration = duration;
          isPausing = true;
          _isAudioInitialized = true;
        });
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((
      Duration position,
    ) {
      if (_isDisposed) return;

      if (mounted) {
        setState(() {
          currentPosition = position;
          isPausing = true;
          _isPlayingCompleted = false;
        });

        String matchedTranscription = _findMatchedTranscription(
          position,
          transcriptionSegments,
        );
        setState(() {
          _highlightedTranscription = matchedTranscription;
        });

        _checkCurrentSegment(position);
      }
    });
  }

  Future<void> _fetchTranscription() async {
    try {
      final transcription = await getAudioTranscriptionByGuidDemo(widget.guid);

      if (transcription != null && !_isDisposed && mounted) {
        setState(() {
          transcriptionSegments = transcription.srtSegments;
          _fullTranscription = transcription.transcription;
        });
      } else {
        _safeCallOnError(WavedAudioPlayerError("Transcription is null."));
      }
    } catch (e) {
      _safeCallOnError(
        WavedAudioPlayerError("Failed to fetch transcription: $e"),
      );
    }
  }

Future<void> _onWaveformTap(double tapX) async {
  if (!_isAudioInitialized ||
      waveWidth == 0 ||
      audioDuration == Duration.zero ||
      _isDisposed) {
    _safeCallOnError(
      WavedAudioPlayerError("Audio not fully initialized for seeking"),
    );
    return;
  }

  double tapPercent = tapX / waveWidth;
  Duration newPosition = Duration(
    milliseconds: (audioDuration.inMilliseconds * tapPercent).round(),
  );

  try {
    if (kIsWeb) {
      if (isPlaying) {
        await _audioPlayer.pause();
      }
      await _audioPlayer.seek(newPosition);
      await _audioPlayer.resume();
    } else {
      await _audioPlayer.seek(newPosition);
      await _audioPlayer.resume();
    }

    if (!_isDisposed && mounted) {
      setState(() {
        _isPlayingCompleted = false;
        isPlaying = true;
        _isAudioSourceSet = true;
      });
    }

    TranscriptionSegment? tappedSegment = _findSegmentAtPosition(newPosition);
    if (!_isDisposed && mounted) {
      setState(() {
        selectedSegment = tappedSegment;
      });
      if (tappedSegment != null && widget.onTranscriptionReceived != null) {
        String highlightedTranscription = _highlightTranscriptionSentence(
          tappedSegment.transcriptText,
          _fullTranscription,
        );
        widget.onTranscriptionReceived!(
          highlightedTranscription,
        );
      }
    }
  } catch (e) {
    _safeCallOnError(
      WavedAudioPlayerError("Failed to seek audio: $e"),
    );
  }
}


Future<void> _playAudio() async {
  if (_isDisposed) return;

  try {
    if (!_isAudioSourceSet && _audioBytes != null) {
      await _setAudioSource();
    }

    await _audioPlayer.resume();

    if (!_isDisposed && mounted) {
      setState(() {
        isPlaying = true;
        isPausing = false;
        _isPlayingCompleted = false;
      });
    }
  } catch (e) {
    _safeCallOnError(
      WavedAudioPlayerError("Error playing audio: $e"),
    );
  }
}


// Future<void> _playAudio() async {
//   if (_isDisposed) return;

//   try {
//     if (!_isAudioSourceSet) {
//       await _setAudioSource();
//     }


//     if (kIsWeb && _isPlayingCompleted) {
//       await _audioPlayer.seek(Duration.zero);
//     }

//     await _audioPlayer.resume();
    
//     if (!_isDisposed && mounted) {
//       setState(() {
//         isPlaying = true;
//         _isPlayingCompleted = false;
//       });
//     }
//   } catch (e) {
//     _safeCallOnError(WavedAudioPlayerError("Error playing audio: $e"));
//   }
// }

      Future<void> _pauseAudio() async {
    if (_isDisposed) return;

    try {
      await _audioPlayer.pause();
      if (!_isDisposed && mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    } catch (e) {
      _safeCallOnError(WavedAudioPlayerError("Error pausing audio: $e"));
    }
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _pauseAudio();
    } else {
      await _playAudio();
    }
  }


  Future<void> seekToPosition(double percentage) async {
    if (!_isAudioInitialized || audioDuration == Duration.zero) {
      _safeCallOnError(
        WavedAudioPlayerError("Audio not fully initialized for seeking"),
      );
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
    if (!_isDisposed && mounted) {
      setState(() {
        selectedSegment = segment;
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

  void _checkCurrentSegment(Duration position) {
    for (var segment in transcriptionSegments) {
      Duration start = _parseDuration(segment.startTime);
      Duration end = _parseDuration(segment.endTime);

      if (position >= start && position <= end) {
        if (selectedSegment != segment) {
          if (!_isDisposed && mounted) {
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

    if (selectedSegment != null && !_isDisposed && mounted) {
      setState(() {
        selectedSegment = null;
      });
    }
  }

  void _safeCallOnError(WavedAudioPlayerError error) {
    if (_isDisposed) return;

    if (widget.onError != null) {
      widget.onError!(error);
    }
    debugPrint('\x1B[31m${error.message}\x1B[0m');
  }

  @override
 Widget build(BuildContext context) {
    waveWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: (TapDownDetails details) {
                if (_isAudioInitialized && !_isDisposed) {
                  _onWaveformTap(details.localPosition.dx);
                }
              },
              child: SizedBox(
                width: constraints.maxWidth,
                height: max(widget.waveHeight, widget.buttonSize),
                child:
                    (_isAudioInitialized &&
                            waveformData.isNotEmpty &&
                            audioDuration != Duration.zero)
                        ? CustomPaint(
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
                              value:
                                  (_isAudioSourceSet &&
                                          audioDuration.inMilliseconds > 0)
                                      ? currentPosition.inMilliseconds /
                                          audioDuration.inMilliseconds
                                      : null,
                            ),
                          ),
              ),
            );
          },
        ),

        SizedBox(height: 50),
        Center(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: widget.buttonSize,
              height: widget.buttonSize,
              decoration: BoxDecoration(
                color: widget.iconBackgoundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_fill_rounded,
                color: widget.iconColor,
                size: widget.buttonSize * 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

@override
void dispose() {
  _isDisposed = true;
  _audioPlayer.dispose();
  _playerStateSubscription?.cancel();
  _playerCompleteSubscription?.cancel();
  _durationSubscription?.cancel();
  _positionSubscription?.cancel();
  super.dispose();
}

}

class WavedAudioPlayerError {
  final String message;
  const WavedAudioPlayerError(this.message);
}
