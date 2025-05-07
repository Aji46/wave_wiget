// // class AudioExplorerState {
// //   final bool showFolders;
// //   final bool loadingFolders;
// //   final bool loadingSubFolders;
// //   final bool loadingAudio;
// //   final List<String> dateFolders;
// //   final List<String> subFolders;
// //   final List<AudioFile> audioFiles;
// //   final String error;

// //   AudioExplorerState({
// //     required this.showFolders,
// //     required this.loadingFolders,
// //     required this.loadingSubFolders,
// //     required this.loadingAudio,
// //     required this.dateFolders,
// //     required this.subFolders,
// //     required this.audioFiles,
// //     required this.error,
// //   });

// //   factory AudioExplorerState.initial() {
// //     return AudioExplorerState(
// //       showFolders: false,
// //       loadingFolders: false,
// //       loadingSubFolders: false,
// //       loadingAudio: false,
// //       dateFolders: [],
// //       subFolders: [],
// //       audioFiles: [],
// //       error: '',
// //     );
// //   }

// //   AudioExplorerState copyWith({
// //     bool? showFolders,
// //     bool? loadingFolders,
// //     bool? loadingSubFolders,
// //     bool? loadingAudio,
// //     List<String>? dateFolders,
// //     List<String>? subFolders,
// //     List<AudioFile>? audioFiles,
// //     String? error,
// //   }) {
// //     return AudioExplorerState(
// //       showFolders: showFolders ?? this.showFolders,
// //       loadingFolders: loadingFolders ?? this.loadingFolders,
// //       loadingSubFolders: loadingSubFolders ?? this.loadingSubFolders,
// //       loadingAudio: loadingAudio ?? this.loadingAudio,
// //       dateFolders: dateFolders ?? this.dateFolders,
// //       subFolders: subFolders ?? this.subFolders,
// //       audioFiles: audioFiles ?? this.audioFiles,
// //       error: error ?? this.error,
// //     );
// //   }
// // }

// // class AudioFile {
// //   final String fileName;
// //   final String transcription;
// //   final String receivedAt;
// //   final String convertedAt;

// //   AudioFile({
// //     required this.fileName,
// //     required this.transcription,
// //     required this.receivedAt,
// //     required this.convertedAt,
// //   });
// // }


// import 'package:equatable/equatable.dart';
// import 'package:test_widget/audio/data/entity/audio_file_entity.dart';
// import 'package:test_widget/audio/data/entity/sub_folder_entity.dart';
// import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';

// class AudioExplorerState extends Equatable {
//   final List<String> dateFolders;
//   final List<SubFolderEntity> subFolders;
//   final List<AudioFileEntity> audioFiles;
//   final bool showFolders;
//   final bool loadingFolders;
//   final bool loadingSubFolders;
//   final bool loadingAudio;
//   final bool loadingTranscription;
//   final String? error;
//   final AudioFileEntity? selectedAudioFile;
//   final AudioTranscription? selectedTranscription;
//   final List<TranscriptionSegment> segments;

//   const AudioExplorerState({
//     required this.dateFolders,
//     required this.subFolders,
//     required this.audioFiles,
//     required this.showFolders,
//     required this.loadingFolders,
//     required this.loadingSubFolders,
//     required this.loadingAudio,
//     required this.loadingTranscription,
//     this.error,
//     this.selectedAudioFile,
//     this.selectedTranscription,
//     required this.segments,
//   });

//   factory AudioExplorerState.initial() {
//     return AudioExplorerState(
//       dateFolders: [],
//       subFolders: [],
//       audioFiles: [],
//       showFolders: true,
//       loadingFolders: false,
//       loadingSubFolders: false,
//       loadingAudio: false,
//       loadingTranscription: false,
//       error: null,
//       selectedAudioFile: null,
//       selectedTranscription: null,
//       segments: [],
//     );
//   }

//   AudioExplorerState copyWith({
//     List<String>? dateFolders,
//     List<SubFolderEntity>? subFolders,
//     List<AudioFileEntity>? audioFiles,
//     bool? showFolders,
//     bool? loadingFolders,
//     bool? loadingSubFolders,
//     bool? loadingAudio,
//     bool? loadingTranscription,
//     String? error,
//     AudioFileEntity? selectedAudioFile,
//     AudioTranscription? selectedTranscription,
//     List<TranscriptionSegment>? segments,
//   }) {
//     return AudioExplorerState(
//       dateFolders: dateFolders ?? this.dateFolders,
//       subFolders: subFolders ?? this.subFolders,
//       audioFiles: audioFiles ?? this.audioFiles,
//       showFolders: showFolders ?? this.showFolders,
//       loadingFolders: loadingFolders ?? this.loadingFolders,
//       loadingSubFolders: loadingSubFolders ?? this.loadingSubFolders,
//       loadingAudio: loadingAudio ?? this.loadingAudio,
//       loadingTranscription: loadingTranscription ?? this.loadingTranscription,
//       error: error ?? this.error,
//       selectedAudioFile: selectedAudioFile ?? this.selectedAudioFile,
//       selectedTranscription: selectedTranscription ?? this.selectedTranscription,
//       segments: segments ?? this.segments,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         dateFolders,
//         subFolders,
//         audioFiles,
//         showFolders,
//         loadingFolders,
//         loadingSubFolders,
//         loadingAudio,
//         loadingTranscription,
//         error,
//         selectedAudioFile,
//         selectedTranscription,
//         segments,
//       ];
// }


import 'package:equatable/equatable.dart';
import 'package:test_widget/audio/data/entity/audio_entity.dart';
import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';

class AudioExplorerState extends Equatable {
  final List<String> dateFolders;
  final List<AudioEntity> audioFiles;
  final bool showFolders;
  final bool loadingFolders;
  final bool loadingSubFolders;
  final bool loadingAudio;
  final bool loadingTranscription;
  final String? error;
  final AudioEntity? selectedAudioFile;
  final AudioTranscription? selectedTranscription;
  final List<TranscriptionSegment> segments;

  const AudioExplorerState({
    required this.dateFolders,
    required this.audioFiles,
    required this.showFolders,
    required this.loadingFolders,
    required this.loadingSubFolders,
    required this.loadingAudio,
    required this.loadingTranscription,
    this.error,
    this.selectedAudioFile,
    this.selectedTranscription,
    required this.segments,
  });

  factory AudioExplorerState.initial() {
    return AudioExplorerState(
      dateFolders: [],
      audioFiles: [],
      showFolders: true,
      loadingFolders: false,
      loadingSubFolders: false,
      loadingAudio: false,
      loadingTranscription: false,
      error: null,
      selectedAudioFile: null,
      selectedTranscription: null,
      segments: [],
    );
  }

  AudioExplorerState copyWith({
    List<String>? dateFolders,
    List<AudioEntity>? audioFiles,
    bool? showFolders,
    bool? loadingFolders,
    bool? loadingSubFolders,
    bool? loadingAudio,
    bool? loadingTranscription,
    String? error,
    AudioEntity? selectedAudioFile,
    AudioTranscription? selectedTranscription,
    List<TranscriptionSegment>? segments,
  }) {
    return AudioExplorerState(
      dateFolders: dateFolders ?? this.dateFolders,
      audioFiles: audioFiles ?? this.audioFiles,
      showFolders: showFolders ?? this.showFolders,
      loadingFolders: loadingFolders ?? this.loadingFolders,
      loadingSubFolders: loadingSubFolders ?? this.loadingSubFolders,
      loadingAudio: loadingAudio ?? this.loadingAudio,
      loadingTranscription: loadingTranscription ?? this.loadingTranscription,
      error: error ?? this.error,
      selectedAudioFile: selectedAudioFile ?? this.selectedAudioFile,
      selectedTranscription: selectedTranscription ?? this.selectedTranscription,
      segments: segments ?? this.segments,
    );
  }

  @override
  List<Object?> get props => [
        dateFolders,
        audioFiles,
        showFolders,
        loadingFolders,
        loadingSubFolders,
        loadingAudio,
        loadingTranscription,
        error,
        selectedAudioFile,
        selectedTranscription,
        segments,
      ];
}
