import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:music_streaming/controls/bottom_control.dart';
import '../category selection/category_selection.dart';
import '../controls/audio_quality.dart';
typedef PlaySongCallback = void Function(int songId);

class Song {
  final int id;
  final String title;
  final String artist;
  final List<String> tags;
  Song({required this.id, required this.title, required this.artist, required this.tags});
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int,
      title: json['title'] as String,
      artist: json['artist'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString().toLowerCase()).toList() ?? [],
    );
  }
}

class CategorySongsScreen extends StatefulWidget {
  final SongCategory category;
  final AudioPlayer sharedAudioPlayer;
  final int? currentlyPlayingId;
  final AudioQuality currentQuality;
  final PlaySongCallback playSongCallback;

  final Song? currentSong;
  final VoidCallback onSkipNext;
  final VoidCallback onSkipPrevious;

  const CategorySongsScreen({
    super.key,
    required this.category,
    required this.sharedAudioPlayer,
    required this.currentlyPlayingId,
    required this.currentQuality,
    required this.playSongCallback,
    required this.currentSong,
    required this.onSkipNext,
    required this.onSkipPrevious
  });

  @override
  State<CategorySongsScreen> createState() => _CategorySongsScreenState();
}

class _CategorySongsScreenState extends State<CategorySongsScreen> {
  final String _baseUrl = 'https://7937e4046971.ngrok-free.app';
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSongs(categoryId: widget.category.id);
  }

  Future<void> _fetchSongs({String categoryId = 'all'}) async {
    setState(() { _isLoading = true; });
    try {
      String url = '$_baseUrl/songs';
      if (categoryId != 'all') {
        url = '$url?category=$categoryId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> songJson = json.decode(response.body);
        setState(() {
          _songs = songJson.map((json) => Song.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching songs: $e");
      setState(() {
        _songs = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.currentSong;
    const defaultTitle = 'Not Playing';
    const defaultArtist = 'Select a song from the list';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.category.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      bottomNavigationBar: SimpleBottomControls(
        audioPlayer: widget.sharedAudioPlayer,
        currentSongTitle: song?.title ?? defaultTitle,
        currentSongArtist: song?.artist ?? defaultArtist,
        onSkipNext: widget.onSkipNext,
        onSkipPrevious: widget.onSkipPrevious,
      ),
      body: RefreshIndicator(
        color: Colors.tealAccent,
        onRefresh: () => _fetchSongs(categoryId: widget.category.id),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        )
            : _songs.isEmpty
            ? Center(
          child: Text(
            "No songs found for ${widget.category.label}.",
            style: TextStyle(color: Colors.white70.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
        )
            : ListView.builder(
          itemCount: _songs.length,
          itemBuilder: (context, index) {
            final song = _songs[index];
            final isCurrentSong = widget.currentlyPlayingId == song.id && widget.sharedAudioPlayer.playing;

            return ListTile(
              leading: Icon(
                isCurrentSong ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: isCurrentSong ? Colors.tealAccent : Colors.white,
              ),
              title: Text(song.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(song.artist, style: const TextStyle(color: Colors.white70)),
              onTap: () {
                widget.playSongCallback(song.id);
              },
            );
          },
        ),
      ),
    );
  }
}