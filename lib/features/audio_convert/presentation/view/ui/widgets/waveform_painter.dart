import 'package:flutter/material.dart';
import 'package:test_widget/features/audio_convert/data/entity/transcription_segment.dart';

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  final Color playedColor;
  final Color unplayedColor;
  final double barWidth;
  final double waveWidth;
  final List<TranscriptionSegment> transcriptionSegments;
  final Duration audioDuration;
  final TranscriptionSegment? selectedSegment;

  WaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
    required this.barWidth,
    required this.waveWidth,
    required this.transcriptionSegments,
    required this.audioDuration,
    this.selectedSegment,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint playedPaint = Paint()..color = playedColor;
    final Paint unplayedPaint = Paint()..color = unplayedColor;
    final Paint greenLinePaint = Paint()..color = Colors.green..strokeWidth = 3;
    final Paint segmentHighlightPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 59, 59).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    double greenLineHeight = size.height * 2;

    if (selectedSegment != null) {
      Duration start = _parseDuration(selectedSegment!.startTime);
      Duration end = _parseDuration(selectedSegment!.endTime);

      double startPosition = (start.inMilliseconds / audioDuration.inMilliseconds) * waveWidth;
      double endPosition = (end.inMilliseconds / audioDuration.inMilliseconds) * waveWidth;

      canvas.drawRect(
        Rect.fromLTWH(startPosition, size.height - greenLineHeight, endPosition - startPosition, greenLineHeight + 35),
        segmentHighlightPaint,
      );
    }

    final double availableWidth = size.width;
    final int barCount = waveformData.length;

    const double minBarWidth = 2.0;
    const double maxBarWidth = 2.0;
    const double minBarSpacing = 2.0;
    const double maxBarSpacing = 6.0;

    double barWidth = (availableWidth / barCount) - minBarSpacing;
    barWidth = barWidth.clamp(minBarWidth, maxBarWidth);

    double barSpacing = (availableWidth - (barWidth * barCount)) / (barCount - 1);
    barSpacing = barSpacing.clamp(minBarSpacing, maxBarSpacing);

    final double totalWidth = (barWidth * barCount) + (barSpacing * (barCount - 1));
    final double startX = (availableWidth - totalWidth) / 2;

    for (int i = 0; i < barCount; i++) {
      double x = startX + i * (barWidth + barSpacing);
      double height = waveformData[i] * size.height;
      double y = (size.height - height) / 2;

      final paint = i / barCount < progress ? playedPaint : unplayedPaint;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, height), paint);
    }

    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    TextStyle textStyle = const TextStyle(
      color: Colors.green,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    for (var segment in transcriptionSegments) {
      Duration end = _parseDuration(segment.endTime);
      double endPosition = (end.inMilliseconds / audioDuration.inMilliseconds) * waveWidth;

      canvas.drawLine(
        Offset(endPosition, size.height - greenLineHeight),
        Offset(endPosition, greenLineHeight),
        greenLinePaint,
      );

      textPainter.text = TextSpan(
        text: _formatDuration(end),
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(endPosition - textPainter.width / 2, greenLineHeight));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

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

  String _formatDuration(Duration duration) {
    int seconds = duration.inSeconds;
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    int hours = minutes ~/ 60;
    minutes = minutes % 60;

    return '${_twoDigitFormat(minutes)}:${_twoDigitFormat(seconds)}';
  }

  String _twoDigitFormat(int number) {
    return number.toString().padLeft(2, '0');
  }
} 