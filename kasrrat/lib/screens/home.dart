import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../core/kasrrat_colors.dart';
// Navigation from exercise card to GetReadyScreen
import 'get_ready_screen.dart';  

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user from Supabase
    final user = Supabase.instance.client.auth.currentUser;

    // Get the username
    final String userName = user?.userMetadata?['full_name'] ?? "User";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Hello, $userName!", style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline, color: AppColors.primary))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User progress 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text("Today's Progress", style: TextStyle(color: AppColors.textGrey)),
                  const SizedBox(height: 10),
                  const Text("125 Reps", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 5),
                  const Text("Target: 200 Reps", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("Choose your workout for today", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Workout Grid
            GridView.count(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              crossAxisCount: 2, // 2 exercise per row
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                // adding Icons images to the exercise cards
                _workoutCard(context, "Squats", "assets/icons/Squats_icon.png"),
                _workoutCard(context, "Pushups", "assets/icons/PushUp_icon.png"),
                _workoutCard(context, "Lateral Raises", "assets/icons/LateralRaises_icon.png"),
                _workoutCard(context, "Bicep Curls", "assets/icons/BicepsCurls_icon.png"),
              ],
            ),
            const SizedBox(height: 30),
            // Video Tutorial guide has been moved to the individual GetReadyScreen for each exercise.
          ],
        ),
      ),
    );
  }

  // workout card build function
  // ImagePath parameter
  Widget _workoutCard(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        // Navigation layout
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GetReadyScreen(exerciseName: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using Image.asset to display images
            Image.asset(
              imagePath,
              width: 60, // icon size
              height: 60,
              // icon color
              color: AppColors.primary, 
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(height: 15),
            Text(
              title, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}