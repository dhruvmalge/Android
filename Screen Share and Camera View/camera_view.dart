import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  late String streamUrl = 'http://192.168.43.172:5000/video_feed.mp4';
  late String screenUrl = 'http://192.168.43.172:5000/screen_feed.mp4';
  late String stopStreamUrl = 'http://192.168.43.172:5000/stop_camera';
  late String stopScreenUrl = 'http://192.168.43.172:5000/stop_stream';
  late VlcPlayerController _vlcPlayerController;
  late VlcPlayerController _vlcScreenPlayerController;
  int currentIndex = 0;
  bool isPlaying = false;
  bool isStopped = false;
  bool isScreenPlaying = false;
  bool isScreenStopped = false;
  bool isCameraConnected = false;
  bool isScreenConnected = false;
  double _scale = 1.0;
  double _x = 0.0;
  double _y = 0.0;

  // Joystick movement values
  double moveX = 0.0;
  double moveY = 0.0;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _vlcPlayerController = VlcPlayerController.network(
      streamUrl,
      autoPlay: false,
      allowBackgroundPlayback: true,
      hwAcc: HwAcc.auto,
      autoInitialize: true,
      options: VlcPlayerOptions(
        video: VlcVideoOptions([]),
        subtitle: VlcSubtitleOptions([]),
        audio: VlcAudioOptions([]),
      ),
    );

    _vlcScreenPlayerController = VlcPlayerController.network(
      screenUrl,
      autoPlay: false,
      allowBackgroundPlayback: true,
      hwAcc: HwAcc.auto,
      autoInitialize: true,
      options: VlcPlayerOptions(
        video: VlcVideoOptions([]),
        subtitle: VlcSubtitleOptions([]),
        audio: VlcAudioOptions([]),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
      if (currentIndex == 0 && isScreenPlaying) {
        _vlcScreenPlayerController.pause();
        isScreenPlaying = false;
      } else if (currentIndex == 1 && isPlaying) {
        _vlcPlayerController.pause();
        isPlaying = false;
      }
    });
  }

  Future<void> _checkConnection() async {
    try {
      final fetchCamUrl = await http.get(Uri.parse(streamUrl));
      final fetchVidUrl = await http.get(Uri.parse(screenUrl));
      if (fetchCamUrl.statusCode == 200) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Cam Streaming Started"),
            duration: Duration(seconds: 3),
            showCloseIcon: true,
            closeIconColor: Colors.redAccent,
            dismissDirection: DismissDirection.down,
            action: SnackBarAction(label: "OK", onPressed: (){
              ScaffoldMessenger.of(context).clearSnackBars();
            },),
          ));
        });
      }
      if (fetchVidUrl.statusCode == 200){
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("ScreenShare Streaming Started"),
            duration: Duration(seconds: 3),
            showCloseIcon: true,
            closeIconColor: Colors.redAccent,
            dismissDirection: DismissDirection.down,
            action: SnackBarAction(label: "OK", onPressed: (){
              ScaffoldMessenger.of(context).clearSnackBars();
            },),
          ));
        });
      }
    } on Exception catch (e) {
      // Just Do It
    }
  }

   void stopCamStream() async {
     if (isPlaying) {
       await _vlcPlayerController.pause();
       setState(() {
         isPlaying = false;
       });
     }
  }

  void stopScreenStream() async {
    if (isScreenPlaying) {
      await _vlcScreenPlayerController.stop();
      setState(() {
        isScreenPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Screen Stream Stopped"),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Future<void> startCamStream() async {
    if (isPlaying) {
      await _vlcPlayerController.pause();  // Pause screen stream if active
      isPlaying = false;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Starting Cam Stream... Please Wait"),
      duration: Duration(seconds: 5),
    ));
    await _vlcPlayerController.play();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Camera Stream Started!"),
      duration: Duration(seconds: 2),
    ));
    setState(() {
      isPlaying = true;
    });
  }

  Future<void> startScreenStream() async {
    if (isScreenPlaying) {
      await _vlcScreenPlayerController.pause();
      setState(() {
        isScreenPlaying = false;
      });
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Starting Screen Share Stream... Please Wait"),
      duration: Duration(seconds: 5),
    ));
    await _vlcScreenPlayerController.play();
    setState(() {
      isScreenPlaying = true;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Screen Share Started!"),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _vlcPlayerController.dispose();
    _vlcScreenPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32-CAM and Screen Stream'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.linked_camera_sharp), label: "Camera Stream"),
          BottomNavigationBarItem(
            icon: Icon(Icons.screen_share_outlined),
            label: "Screen Share",
          ),
        ],
        backgroundColor: Colors.cyan[200],
        onTap: _onItemTapped,
        currentIndex: currentIndex,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Mirror Mirror On the Wall, Who is the genius of them all",
                      style: TextStyle(fontSize: 20),
                    ),
                    GestureDetector(
                      onTap: startCamStream,
                      onDoubleTap: stopCamStream,
                      child: Center(
                        child: Container(
                          width: 240 * 1.75,
                          height: 320 * 0.9,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          transformAlignment: Alignment.center,
                          child: VlcPlayer(
                            controller: _vlcPlayerController,
                            aspectRatio: 16 / 9,
                            virtualDisplay: true,
                            placeholder: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: startCamStream,
                          label: Text("Start"),
                          icon: Icon(Icons.start),
                        ),
                        ElevatedButton.icon(
                            onPressed: stopCamStream,
                            label: Text("Stop"),
                            icon: Icon(Icons.stop)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: startScreenStream,
            onDoubleTap: stopScreenStream,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Screen Sharing is Caring",
                        style: TextStyle(fontSize: 20),
                      ),
                      Center(
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _x += details.localPosition.dx;
                              _y += details.localPosition.dy;
                            });
                          },
                          child: Container(
                            width: 240 * 1.75,
                            height: 320 * 0.9,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            transformAlignment: Alignment.center,
                            child: VlcPlayer(
                              controller: _vlcScreenPlayerController,
                              aspectRatio: 16 / 9,
                              virtualDisplay: true,
                              placeholder: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: startScreenStream,
                            label: Text("Start"),
                            icon: Icon(Icons.start),
                          ),
                          ElevatedButton.icon(
                            onPressed: stopScreenStream,
                            label: Text("Stop"),
                            icon: Icon(Icons.stop),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
