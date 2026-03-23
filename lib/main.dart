import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:panah_presensi/screen/splash%20screen/Splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: 'https://clparjsshhnxjgvwujzx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNscGFyanNzaGhueGpndnd1anp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5NDQyOTgsImV4cCI6MjA4MTUyMDI5OH0.Ud7OYgFGNiIP5sK_04uldvYASBb7KgOucCQkEnN_zQY',
  );

  try {
    await GoogleSignIn.instance.initialize(
      serverClientId:
          '229312233486-kli5atno31233jagqgaa3isoubh4d3tq.apps.googleusercontent.com',
    );
  } catch (_) {
    // Google Sign-In init may fail on web/desktop — akan tetap jalan di Android
  }

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
