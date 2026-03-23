import 'package:flutter/material.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:panah_presensi/screen/Login/LoginScreen.dart';
import 'package:panah_presensi/utils/lightweight_route.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() => lightPushReplacement(context, LoginScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ═══ Top bar ═══
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.coral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset('assets/image/logo.png',
                          width: 36, height: 36),
                    ),
                    const SizedBox(width: 10),
                    Text("Panah Presensi",
                        style: AppTheme.h3.copyWith(fontSize: 16)),
                    const Spacer(),
                    if (_currentPage == 0)
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text("Lewati",
                            style:
                                AppTheme.body.copyWith(color: AppTheme.coral)),
                      ),
                  ],
                ),
              ),

              // ═══ Pages ═══
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [_buildPage1(), _buildPage2()],
                ),
              ),

              // ═══ Bottom ═══
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (i) {
                        final active = _currentPage == i;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 32 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: active ? AppTheme.coralGradient : null,
                            color: active
                                ? null
                                : AppTheme.slate.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    CoralButton(
                      onPressed: _next,
                      child: Text(_currentPage == 0
                          ? "Berikutnya →"
                          : "Mulai Sekarang 🚀"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero illustration area
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/image/archery.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text("Selamat Datang! 🏹", style: AppTheme.h1),
          const SizedBox(height: 8),
          Text(
            "Aplikasi presensi digital untuk ekskul panahan.",
            style: AppTheme.bodyLarge.copyWith(height: 1.6),
          ),
          const SizedBox(height: 24),
          _featureItem("Absensi berbasis aplikasi", Icons.phone_android_rounded,
              AppTheme.coral),
          _featureItem(
              "Data tercatat digital", Icons.cloud_done_rounded, AppTheme.teal),
          _featureItem("Pantau kehadiran mudah", Icons.visibility_rounded,
              AppTheme.info),
          _featureItem(
              "Cepat dan simpel", Icons.bolt_rounded, AppTheme.warning),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smartphone_rounded,
                  size: 80, color: AppTheme.teal),
            ),
          ),
          const SizedBox(height: 32),
          Text("Absensi Lebih\nPraktis! 📱", style: AppTheme.h1),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.snow,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.ultraSoft,
            ),
            child: Text(
              "Cukup pakai ponsel pintarmu, nggak perlu ribet bawa alat tulis atau buku absensi. Simpel, cepat, dan bebas repot!",
              textAlign: TextAlign.justify,
              style: AppTheme.bodyLarge.copyWith(height: 1.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(String text, IconData icon, Color color) {
    return AccentCard(
      accentColor: color,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(text,
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.navy))),
          Icon(Icons.check_circle_rounded, color: color, size: 20),
        ],
      ),
    );
  }
}
