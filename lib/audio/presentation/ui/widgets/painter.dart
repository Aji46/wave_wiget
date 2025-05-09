
import 'package:flutter/material.dart';
import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';

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
      ..color = const Color.fromARGB(255, 255, 59, 59).withOpacity(0.3) // Light yellow with transparency
      ..style = PaintingStyle.fill;
         double greenLineHeight = size.height * 2;

    // Only highlight the selected segment if there is one
    if (selectedSegment != null) {
      Duration start = _parseDuration(selectedSegment!.startTime);
      Duration end = _parseDuration(selectedSegment!.endTime);

      double startPosition = (start.inMilliseconds / audioDuration.inMilliseconds) * waveWidth;
      double endPosition = (end.inMilliseconds / audioDuration.inMilliseconds) * waveWidth;

      // Draw yellow highlight rectangle for the selected segment area
      canvas.drawRect(
        Rect.fromLTWH(startPosition, size.height - greenLineHeight, endPosition - startPosition, greenLineHeight+35),
        segmentHighlightPaint,
      );
    }

// Draw waveform
// Draw waveform with responsive but constrained bar sizes
final double availableWidth = size.width;
final int barCount = waveformData.length;

// Define min/max bar dimensions
const double minBarWidth = 2.0;
const double maxBarWidth = 2.0;
const double minBarSpacing = 2.0;
const double maxBarSpacing = 6.0;

// Calculate optimal bar width and spacing
double barWidth = (availableWidth / barCount) - minBarSpacing;
barWidth = barWidth.clamp(minBarWidth, maxBarWidth);

double barSpacing = (availableWidth - (barWidth * barCount)) / (barCount - 1);
barSpacing = barSpacing.clamp(minBarSpacing, maxBarSpacing);

// Center the waveform if there's extra space
final double totalWidth = (barWidth * barCount) + (barSpacing * (barCount - 1));
final double startX = (availableWidth - totalWidth) / 2;

for (int i = 0; i < barCount; i++) {
  double x = startX + i * (barWidth + barSpacing);
  double height = waveformData[i] * size.height;
  double y = (size.height - height) / 2;

  final paint = i / barCount < progress ? playedPaint : unplayedPaint;
  canvas.drawRect(Rect.fromLTWH(x, y, barWidth, height), paint);
}

    // Draw green lines for transcription segments and show start and end times at the bottom
    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    TextStyle textStyle = TextStyle(
      color: Colors.green,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    for (var segment in transcriptionSegments) {
      // Duration start = _parseDuration(segment.startTime);
      Duration end = _parseDuration(segment.endTime);

      // double startPosition = (start.inMilliseconds / audioDuration.inMilliseconds) * waveWidth;
      double endPosition = (end.inMilliseconds / audioDuration.inMilliseconds) * waveWidth;

      // Draw green lines at the start and end times of the segment
     // Increased height of green lines
      // canvas.drawLine(
      //   Offset(startPosition, 0),
      //   Offset(startPosition, size.height - greenLineHeight), 
      //   greenLinePaint
      // );

      canvas.drawLine(
        Offset(endPosition, size.height - greenLineHeight),
        Offset(endPosition, greenLineHeight), 
        greenLinePaint
      );

      // Draw the start time text at the bottom of the green line
      // textPainter.text = TextSpan(
      //   text: _formatDuration(start),
      //   style: textStyle,
      // );
      // textPainter.layout();
      // textPainter.paint(canvas, Offset(startPosition - textPainter.width / 2, greenLineHeight));

      // Draw the end time text at the bottom of the green line
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

  // Helper method to parse the transcription segment time into Duration
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

  // Helper method to format Duration into a readable string (hh:mm:ss)
  String _formatDuration(Duration duration) {
    int seconds = duration.inSeconds;
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    int hours = minutes ~/ 60;
    minutes = minutes % 60;

    // return '${_twoDigitFormat(hours)}:${_twoDigitFormat(minutes)}:${_twoDigitFormat(seconds)}';
     return '${_twoDigitFormat(minutes)}:${_twoDigitFormat(seconds)}';
  }

  // Helper method to format numbers with two digits
  String _twoDigitFormat(int number) {
    return number.toString().padLeft(2, '0');
  }
}