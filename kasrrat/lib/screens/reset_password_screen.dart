import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/kasrrat_colors.dart';
import '../widgets/custom_text_field.dart';
import '../routes/app_routes.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Supabase Update Logic
  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (password.isEmpty || password.length < 6) {
      _showSnackBar("Password must be at least 6 characters.", Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // calling Supabase to update password for current recovery session
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      if (mounted) {
        _showSnackBar("Password updated successfully! Please login.", Colors.green);
        
        // Sedn user back to login screen after the password is reset
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      }
    } on AuthException catch (error) {
      _showSnackBar(error.message, Colors.red);
    } catch (error) {
      _showSnackBar("An unexpected error occurred.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
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
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // UI
              const Icon(Icons.lock_reset_rounded, size: 80, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                "New Password",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                "Set a strong password for your KasRrat account",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
              
              const SizedBox(height: 50),

              // Fleids
              CustomTextField(
                hint: "New Password:", 
                isPassword: true, 
                controller: _passwordController
              ),
              const SizedBox(height: 15),
              CustomTextField(
                hint: "Confirm Password:", 
                isPassword: true, 
                controller: _confirmPasswordController
              ),

              const SizedBox(height: 50),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _isLoading ? null : _updatePassword, 
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Update Password", 
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Cancel option
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                child: const Text("Back to Login", style: TextStyle(color: AppColors.textGrey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}