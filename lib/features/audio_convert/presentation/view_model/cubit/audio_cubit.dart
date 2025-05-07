import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_widget/features/audio_convert/data/entity/transcription_segment.dart';
import 'package:test_widget/features/audio_convert/domain/repository/audio_repository.dart';
import 'package:test_widget/features/audio_convert/presentation/view_model/state/audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioRepository repository;

  AudioCubit({required this.repository}) : super(AudioInitial());

  Future<void> loadAudio(String audioPath) async {
    try {
      emit(AudioLoading());
      
      final waveformData = await repository.getWaveformData(audioPath);
      final segments = await repository.getTranscriptionSegments(audioPath);
      final duration = await repository.getAudioDuration(audioPath);

      emit(AudioLoaded(
        waveformData: waveformData,
        segments: segments,
        duration: duration,
      ));
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  void updateProgress(double progress) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      emit(currentState.copyWith(progress: progress));
    }
  }

  void selectSegment(TranscriptionSegment? segment) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      emit(currentState.copyWith(selectedSegment: segment));
    }
  }
} 