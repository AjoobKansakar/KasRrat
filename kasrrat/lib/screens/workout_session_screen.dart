import 'package:flutter/material.dart';
// Camera Package import
import 'package:camera/camera.dart'; 
import '../core/kasrrat_colors.dart';
// AI Logic Imports
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../logic/pose_detector_service.dart';
import '../widgets/skeleton_lines.dart'; 
// Workout Logic Imports
import '../logic/squat_rep_counter.dart';   // Squats logic 
import '../logic/pushup_rep_counter.dart';  // Push-up logic
import '../logic/lunge_rep_counter.dart';   // Lunge logic
import '../logic/bicep_curl_counter.dart';  // Bicep Curl logic
// Summary screen import
import 'workout_complete_screen.dart';
// TTS Service 
import '../logic/tts_service.dart'; 
// import for WriteBuffer
import 'dart:typed_data'; // memory management using ByteData

class WorkoutSessionScreen extends StatefulWidget {
  final String exerciseName;
  final int targetReps;

  const WorkoutSessionScreen({
    super.key, 
    required this.exerciseName,
    required this.targetReps,
  });

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

  // Counters for the exercises
  // Squat rep counter
  final SquatCounter _squatCounter = SquatCounter();
  // pushup rep counter
  final PushupCounter _pushupCounter = PushupCounter();
  // Lunge rep counter
  final LungeCounter _lungeCounter = LungeCounter();
  // Bicep Curl rep counter 
  final BicepCurlCounter _bicepCurlCounter = BicepCurlCounter();

  String _currentFeedback = "Aligning...";
  bool _workoutCompleted = false;

  // Requirements check before starting the workout
  bool _isBodyInFrame = false;
  bool _isLightingGood = false;
  bool _sessionStarted = false; // track if user clicked the Start button inside this screen

  // Auto workout session start
  int _countdown = 5; // 5 second countdown before starting the workout
  bool _isCountingDown = false;

  // TTS Voice Service
  final TTSService _ttsService = TTSService(); // Initializing voice

  // Helper to get the active exercise rep count, routes counter depending on which exercise is currently active
  int get _currentReps {
    switch (widget.exerciseName.toLowerCase()) {
      case 'pushups':     return _pushupCounter.reps;    // pushup rep counter
      case 'lunges':      return _lungeCounter.reps;     // lunge rep counter
      case 'bicep curls': return _bicepCurlCounter.reps; // bicep curl rep counter
      default:            return _squatCounter.reps;     // default squats rep counter
    }
  }

  // Helper to get the active exercise form error state, used to trigger the red screen overlay
  bool get _currentHasFormError {
    switch (widget.exerciseName.toLowerCase()) {
      case 'pushups':     return _pushupCounter.hasFormError;
      case 'lunges':      return _lungeCounter.hasFormError;
      case 'bicep curls': return _bicepCurlCounter.hasFormError;
      default:            return _squatCounter.hasFormError;
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCamera(); // set camera when the screen starts
  }

  // camera access logic
  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      CameraDescription selectedCamera = cameras.first;
      for (var cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.front) {
          selectedCamera = cam;
          break;
        }
      }

      _controller = CameraController(
        selectedCamera,
        // preset redunced to low due to latency issue
        ResolutionPreset.low, 
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, 
      );

      await _controller!.initialize();

      if (!mounted) return;

      // send every frame to AI logic with throttling
      _controller!.startImageStream((CameraImage image) {
        if (_workoutCompleted) return;
        _frameCount++;
        if (_frameCount % 3 != 0) return;
        if (_isProcessing) return; 
        _processCameraImage(image);
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Error msg
      debugPrint("KasRrat Camera error!!!: $e");
    }
  }

  // function to convert camera pixels into coordinates
  Future<void> _processCameraImage(CameraImage image) async {
    _isProcessing = true;

    try {
      // to check the ligthing in the video
      final int pixelCount = (image.width * image.height).toInt();
      final Uint8List yPlane = image.planes[0].bytes;
      int sum = 0;
      for (int i = 0; i < pixelCount; i += 20) { sum += yPlane[i]; }
      bool lightOk = (sum / (pixelCount / 20)) > 60;

      final inputImage = _inputImageFromCameraImage(image);
      
      if (inputImage != null) {
        final results = await _poseDetectorService.detectPose(inputImage);
        bool bodyOk = false;

        if (results.isNotEmpty) {
          final pose = results.first;

          // Dynamic landmark detection to start the workout
          List<PoseLandmarkType> requiredLandmarks;
          
          // for Bicep curls we only need the upper body
          if (widget.exerciseName.toLowerCase() == 'bicep curls') {
            requiredLandmarks = [
              PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
              PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
              PoseLandmarkType.leftElbow, PoseLandmarkType.rightElbow,
              PoseLandmarkType.leftWrist, PoseLandmarkType.rightWrist,
            ];
          } else {
            // Standard full body check for Squats, Pushups, Lunges
            requiredLandmarks = [
              PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
              PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
              PoseLandmarkType.leftKnee, PoseLandmarkType.rightKnee,
              PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle,
            ];
          }

          // Check if every landmark in our list is visible with high confidence (> 0.7)
          bodyOk = requiredLandmarks.every((type) => (pose.landmarks[type]?.likelihood ?? 0) > 0.7);

          // only run exercise logic if the user is fully in the frame
          if (_sessionStarted) {
            // routing the pose to the correct counter based on exersie name
            _routePoseToCounter(pose); // processPose() is same for all the counters
          }
        }

        if (mounted) {
          setState(() {
            _isBodyInFrame = bodyOk;
            _isLightingGood = lightOk;
            _poses = results;
            if (_sessionStarted) _currentFeedback = _getActiveFeedback();

            // Auto start trigger 
            // Only start countdown if the required landmarks are detected clearly
            if (bodyOk && lightOk && !_sessionStarted && !_isCountingDown) {
              _startAutoCountdown();
            }

            if (!_workoutCompleted && _currentReps >= widget.targetReps) {
              _workoutCompleted = true;
              _onWorkoutFinished();
            }
          });
        }
      }
    } catch (e) {
      debugPrint("AI Processing Error: $e");
    } finally {
      _isProcessing = false; 
    }
  }

  // Routing the detected pose to the active counter
  void _routePoseToCounter(Pose pose) {
    switch (widget.exerciseName.toLowerCase()) {
      case 'pushups':
        _pushupCounter.processPose(
          pose,
          onRepCount: () => _ttsService.speak("Good rep!"),
          onFormError: () => _ttsService.speak("Error! Try again"),
        );
        break;
      case 'lunges': 
        _lungeCounter.processPose(
          pose,
          onRepCount: () => _ttsService.speak("Good rep!"),
          onFormError: () => _ttsService.speak("Error! Try again"),
        );
        break;
      case 'bicep curls': 
        _bicepCurlCounter.processPose(
          pose,
          onRepCount: () => _ttsService.speak("Good rep!"),
          // Elbow swinging error
          onFormError: () => _ttsService.speak("Try again! Keep your elbows in a fixed position"),
          // Only one arm used error
          onSymmetryError: () => _ttsService.speak("Use both arms while curling"),
        );
        break;
      default:
        _squatCounter.processPose(
          pose,
          onRepCount: () => _ttsService.speak("Good rep!"),
          onFormError: () => _ttsService.speak("Error! Try again"),
        );
    }
  }

  // return feedback text from the active counter
  String _getActiveFeedback() {
    switch (widget.exerciseName.toLowerCase()) {
      case 'pushups':     return _pushupCounter.feedback;
      case 'lunges':      return _lungeCounter.feedback;
      case 'bicep curls': return _bicepCurlCounter.feedback; 
      default:            return _squatCounter.feedback;
    }
  }

  // return error set from the active counter, used to build WorkoutCompleteScreen review
  Set<String> _getActiveErrors() {
    switch (widget.exerciseName.toLowerCase()) {
      case 'pushups':     return _pushupCounter.errorsFound;
      case 'lunges':      return _lungeCounter.errorsFound;
      case 'bicep curls': return _bicepCurlCounter.errorsFound; 
      default:            return _squatCounter.errorsFound;
    }
  }

  // returns totalAttempts from the active counter
  int _getActiveTotalAttempts() {
    switch (widget.exerciseName.toLowerCase()) {
      case 'pushups':     return _pushupCounter.totalAttempts;
      case 'lunges':      return _lungeCounter.totalAttempts;
      case 'bicep curls': return _bicepCurlCounter.totalAttempts; 
      default:            return _squatCounter.totalAttempts;
    }
  }

  // returns goodreps from the active counter
  int _getActiveGoodReps() {
    switch (widget.exerciseName.toLowerCase()) {
      case 'pushups':     return _pushupCounter.goodReps;
      case 'lunges':      return _lungeCounter.goodReps;
      case 'bicep curls': return _bicepCurlCounter.goodReps; 
      default:            return _squatCounter.goodReps;
    }
  }

  // auto start countdown function
  void _startAutoCountdown() async {
    _isCountingDown = true;
    for (int i = 5; i > 0; i--) { // 5 second countdown
      // If the user moves out of frame during the 5 seconds, cancel
      if (!mounted || !_isBodyInFrame || !_isLightingGood) {
        setState(() {
          _isCountingDown = false;
          _countdown = 5; 
        });
        return; 
      }
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (mounted && _isBodyInFrame && _isLightingGood) {
      setState(() {
        _sessionStarted = true;
        _isCountingDown = false;
      });
    }
  }

  // Recording data for summary
  void _onWorkoutFinished() {
    if (_controller != null && _controller!.value.isStreamingImages) {
      _controller?.stopImageStream();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutCompleteScreen(
          exerciseName: widget.exerciseName,
          repsCompleted: _currentReps,                  // to show the valid rep counted
          totalReps: _getActiveTotalAttempts(),         // to show how many rep user tried
          goodReps: _getActiveGoodReps(),               // to store good reps
          errors: _getActiveErrors(),                   // to store the error during the workout
        ),
      ),
    );
  }

  // helper function to convert raw camera format to AI format
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null || !_controller!.value.isInitialized) return null;
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
    if (_controller != null && _controller!.value.isInitialized && _controller!.value.isStreamingImages) {
      _controller!.stopImageStream();
    }
    _controller?.dispose();
    _poseDetectorService.dispose(); // stop pose detection if user exits
    _ttsService.stop(); // stop voice if user exits
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
                              // Draws the AI skeleton dots and lines on top of the camera
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
          
          // Error background with red color effect
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: (_currentHasFormError && _sessionStarted) 
                ? Colors.red.withValues(alpha: 0.3) 
                : Colors.transparent,
          ),

          // HUD overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      // when the session starts live indicator is kept beside the exercise title
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.exerciseName.toUpperCase(), 
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)
                          ),
                          if (_sessionStarted) ...[
                            const SizedBox(width: 10),
                            _buildLiveIndicator(),
                          ],
                        ],
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                
                // Requirement list until the workout session begins
                if (!_sessionStarted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCheckChip(
                        widget.exerciseName.toLowerCase() == 'bicep curls' ? "Upper Body" : "Full Body", 
                        _isBodyInFrame
                      ),
                      const SizedBox(width: 10),
                      _buildCheckChip("Lighting", _isLightingGood),
                    ],
                  ),
                ),

                const Spacer(),

                // countdown UI
                if (_isCountingDown && !_sessionStarted)
                Center(
                  child: Text(
                    "STAY IN FRAME\n$_countdown",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.primary, fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                ),

                // feedback text 
                if (_sessionStarted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _currentFeedback,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: (_currentHasFormError || _currentFeedback.contains("Try again")) ? Colors.redAccent : AppColors.primary,
                      fontSize: 22, fontWeight: FontWeight.bold, backgroundColor: Colors.black54,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // main action button and rep display 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: _sessionStarted 
                  ? Container( // Show Reps when started
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                      child: Center(child: Text(
                        "REPs: $_currentReps / ${widget.targetReps}",
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                      )),
                    )
                  // Show Status bar when not started
                  : Container( 
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: (_isBodyInFrame && _isLightingGood) ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: (_isBodyInFrame && _isLightingGood) ? Colors.green : Colors.red),
                      ),
                      child: Center(
                        child: Text(
                          (_isBodyInFrame && _isLightingGood) ? "STABILIZING..." : "POSITION YOUR BODY", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      ),
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

  // live indicator button
  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            "LIVE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckChip(String label, bool isMet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // changed withOpacity to withValues due to flutter update
        color: isMet ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isMet ? Colors.green : Colors.red),
      ),
      child: Row(
        children: [
          Icon(isMet ? Icons.check_circle : Icons.error_outline, color: isMet ? Colors.green : Colors.red, size: 16),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: isMet ? Colors.green : Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  Size constraintsFix(Size size) {
  // proper Android portrait display
    if (_controller == null || !_controller!.value.isInitialized) return size;
    return Size(size.width, size.width * _controller!.value.aspectRatio);
  }
}