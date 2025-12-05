import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_streaming/category selection/category_selection.dart';
import '../controls/audio_quality.dart';
import 'category_songs_screen.dart';
import '../controls/bottom_control.dart';

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
}

typedef PlaySongCallback = void Function(int songId);
typedef ControlCallback = VoidCallback;

class CategoryGrid extends StatefulWidget {
  final AudioPlayer sharedAudioPlayer;
  final int? currentlyPlayingId;
  final AudioQuality currentQuality;
  final PlaySongCallback playSongCallback;

  final Song? currentSong;

  final ControlCallback onSkipNext;
  final ControlCallback onSkipPrevious;

  const CategoryGrid({
    super.key,
    required this.sharedAudioPlayer,
    required this.currentlyPlayingId,
    required this.currentQuality,
    required this.playSongCallback,
    required this.currentSong,
    required this.onSkipNext,
    required this.onSkipPrevious,
  });

  @override
  CategoryGridState createState() => CategoryGridState();
}

class CategoryGridState extends State<CategoryGrid> {
  Widget _buildCategoryItem(SongCategory category) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => CategorySongsScreen(
              category: category,
              sharedAudioPlayer: widget.sharedAudioPlayer,
              currentlyPlayingId: widget.currentlyPlayingId,
              currentQuality: widget.currentQuality,
              playSongCallback: widget.playSongCallback,
              currentSong: null,
              onSkipNext: () {},
              onSkipPrevious: () {},
            ),
          ),
        );
        if (mounted) {
          setState(() {});
        }
      },
      splashColor: Colors.blue,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.7), Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              category.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.currentSong;
    const defaultTitle = 'Not Playing';
    const defaultArtist = 'Select a song from the list';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),

      bottomNavigationBar: SimpleBottomControls(
        audioPlayer: widget.sharedAudioPlayer,
        currentSongTitle: song?.title ?? defaultTitle,
        currentSongArtist: song?.artist ?? defaultArtist,
        onSkipNext: widget.onSkipNext,
        onSkipPrevious: widget.onSkipPrevious,
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: categories.length,
        itemBuilder: (ctx, index) {
          return SingleChildScrollView(child: _buildCategoryItem(categories[index]));
        },
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20.0,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
        ),
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
