

  import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:test_widget/audio/data/entity/audio_entity.dart';
import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';


Future<List<AudioEntity>> getAudioFilesBySubFolder() async {
    print("+++++++++++__________");
  try {
      print("+++++++++++====================");
    final response = await http.get(Uri.parse('http://localhost:58508/api/FileExplorer/completed-files'));
   print("++++++++++++++++++++++++++++++");
   print(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Transform the response into a list of AudioEntity objects
      print(response.body);
      return data.map((e) => AudioEntity.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load audio files. Status code: ${response.statusCode}');
    }
  } catch (e) {
    if (e is http.ClientException) {
      print("Caught a ClientException: ${e.message}");
    } else if (e is FormatException) {
      print("Caught a FormatException: Invalid response format.");
    } else {
      print("Error fetching audio files: $e");
    }
    return [];
  }
}



Future<AudioTranscription?> getAudioTranscriptionByGuidDemo(String guid) async {
  final uri = Uri.parse("http://localhost:58508/api/FileExplorer/GetByProcessedGuid/$guid");
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return AudioTranscription.fromJson(data);
  } else {
    print("Failed to fetch transcription. Status: ${response.statusCode}");
    return null;
  }
}


class AudioDownloader {
  Future<String?> downloadAudio(String guid, String fileName) async {
  final url = Uri.parse('http://localhost:58508/api/FileExplorer/DownloadAudio/$guid');
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/assets/audio');
      if (!(await audioDir.exists())) {
        await audioDir.create(recursive: true);
      }

      final filePath = '${audioDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      debugPrint('Audio downloaded to: $filePath');
      return filePath;
    } else {
      debugPrint('Failed to download audio. Status code: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error downloading audio: $e');
  }

  return null;
}

}


Future<void> downloadAndAssignPath(AudioFile originalFile) async {
  final downloader = AudioDownloader();
  final downloadedPath = await downloader.downloadAudio(originalFile.guid, originalFile.fileName);

  if (downloadedPath != null) {
    final updatedFile = originalFile.copyWith(folderPath: downloadedPath);

    debugPrint('Updated file path: ${updatedFile.folderPath}');
  }
}


Future<List<AudioFile>> downloadAndUpdateFilePaths(List<AudioFile> files) async {
  final downloader = AudioDownloader();
  List<AudioFile> updatedFiles = [];

  for (final file in files) {
    final path = await downloader.downloadAudio(file.guid, file.fileName);
    if (path != null) {
      updatedFiles.add(file.copyWith(folderPath: path));
    } else {
      updatedFiles.add(file); 
    }
  }

  return updatedFiles;
}





// import 'package:test_widget/audio/data/entity/audio_entity.dart';
// import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';

// Future<List<AudioEntity>> getAudioFilesBySubFolder() async {
//   await Future.delayed(const Duration(milliseconds: 300));

//   return [
//     AudioEntity(
//       name: "Meeting Recordings",
//       path: "/audio/meetings",
//       type: "folder",
//       subFolders: [],
//       files: [
//         AudioFile(
//           guid: "001",
//           fileName: "meeting_01.mp3",
//           transcription: "Hello, this is the first meeting.",
//           folderPath: "/audio/meetings",
//           receivedAt: DateTime.now().subtract(const Duration(days: 1)),
//           convertedAt: DateTime.now(),
//         ),
//       ],
//       children: [],
//     ),
//     AudioEntity(
//       name: "Lectures",
//       path: "/audio/lectures",
//       type: "folder",
//       subFolders: [
//         AudioFolder(
//           name: "Physics Lectures",
//           path: "/audio/lectures/physics",
//           type: "folder",
//           files: [
//           AudioFile(
//           guid: "003",
//           fileName: "subfolder_audio_01.mp3",
//           transcription:
//               "General Hospital Discharge Creation and hospital details Question name John D. Data board...",
//           folderPath: "assets/iiii.mp3",
//           receivedAt: DateTime.now().subtract(const Duration(days: 1)),
//           convertedAt: DateTime.now(),
//         ),
//           ],
//         ),
//         AudioFolder(
//           name: "Chemistry Lectures",
//           path: "/audio/lectures/chemistry",
//           type: "folder",
//           files: [
//               AudioFile(
//           guid: "004",
//           fileName: "subfolder_audio_02.mp3",
//           transcription:
//               "Treatment Certificate of Mrs. Bindu KK, Hospital ID 6266666...",
//           folderPath: "assets/1_11314.wav",
//           receivedAt: DateTime.now().subtract(const Duration(days: 3)),
//           convertedAt: DateTime.now().subtract(const Duration(days: 1)),
//         ),
//              AudioFile(
//           guid: "005",
//           fileName: "subfolder_audio_05.mp3",
//           transcription: "Second audio transcription.",
//           folderPath: "assets/tt.mp3",
//           receivedAt: DateTime.now().subtract(const Duration(days: 3)),
//           convertedAt: DateTime.now().subtract(const Duration(days: 1)),
//         ),
//           ],
//         ),
//       ],
//       files: [],
//       children: [],
//     ),
//   ];
// }







// Future<AudioTranscription> getAudioTranscriptionByGuidDemo(guid) async {
//   await Future.delayed(const Duration(milliseconds: 300));

//   return AudioTranscription(
//     guid: "fguid",
//     fileName: "Bindu_KK_Treatment.mp3",
//     receivedAt: DateTime.parse("2025-04-22T16:17:25.564035Z"),
//     convertedAt: DateTime.parse("2025-04-22T16:18:18.669669Z"),
//     transcription: "Treatment Certificate of Mrs. Bindu KK, Hospital ID 6266666. "
//         "Mrs. to certify that, Mrs. Bindu KK, 49-year-old lady with Hospital ID 6266666, "
//         "is a case of castor my left breast, locally advanced. "
//         "She is on ERPR negative and ERPR positive and HER2 new 3+. "
//         "She is on neurogenic chemotherapy with TCH, that is docetaxel carboplatin with trastasmab. "
//         "She is planned for surgery after six cycles. And radiation. "
//         "He is planned for adjuvant trastasmab for a total of one year. "
//         "The estimated treatment cost is approximately 9 to 10 lakhs. "
//         "Kindly do the needful. Thank you. Thank you.",
//     folderPath: "G:\\dotnet learning\\AudioToText\\AudioToText.API\\Audio\\completed\\Bindu_KK_Treatment.mp3",
//     type: null,
//     status: "Completed",
//     srtSegments: [
//       TranscriptionSegment(
//         startTime: "00:00:00",
//         endTime: "00:00:08",
//         transcriptText: "Treatment Certificate of Mrs. Bindu KK, Hospital ID 6266666.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:00:09",
//         endTime: "00:00:18",
//         transcriptText: "Mrs. to certify that, Mrs. Bindu KK, 49-year-old lady with Hospital ID 6266666,",
//       ),
//       TranscriptionSegment(
//         startTime: "00:00:19",
//         endTime: "00:00:23",
//         transcriptText: "is a case of castor my left breast, locally advanced.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:00:23",
//         endTime: "00:00:41",
//         transcriptText: "She is on ERPR negative and ERPR positive and HER2 new 3+.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:00:41",
//         endTime: "00:00:49",
//         transcriptText: "She is on neurogenic chemotherapy with TCH, that is docetaxel carboplatin with trastasmab.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:00:49",
//         endTime: "00:00:53",
//         transcriptText: "She is planned for surgery after six cycles.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:00:53",
//         endTime: "00:00:55",
//         transcriptText: "And radiation.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:00:56",
//         endTime: "00:01:02",
//         transcriptText: "He is planned for adjuvant trastasmab for a total of one year.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:01:03",
//         endTime: "00:01:09",
//         transcriptText: "The estimated treatment cost is approximately 9 to 10 lakhs.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:01:09",
//         endTime: "00:01:10",
//         transcriptText: "Kindly do the needful.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:01:11",
//         endTime: "00:01:11",
//         transcriptText: "Thank you.",
//       ),
//       TranscriptionSegment(
//         startTime: "00:01:11",
//         endTime: "00:01:13",
//         transcriptText: "Thank you.",
//       ),
//     ],
//   );
// }


