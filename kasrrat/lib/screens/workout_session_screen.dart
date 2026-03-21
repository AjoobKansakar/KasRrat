import 'package:flutter/material.dart';
// Camera Package import
import 'package:camera/camera.dart'; 
import '../core/kasrrat_colors.dart';
// AI Logic Imports
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../logic/pose_detector_service.dart';
import '../widgets/skeleton_lines.dart'; 

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

  final PoseDetectorService _poseDetectorService = PoseDetectorService();
  bool _isProcessing = false; // prevent overloading the AI with too many frames
  List<Pose> _poses = [];     // To store detected body joints

  int _frameCount = 0;

  @override
  void initState() {
    super.initState();
    _setupCamera(); // sets the camera up when the screen starts
  }

  // camera access logic
  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      CameraDescription selectedCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front
      );

      _controller = CameraController(
        selectedCamera,
        // preset redunced to low
        ResolutionPreset.low, 
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, 
      );

      await _controller!.initialize();

      // send frames to AI logic with throttling
      _controller!.startImageStream((CameraImage image) {
        _frameCount++;
        
        // Only processing every 3rd frame
        if (_frameCount % 3 != 0) return;

        if (_isProcessing) return; 
        _processCameraImage(image);
      });

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint("KasRrat Camera error!!!: $e");
    }
  }

  // function to convert camera pixels into coordinates
  Future<void> _processCameraImage(CameraImage image) async {
    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      
      if (inputImage != null) {
        final results = await _poseDetectorService.detectPose(inputImage);
        
        if (mounted && results.isNotEmpty) {
          setState(() {
            _poses = results; 
          });
        }
      }
    } catch (e) {
      debugPrint("AI Processing Error: $e");
    } finally {
      _isProcessing = false; 
    }
  }

  // helper function to convert raw camera format to AI format
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final sensorOrientation = _controller!.description.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ?? InputImageRotation.rotation0deg;
    final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    if (image.planes.isEmpty) return null;

    final plane = image.planes[0];

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _poseDetectorService.dispose(); 
    super.dispose();
  }

  // UI
@override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _isInitialized
            ? SizedBox.expand(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Transform.scale(
                        scaleX: 1.0,
                        child: SizedBox(
                          width: constraintsFix(size).width,
                          height: constraintsFix(size).height,
                          child: Stack(
                            children: [
                              CameraPreview(_controller!),
                              if (_poses.isNotEmpty)
                                CustomPaint(
                                  size: constraintsFix(size),
                                  painter: PosePainter(
                                    _poses,
                                    _controller!.value.previewSize!,
                                    InputImageRotationValue.fromRawValue(_controller!.description.sensorOrientation) ?? InputImageRotation.rotation0deg,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),

          // Overlay for text visibiltity
          IgnorePointer(
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

  // Helper to maintain layout constraints
  Size constraintsFix(Size size) {
  // proper Android portrait orientation
    return Size(size.width, size.width * _controller!.value.aspectRatio);
  }
}
