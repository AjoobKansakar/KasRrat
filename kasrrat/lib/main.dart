import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/login.dart';
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
      theme: ThemeData.dark(),
  
      // show the login screen first
      initialRoute: AppRoutes.login, 
      
      // navigtaion routes of the application
      routes: {
        AppRoutes.signup: (context) => const SignUpScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
      },
    );
  }
}