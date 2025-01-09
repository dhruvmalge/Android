import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'table_screen_view.dart';
import 'charts_screen.dart';
import 'control_screen.dart';

class StreamView extends StatefulWidget {
  const StreamView({super.key});

  @override
  StreamViewState createState() => StreamViewState();
}

class StreamViewState extends State<StreamView> {
  bool isPlaying = false;
  late String urlStreamVlc = "http://192.168.43.172:5000/video_feed.mp4";
  int indexNavigator = 0;

  late VlcPlayerController _streamController;

  Future<void> streamUrl() async {
    final url = Uri.parse(urlStreamVlc);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      AboutDialog(
        key: Key(response.body),
        children: [
          const Text("Fetching Data"),
          Image.asset('assets/fetched_successfully.gif'),
        ],
      );
    } else {
      AboutDialog(
        key: Key(response.body),
        children: const [
          Text("Failed to fetch"),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize VLC Player Controller
    _streamController = VlcPlayerController.network(urlStreamVlc,
        autoInitialize: true,
        allowBackgroundPlayback: true,
        autoPlay: false,
        options: VlcPlayerOptions(),
        hwAcc: HwAcc.auto);

  }



  Future<void> startStream() async {
    if (isPlaying) {
      await _streamController.stop();
    }
    await _streamController.play();
    setState(() {
      isPlaying = true;
    });
  }

  void onBottomNavTapped(int index) {
    setState(() {
      indexNavigator = index;
    });
  }



  @override
  void dispose() {
    _streamController.dispose();
    super.dispose();
  }

  Widget buildNavItem(IconData icon, String label, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(
        icon,
        size: isSelected ? 30 : 24,
        color: isSelected ? Colors.white : Colors.grey,
      ),
    );
  }

  Widget buildStreamPage() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
            },
            child: Container(
              width: double.infinity,
              height: 300 * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.7),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: VlcPlayer(
                  controller: _streamController,
                  aspectRatio: 16 / 9,
                  placeholder: const Placeholder(
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  virtualDisplay: true,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 70,
            child: ElevatedButton(
              onPressed: startStream,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
                elevation: 10,
              ),
              child: const Icon(
                Icons.start,
                size: 35,
                color: Colors.white,
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 150,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                  isPlaying ? _streamController.play() : _streamController.pause();
                },
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 220,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _streamController.stop,
                icon: const Icon(
                  Icons.stop,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTablePage() {
    return const TableView();
  }

  Widget buildChartPage() {
    return const ChartScreen();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildStreamPage(),
      buildTablePage(),
      buildChartPage(),
      ControlScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreenAccent,
        title: const Text("Watch my Plants"),
        centerTitle: true,
        shadowColor: const Color.fromARGB(155, 144, 151, 144),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_enhance), label: "Stream"),
          BottomNavigationBarItem(
              icon: Icon(Icons.data_exploration_outlined), label: "Table"),
          BottomNavigationBarItem(
              icon: Icon(Icons.stacked_line_chart), label: "Charts"),
          BottomNavigationBarItem(
              icon: Icon(Icons.control_camera_sharp), label: "Control"),
        ],
        currentIndex: indexNavigator,
        onTap: onBottomNavTapped,
        iconSize: 20,
        enableFeedback: true,
        selectedFontSize: 20,
        selectedItemColor: Colors.lightGreenAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.shifting,
      ),
      body: pages[indexNavigator],
      );
  }
}
