import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_widget/audio/controller/services.dart';
import 'package:test_widget/audio/model/api/audio_entity.dart';
import 'package:test_widget/audio/view/audio_info.dart';

class FileExploreScreen extends StatefulWidget {
  const FileExploreScreen({super.key});

  @override
  State<FileExploreScreen> createState() => _FileExploreScreenState();
}

class _FileExploreScreenState extends State<FileExploreScreen> {
  bool loadingAudio = false;
  List<AudioFolder> audioFolders = [];
  List<AudioFile> audioFiles = [];
  Timer? _audioFetchTimer;

  String? expandedFolder;
  String? selectedSubFolderName;
  String? audioEntityName;

  @override
  void initState() {
    super.initState();
    fetchAudioFolders();
    _audioFetchTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchAudioFolders();
    });
  }
  Future<void> fetchAudioFolders() async {
    setState(() => loadingAudio = true);
    try {
      final entities = await getAudioFilesBySubFolder();

      if (entities.isNotEmpty) {
        final mainEntity = entities.first;
        setState(() {
          audioEntityName = mainEntity.name;
          audioFolders = mainEntity.subFolders;
          loadingAudio = false;
        });
      } else {
        setState(() {
          audioFolders = [];
          loadingAudio = false;
        });
      }
    } catch (e) {
      setState(() => loadingAudio = false);
      debugPrint("Error fetching audio folders: $e");
    }
  }
  void onFolderTap(AudioFolder folder) {
    setState(() {
      selectedSubFolderName = folder.name;
      audioFiles =
          folder.files; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
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
                      if (expandedFolder == audioEntityName) {
                        expandedFolder = null;
                        audioFiles.clear();
                        selectedSubFolderName = null;
                      } else {
                        expandedFolder = audioEntityName;
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        expandedFolder == audioEntityName
                            ? Icons.folder_open
                            : Icons.folder,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        audioEntityName ?? "Folder",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                if (expandedFolder == audioEntityName)
                  ...audioFolders.map(
                    (subFolder) => GestureDetector(
                      onTap: () => onFolderTap(subFolder),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              selectedSubFolderName == subFolder.name
                                  ? Icons.folder_open
                                  : Icons.folder,
                              color: Colors.amber,
                            ),
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

          // Content Area to display the audio files
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  loadingAudio
                      ? const Center(child: CircularProgressIndicator())
                      : audioFiles.isEmpty
                      ? const Center(child: Text("No audio files found"))
                      : ListView.builder(
                        itemCount: audioFiles.length,
                        itemBuilder: (context, index) {
                          final audio = audioFiles[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AudioInfo(audioFile: audio),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Received at: ${audio.receiveddAt}",
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
