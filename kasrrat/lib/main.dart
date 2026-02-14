import 'package:flutter/material.dart';
import 'screens/signup.dart';

void main() {
  runApp(const KasRratApp());
}

class KasRratApp extends StatelessWidget {
  const KasRratApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KasRrat',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyanAccent,
      ),
      home: const SignUpScreen(),
    );
  }
}