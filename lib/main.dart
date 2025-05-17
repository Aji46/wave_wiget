import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_widget/audio/controller/cubit/audio_cubit.dart';
import 'package:test_widget/audio/view/home_page.dart';
import 'package:test_widget/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.loadConfig(); // Wait for config
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create:
            (_) =>
                AudioCubit()
                  ..fetchAudioFolders(), // Initialize cubit and fetch data
        child: const FileExploreScreen(), // Your home screen
      ),
    );
  }
}
