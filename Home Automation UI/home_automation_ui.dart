import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // REQUIRED IMPORT

void main() {
  runApp(const HomeAutomationApp());
}

// --- MAIN APPLICATION SETUP ---

class HomeAutomationApp extends StatelessWidget {
  const HomeAutomationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Control Ring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF14141C), // Deep dark background
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const HomeAutomationScreen(),
    );
  }
}

// --- STATEFUL SCREEN IMPLEMENTATION ---

class HomeAutomationScreen extends StatefulWidget {
  const HomeAutomationScreen({super.key});

  @override
  State<HomeAutomationScreen> createState() => _HomeAutomationScreenState();
}

class _HomeAutomationScreenState extends State<HomeAutomationScreen> {
  // Device States
  int lightsOn = 3;
  int totalLights = 8;
  int fanSpeed = 1; // 0 (Off) to 3 (Max)
  bool isGarageOpen = false;

  // Constants
  static const Color accentColor = Color(0xFF4A90E2); // Electric Blue
  static const Color cardColor = Color(0xFF1F1F27); // Slightly lighter dark card

  void _toggleGarage() {
    setState(() {
      isGarageOpen = !isGarageOpen;
    });
  }

  void _cycleFanSpeed() {
    setState(() {
      fanSpeed = (fanSpeed + 1) % 4; // Cycles 0, 1, 2, 3, then back to 0
    });
  }

  void _toggleLights() {
    setState(() {
      if (lightsOn > 0) {
        lightsOn = 0;
      } else {
        lightsOn = 4; // Set a default on state
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Ensure the overall content area scales gracefully
    final double padding = size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Control', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, color: Colors.white70),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: SizedBox(
            height: size.height * 0.85, // Allocate enough space for the unique layout
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Garage Door (Top Wide Card)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _WideControlCard(
                    title: 'Garage Door',
                    status: isGarageOpen ? 'OPEN' : 'CLOSED',
                    icon: Icons.garage_sharp,
                    isActive: isGarageOpen,
                    onTap: _toggleGarage,
                  ),
                ),

                // 2. Control Ring (Centerpiece)
                Positioned(
                  top: size.height * 0.15, // Pushed down from the garage card
                  child: const _ControlRingCCTV(),
                ),

                // 3. Lights Control (Left Card)
                Positioned(
                  top: size.height * 0.40,
                  left: padding,
                  child: _SmallControlCard(
                    title: 'Lights',
                    value: '$lightsOn / $totalLights',
                    icon: Icons.lightbulb_outline,
                    isActive: lightsOn > 0,
                    onTap: _toggleLights,
                  ),
                ),

                // 4. Fan Control (Right Card)
                Positioned(
                  top: size.height * 0.40,
                  right: padding,
                  child: _SmallControlCard(
                    title: 'Fan',
                    value: fanSpeed == 0 ? 'OFF' : 'Speed $fanSpeed',
                    icon: Icons.mode_fan_off_outlined,
                    activeIcon: Icons.air,
                    isActive: fanSpeed > 0,
                    onTap: _cycleFanSpeed,
                  ),
                ),

                // 5. Ambient Card (Bottom Card - Placeholder for another device)
                Positioned(
                  bottom: size.height * 0.05,
                  left: 0,
                  right: 0,
                  child: const _WideControlCard(
                    title: 'Thermostat',
                    status: '21.5°C | AUTO',
                    icon: Icons.thermostat_outlined,
                    isActive: true,
                    onTap: null, // No action
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM WIDGETS ---

/// The central unique element that displays the CCTV feed (now using VideoPlayer).
class _ControlRingCCTV extends StatefulWidget {
  const _ControlRingCCTV();

  @override
  State<_ControlRingCCTV> createState() => _ControlRingCCTVState();
}

class _ControlRingCCTVState extends State<_ControlRingCCTV> with SingleTickerProviderStateMixin {
  // Animation for the rotating glow effect
  late AnimationController _rotationController;
  // Controller for the video playback
  late VideoPlayerController _videoController;

  // Custom size for the ring
  static const double ringSize = 180;
  static const Color accentColor = _HomeAutomationScreenState.accentColor;

  @override
  void initState() {
    super.initState();

    // 1. Rotation Animation Setup
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 2. Video Player Setup
    // IMPORTANT: Make sure you have added the 'video_player' dependency and
    // placed 'cctv_loop.mp4' in your 'assets/' folder and registered it in pubspec.yaml.
    _videoController = VideoPlayerController.asset('assets/cctv_loop.mp4')
      ..initialize().then((_) {
        // Only call setState if the widget is mounted to prevent errors
        if (mounted) {
          setState(() {});
        }
        // Start playing the video immediately and set it to loop
        _videoController.play();
        _videoController.setLooping(true);
        _videoController.setVolume(0.0); // Keep it silent
      }).catchError((error) {
        // Log an error if the video asset is not found or fails to initialize
        debugPrint('Error loading video asset: $error');
      });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _videoController.dispose(); // Dispose the video controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint('CCTV Feed tapped - Fullscreen view opened.');
      },
      borderRadius: BorderRadius.circular(ringSize / 2),
      child: Container(
        width: ringSize,
        height: ringSize,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _rotationController, // Use the rotation controller
          builder: (context, child) {
            return CustomPaint(
              painter: _RotatingRingPainter(
                controllerValue: _rotationController.value,
                color: accentColor,
              ),
              child: child,
            );
          },
          // This child contains the video and overlay
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. The Video Feed
                if (_videoController.value.isInitialized)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover, // Ensure video covers the circular area
                      child: SizedBox(
                        // Set the size based on the video's intrinsic dimensions
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                else
                // Fallback/Loading State
                  Container(
                    color: const Color(0xFF121215), // Inner dark surface
                    alignment: Alignment.center,
                    child: const Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
                  ),

                // 2. Status Overlay
                // Add a transparent black overlay to help the text stand out over the video
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_outlined, color: Colors.redAccent, size: 40),
                      SizedBox(height: 4),
                      Text(
                        'LIVE FEED',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Front Door',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A CustomPainter to draw the animated, glowing 'Control Ring'
class _RotatingRingPainter extends CustomPainter {
  final double controllerValue;
  final Color color;

  _RotatingRingPainter({required this.controllerValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw the main outer ring
    final paintRing = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius, paintRing);

    // 2. Draw the rotating highlight arc
    final paintArc = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 3.14 * 2,
        colors: [
          Colors.transparent,
          color.withOpacity(0.8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        // GradientRotation uses the controller's value (0.0 to 1.0) multiplied by 2*PI
        // to complete a 360-degree rotation.
        transform: GradientRotation(controllerValue * 2 * 3.1415),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // The arc covers the full circle, and the gradient provides the visual effect
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      3.14 * 2,
      false,
      paintArc,
    );
  }

  @override
  bool shouldRepaint(covariant _RotatingRingPainter oldDelegate) {
    return oldDelegate.controllerValue != controllerValue;
  }
}

/// Wide card for controls like Garage/Thermostat.
class _WideControlCard extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _WideControlCard({
    required this.title,
    required this.status,
    required this.icon,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = _HomeAutomationScreenState.cardColor;
    final Color accentColor = _HomeAutomationScreenState.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? accentColor.withOpacity(0.15) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? accentColor.withOpacity(0.5) : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: isActive ? accentColor : Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(
              icon,
              size: 45,
              color: isActive ? accentColor : Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small square card for controls like Lights/Fan.
class _SmallControlCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final IconData? activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _SmallControlCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.activeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = _HomeAutomationScreenState.cardColor;
    final Color accentColor = _HomeAutomationScreenState.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? accentColor.withOpacity(0.15) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? accentColor.withOpacity(0.5) : Colors.white10,
            width: 1.5,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              isActive ? (activeIcon ?? icon) : icon,
              size: 35,
              color: isActive ? accentColor : Colors.white30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isActive ? accentColor : Colors.white60,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
