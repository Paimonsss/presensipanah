import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:panah_presensi/app_theme.dart';
import 'package:panah_presensi/screen/dashboard/dashboard_screen.dart';
import 'package:panah_presensi/screen/absensi/absensi_screen.dart';
import 'package:panah_presensi/screen/profil/profil_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void switchToTab(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  void _onPageChanged(int i) => setState(() => _currentIndex = i);

  void _onTap(int i) {
    _pageController.animateToPage(i,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: [
              const DashboardScreen(),
              AbsensiScreen(),
              const ProfilScreen(),
            ],
          ),
          // ═══ FLOATING PILL NAV ═══
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.snow.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: AppTheme.navShadow,
                    border: Border.all(
                      color: AppTheme.slate.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(
                          Icons.home_outlined, Icons.home_rounded, "Home", 0),
                      _centerNavItem(),
                      _navItem(Icons.person_outline_rounded,
                          Icons.person_rounded, "Profil", 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index) {
    final active = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.coral.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon,
                color: active ? AppTheme.coral : AppTheme.slate, size: 22),
            if (active) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.coral,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _centerNavItem() {
    final active = _currentIndex == 1;
    return GestureDetector(
      onTap: () => _onTap(1),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.coralGradient : null,
          color: active ? null : AppTheme.cloud,
          shape: BoxShape.circle,
          boxShadow: active ? AppTheme.coralGlow : null,
        ),
        child: Image.asset(
          'assets/image/logo.png',
          width: 32,
          height: 32,
          color: active ? Colors.white : AppTheme.slate,
          colorBlendMode: BlendMode.srcATop,
        ),
      ),
    );
  }
}
