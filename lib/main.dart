import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:panah_presensi/screen/splash%20screen/Splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fullscreen edge-to-edge mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: 'https://clparjsshhnxjgvwujzx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNscGFyanNzaGhueGpndnd1anp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5NDQyOTgsImV4cCI6MjA4MTUyMDI5OH0.Ud7OYgFGNiIP5sK_04uldvYASBb7KgOucCQkEnN_zQY',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Panah Presensi',
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
