import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Are you ready to master your exercises?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "KasRrat uses computer vision to ensure every rep you perform is perfect.",
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
              const SizedBox(height: 40),
              
              // KasRrat description list
              _buildPoint("1.", "Lift with Confidence:", "Stop second-guessing your technique and start training with certainty."),
              _buildPoint("2.", "Optimize Every Rep:", "Ensure your muscles are fully engaged by maintaining the perfect range of motion."),
              _buildPoint("3.", "Set Performance Tracking:", "Automated set summary and streak tracking to keep you on track."),
              _buildPoint("4.", "Secured Coaching:", "All AI processing happens on your device, no video data ever leaves your phone."),
              
              const Spacer(),
              
              // Get Started btn
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: const Text(
                      "Get started with your KasRrat",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // helper with title & dscription for better clarity
  Widget _buildPoint(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number, 
            style: const TextStyle(color: Colors.white24, fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}