import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
// Supabase Import
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'screens/login.dart';
// import 'screens/signup.dart';

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

      // maping for navigation
      routes: AppRoutes.getRoutes(),
    );
  }
}
