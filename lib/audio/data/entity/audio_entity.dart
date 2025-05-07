// import 'package:test_widget/audio/data/entity/sub_folder_entity.dart';

// class AudioEntity {
//   final String name;
//   final String path;
//   final String type;
//   final List<SubFolderEntity> subFolders;

//   AudioEntity({
//     required this.name,
//     required this.path,
//     required this.type,
//     required this.subFolders,
//   });

//   factory AudioEntity.fromJson(Map<String, dynamic> json) {
//     return AudioEntity(
//       name: json['name'],
//       path: json['path'],
//       type: json['type'],
//       subFolders: (json['subFolders'] as List)
//           .map((e) => SubFolderEntity.fromJson(e))
//           .toList(),
//     );
//   }
// }


class AudioEntity {
  final String name;
  final String path;
  final String type;
  final List<AudioEntity> subFolders;
  final List<AudioFile> files;

  AudioEntity({
    required this.name,
    required this.path,
    required this.type,
    required this.subFolders,
    required this.files,
  });

  factory AudioEntity.fromJson(Map<String, dynamic> json) {
    return AudioEntity(
      name: json['name'],
      path: json['path'],
      type: json['type'],
      subFolders: (json['subFolders'] as List<dynamic>?)
              ?.map((e) => AudioEntity.fromJson(e))
              .toList() ??
          [],
      files: (json['files'] as List<dynamic>?)
              ?.map((e) => AudioFile.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AudioFile {
  final String guid;
  final String fileName;
  final String transcription;
  final String folderPath;
  final DateTime receivedAt;
  final DateTime convertedAt;

  AudioFile({
    required this.guid,
    required this.fileName,
    required this.transcription,
    required this.folderPath,
    required this.receivedAt,
    required this.convertedAt,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      guid: json['guid'],
      fileName: json['fileName'],
      transcription: json['transcription'],
      folderPath: json['folderPath'],
      receivedAt: DateTime.parse(json['receivedAt']),
      convertedAt: DateTime.parse(json['convertedAt']),
    );
  }
}
