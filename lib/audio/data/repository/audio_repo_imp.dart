// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:test_widget/audio/data/model/api/model.dart';
// import 'package:test_widget/audio/domain/repository/audio_repository.dart';



// class AudioRepositoryImpl implements AudioRepository {
//   final http.Client client;

//   AudioRepositoryImpl(this.client);

//   static const baseUrl = 'https://your-api-url.com/api'; 

//   @override
//   Future<List<String>> getAudioFolders() async {
//     final response = await client.get(Uri.parse('$baseUrl/folders'));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((folder) => folder.toString()).toList();
//     } else {
//       throw Exception('Failed to load folders');
//     }
//   }

//   @override
//   Future<List<AudioModel>> getAudioFilesByDate(String folderName) async {
//     final response = await client.get(Uri.parse('$baseUrl/folders/$folderName/audio-files'));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((item) => AudioModel.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load audio files for folder: $folderName');
//     }
//   }
// }






import 'dart:convert';

import 'package:test_widget/audio/data/entity/audio_entity.dart';
import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';
import 'package:test_widget/audio/domain/repository/audio_repository.dart';
import 'package:test_widget/core/network/api_endpoints/audio_endpoint.dart';
import 'package:test_widget/core/network/service/api_service.dart';

class AudioRepositoryImpl implements AudioRepository {
  final IApiService _apiService;

  AudioRepositoryImpl({required IApiService apiService}) : _apiService = apiService;


  @override
  Future<List<AudioEntity>> getAudioFilesBySubFolder() async {
    final response = await _apiService.get("${AudioEndpoints.completedFiles}");
    if (response.success) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => AudioEntity.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load audio files for subfolder: ');
    }
  }

  @override
  Future<AudioTranscription> getAudioTranscriptionByGuid(String guid) async {
    final response = await _apiService.get("${AudioEndpoints.getbyprocessedGuid}/$guid");
    if (response.success) {
      final Map<String, dynamic> data = json.decode(response.data);
      return AudioTranscription.fromJson(data);
    } else {
      throw Exception('Failed to load transcription for guid: $guid');
    }
  }
}




// import 'package:http/http.dart' as http;
// import 'package:test_widget/audio/data/model/api/model.dart';
// import 'package:test_widget/audio/domain/repository/audio_repository.dart';

// class AudioRepositoryImpl implements AudioRepository {
//   final http.Client client;

//   AudioRepositoryImpl(this.client);

//   @override
//   Future<List<String>> getAudioFolders() async {
//     await Future.delayed(Duration(seconds: 1));
//     return ['2025-04-20', '2025-04-21', '2025-04-22'];
//   }

//   @override
//   Future<List<AudioModel>> getAudioFilesByDate(String folderName) async {
//     await Future.delayed(Duration(milliseconds: 800));

//     final dummyData = [
//       {
//         "fileName": "audio1.mp3",
//         "fileUrl": "https://example.com/audio/$folderName/audio1.mp3",
//         "duration": 120,
//         "uploadedAt": "2025-04-21T10:00:00Z"
//       },
//       {
//         "fileName": "audio2.mp3",
//         "fileUrl": "https://example.com/audio/$folderName/audio2.mp3",
//         "duration": 95,
//         "uploadedAt": "2025-04-21T11:00:00Z"
//       }
//     ];

//     return dummyData.map((item) => AudioModel.fromJson(item)).toList();
//   }
// }

