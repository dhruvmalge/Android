import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:music_streaming/controls/bottom_control.dart';
import 'package:music_streaming/decorations/song_tiles.dart';
import 'package:music_streaming/controls/audio_quality.dart';
import 'package:music_streaming/category selection/category_selection.dart';
import 'package:music_streaming/pages/grid_view_page.dart';

class Song {
  final int id;
  final String title;
  final String artist;
  final List<String> tags;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.tags,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int,
      title: json['title'] as String,
      artist: json['artist'] as String,
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          [],
    );
  }
}

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final String _baseUrl = 'https://7937e4046971.ngrok-free.app';

  List<Song> _allSongs = [];
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingId;
  AudioQuality _currentQuality = AudioQuality.highQuality;

  String _searchQuery = '';
  SongCategory _selectedCategory = categories.first;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  List<Song> get _filteredSongs {
    List<Song> list = _allSongs;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list
          .where(
            (song) =>
                song.title.toLowerCase().contains(query) ||
                song.artist.toLowerCase().contains(query),
          )
          .toList();
    }

    return list;
  }

  Song? get _currentSong {
    if (_currentlyPlayingId == null) return null;
    return _allSongs.firstWhere(
      (song) => song.id == _currentlyPlayingId,
      orElse: () => Song(id: -1, title: 'Unknown', artist: 'Unknown', tags: []),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchSongs(categoryId: _selectedCategory.id);
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextSong();
      }
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _playNextSong() {
    if (_currentlyPlayingId == null || _filteredSongs.isEmpty) return;

    final currentSongIndex = _filteredSongs.indexWhere(
      (song) => song.id == _currentlyPlayingId,
    );
    final nextSongIndex = currentSongIndex + 1;

    if (nextSongIndex < _filteredSongs.length) {
      _playSong(_filteredSongs[nextSongIndex].id);
    } else {
      _audioPlayer.stop();
      setState(() => _currentlyPlayingId = null);
      _showErrorSnackBar("Playlist finished.", isError: false);
    }
  }

  void _playPreviousSong() {
    if (_currentlyPlayingId == null || _filteredSongs.isEmpty) return;

    final currentSongIndex = _filteredSongs.indexWhere(
      (song) => song.id == _currentlyPlayingId,
    );
    final previousSongIndex = currentSongIndex - 1;

    if (previousSongIndex >= 0) {
      _playSong(_filteredSongs[previousSongIndex].id);
    } else {
      _audioPlayer.stop();
      setState(() => _currentlyPlayingId = null);
      _showErrorSnackBar("Reached first song.", isError: false);
    }
  }

  Future<void> _fetchSongs({String categoryId = 'all'}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String url = '$_baseUrl/songs';
      if (categoryId != 'all') {
        url = '$url?category=$categoryId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> songJson = json.decode(response.body);
        setState(() {
          _allSongs = songJson.map((json) => Song.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar("Failed to connect to server or fetch category: $e");
      setState(() {
        _allSongs = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playSong(int songId) async {
    final qualityRate = _currentQuality.rate;
    final streamUrl = '$_baseUrl/stream/$songId?quality=$qualityRate';

    try {
      if (_currentlyPlayingId == songId && _audioPlayer.playing) {
        await _audioPlayer.pause();
        setState(() => _currentlyPlayingId = null);
      } else {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingId = songId;
        });
        await _audioPlayer.setUrl(streamUrl);
        await _audioPlayer.play();
      }
    } catch (e) {
      _showErrorSnackBar(
        "Error streaming song. File might be corrupted or missing.",
      );
      setState(() => _currentlyPlayingId = null);
    }
  }

  void _showErrorSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: 'Search by title or artist...',
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }

  void _toggleSearching() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _showCategoryGridFilter(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CategoryGrid(
          sharedAudioPlayer: _audioPlayer,
          currentlyPlayingId: _currentlyPlayingId,
          currentQuality: _currentQuality,
          playSongCallback: _playSong,
          currentSong: null,
          onSkipNext: _playNextSong,
          onSkipPrevious: _playPreviousSong,
        ),
      ),
    );

    setState(() {});

    if (result != null && result is SongCategory) {
      setState(() {
        _selectedCategory = result;
        _searchController.clear();
        _searchQuery = '';
      });

      _fetchSongs(categoryId: result.id);

      _showErrorSnackBar("Filter applied: ${result.label}", isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = _currentSong;
    const defaultTitle = 'Not Playing';
    const defaultArtist = 'Select a song from the list';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : Text(
                _selectedCategory.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          IconButton(
            icon: Icon(
              _selectedCategory.icon,
              color: _selectedCategory.id == 'all'
                  ? Colors.white
                  : Colors.tealAccent,
              size: 28,
            ),
            onPressed: () => _showCategoryGridFilter(context),
            tooltip: 'Filter by Category',
          ),

          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: _toggleSearching,
            tooltip: 'Search Songs',
          ),

          PopupMenuButton<AudioQuality>(
            onSelected: (AudioQuality result) {
              setState(() {
                _currentQuality = result;
                _showErrorSnackBar(
                  "Quality set to ${result.label}",
                  isError: false,
                );

                if (_currentlyPlayingId != null && _audioPlayer.playing) {
                  _playSong(_currentlyPlayingId!);
                }
              });
            },
            itemBuilder: (BuildContext context) => AudioQuality.values
                .map(
                  (quality) => PopupMenuItem<AudioQuality>(
                    value: quality,
                    child: Text(
                      quality.label,
                      style: TextStyle(
                        color: _currentQuality == quality
                            ? Colors.tealAccent
                            : Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${_currentQuality.rate}kbps',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SimpleBottomControls(
        audioPlayer: _audioPlayer,
        currentSongTitle: song?.title ?? defaultTitle,
        currentSongArtist: song?.artist ?? defaultArtist,
        onSkipNext: _playNextSong,
        onSkipPrevious: _playPreviousSong,
      ),

      body: RefreshIndicator(
        color: Colors.tealAccent,
        onRefresh: () => _fetchSongs(categoryId: _selectedCategory.id),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              )
            : _filteredSongs.isEmpty
            ? Center(
                child: Text(
                  _searchQuery.isNotEmpty
                      ? "No songs match your search or filter."
                      : "No songs found in this category.",
                  style: TextStyle(color: Colors.white70.withOpacity(0.6)),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: _filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = _filteredSongs[index];
                  final isPlaying =
                      _currentlyPlayingId == song.id && _audioPlayer.playing;

                  return AnimatedSongTile(
                    song: song,
                    isPlaying: isPlaying,
                    onTap: () => _playSong(song.id),
                    audioPlayer: _audioPlayer,
                  );
                },
              ),
      ),
    );
  }
}
