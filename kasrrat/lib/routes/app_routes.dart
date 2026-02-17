import 'package:flutter/material.dart';
import '../screens/signup.dart';
import '../screens/login.dart';
import '../screens/home.dart';

class AppRoutes {
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      signup: (context) => const SignUpScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
    };
  }
}
