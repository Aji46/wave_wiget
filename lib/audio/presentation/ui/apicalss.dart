// import 'dart:convert';

// import 'package:http/http.dart' as _apiService;
// import 'package:test_widget/audio/data/entity/audio_entity.dart';
// import 'package:test_widget/audio/data/entity/audio_file_entity.dart';
// import 'package:test_widget/audio/data/entity/sub_folder_entity.dart';

// Future<List<AudioEntity>> getAudioFolders() async {
//   final uri = Uri.parse("http://localhost:5229/api/Audio/all"); 
//   final response = await _apiService.get(uri);

//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(response.body);
//     return data.map((e) => AudioEntity.fromJson(e)).toList();
//   } else {
//     throw Exception('Failed to load audio folders: ${response.statusCode}');
//   }
// }


  import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test_widget/audio/data/entity/audio_entity.dart';
import 'package:test_widget/audio/data/entity/tanscriptionSegment.dart';
import 'package:test_widget/core/network/service/api_service.dart';

  late final IApiService _apiService;


  Future<List<AudioEntity>> getAudioFilesBySubFolder() async {
  try {
  final response = await http.get(Uri.parse('http://127.0.0.1:5259/api/FileExplorer/completed-files'));

    if (response.statusCode == 200) {

      
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => AudioEntity.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load audio files. Status code: ${response.statusCode}');
    }
  } catch (e) {
  if (e is http.ClientException) {
    print("Caught a ClientException: ${e.message}");
  } 
    print('Error fetching audio files: $e');
    return []; // return an empty list or rethrow the exception depending on your use case
  }
}


Future<AudioTranscription?> getAudioTranscriptionByGuidDemo(String guid) async {
  final uri = Uri.parse("http://localhost:5259/api/FileExplorer/transcription/$guid");
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return AudioTranscription.fromJson(data);
  } else {
    print("Failed to fetch transcription. Status: ${response.statusCode}");
    return null;
  }
}



// import 'package:test_widget/audio/data/entity/audio_file_entity.dart';
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
//     ),
//     AudioEntity(
//       name: "Lectures",
//       path: "/audio/lectures",
//       type: "folder",
//       subFolders: [],
//       files: [],
//     ),
//     AudioEntity(
//       name: "Subfolder Audios",
//       path: "/audio/subfolder",
//       type: "folder",
//       subFolders: [],
//       files: [
//         AudioFile(
//           guid: "003",
//           fileName: "subfolder_audio_01.mp3",
//           transcription:
//               "General Hospital Discharge Creation and hospital details Question name John D. Data board...",
//           folderPath: "assets/iiii.mp3",
//           receivedAt: DateTime.now().subtract(const Duration(days: 1)),
//           convertedAt: DateTime.now(),
//         ),
//         AudioFile(
//           guid: "004",
//           fileName: "subfolder_audio_02.mp3",
//           transcription:
//               "Treatment Certificate of Mrs. Bindu KK, Hospital ID 6266666...",
//           folderPath: "assets/1_11314.wav",
//           receivedAt: DateTime.now().subtract(const Duration(days: 3)),
//           convertedAt: DateTime.now().subtract(const Duration(days: 1)),
//         ),
//         AudioFile(
//           guid: "005",
//           fileName: "subfolder_audio_05.mp3",
//           transcription: "Second audio transcription.",
//           folderPath: "assets/tt.mp3",
//           receivedAt: DateTime.now().subtract(const Duration(days: 3)),
//           convertedAt: DateTime.now().subtract(const Duration(days: 1)),
//         ),
//       ],
//     ),
//   ];
// }


// Future<List<SubFolderEntity>> getSubFoldersByFolderName() async {
//   await Future.delayed(const Duration(milliseconds: 300));

//   return [
//     SubFolderEntity(
//       name: "Jan_2024",
//       path: "/audio/lectures/Jan_2024",
//       type: "folder",
//       files: [
//         AudioFileEntity(
//           guid: "002",
//           fileName: "lecture_01.mp3",
//           transcription: "Lecture on Flutter architecture.",
//           folderPath: "/audio/lectures/Jan_2024",
//           receivedAt: DateTime.now().subtract(const Duration(days: 2)),
//           convertedAt: DateTime.now(),
//           type: "audio/mpeg",
//         ),
//              AudioFileEntity(
//           guid: "003",
//           fileName: "lecture_01.mp3",
//           transcription: "Lecture on Flutter architecture.",
//           folderPath: "/audio/lectures/Jan_2024",
//           receivedAt: DateTime.now().subtract(const Duration(days: 2)),
//           convertedAt: DateTime.now(),
//           type: "audio/mpeg",
//         ),
//       ],
//     ),
//         SubFolderEntity(
//       name: "march_2024",
//       path: "/audio/lectures/Jan_2024",
//       type: "folder",
//       files: [
//         AudioFileEntity(
//           guid: "002",
//           fileName: "lecture_01.mp3",
//           transcription: "Lecture on Flutter architecture.",
//           folderPath: "/audio/lectures/Jan_2024",
//           receivedAt: DateTime.now().subtract(const Duration(days: 2)),
//           convertedAt: DateTime.now(),
//           type: "audio/mpeg",
//         ),
//              AudioFileEntity(
//           guid: "003",
//           fileName: "lecture_01.mp3",
//           transcription: "Lecture on Flutter architecture.",
//           folderPath: "/audio/lectures/Jan_2024",
//           receivedAt: DateTime.now().subtract(const Duration(days: 2)),
//           convertedAt: DateTime.now(),
//           type: "audio/mpeg",
//         ),
//       ],
//     ),
//   ];
// }

// // Future<List<AudioFileEntity>> getAudioFilesBySubFolder() async {
// //   await Future.delayed(const Duration(milliseconds: 300));

// //   return [
// //     AudioFileEntity(
// //       guid: "003",
// //       fileName: "subfolder_audio_01.mp3",
// //       transcription: "Subfolder audio transcription.",
// //       folderPath: "C:/Users/AJI/Downloads/audio/ll.mp3",
// //       receivedAt: DateTime.now().subtract(const Duration(days: 1)),
// //       convertedAt: DateTime.now(),
// //       type: "audio/mpeg",
// //     ),
// //     AudioFileEntity(
// //       guid: "004",
// //       fileName: "subfolder_audio_02.mp3",
// //       transcription: "Second audio transcription.",
// //       folderPath: "/audio/lectures/Jan_2024",
// //       receivedAt: DateTime.now().subtract(const Duration(days: 3)),
// //       convertedAt: DateTime.now().subtract(const Duration(days: 1)),
// //       type: "audio/mpeg",
// //     ),
// //   ];
// // }




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







// // Future<List<AudioFileEntity>> getAudioFolders() async {
// //   await Future.delayed(const Duration(milliseconds: 300));

// //   // Return the original list (no file‑picker logic)
// //   return [
// //     AudioFileEntity(
// //       guid: "003",
// //       fileName: "subfolder_audio_01.mp3",
// //       transcription: "General Hospital Discharge Creation and hospital details Question name John D. Data board 12th June 1952, 73 years old Medical record number NRM 123456 Date of admission time January 2025 Date of discharge 15th January 2025 Hospital name and what City General Hospital Hospitality Unit Attending physician Dr. James Patterson Primary care provider Dr. Sara Mitchell and Dr. Edward Saad family, clinic Diagnosis and clinical purpose Admission diagnosis Community acute pneumonia requirin oxygen therapy Discharge diagnosis Resorder pneumonia in good oxygen on home air Secondary diagnosisHypertension Type 2 Diabetics Traumatic picnic disease stage 3 Hospital and stage summary Consultation Infectious disease for antibiotic selection and duration guidance Polymerally for persistent hypoxia and weaning procedure Procedure number History of person illness 70 years old male person with worsening dyspnea productive cough and fever Just extra shower, night, lower blood, consolidation consistent with pneumonia Embryic treatment started with IV, Cif-Triaxone and Aziromazole Required supplement of oxygen at 2 LNC Brief hospital close",
// //       folderPath: "assets/iiii.mp3",
// //       receivedAt: DateTime.now().subtract(const Duration(days: 1)),
// //       convertedAt: DateTime.now(),
// //       type: "audio/mpeg",
// //     ),
// //     AudioFileEntity(
// //       guid: "004",
// //       fileName: "assets/1_11314.wav",
// //       transcription: "Second audio transcription.",
// //       folderPath: "assets/1_11314.wav",
// //       receivedAt: DateTime.now().subtract(const Duration(days: 3)),
// //       convertedAt: DateTime.now().subtract(const Duration(days: 1)),
// //       type: "audio/mpeg",
      
// //     ),
// //      AudioFileEntity(
// //       guid: "005",
// //       fileName: "subfolder_audio_05.mp3",
// //       transcription: "Second audio transcription.",
// //       folderPath: "assets/tt.mp3",
// //       receivedAt: DateTime.now().subtract(const Duration(days: 3)),
// //       convertedAt: DateTime.now().subtract(const Duration(days: 1)),
// //       type: "audio/mpeg",
// //     ),
// //   ];
// // }



// Future<List<AudioFileEntity>> getAudioFilesBySubFolder() async {
//   await Future.delayed(const Duration(milliseconds: 300));

//   // Return the original list (no file‑picker logic)
//   return [
//     AudioFileEntity(
//       guid: "003",
//       fileName: "subfolder_audio_01.mp3",
//       transcription: "General Hospital Discharge Creation and hospital details Question name John D. Data board 12th June 1952, 73 years old Medical record number NRM 123456 Date of admission time January 2025 Date of discharge 15th January 2025 Hospital name and what City General Hospital Hospitality Unit Attending physician Dr. James Patterson Primary care provider Dr. Sara Mitchell and Dr. Edward Saad family, clinic Diagnosis and clinical purpose Admission diagnosis Community acute pneumonia requirin oxygen therapy Discharge diagnosis Resorder pneumonia in good oxygen on home air Secondary diagnosisHypertension Type 2 Diabetics Traumatic picnic disease stage 3 Hospital and stage summary Consultation Infectious disease for antibiotic selection and duration guidance Polymerally for persistent hypoxia and weaning procedure Procedure number History of person illness 70 years old male person with worsening dyspnea productive cough and fever Just extra shower, night, lower blood, consolidation consistent with pneumonia Embryic treatment started with IV, Cif-Triaxone and Aziromazole Required supplement of oxygen at 2 LNC Brief hospital close",
//       folderPath: "assets/iiii.mp3",
//       receivedAt: DateTime.now().subtract(const Duration(days: 1)),
//       convertedAt: DateTime.now(),
//       type: "audio/mpeg",
//     ),
//     AudioFileEntity(
//       guid: "004",
//       fileName: "subfolder_audio_02.mp3",
//       transcription: "Treatment Certificate of Mrs. Bindu KK, Hospital ID 6266666. "
//         "Mrs. to certify that, Mrs. Bindu KK, 49-year-old lady with Hospital ID 6266666, "
//         "is a case of castor my left breast, locally advanced. "
//         "She is on ERPR negative and ERPR positive and HER2 new 3+. "
//         "She is on neurogenic chemotherapy with TCH, that is docetaxel carboplatin with trastasmab. "
//         "She is planned for surgery after six cycles. And radiation. "
//         "He is planned for adjuvant trastasmab for a total of one year. "
//         "The estimated treatment cost is approximately 9 to 10 lakhs. "
//         "Kindly do the needful. Thank you. Thank you.",
//       folderPath: "assets/1_11314.wav",
//       receivedAt: DateTime.now().subtract(const Duration(days: 3)),
//       convertedAt: DateTime.now().subtract(const Duration(days: 1)),
//       type: "audio/mpeg",
      
//     ),
//      AudioFileEntity(
//       guid: "005",
//       fileName: "subfolder_audio_05.mp3",
//       transcription: "Second audio transcription.",
//       folderPath: "assets/tt.mp3",
//       receivedAt: DateTime.now().subtract(const Duration(days: 3)),
//       convertedAt: DateTime.now().subtract(const Duration(days: 1)),
//       type: "audio/mpeg",
//     ),
//   ];
// }


