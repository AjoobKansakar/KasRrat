import 'package:flutter/material.dart';
import '../core/kasrrat_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 30),

                // Sign In / Sign Up Toggle
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Center(
                          child: Text("Sign in", style: TextStyle(color: AppColors.textGrey)),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary, // Changed from primaryCyan
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "Sign up",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                const CustomTextField(hint: "Name"),
                const CustomTextField(hint: "Email address"),
                const CustomTextField(hint: "Password", isPassword: true),
                const CustomTextField(hint: "Confirm password", isPassword: true),

                const SizedBox(height: 15),

                const Row(
                  children: [
                    Icon(Icons.check_box_outline_blank, color: AppColors.textGrey),
                    SizedBox(width: 8),
                    Text("Remember me", style: TextStyle(color: AppColors.textGrey)),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Changed from primaryCyan
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Sign up",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Already have an account? ", style: TextStyle(color: AppColors.textGrey)),
                    Text(
                      "Sign in!",
                      style: TextStyle(
                        color: AppColors.primary, // Changed from primaryCyan
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Row(
                  children: [
                    Expanded(child: SocialButton(text: "Google")),
                    SizedBox(width: 15),
                    Expanded(child: SocialButton(text: "Apple")),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}