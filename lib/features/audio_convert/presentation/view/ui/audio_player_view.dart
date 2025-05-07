import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_widget/features/audio_convert/presentation/view_model/cubit/audio_cubit.dart';
import 'package:test_widget/features/audio_convert/presentation/view_model/state/audio_state.dart';
import 'package:test_widget/features/audio_convert/presentation/view/ui/widgets/waveform_painter.dart';

class AudioPlayerView extends StatelessWidget {
  final String audioPath;

  const AudioPlayerView({
    Key? key,
    required this.audioPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        if (state is AudioInitial) {
          context.read<AudioCubit>().loadAudio(audioPath);
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AudioLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AudioError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is AudioLoaded) {
          return Column(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: WaveformPainter(
                    waveformData: state.waveformData,
                    progress: state.progress,
                    playedColor: Colors.blue,
                    unplayedColor: Colors.grey,
                    barWidth: 2.0,
                    waveWidth: MediaQuery.of(context).size.width,
                    transcriptionSegments: state.segments,
                    audioDuration: state.duration,
                    selectedSegment: state.selectedSegment,
                  ),
                ),
              ),
              // Add playback controls here
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
} 