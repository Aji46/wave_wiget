// import 'package:flutter/material.dart';
// import 'package:test_widget/audio/data/entity/audio_entity.dart';
// import 'package:test_widget/audio/presentation/ui/apicalss.dart';
// import 'package:test_widget/audio/presentation/ui/audio_info.dart';

// class FileExploreScreen extends StatefulWidget {
//   const FileExploreScreen({super.key});

//   @override
//   State<FileExploreScreen> createState() => _FileExploreScreenState();
// }

// class _FileExploreScreenState extends State<FileExploreScreen> {
//   bool loadingAudio = false;
//   List<AudioEntity> subFolders = [];
//   List<AudioFile> audioFiles = [];

//   String? expandedFolder;

//   @override
//   void initState() {
//     super.initState();
//     // fetchSubFolders();
//     fetchAudioFiles();
//   }

//   // Future<void> fetchSubFolders() async {
//   //   setState(() => loadingAudio = true);
//   //   try {
//   //     final folders = await getSubFoldersByFolderName();
//   //     setState(() {
//   //       subFolders = folders;
//   //       loadingAudio = false;
//   //     });
//   //   } catch (e) {
//   //     setState(() => loadingAudio = false);
//   //     debugPrint("Error fetching subfolders: $e");
//   //   }
//   // }

//  Future<void> fetchAudioFiles() async {
//   setState(() => loadingAudio = true);
//   try {
//     final files = await getAudioFilesBySubFolder();
//     setState(() {
//       // Assuming files is a List<AudioEntity> and we need to get the AudioFile list from each entity
//       audioFiles = files.expand((entity) => entity.files).toList(); // Flattening and adding all files from each AudioEntity
//       loadingAudio = false;
//     });
//   } catch (e) {
//     setState(() => loadingAudio = false);
//     debugPrint("Error fetching audio files: $e");
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Row(
//         children: [
//           // Sidebar
//           Container(
//             width: 250,
//             color: Colors.grey[200],
//             padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "FILE EXPLORE",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 30),
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       if (expandedFolder == "Audio") {
//                         expandedFolder = null;
//                         audioFiles.clear();
//                       } else {
//                         expandedFolder = "Audio";
//                         fetchAudioFiles();
//                       }
//                     });
//                   },
//                   child: Row(
//                     children: [
//                       Icon(
//                         expandedFolder == "Audio"
//                             ? Icons.folder_open
//                             : Icons.folder,
//                         color: Colors.amber,
//                       ),
//                       const SizedBox(width: 8),
//                       const Text("Audio", style: TextStyle(fontSize: 16)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 if (expandedFolder == "Audio")
//                   ...subFolders.map(
//                     (subFolder) => GestureDetector(
//                       onTap:
//                           fetchAudioFiles, // Ideally should pass subfolder info if needed
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 30.0, bottom: 10),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.folder, color: Colors.amber),
//                             const SizedBox(width: 8),
//                             Text(
//                               subFolder.name,
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // Content Area
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child:
//                   loadingAudio
//                       ? const Center(child: CircularProgressIndicator())
//                       : ListView.builder(
//                         itemCount: audioFiles.length,
//                         itemBuilder: (context, index) {
//                           final audio = audioFiles[index];
//                           return GestureDetector(
//                             onTap: () {
//                               // Navigator.push(
//                               //   context,
//                               //   MaterialPageRoute(
//                               //     builder: (_) => FileItem(filename: audio.fileName, receivedTime: audio.receivedAt, convertedTime: audio.convertedAt, transcriptText: audio.transcription,),
//                               //   ),
//                               // );

//                               // Example usage: in your previous page

//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (_) => 
//                                       AudioInfo(
//                                         audioFile: AudioFile(
//                                           guid: audio.guid,
//                                           fileName: audio.fileName,
//                                           receivedAt: audio.receivedAt,
//                                           convertedAt: audio.convertedAt,
//                                           transcription: audio.transcription,
//                                           folderPath: audio.folderPath,
                                         
//                                         ),
//                                       ),
//                                       //          AudioInfo(
//                                       //   audioFile: AudioTranscription(
//                                       //     guid: audio.guid,
//                                       //     fileName: audio.fileName,
//                                       //     receivedAt: audio.receivedAt,
//                                       //     convertedAt: audio.convertedAt,
//                                       //     transcription: audio.transcription,
//                                       //     folderPath: audio.folderPath,
//                                       //     type: audio.type, status: '', srtSegments: [],
//                                       //   ),
//                                       // ),
//                                 ),
//                               );
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.only(bottom: 20.0),
//                               child: Container(
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(
//                                     color: Colors.grey.shade300,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Icon(
//                                       Icons.audio_file,
//                                       size: 40,
//                                       color: Colors.grey[700],
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             audio.fileName,
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             audio.transcription.isNotEmpty
//                                                 ? audio.transcription
//                                                 : "No transcription available",
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey[700],
//                                             ),
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           "Received at : ${audio.receivedAt}",
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           "Converted at : ${audio.convertedAt}",
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:test_widget/audio/data/entity/audio_entity.dart';
import 'package:test_widget/audio/presentation/ui/apicalss.dart';
import 'package:test_widget/audio/presentation/ui/audio_info.dart';

class FileExploreScreen extends StatefulWidget {
  const FileExploreScreen({super.key});

  @override
  State<FileExploreScreen> createState() => _FileExploreScreenState();
}

class _FileExploreScreenState extends State<FileExploreScreen> {
  bool loadingAudio = false;
  List<AudioEntity> subFolders = [];
  List<AudioFile> audioFiles = [];

  String? expandedFolder;

  @override
  void initState() {
    super.initState();
    fetchAudioFiles();
  }

  Future<void> fetchAudioFiles() async {
    setState(() => loadingAudio = true);
    try {
      // Simulate fetching the AudioEntity list (replace with your actual fetch logic)
      final files = await getAudioFilesBySubFolder();
      setState(() {
        // Flatten the list of AudioEntity objects and extract the AudioFile objects
        audioFiles = files.expand((entity) => entity.files).toList();
        loadingAudio = false;
      });
    } catch (e) {
      setState(() => loadingAudio = false);
      debugPrint("Error fetching audio files: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "FILE EXPLORE",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (expandedFolder == "Audio") {
                        expandedFolder = null;
                        audioFiles.clear();
                      } else {
                        expandedFolder = "Audio";
                        fetchAudioFiles();
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        expandedFolder == "Audio"
                            ? Icons.folder_open
                            : Icons.folder,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      const Text("Audio", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                if (expandedFolder == "Audio")
                  ...subFolders.map(
                    (subFolder) => GestureDetector(
                      onTap: fetchAudioFiles,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.folder, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              subFolder.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: loadingAudio
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: audioFiles.length,
                      itemBuilder: (context, index) {
                        final audio = audioFiles[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to audio info page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AudioInfo(
                                  audioFile: AudioFile(
                                    guid: audio.guid,
                                    fileName: audio.fileName,
                                    receivedAt: audio.receivedAt,
                                    convertedAt: audio.convertedAt,
                                    transcription: audio.transcription,
                                    folderPath: audio.folderPath,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.audio_file,
                                    size: 40,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          audio.fileName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          audio.transcription.isNotEmpty
                                              ? audio.transcription
                                              : "No transcription available",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Received at: ${audio.receivedAt}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Converted at: ${audio.convertedAt}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
