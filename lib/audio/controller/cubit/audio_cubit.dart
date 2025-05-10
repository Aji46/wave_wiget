
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
          mainEntity: mainEntity,
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
      // Collapse
      emit(state.copyWith(
        expandedFolder: null,
        audioFiles: [],
        selectedSubFolder: null,
      ));

      // Expand main folder and show its files
      emit(state.copyWith(
        expandedFolder: folderName,
        audioFiles: state.mainEntity?.files ?? [],
        selectedSubFolder: null,
      ));
    
  }

  void selectSubFolder(AudioFolder folder) {
    emit(state.copyWith(
      selectedSubFolder: folder.name,
      audioFiles: folder.files,
    ));
  }
}