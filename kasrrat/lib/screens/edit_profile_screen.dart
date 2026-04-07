import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/kasrrat_colors.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch current data to show in text fields
  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _nameController.text = user.userMetadata?['full_name'] ?? "";
      _emailController.text = user.email ?? "";
    }
  }

  // update profile logic
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {'full_name': _nameController.text.trim()},
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!")),
        );
      }
    } catch (e) {
      debugPrint("Update error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // reset password logic
  Future<void> _handlePasswordReset() async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset link sent to your email!")),
        );
      }
    } catch (e) {
      debugPrint("Reset error: $e");
    }
  }

  // delete account Logic
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primary, width: 1)),
        title: const Text("Are you sure you want to delete your account?", 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text("This action is permanent and cannot be undone.", 
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("No", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const VerticalDivider(color: Colors.white24),
              Expanded(
                child: TextButton(
                onPressed: () async {
                  // Logic to sign out and navigate
                  await Supabase.instance.client.auth.signOut();
                  
                  // Check if the context is still active after the async gap
                  if (!context.mounted) return;

                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
                  child: const Text("Yes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

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
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _showDeleteDialog,
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Icon Placeholder
            const Icon(Icons.person_pin, size: 100, color: Colors.white),
            const SizedBox(height: 50),

            CustomTextField(hint: "User Name", controller: _nameController),
            CustomTextField(hint: "Email address", controller: _emailController),
            
            const SizedBox(height: 20),
            
            // Reset Password Trigger
            GestureDetector(
              onTap: _handlePasswordReset,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.fieldBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("Reset password", style: TextStyle(color: Colors.white70)),
                ),
              ),
            ),

            const SizedBox(height: 100),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("Update Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}