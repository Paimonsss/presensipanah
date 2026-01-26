import 'package:flutter/material.dart';
import 'package:panah_presensi/screen/dashboard/dashboard_screen.dart';
import 'package:panah_presensi/screen/onboarding/onboarding_screen.dart';
import 'package:panah_presensi/screen/splash%20screen/Splashscreen.dart';
import 'package:panah_presensi/screen/welcome/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://clparjsshhnxjgvwujzx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNscGFyanNzaGhueGpndnd1anp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5NDQyOTgsImV4cCI6MjA4MTUyMDI5OH0.Ud7OYgFGNiIP5sK_04uldvYASBb7KgOucCQkEnN_zQY',
  );

  runApp(MyApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Panah Presensi',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
