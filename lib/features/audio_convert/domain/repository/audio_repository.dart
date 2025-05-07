import 'package:test_widget/features/audio_convert/data/entity/transcription_segment.dart';

abstract class AudioRepository {
  Future<List<double>> getWaveformData(String audioPath);
  Future<List<TranscriptionSegment>> getTranscriptionSegments(String audioPath);
  Future<Duration> getAudioDuration(String audioPath);
} 