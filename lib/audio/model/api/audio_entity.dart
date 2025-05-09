
// class AudioEntity {
//   final String name;
//   final String path;
//   final String type;
//   final List<AudioFolder> subFolders;
//   final List<AudioFile> files;
//   final List<AudioFile> children;

//   AudioEntity({
//     required this.name,
//     required this.path,
//     required this.type,
//     required this.subFolders,
//     required this.files, 
//     required this.children,
//   });

//   factory AudioEntity.fromJson(Map<String, dynamic> json) {
//     return AudioEntity(
//       name: json['name'] ?? '',
//       path: json['path'] ?? '',
//       type: json['type'] ?? '',
//       children: (json['children'] as List?)?.map((e) => AudioFile.fromJson(e)).toList() ?? [],
//       subFolders: (json['subFolders'] as List?)?.map((e) => AudioFolder.fromJson(e)).toList() ?? [],
//       files: (json['files'] as List?)?.map((e) => AudioFile.fromJson(e)).toList() ?? [],
//     );
//   }
// }


// class AudioFolder {
//   final String name;
//   final String path;
//   final String type;
//   final List<AudioFile> files;

//   AudioFolder({
//     required this.name,
//     required this.path,
//     required this.type,
//     required this.files,
//   });

//   factory AudioFolder.fromJson(Map<String, dynamic> json) {
//     return AudioFolder(
//       name: json['name'] ?? '',
//       path: json['path'] ?? '',
//       type: json['type'] ?? '',
//       files: (json['files'] as List?)?.map((e) => AudioFile.fromJson(e)).toList() ?? [],
//     );
//   }
// }

// class AudioFile {
//   final int guid;
//   final String fileName;
//   final DateTime receiveddAt;
//   final DateTime convertedAt;
//   final String transcription;
//   final String folderPath;
//   final String? type;
//   final String? status;

//   AudioFile({
//     required this.guid,
//     required this.fileName,
//     required this.receiveddAt,
//     required this.convertedAt,
//     required this.transcription,
//     required this.folderPath,
//     this.type,
//     this.status,
//   });

//   factory AudioFile.fromJson(Map<String, dynamic> json) {
//     return AudioFile(
//       guid: json['guid'] ?? '',
//       fileName: json['fileName'] ?? '',
//       receiveddAt: DateTime.parse(json['receivedAt'] ?? '1970-01-01T00:00:00Z'),
//       convertedAt: DateTime.parse(json['convertedAt'] ?? '1970-01-01T00:00:00Z'),
//       transcription: json['transcription'] ?? '',
//       folderPath: json['folderPath'] ?? '',
//       type: json['type'],
//       status: json['status'],
//     );
//   }
//   AudioFile copyWith({String? folderPath}) {
//     return AudioFile(
//       guid: guid,
//       fileName: fileName,
//       receiveddAt: receiveddAt,
//       convertedAt: convertedAt,
//       transcription: transcription,
//       folderPath: folderPath ?? this.folderPath,
//       type: type,
//       status: status,
//     );
//   }
// }



import 'dart:convert';

class AudioEntity {
  final String name;
  final String path;
  final String type;
  final List<AudioFile> children;
  final List<AudioFolder> subFolders;
  final List<AudioFile> files;

  AudioEntity({
    required this.name,
    required this.path,
    required this.type,
    required this.children,
    required this.subFolders,
    required this.files,
  });

  factory AudioEntity.fromJson(Map<String, dynamic> json) {
    return AudioEntity(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      type: json['type'] ?? '',
      children: (json['children'] as List?)?.map((e) => AudioFile.fromJson(e)).toList() ?? [],
      subFolders: (json['subFolders'] as List?)?.map((e) => AudioFolder.fromJson(e)).toList() ?? [],
      files: (json['files'] as List?)?.map((e) => AudioFile.fromJson(e)).toList() ?? [],
    );
  }

  static List<AudioEntity> listFromJson(String jsonStr) {
    final data = jsonDecode(jsonStr);
    return (data as List).map((e) => AudioEntity.fromJson(e)).toList();
  }
}

class AudioFolder {
  final String name;
  final String path;
  final String type;
  final List<AudioFile> files;

  AudioFolder({
    required this.name,
    required this.path,
    required this.type,
    required this.files,
  });

  factory AudioFolder.fromJson(Map<String, dynamic> json) {
    return AudioFolder(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      type: json['type'] ?? '',
      files: (json['files'] as List?)?.map((e) => AudioFile.fromJson(e)).toList() ?? [],
    );
  }
}


class AudioFile {
  final int guid;
  final String fileName;
  final DateTime receiveddAt;
  final DateTime convertedAt;
  final String transcription;
  final String folderPath;
  final String? type;
  final String? status;

  AudioFile({
    required this.guid,
    required this.fileName,
    required this.receiveddAt,
    required this.convertedAt,
    required this.transcription,
    required this.folderPath,
    this.type,
    this.status,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      guid: json['id'] ?? 0,
      fileName: json['fileName'] ?? '',
      receiveddAt: DateTime.tryParse(json['receivedAt'] ?? '') ?? DateTime(1970),
      convertedAt: DateTime.tryParse(json['convertedAt'] ?? '') ?? DateTime(1970),
      transcription: json['transcription'] ?? '',
      folderPath: json['folderPath'] ?? '',
      type: json['type'],
      status: json['status'],
    );
  }

  AudioFile copyWith({String? folderPath}) {
    return AudioFile(
      guid: guid,
      fileName: fileName,
      receiveddAt: receiveddAt,
      convertedAt: convertedAt,
      transcription: transcription,
      folderPath: folderPath ?? this.folderPath,
      type: type,
      status: status,
    );
  }
}
