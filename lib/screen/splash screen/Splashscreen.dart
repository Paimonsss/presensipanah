import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:panah_presensi/screen/onboarding/onboarding_screen.dart'; // Jika Anda menggunakan Lottie animasi, pastikan sudah menambahkannya di pubspec.yaml

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Pindah ke OnboardingPage setelah 3 detik
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Lottie.asset(
          'assets/image/logo2.json', // Ganti ini dengan animasi Lottie Anda
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
