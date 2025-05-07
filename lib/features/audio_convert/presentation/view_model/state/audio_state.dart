import 'package:equatable/equatable.dart';
import 'package:test_widget/features/audio_convert/data/entity/transcription_segment.dart';

abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {}

class AudioLoaded extends AudioState {
  final List<double> waveformData;
  final List<TranscriptionSegment> segments;
  final Duration duration;
  final double progress;
  final TranscriptionSegment? selectedSegment;

  const AudioLoaded({
    required this.waveformData,
    required this.segments,
    required this.duration,
    this.progress = 0.0,
    this.selectedSegment,
  });

  @override
  List<Object?> get props => [waveformData, segments, duration, progress, selectedSegment];

  AudioLoaded copyWith({
    List<double>? waveformData,
    List<TranscriptionSegment>? segments,
    Duration? duration,
    double? progress,
    TranscriptionSegment? selectedSegment,
  }) {
    return AudioLoaded(
      waveformData: waveformData ?? this.waveformData,
      segments: segments ?? this.segments,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      selectedSegment: selectedSegment ?? this.selectedSegment,
    );
  }
}

class AudioError extends AudioState {
  final String message;

  const AudioError(this.message);

  @override
  List<Object> get props => [message];
} 