import 'package:flutter/material.dart';
// Camera Package import
import 'package:camera/camera.dart'; 
import '../core/kasrrat_colors.dart';
import 'dart:math' as math; 

class WorkoutSessionScreen extends StatefulWidget {
  final String exerciseName;

  const WorkoutSessionScreen({super.key, required this.exerciseName});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  // Camera variables
  CameraController? _controller; // camera hardware
  bool _isInitialized = false;  // to track if camera is ready

  @override
  void initState() {
    super.initState();
    _setupCamera(); // sets the camera up when the screen starts
  }

  // camera access logic
  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        debugPrint("No cameras found on this device");
        return;
      }

      // Select Front Camera
      CameraDescription selectedCamera = cameras.first;
      for (var cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.front) {
          selectedCamera = cam;
          break;
        }
      }

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("KasRrat Camera error!!!: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Screen Dimensions
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 2. THE ULTIMATE CENTER FIX
          _isInitialized
              ? Container(
                  width: size.width,
                  height: size.height,
                  color: Colors.black,
                  child: Center( // This ensures the pivot point is the center of the screen
                    child: Transform.scale(
                      scale: _calculateFullScale(size),
                      alignment: Alignment.center, // Scale from the middle
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi), // Mirror the camera
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),

          // Overlay for text visibiltity
          IgnorePointer( // Allows clicks to pass through to the camera if needed
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),

          // overlay UI
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        widget.exerciseName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const Spacer(),
                
                // Rep Counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "REPS: 0",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Working on camera positioning for the workout sessions
  double _calculateFullScale(Size screenSize) {
    if (_controller == null || !_controller!.value.isInitialized) return 1.0;
    
    double cameraRatio = _controller!.value.aspectRatio;
    double screenRatio = screenSize.aspectRatio;

    // formula to center crop the camera positioning
    return (1 / (cameraRatio * screenRatio)) * 1.1; 
  }
}