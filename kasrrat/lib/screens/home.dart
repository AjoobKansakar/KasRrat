import 'package:flutter/material.dart';
import '../core/kasrrat_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Hello, Ajoob!", style: TextStyle(fontWeight: FontWeight.bold)),
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
              // user's progress data Static for now
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
            const Text("Choose Your Workout", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Workout Grid
            GridView.count(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              crossAxisCount: 2, // 2 exercise per row
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _workoutCard("Squats", Icons.airline_seat_legroom_extra, "12 Sets"),
                _workoutCard("Pushups", Icons.fitness_center, "8 Sets"),
                _workoutCard("Lunges", Icons.directions_run, "5 Sets"),
                _workoutCard("Bicep Curls", Icons.accessibility_new, "10 Sets"),
              ],
            )
          ],
        ),
      ),
    );
  }

  // workout card build function
  Widget _workoutCard(String title, IconData icon, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 40),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        ],
      ),
    );
  }
}