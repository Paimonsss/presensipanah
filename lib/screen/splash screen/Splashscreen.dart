import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:panah_presensi/screen/onboarding/onboarding_screen.dart';
import 'package:panah_presensi/screen/main_screen.dart';
import 'package:panah_presensi/utils/lightweight_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    // Fade-in animation agar transisi lebih smooth
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Tampilkan splash 3 detik, lalu cek sesi login
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // User sudah login → langsung ke MainScreen
        lightPushReplacement(context, const MainScreen());
      } else {
        // User belum login → ke OnboardingScreen
        lightPushReplacement(context, OnboardingScreen());
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: FadeTransition(
          opacity: _fadeController,
          child: RepaintBoundary(
            child: Lottie.asset(
              'assets/image/logo2.json',
              width: 150,
              height: 150,
              frameRate: FrameRate(30), // Batasi ke 30fps (hemat GPU)
              options: LottieOptions(
                enableMergePaths: true, // Optimasi render path
              ),
            ),
          ),
        ),
      ),
    );
  }
}
