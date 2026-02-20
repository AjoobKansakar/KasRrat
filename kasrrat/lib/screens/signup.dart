import 'package:flutter/material.dart';
// SupaBase import
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/kasrrat_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import '../routes/app_routes.dart'; 

class SignUpScreen extends StatefulWidget { 
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // To get user input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // loading spinner
  bool _isLoading = false; 

  Future<void> _handleSignUp() async {
    // Validations
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    setState(() => _isLoading = true); // Start loading

    try {
      final supabase = Supabase.instance.client;
      
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'full_name': _nameController.text.trim()},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful! Please check your email.")),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
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
          const SnackBar(content: Text("An unexpected error occurred."), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Stop loading
    }
  }

  @override
  void dispose() {
    // Cleaning up controllers to save memory
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
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
                    // CLickable Toggle 
                    Expanded(
                      // navigation
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                        child: const Center(
                          child: Text("Sign in", style: TextStyle(color: AppColors.textGrey)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text("Sign up", 
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

                const SizedBox(height: 35),

                // controller use
                CustomTextField(hint: "Name:", controller: _nameController),
                CustomTextField(hint: "Email address:", controller: _emailController),
                CustomTextField(hint: "Password:", isPassword: true, controller: _passwordController),
                CustomTextField(hint: "Confirm password:", isPassword: true, controller: _confirmPasswordController),

                const SizedBox(height: 15),

                const Row(
                  children: [
                    Icon(Icons.check_box_outline_blank, color: AppColors.textGrey),
                    SizedBox(width: 8),
                    Text("Remember me", style: TextStyle(color: AppColors.textGrey)),
                  ],
                ),

                const SizedBox(height: 30),

                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isLoading ? null : _handleSignUp,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "Sign up",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                  ),
                ),

                const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: AppColors.textGrey)),
                  // navigation
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                    child: const Text(
                      "Sign in!",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Social Button
              const SizedBox(
                width: double.infinity,
                child: SocialButton(text: "Continue with Google"),
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