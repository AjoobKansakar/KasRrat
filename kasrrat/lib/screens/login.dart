import 'package:flutter/material.dart';
import '../core/kasrrat_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart'; 
import '../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Login to continue your training",
                  style: TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 30),

                // Sign In <---> Sign Up Toggle
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "Sign in",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        // navigation
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signup),
                          child: const Center(
                            child: Text(
                              "Sign up", 
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const CustomTextField(hint: "Email address:"),
                const CustomTextField(hint: "Password:", isPassword: true),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text("Forgot Password?", style: TextStyle(color: AppColors.primary)),
                ),

                const SizedBox(height: 40),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      // Login Logic for later
                    },
                    child: const Text("Login", 
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.fieldBorder)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR", style: TextStyle(color: AppColors.textGrey)),
                    ),
                    Expanded(child: Divider(color: AppColors.fieldBorder)),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  children: const [
                    Expanded(child: SocialButton(text: "Google")),
                    SizedBox(width: 15),
                    Expanded(child: SocialButton(text: "Apple")),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AppColors.textGrey)),
                    // navigation
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signup),
                      child: Text("Sign Up!", 
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
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