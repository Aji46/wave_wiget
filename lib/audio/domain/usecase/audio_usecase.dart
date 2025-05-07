// import 'package:test_widget/audio/data/model/api/model.dart';
// import 'package:test_widget/audio/domain/repository/audio_repository.dart';

// class GetAudioFoldersUseCase {
//   final AudioRepository repository;

//   GetAudioFoldersUseCase(this.repository);

//   Future<List<String>> call() async {
//     return await repository.getAudioFolders();
//   }
// }

// class GetAudioFilesUseCase {
//   final AudioRepository repository;

//   GetAudioFilesUseCase(this.repository);

//   Future<List<AudioModel>> call(String folderName) async {
//     return await repository.getAudioFilesByDate(folderName);
//   }
// }


import 'package:test_widget/audio/data/entity/audio_entity.dart';
import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';
import 'package:test_widget/audio/domain/repository/audio_repository.dart';


// class GetAudioFoldersUseCase {
//   final AudioRepository repository;
//   GetAudioFoldersUseCase(this.repository);
//   Future<List<AudioEntity>> call() => repository.getAudioFolders();
// }

// class GetSubFoldersUseCase {
//   final AudioRepository repository;
//   GetSubFoldersUseCase(this.repository);
//   Future<List<SubFolderEntity>> call() =>
//       repository.getSubFoldersByFolderName();
// }

class GetAudioFilesUseCase {
  final AudioRepository repository;
  GetAudioFilesUseCase(this.repository);
  Future<List<AudioEntity>> call() =>
      repository.getAudioFilesBySubFolder();
}

class GetTranscriptionUseCase {
  final AudioRepository repository;
  GetTranscriptionUseCase(this.repository);
  Future<AudioTranscription> call(String guid) =>
      repository.getAudioTranscriptionByGuid(guid);
}

