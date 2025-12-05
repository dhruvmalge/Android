import 'package:flutter/material.dart';
import 'package:music_streaming/pages/music_stream.dart';

void main() {
  runApp(MusicStreamingApp());
}

class MusicStreamingApp extends StatelessWidget {
  const MusicStreamingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saatvik Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
        hintColor: Colors.tealAccent,
        textTheme: const TextTheme(
          titleMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const SongListScreen(),
    );
  }
}
