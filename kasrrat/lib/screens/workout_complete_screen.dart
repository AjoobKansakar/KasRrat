// This screen appears automatically afer the User finishes the selected rep range and shows the set summary
import 'package:flutter/material.dart';
import '../core/kasrrat_colors.dart';
import '../routes/app_routes.dart';
import 'get_ready_screen.dart'; // to navigate back for another set

class WorkoutCompleteScreen extends StatefulWidget {
  final String exerciseName;
  final int repsCompleted;
  final int totalReps; // total reps performed analysis
  final int goodReps;  // good reps analysis
  final Set<String> errors; // display specific mistakes

  const WorkoutCompleteScreen({
    super.key,
    required this.exerciseName,
    required this.repsCompleted,
    this.totalReps = 0,
    this.goodReps = 0,
    required this.errors,
  });

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for checkmarks
  late AnimationController _animController;

  // CurvedAnimation applies an easing curve on top of the controller
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // 600ms bounce animation on screen open
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut, // bouncy spring effect
    );

    // Start the animation as soon as the screen appears
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate a score out of 100 based on form quality
    int score = widget.repsCompleted == 0 ? 0 : ((widget.goodReps / widget.repsCompleted) * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Review 
              const Text("Review", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 15),

              // Score Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text("$score / 100", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              // Animated bounce effect on the checkmark display
              Center(
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 3),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 60,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // What went well section
              _buildSectionTitle("What went well"),
              _buildReviewItem(Icons.check_circle, Colors.tealAccent,
                "Completed ${widget.repsCompleted} total reps"),
              if (score > 70) _buildReviewItem(Icons.check_circle, Colors.tealAccent, "Maintained great form throughout"),
              _buildReviewItem(Icons.check_circle, Colors.tealAccent, "Camera view stayed clear"),

              const SizedBox(height: 30),

              // Needs work section
              if (widget.errors.isNotEmpty) ...[
                _buildSectionTitle("Needs work"),

                // Squats errors
                if (widget.errors.contains("Back Bending"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Back rounds up at the bottom, keep the back straigth as possible"),
                if (widget.errors.contains("Shallow Depth"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Range of motion was too short, go deeper"),
                if (widget.errors.contains("Stand sideways"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Body was not in the ideal positioning for Pose Detection tracking"),
                if (widget.errors.contains("Form Issues"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Form issues detected during the set, focus on controlled movement"),

                // Pushup errors
                if (widget.errors.contains("Body not straight"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Keep your body in a straight line from head to heels during push-ups"),

                // Lunge errors
                if (widget.errors.contains("Torso Lean"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Keep your torso upright during lunges, avoid leaning forward"),
                if (widget.errors.contains("Incorrect Form"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Remember to step one leg forward and lunge down, not squat down"),

                // Bicep Curl errors
                if (widget.errors.contains("Elbow Swinging"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Keep your upper arm still, your elbow should not swing forward during the curl"),
                if (widget.errors.contains("Shallow Curl"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Curl the weight all the way up so your forearm touches your bicep for full range"),

                // Lateral Raise errors
                if (widget.errors.contains("Standing sideways"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Face directly infront of the camera for Lateral Raises so the AI can see arm height"),
                if (widget.errors.contains("Asymmetric Raise"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "One arm was raised higher than the other, focus on lifting evenly"),
                if (widget.errors.contains("Shallow Raise"))
                  _buildReviewItem(Icons.cancel, Colors.redAccent, "Arms did not reach shoulder height, increase your range of motion"),

                const SizedBox(height: 30),
              ],

              // Static tips for next set section 
              _buildSectionTitle("Tips for next set"),
              // tips change based on the exercise
              ..._buildExerciseTips(widget.exerciseName),

              const SizedBox(height: 40),

              // Go Home button to navigate to home screen
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Go back to Home Screen',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Another set button 
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    // Load a fresh GetReadyScreen for the user
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GetReadyScreen(exerciseName: widget.exerciseName),
                      ),
                    );
                  },
                  child: const Text(
                    'Perform Another Set',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // to return summary screen based on exercise
  List<Widget> _buildExerciseTips(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'pushups':
        return [
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Keep your core tight and body in a straight line from head to toe"),
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Lower your chest all the way down to get a full range of motion"),
        ];
      case 'bicep curls': 
        return [
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Pin your elbows to your sides throughout the entire movement"),
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Curl all the way up and lower slowly for maximum muscle engagement"),
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Pro tip: Twist your biceps in-wards using you pinky finger"),
        ];
      case 'lateral raises': 
        return [
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Raise your arms until they are parallel to the floor till yout shoulder height"),
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Avoid swinging your body, use your shoulders to lift the weight"),
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Pro tip: Imagine your pouring a glass of water"),
        ];
      default: // Squats
        return [
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Brace your core and keep a straight line from head to heels. Try not to bend your back"),
          _buildReviewItem(Icons.lightbulb, Colors.yellowAccent, "Perform a complete rep with proper form"),
        ];
    }
  }

  // Helper widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  // Helper widget for individual review items
  Widget _buildReviewItem(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 15))),
        ],
      ),
    );
  }
}