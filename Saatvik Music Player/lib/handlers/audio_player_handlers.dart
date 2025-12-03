import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioStateListeners();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error loading playlist: $e");
    }
  }

  void _notifyAudioStateListeners() {
    _player.playerStateStream.listen((playerState) {
      final playing = playerState.playing;
      final processingState = _getAudioServiceState(playerState.processingState);

      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: playing,
      ));
    });
  }

  AudioProcessingState _getAudioServiceState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return AudioProcessingState.loading;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        return AudioProcessingState.idle;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) {
    return super.setRepeatMode(repeatMode);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Future<void> updateQueue(List<MediaItem> newItems) async {
    queue.add(newItems);

    final newSources = newItems.map((item) => AudioSource.uri(Uri.parse(item.id), tag: item));

    await _playlist.clear();
    await _playlist.addAll(newSources.toList());
  }

  Future<void> playIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
    play();
  }
}

@pragma('vm:entry-point')
Future<void> audioPlayerHandler() async {
  await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music_streaming.audio',
      androidNotificationChannelName: 'Music Streaming',
      androidResumeOnClick: true,
    ),
  );
}

Future<Uri> _fetchArt(String artUri) async {
  return Uri.parse(artUri);
}