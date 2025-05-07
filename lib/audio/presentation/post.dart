// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart';

// class AudioUploadPage extends StatefulWidget {
//   @override
//   _AudioUploadPageState createState() => _AudioUploadPageState();
// }

// class _AudioUploadPageState extends State<AudioUploadPage> {
//   String? _response;
//   bool _loading = false;

//   Future<void> uploadAudioFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['mp3', 'wav', 'mpeg'],
//     );

//     if (result == null) return;

//     File file = File(result.files.single.path!);
//     String fileName = basename(file.path);

//     var uri = Uri.parse('http://localhost:5259/api/Audio/upload');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['CallbackUrl'] = 'asd'
//       ..files.add(await http.MultipartFile.fromPath(
//         'File',
//         file.path,
//         contentType: MediaType('audio', 'mpeg'),
//         filename: fileName,
//       ));

//     setState(() => _loading = true);

//     try {
//       var response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       setState(() {
//         _response = responseBody;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _response = 'Error: $e';
//         _loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Audio Upload')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _loading ? null : uploadAudioFile,
//                 child: _loading
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text('Upload Audio'),
//               ),
//               SizedBox(height: 20),
//               Text(_response ?? 'Upload response will appear here'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
