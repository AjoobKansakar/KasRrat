import 'package:flutter/material.dart';
import '../core/kasrrat_colors.dart';
import 'workout_session_screen.dart';
// video card import
import '../widgets/video_guide_card.dart'; 

// Screen to select the desired Rep range for the exercise
class GetReadyScreen extends StatefulWidget {
  final String exerciseName;

  const GetReadyScreen({super.key, required this.exerciseName});

  @override
  State<GetReadyScreen> createState() => _GetReadyScreenState();
}

class _GetReadyScreenState extends State<GetReadyScreen> {
  // Rep range List
  int? _selectedReps;
  final List<int> _repOptions = [5, 8, 10, 12, 15, 20];
  
  // Track the current video index for video slider
  int _currentVideoIndex = 0;

  // Camera Access Permission logic
  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '“KasRrat” Would Like to Access the Camera',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'KasRrat uses the camera to analyze your exercise form',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actionsPadding: EdgeInsets.zero,
        actions: [
          Column(
            children: [
              const Divider(color: Colors.white24, height: 1),
              IntrinsicHeight(
                child: Row(
                  children: [
                    // navigate to home page if camera access is not granted
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Navigate back to Home page
                        },
                        child: const Text(
                          "Don’t Allow",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(color: Colors.white24, width: 1),
                    // navigate to workout screen if camera access is granted
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutSessionScreen(
                                exerciseName: widget.exerciseName,
                                targetReps: _selectedReps!,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Allow",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Data selection to fetch correct manula for active exercise
    final manualData = _getExerciseManual(widget.exerciseName);
    final List<String> videoPaths = manualData['videos'] as List<String>;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Get Ready',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // scroll view to fit all text
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // Exercise Title
            Center(
              child: Text(
                widget.exerciseName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Exercise Manual section
            _buildSectionHeader("Exercise Manual:"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                manualData['manual']!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Rep count rules section
            _buildSectionHeader("Rules:"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: (manualData['rules'] as List<String>).map((rule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.numbers,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            rule,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // video guide section
            _buildSectionHeader("Form Demonstration:"),
            const SizedBox(height: 10),
            // slider for Tutorial and Demonstration videos
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 310, // fixed SizeBox
                    child: PageView.builder(
                      itemCount: videoPaths.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentVideoIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final String type = index == 0 ? "Tutorial" : "Demonstration";
                        return VideoGuideCard(
                          title: "${widget.exerciseName} $type", 
                          videoPath: videoPaths[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Slider indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      videoPaths.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentVideoIndex == index 
                              ? AppColors.primary 
                              : Colors.white24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Rep selection
            _buildSectionHeader("Select rep range you want to perform"),
            const Text(
              "Read the exercise manual and rules above carefully, then select your rep range to practice your form.",
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            Center(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                children: _repOptions.map((rep) {
                  final isSelected = _selectedReps == rep;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedReps = rep),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white10,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$rep',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 50),

            // Navigation button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedReps != null
                      ? AppColors.primary
                      : AppColors.surfaceGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                // shows the camera acess permission pop-up when start set is clicked
                onPressed: _selectedReps == null
                    ? null
                    : _showCameraPermissionDialog,
                child: const Text(
                  "Start Set",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper for consistent headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // cards for manual, rules, and tutorial
  Map<String, dynamic> _getExerciseManual(String name) {
    switch (name.toLowerCase()) {
      // For Squats
      case 'squats':
        return {
          'videos': [
            "assets/videos/Squats_tutorial.mp4",
            "assets/videos/Squats_demo.mp4"
          ],
          'manual':
              "Stand with feet shoulder-width apart. Keep your back straight. Slowly bend your knees and hips, go down maintaining straight back, keeping your weight balanced on both legs. Stand back up to the starting position keeping you back straight throughout the movement.",
          'rules': [
            "Full body must be in frame",
            "Stand sideways to the camera",
            "Back must remain straight",
            "Both knees must bend below 100°",
            "Knee angle must go below 100° for a proper rep count",
            "Must return to fully standing position",
            "No switching into a lunge position",
            "View the exercise tutorial and demonstration below before you start your set",
          ],
        };
      // For pushups
      case 'pushups':
        return {
          'videos': [
            "assets/videos/PushUp_tutorial.mp4",
            "assets/videos/PushUp_demo.mp4"
          ],
          'manual':
              "Start in a high plank position. Place your hand under your shoulders. Keep your body in a straight line. Lower your body until your chest nearly touches the floor bending your elbows, keeping your elbows at a 45° angle. Go down until elbows are around 90°. Push back up until arms are straight again.",
          'rules': [
            "Full body must be in frame",
            "Stand sideways to the camera",
            "Body must remain straight (>160°)",
            "Maintain a straight line between Shoulder-Hip-Ankle",
            "Elbows must bend below 90° for a full rep",
            "Must return to full extension (>160°)",
            "View the exercise tutorial and demonstration below before you start your set",
          ],
        };
      // for biceps curls
      case 'bicep curls':
        return {
          'videos': [
            "assets/videos/BicepCurls_tutorial.mp4",
            "assets/videos/BicepCurls_demo.mp4"
          ],
          'manual':
              "Stand tall with arms at your sides. Keeping your elbows pinned to your ribs, start with arms fully extended then curl both the arms upwards toward your shoulders. Keep in mind not to move your elbows during the movement keep them in a fix position. Slowly lower your arms back to the start position.",
          'rules': [
            "Upper body must be in frame",
            "Stand Sideways to the camera",
            "Elbow angle must go below 60° at the top position",
            "Both arms must curl together",
            "Arms must return to >150° at the down position",
            "Elbows must stay stable no elbow swinging is allowed",
            "View the exercise tutorial and demonstration below before you start your set",
          ],
        };
      // for lateral raises 
      case 'lateral raises':
        return {
          'videos': [
            "assets/videos/LateralRaise_tutorial.mp4",
            "assets/videos/LateralRaises_demo.mp4"
          ],
          'manual':
              "Hold weights at your sides of your hips, with a slight bend in elbows. Lift both arms outwards to your sides until they are parallel to the floor, until arms reach shoulder height. Lower them back down. control the weight throughout the movement",
          'rules': [
            "Upper body must be in frame",
            "Face the camera directly facing front",
            "Raise both arms together evenly",
            "Shoulder angle must reach around 90° in top position",
            "Both the arms must reach shoulder height",
            "Must return to <30° in down position",
            "View the exercise tutorial and demonstration below before you start your set",
          ],
        };
      default:
        return {
          'videos': ["assets/videos/Squats_tutorial.mp4", "assets/videos/Squats_demo.mp4"],
          'manual': "Align yourself and follow instructions.",
          'rules': ["Full body in frame"],
        };
    }
  }
}