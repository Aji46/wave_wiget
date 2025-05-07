import 'package:test_widget/features/audio_convert/data/entity/transcription_segment.dart';
import 'package:test_widget/features/audio_convert/domain/repository/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  @override
  Future<List<double>> getWaveformData(String audioPath) async {
    // TODO: Implement waveform data extraction
    return [];
  }

  @override
  Future<List<TranscriptionSegment>> getTranscriptionSegments(String audioPath) async {
    // TODO: Implement transcription segment extraction
    return [];
  }

  @override
  Future<Duration> getAudioDuration(String audioPath) async {
    // TODO: Implement audio duration extraction
    return Duration.zero;
  }
} 