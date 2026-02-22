import 'package:flutter/material.dart';
import '../core/kasrrat_colors.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Logic to track if the text is hidden or visible
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Initialize _obscureText on Password Field
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: widget.controller,
        // Use local _obscureText variable
        obscureText: _obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          // Eye icons feature
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textGrey,
                  ),
                  onPressed: () {
                    // Toggle the visibility
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}