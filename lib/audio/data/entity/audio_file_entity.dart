// import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';

// class AudioFileEntity {
//   final String guid;
//   final String fileName;
//   final DateTime receivedAt;
//   final DateTime convertedAt;
//   final String transcription;
//   final String folderPath;
//   final String? type;
//   final AudioTranscription? audioTranscription; // audioTranscription is nullable

//   AudioFileEntity({
//     required this.guid,
//     required this.fileName,
//     required this.receivedAt,
//     required this.convertedAt,
//     required this.transcription,
//     required this.folderPath,
//     this.audioTranscription, // audioTranscription is optional
//     this.type,
//   });

//   factory AudioFileEntity.fromJson(Map<String, dynamic> json) {
//     return AudioFileEntity(
//       guid: json['guid'],
//       fileName: json['fileName'],
//       receivedAt: DateTime.parse(json['receivedAt']),
//       convertedAt: DateTime.parse(json['convertedAt']),
//       transcription: json['transcription'],
//       folderPath: json['folderPath'],
//       type: json['type'],
//       audioTranscription: json['audioTranscription'] != null
//           ? AudioTranscription.fromJson(json['audioTranscription'])
//           : null, // Handle null case for audioTranscription
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'guid': guid,
//       'fileName': fileName,
//       'receivedAt': receivedAt.toIso8601String(),
//       'convertedAt': convertedAt.toIso8601String(),
//       'transcription': transcription,
//       'folderPath': folderPath,
//       'type': type,
//       'audioTranscription': audioTranscription?.toJson(), // Handle nullable audioTranscription
//     };
//   }
// }
