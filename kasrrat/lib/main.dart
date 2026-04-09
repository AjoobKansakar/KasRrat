import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
// Supabase Import
import 'package:supabase_flutter/supabase_flutter.dart';
// import for StreamSubscription/live connection
import 'dart:async'; 

Future<void> main() async {
  // Flutter cloud connection
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase
  await Supabase.initialize(
    url: 'https://qdoprrnffikvwlkdcccx.supabase.co',
    anonKey: 'sb_publishable_Gn1H7BM8cABc85ajouVeOw_-F4gINdS',
  );

  runApp(const KasRratApp());
}

final supabase = Supabase.instance.client;

// Global key to allow navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class KasRratApp extends StatefulWidget {
  const KasRratApp({super.key});

  @override
  State<KasRratApp> createState() => _KasRratAppState();
}

class _KasRratAppState extends State<KasRratApp> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  // Global Listener for Password Recovery 
  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // Using the master key to jump to the reset screen immediately
        navigatorKey.currentState?.pushNamed(AppRoutes.resetPassword);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // master key
      debugShowCheckedModeBanner: false,
      title: 'KasRrat',
      theme: ThemeData.dark(),

      // show the login screen first
      initialRoute: AppRoutes.login,

      // maping for navigation
      routes: AppRoutes.getRoutes(),
    );
  }
}