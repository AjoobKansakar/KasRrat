import 'package:flutter/material.dart';
import '../core/kasrrat_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart'; 
import '../routes/app_routes.dart';
// supabase 
import 'package:supabase_flutter/supabase_flutter.dart'; 

class LoginScreen extends StatefulWidget { 
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // To get user input for login
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // loading spinner
  bool _isLoading = false;

  // Supabase Logic 
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true); // loading
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ).timeout(const Duration(seconds: 15));

      if (mounted) {
        // Navigate to home after successful login
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection Time Out. Check your internet connection please."), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Stop loading
    }
  }

  @override
  void dispose() {
    // Cleaning up controllers to save memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                  "Sign in to continue your training",
                  style: TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 30),

                // Toggle
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      // Active side
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
                      // Clickable Side
                      Expanded(
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

                // Fields reused from signup
                CustomTextField(hint: "Email address:", controller: _emailController),
                CustomTextField(hint: "Password:", isPassword: true, controller: _passwordController),

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
                    onPressed: _isLoading ? null : _handleLogin, 
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Sign in", 
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

                // Social Buttons
                const SizedBox(
                  width: double.infinity,
                  child: SocialButton(text: "Continue with Google"),
                ),

                const SizedBox(height: 30),

                // Link to Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AppColors.textGrey)),
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