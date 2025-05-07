

// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:test_widget/audio/domain/usecase/audio_usecase.dart';
// // import 'package:test_widget/audio/presentation/view_model/audio_state.dart';

// // class AudioExplorerCubit extends Cubit<AudioExplorerState> {
// //   final GetAudioFoldersUseCase getFoldersUseCase;
// //   final GetAudioFilesUseCase getFilesUseCase;

// //   AudioExplorerCubit({required this.getFoldersUseCase, required this.getFilesUseCase})
// //       : super(AudioExplorerState.initial());

// //   void toggleFolderVisibility() {
// //     emit(state.copyWith(showFolders: !state.showFolders));
// //   }

// //   Future<void> loadFolders() async {
// //     final folders = await getFoldersUseCase();
// //     emit(state.copyWith(dateFolders: folders));
// //   }

// //   Future<void> loadAudioFiles(String date) async {
// //     emit(state.copyWith(loadingAudio: true));
// //     final files = await getFilesUseCase(date);
// //     emit(state.copyWith(audioFiles: files, loadingAudio: false));
// //   }
// // }

// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:test_widget/audio/data/entity/audio_file_entity.dart';
// // import 'package:test_widget/audio/domain/usecase/audio_usecase.dart';
// // import 'package:test_widget/audio/presentation/view_model/audio_state.dart';

// // class AudioExplorerCubit extends Cubit<AudioExplorerState> {

// //   final GetAudioFilesUseCase getFilesUseCase;
// //   final GetTranscriptionUseCase getTranscriptionUseCase;

// //   AudioExplorerCubit({

// //     required this.getFilesUseCase,
// //     required this.getTranscriptionUseCase,
// //   }) : super(AudioExplorerState.initial());

// //   void toggleFolderVisibility() {
// //     emit(state.copyWith(showFolders: !state.showFolders));
// //   }

// //   Future<void> loadFolders() async {
// //     try {
// //       emit(state.copyWith(loadingFolders: true));
// //       final folderEntities = await getFoldersUseCase();
// //       final folderNames = folderEntities.map((e) => e.name).toList();
// //       emit(state.copyWith(dateFolders: folderNames, loadingFolders: false));
// //     } catch (e) {
// //       emit(state.copyWith(loadingFolders: false, error: e.toString()));
// //     }
// //   }

// //   Future<void> loadTranscription(String guid) async {
// //     try {
// //       emit(state.copyWith(loadingTranscription: true));
// //       final transcription = await getTranscriptionUseCase(guid);
// //       emit(state.copyWith(
// //         selectedTranscription: transcription,
// //         segments: transcription.srtSegments,
// //         loadingTranscription: false,
// //       ));
// //     } catch (e) {
// //       emit(state.copyWith(loadingTranscription: false, error: e.toString()));
// //     }
// //   }

// //   void selectAudioFile(AudioFileEntity file) {
// //     emit(state.copyWith(
// //       selectedAudioFile: file,
// //       selectedTranscription: file.audioTranscription,
// //       segments: file.audioTranscription?.srtSegments ?? [],
// //     ));
// //   }

// //   void clearSelectedAudioFile() {
// //     emit(state.copyWith(
// //       selectedAudioFile: null,
// //       selectedTranscription: null,
// //       segments: [],
// //     ));
// //   }
// // }

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:test_widget/audio/data/entity/audio_file_entity.dart';
// import 'package:test_widget/audio/data/entity/sub_folder_entity.dart';
// import 'package:test_widget/audio/domain/repository/audio_repository.dart';
// import 'package:test_widget/audio/domain/usecase/audio_usecase.dart';
// import 'package:test_widget/audio/presentation/view_model/audio_state.dart';

// class AudioExplorerCubit extends Cubit<AudioExplorerState> {
//   final GetAudioFilesUseCase getFilesUseCase;
//   final GetTranscriptionUseCase getTranscriptionUseCase;

//   AudioExplorerCubit({
//     required this.getFilesUseCase,
//     required this.getTranscriptionUseCase,
//   }) : super(AudioExplorerState.initial());

//   void toggleFolderVisibility() {
//     emit(state.copyWith(showFolders: !state.showFolders));
//   }

//   Future<void> loadFolders() async {
//     try {
//       emit(state.copyWith(loadingFolders: true));
//       final folderEntities = await getFilesUseCase.call();  // Get folders or files based on the use case
//       emit(state.copyWith(dateFolders: folderEntities.map((e) => e.toString()).toList(), loadingFolders: false)); // Adjust as needed
//     } catch (e) {
//       emit(state.copyWith(loadingFolders: false, error: e.toString()));
//     }
//   }

//   Future<void> loadTranscription(String guid) async {
//     try {
//       emit(state.copyWith(loadingTranscription: true));
//       final transcription = await getTranscriptionUseCase.call(guid);
//       emit(state.copyWith(
//         selectedTranscription: transcription,
//         segments: transcription.srtSegments,
//         loadingTranscription: false,
//       ));
//     } catch (e) {
//       emit(state.copyWith(loadingTranscription: false, error: e.toString()));
//     }
//   }

//   void selectAudioFile(AudioTranscription file) {
//     emit(state.copyWith(
//       selectedAudioFile: file,
//       selectedTranscription: file.audioTranscription,
//       segments: file.audioTranscription?.srtSegments ?? [],
//     ));
//   }

//   void clearSelectedAudioFile() {
//     emit(state.copyWith(
//       selectedAudioFile: null,
//       selectedTranscription: null,
//       segments: [],
//     ));
//   }
// }


// // Define the states for the Cubit
// abstract class FileExploreState {}

// class FileExploreInitial extends FileExploreState {}

// class FileExploreLoading extends FileExploreState {}

// class FileExploreLoaded extends FileExploreState {
//   final List<SubFolderEntity> subFolders;

//   FileExploreLoaded(this.subFolders);
// }

// class FileExploreError extends FileExploreState {
//   final String message;

//   FileExploreError(this.message);
// }

// // Define the Cubit
// class FileExploreCubit extends Cubit<FileExploreState> {
//   final AudioRepository audioRepository; // Assuming this repository is used for data fetching

//   FileExploreCubit(this.audioRepository) : super(FileExploreInitial());

//   // Method to fetch subfolders based on the folder name
//   Future<void> getSubFoldersByFolderName() async {
//     emit(FileExploreLoading());
//     try {
//       final subFolders = await audioRepository.getSubFoldersByFolderName(); // Fetching the subfolders
//       emit(FileExploreLoaded(subFolders.cast<SubFolderEntity>()));
//     } catch (e) {
//       emit(FileExploreError("Error fetching subfolders: $e"));
//     }
//   }
// }
