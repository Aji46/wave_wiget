// file: audio_cubit_state.dart
import 'package:equatable/equatable.dart';
import 'package:test_widget/audio/model/api/audio_entity.dart';



class AudioCubitState extends Equatable {
  final bool isLoading;
  final List<AudioFolder> audioFolders;
  final List<AudioFile> audioFiles;
  final String? expandedFolder;
  final String? selectedSubFolder;
  final String? audioEntityName;

  const AudioCubitState({
    this.isLoading = false,
    this.audioFolders = const [],
    this.audioFiles = const [],
    this.expandedFolder,
    this.selectedSubFolder,
    this.audioEntityName,
  });

  AudioCubitState copyWith({
    bool? isLoading,
    List<AudioFolder>? audioFolders,
    List<AudioFile>? audioFiles,
    String? expandedFolder,
    String? selectedSubFolder,
    String? audioEntityName,
  }) {
    return AudioCubitState(
      isLoading: isLoading ?? this.isLoading,
      audioFolders: audioFolders ?? this.audioFolders,
      audioFiles: audioFiles ?? this.audioFiles,
      expandedFolder: expandedFolder ?? this.expandedFolder,
      selectedSubFolder: selectedSubFolder ?? this.selectedSubFolder,
      audioEntityName: audioEntityName ?? this.audioEntityName,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        audioFolders,
        audioFiles,
        expandedFolder,
        selectedSubFolder,
        audioEntityName,
      ];
}
