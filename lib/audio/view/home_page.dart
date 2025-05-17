import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:test_widget/audio/controller/cubit/audio_cubit.dart';
import 'package:test_widget/audio/controller/cubit/audio_cubit_state.dart';
import 'package:test_widget/audio/model/api/audio_entity.dart';
import 'package:test_widget/audio/view/audio_info.dart';

class FileExploreScreen extends StatefulWidget {
  const FileExploreScreen({super.key});

  @override
  State<FileExploreScreen> createState() => _FileExploreScreenState();
}

class _FileExploreScreenState extends State<FileExploreScreen> {
  late final AudioCubit _audioCubit;
  Timer? _timer;
  bool _isDrawerOpen = false;

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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 900;

    return BlocProvider<AudioCubit>.value(
      value: _audioCubit,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar:
            isMobile || isTablet
                ? AppBar(
                  title: const Text('File Explorer'),
                  leading: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => setState(() => _isDrawerOpen = true),
                  ),
                )
                : null,
        drawer:
            (isMobile || isTablet) && _isDrawerOpen
                ? _buildSidePanel(context, isMobile)
                : null,
        body: BlocBuilder<AudioCubit, AudioCubitState>(
          builder: (context, state) {
            final cubit = context.read<AudioCubit>();

            return Row(
              children: [
                // Side panel for desktop
                if (!isMobile && !isTablet) _buildSidePanel(context, isMobile),

                // Main content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 8.0 : 20.0),
                    child:
                        state.isLoading && state.audioFiles.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : state.audioFiles.isEmpty
                            ? const Center(child: Text("No audio files found"))
                            : AudioListComponent(audioFiles: state.audioFiles),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, bool isMobile) {
    final state = context.read<AudioCubit>().state;
    final cubit = context.read<AudioCubit>();

    return SizedBox(
      width: isMobile ? MediaQuery.of(context).size.width * 0.8 : 250,
      child: Drawer(
        child: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 20 : 40,
            horizontal: isMobile ? 10 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _isDrawerOpen = false),
                    ),
                    const Text(
                      "FILE EXPLORER",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  "FILE EXPLORER",
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
                    Flexible(
                      child: Text(
                        state.audioEntityName ?? "Folder",
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              if (state.expandedFolder == state.audioEntityName)
                ...state.audioFolders.map(
                  (subFolder) => GestureDetector(
                    onTap: () {
                      cubit.selectSubFolder(subFolder);
                      if (isMobile) {
                        setState(() => _isDrawerOpen = false);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: isMobile ? 20.0 : 30.0,
                        bottom: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.selectedSubFolder == subFolder.name
                                ? Icons.folder_open
                                : Icons.folder,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              subFolder.name,
                              style: const TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AudioListComponent extends StatefulWidget {
  const AudioListComponent({super.key, required this.audioFiles});

  final List<AudioFile> audioFiles;

  @override
  State<AudioListComponent> createState() => _AudioListComponentState();
}

class _AudioListComponentState extends State<AudioListComponent> {
  late List<AudioFile> sortedAudioFiles;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAscending = false;

  @override
  void initState() {
    super.initState();
    _sortAudioFiles();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  void _sortAudioFiles() {
    sortedAudioFiles = [...widget.audioFiles];
    sortedAudioFiles.sort(
      (a, b) =>
          _isAscending
              ? a.convertedAt.compareTo(b.convertedAt)
              : b.convertedAt.compareTo(a.convertedAt),
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _sortAudioFiles();
    });
  }

  List<AudioFile> get _filteredAudioFiles {
    if (_searchQuery.isEmpty) return sortedAudioFiles;
    return sortedAudioFiles.where((audio) {
      return audio.fileName.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 900;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by file name...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextButton.icon(
              onPressed: _toggleSortOrder,
              icon: Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
              ),
              label: const Text("Sort by Created At"),
            ),
          ),
        ),
        Expanded(
          child:
              _filteredAudioFiles.isEmpty
                  ? Center(child: Text("No audio files found."))
                  : ListView.builder(
                    itemCount: _filteredAudioFiles.length,
                    itemBuilder: (context, index) {
                      final audio = _filteredAudioFiles[index];
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
                          padding: EdgeInsets.only(
                            bottom: isMobile ? 10.0 : 20.0,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(isMobile ? 12 : 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.audio_file,
                                  size: isMobile ? 30 : 40,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: isMobile ? 12 : 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        audio.fileName,
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: isMobile ? 4 : 8),
                                      Text(
                                        audio.transcription.isNotEmpty
                                            ? audio.transcription
                                            : "No transcription available",
                                        style: TextStyle(
                                          fontSize: isMobile ? 12 : 14,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: isMobile ? 2 : 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isMobile) ...[
                                  SizedBox(width: isTablet ? 8 : 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Received: ${DateFormat('dd/MM/yyyy hh:mm:ss a').format(audio.receiveddAt.toLocal())}",
                                        style: TextStyle(
                                          fontSize: isTablet ? 10 : 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 2 : 4),
                                      Text(
                                        "Converted: ${DateFormat('dd/MM/yyyy hh:mm:ss a').format(audio.convertedAt.toLocal())}",
                                        style: TextStyle(
                                          fontSize: isTablet ? 10 : 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
