import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:marquee/marquee.dart';

class PositionData {
  const PositionData(this.position, this.bufferedPosition, this.duration);
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

class SimpleBottomControls extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final String currentSongTitle;
  final String currentSongArtist;
  final VoidCallback onSkipNext;
  final VoidCallback onSkipPrevious;
  final VoidCallback? onFileUploadSuccess;


  const SimpleBottomControls({
    super.key,
    required this.audioPlayer,
    required this.currentSongTitle,
    required this.currentSongArtist,
    required this.onSkipNext,
    required this.onSkipPrevious,
    this.onFileUploadSuccess,
  });

  @override
  State<SimpleBottomControls> createState() => _SimpleBottomControlsState();
}

class _SimpleBottomControlsState extends State<SimpleBottomControls> {
  double _lastVolume = 1.0;
  bool _isUploading = false;

  Stream<PositionData> get _positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      widget.audioPlayer.positionStream,
      widget.audioPlayer.bufferedPositionStream,
      widget.audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
        position,
        bufferedPosition,
        duration ?? Duration.zero,
      ));

  Future<void> uploadFileToFlask() async {
    final String _baseUrl = 'https://7937e4046971.ngrok-free.app';
    late final String _uploadUrl = '$_baseUrl/upload';
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      print("No File Selected");
      return;
    }
    setState(() {
      _isUploading = true;
    });

    File filesToUpload = File(result.files.single.path!);
    String filename = result.files.single.name;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filesToUpload.path,
          filename: filename,
        ),
      );

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        _showErrorSnackBar("File Uploaded Successfully!", isError: false);
      } else {
        String responseBody = await response.stream.bytesToString();
        _showErrorSnackBar("Upload Failed: ${response.statusCode}. Response: $responseBody");
      }
    } catch (e) {
      _showErrorSnackBar("Error During file upload: $e");
    } finally {
      setState(() {
        _isUploading = false;
      });
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


  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.currentSongTitle != 'Not Playing';
    final marqueeText = isPlaying
        ? "${widget.currentSongArtist} - ${widget.currentSongTitle}"
        : "${widget.currentSongTitle} - ${widget.currentSongArtist}";

    return Container(
      color: Colors.blueGrey.shade900,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SizedBox(
              height: 24,
              child: isPlaying
                  ? Marquee(
                text: marqueeText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                blankSpace: 40.0,
                velocity: 30.0,
                pauseAfterRound: const Duration(seconds: 2),
                startPadding: 10.0,
              )
                  : Text(
                marqueeText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white70,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 8.0),

          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data ??
                  const PositionData(Duration.zero, Duration.zero, Duration.zero);

              return ProgressBar(
                progress: positionData.position,
                buffered: positionData.bufferedPosition,
                total: positionData.duration,
                onSeek: widget.audioPlayer.seek,
                baseBarColor: Colors.white24,
                progressBarColor: Colors.blueAccent,
                bufferedBarColor: Colors.white54,
                timeLabelTextStyle: const TextStyle(color: Colors.white),
              );
            },
          ),

          const SizedBox(height: 8.0),

          StreamBuilder<PlayerState>(
            stream: widget.audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final playing = playerState?.playing ?? false;
              final processingState = playerState?.processingState;

              final isLoading = processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              onPressed: _isUploading ? null : uploadFileToFlask, // Disable button while uploading
                              icon: Icon(
                                  Icons.upload,
                                  color: _isUploading ? Colors.white54 : Colors.white
                              ),
                            ),
                            if (_isUploading)
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                                  strokeWidth: 3.0,
                                ),
                              ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                        onPressed: widget.onSkipPrevious,
                        onLongPress: () {
                          final newPosition = widget.audioPlayer.position - const Duration(seconds: 10);
                          widget.audioPlayer.seek(newPosition.isNegative ? Duration.zero : newPosition);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: Colors.blueAccent,
                          size: 64,
                        ),
                        onPressed: playing ? widget.audioPlayer.pause : widget.audioPlayer.play,
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_next, color: Colors.white, size: 30),
                            onPressed: widget.onSkipNext,
                            onLongPress: () {
                              final duration = widget.audioPlayer.duration ?? Duration.zero;
                              final newPosition = widget.audioPlayer.position + const Duration(seconds: 10);
                              widget.audioPlayer.seek(newPosition > duration ? duration : newPosition);
                            },
                          ),
                          StreamBuilder<double>(
                            stream: widget.audioPlayer.volumeStream,
                            builder: (context, snapshot) {
                              final currentVolume = snapshot.data ?? 1.0;
                              final isMuted = currentVolume == 0.0;

                              return IconButton(
                                icon: Icon(
                                    isMuted ? Icons.volume_off : Icons.volume_up,
                                    color: Colors.white,
                                    size: 30
                                ),
                                onPressed: () {
                                  if (isMuted) {
                                    widget.audioPlayer.setVolume(_lastVolume);
                                  } else {
                                    if (currentVolume > 0.0) {
                                      _lastVolume = currentVolume;
                                    }
                                    widget.audioPlayer.setVolume(0.0);
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}