import 'package:flutter/material.dart';
import '../core/kasrrat_colors.dart';
import 'workout_session_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Workout Goal', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exercise Title
            Text(
              widget.exerciseName,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            const Text("Select how many repetitions you want to perform", 
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
            
            const SizedBox(height: 40),

            // Rep Selection Grid
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: _repOptions.map((rep) {
                final isSelected = _selectedReps == rep;
                return GestureDetector(
                  onTap: () => setState(() => _selectedReps = rep),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
                    ),
                    child: Center(
                      child: Text('$rep', 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, 
                        color: isSelected ? Colors.black : Colors.white)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            // Navigation button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedReps != null ? AppColors.primary : AppColors.surfaceGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _selectedReps == null ? null : () {
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
                child: const Text("START SET", 
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}