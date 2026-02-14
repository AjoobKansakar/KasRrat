import 'package:flutter/material.dart';
import '../core/kasrrat_colors.dart';

class SocialButton extends StatelessWidget {
  final String text;
  const SocialButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.fieldBorder),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}