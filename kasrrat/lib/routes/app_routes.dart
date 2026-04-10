import 'package:flutter/material.dart';
import '../screens/signup.dart';
import '../screens/login.dart';
import '../screens/home.dart';
import '../screens/reset_password_screen.dart'; 
import '../screens/splash_screen.dart';
import '../screens/about_screen.dart';

class AppRoutes {
  // splash screen as the default route path
  static const String splash = '/'; 
  static const String about = '/about';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';
  // trigger workout summary
  static const String workoutComplete = '/workout-complete'; 
  // trigger reset password
  static const String resetPassword = '/reset-password';
 
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      about: (context) => const AboutScreen(),
      signup: (context) => const SignUpScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
      resetPassword: (context) => const ResetPasswordScreen(), 
    };
  }
}