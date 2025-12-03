import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../pages/music_stream.dart';

class AnimatedSongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  final AudioPlayer audioPlayer;

  const AnimatedSongTile({
    required this.song,
    required this.isPlaying,
    required this.onTap,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.hintColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPlaying ? accentColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isPlaying
            ? Border.all(color: accentColor.withOpacity(0.5), width: 1)
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        leading: Icon(
          isPlaying ? Icons.graphic_eq_rounded : Icons.music_note,
          color: isPlaying ? accentColor : Colors.white60,
          size: 28,
        ),

        title: Text(
          song.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isPlaying ? accentColor : Colors.white,
            fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Text(
          song.artist,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isPlaying ? accentColor.withOpacity(0.8) : Colors.white54,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        trailing: StreamBuilder<bool>(
          stream: audioPlayer.playingStream,
          builder: (context, snapshot) {
            final isCurrentlyPlayingThisSong =
                isPlaying && (snapshot.data ?? false);
            return Icon(
              isCurrentlyPlayingThisSong
                  ? Icons.pause_circle
                  : Icons.play_circle,
              color: isCurrentlyPlayingThisSong ? accentColor : Colors.white38,
              size: 36,
            );
          },
        ),
      ),
    );
  }
}