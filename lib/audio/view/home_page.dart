
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_widget/audio/controller/cubit/audio_cubit.dart';
import 'package:test_widget/audio/controller/cubit/audio_cubit_state.dart';
import 'package:test_widget/audio/view/audio_info.dart';

class FileExploreScreen extends StatefulWidget {
  const FileExploreScreen({super.key});

  @override
  State<FileExploreScreen> createState() => _FileExploreScreenState();
}

class _FileExploreScreenState extends State<FileExploreScreen> {
  late final AudioCubit _audioCubit;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _audioCubit = AudioCubit()..fetchAudioFolders();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _audioCubit.fetchAudioFolders();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AudioCubit>.value(
      value: _audioCubit,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: BlocBuilder<AudioCubit, AudioCubitState>(
          builder: (context, state) {
            final cubit = context.read<AudioCubit>();
            return Row(
              children: [
                // Left side folder navigation
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
                        onTap: () => cubit.toggleMainFolder(state.audioEntityName),
                        child: Row(
                          children: [
                            Icon(
                              state.expandedFolder == state.audioEntityName
                                  ? Icons.folder_open
                                  : Icons.folder,
                              color: Colors.amber,
                              
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.audioEntityName ?? "Folder",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (state.expandedFolder == state.audioEntityName)
                        ...state.audioFolders.map(
                          (subFolder) => GestureDetector(
                            onTap: () => cubit.selectSubFolder(subFolder),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30.0, bottom: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    state.selectedSubFolder == subFolder.name
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

                // Right side content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: state.isLoading && state.audioFiles.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : state.audioFiles.isEmpty
                            ? const Center(child: Text("No audio files found"))
                            : ListView.builder(
                                itemCount: state.audioFiles.length,
                                itemBuilder: (context, index) {
                                  final audio = state.audioFiles[index];
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
                                            Icon(Icons.audio_file,
                                                size: 40, color: Colors.grey[700]),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                        fontSize: 14, color: Colors.grey[700]),
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
                                                    "Received at: ${audio.receiveddAt}",
                                                    style: const TextStyle(
                                                        fontSize: 12, color: Colors.grey)),
                                                const SizedBox(height: 4),
                                                Text(
                                                    "Converted at: ${audio.convertedAt}",
                                                    style: const TextStyle(
                                                        fontSize: 12, color: Colors.grey)),
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
            );
          },
        ),
      ),
    );
  }
}