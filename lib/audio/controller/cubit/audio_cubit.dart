// file: audio_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_widget/audio/controller/services.dart';
import 'package:test_widget/audio/model/api/audio_entity.dart';

import 'audio_cubit_state.dart';

class AudioCubit extends Cubit<AudioCubitState> {
  AudioCubit() : super(const AudioCubitState());

  Future<void> fetchAudioFolders() async {
    emit(state.copyWith(isLoading: true));
    try {
      final entities = await getAudioFilesBySubFolder();
      if (entities.isNotEmpty) {
        final mainEntity = entities.first;
        emit(state.copyWith(
          isLoading: false,
          audioEntityName: mainEntity.name,
          audioFolders: mainEntity.subFolders,
        ));
      } else {
        emit(state.copyWith(isLoading: false, audioFolders: []));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

void toggleMainFolder(String? folderName) {
  final isExpanded = state.expandedFolder == folderName;

  if (isExpanded) {
    emit(state.copyWith(
      expandedFolder: null,
      audioFiles: [],
      selectedSubFolder: null,
    ));
  } else {
    final selectedEntity = state.audioEntityName == folderName
        ? state.audioFolders.firstWhere((e) => e.name == folderName, orElse: () => AudioFolder(name: '', path: '', type: '', files: []))
        : null;
    emit(state.copyWith(
      expandedFolder: folderName,
      audioFiles: selectedEntity?.files ?? [],
      selectedSubFolder: null,
    ));
  }
}


  void selectSubFolder(AudioFolder folder) {
    emit(state.copyWith(
      selectedSubFolder: folder.name,
      audioFiles: folder.files,
    ));
  }

  
}
