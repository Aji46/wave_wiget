import 'package:equatable/equatable.dart';
import 'package:test_widget/audio/model/api/audio_entity.dart';

class AudioCubitState extends Equatable {
  final bool isLoading;
  final String? audioEntityName;
  final List<AudioFolder> audioFolders;
  final List<AudioFile> audioFiles;
  final String? expandedFolder;
  final String? selectedSubFolder;
  final AudioEntity? mainEntity;

  const AudioCubitState({
    this.isLoading = false,
    this.audioEntityName,
    this.audioFolders = const [],
    this.audioFiles = const [],
    this.expandedFolder,
    this.selectedSubFolder,
    this.mainEntity,
  });

  AudioCubitState copyWith({
    bool? isLoading,
    String? audioEntityName,
    List<AudioFolder>? audioFolders,
    List<AudioFile>? audioFiles,
    String? expandedFolder,
    String? selectedSubFolder,
    AudioEntity? mainEntity,
  }) {
    return AudioCubitState(
      isLoading: isLoading ?? this.isLoading,
      audioEntityName: audioEntityName ?? this.audioEntityName,
      audioFolders: audioFolders ?? this.audioFolders,
      audioFiles: audioFiles ?? this.audioFiles,
      expandedFolder: expandedFolder ?? this.expandedFolder,
      selectedSubFolder: selectedSubFolder ?? this.selectedSubFolder,
      mainEntity: mainEntity ?? this.mainEntity,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        audioEntityName,
        audioFolders,
        audioFiles,
        expandedFolder,
        selectedSubFolder,
        mainEntity,
      ];
}
