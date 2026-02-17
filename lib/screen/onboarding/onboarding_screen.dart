import 'package:flutter/material.dart';
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

  void _goToNextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    lightPushReplacement(context, LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header merah dengan rounded bottom corners
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset(
                    'assets/image/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "PANAH PRESENSI",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // PageView untuk swipe antar halaman
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildPage1(),
                _buildPage2(),
              ],
            ),
          ),

          // Bottom navigation area dengan background PUTIH
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            color: Colors.white,
            child: _currentPage == 0 ? _buildBottomNav1() : _buildBottomNav2(),
          ),
        ],
      ),
    );
  }

  // Bottom navigation untuk halaman 1
  Widget _buildBottomNav1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tombol LEWATI - outlined merah
        OutlinedButton(
          onPressed: _goToLogin,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text(
            "LEWATI",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Dots indicator - halaman 1 aktif
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),

        // Tombol BERIKUT - outlined merah
        OutlinedButton(
          onPressed: _goToNextPage,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text(
            "BERIKUT",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Bottom navigation untuk halaman 2
  Widget _buildBottomNav2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dots indicator - halaman 2 aktif
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),

        const SizedBox(width: 20),

        // Tombol SELESAI - outlined merah
        OutlinedButton(
          onPressed: _goToLogin,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
          ),
          child: const Text(
            "SELESAI",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Konten Halaman 1
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Judul bold
          const Text(
            "Selamat Datang di Panah Presensi!",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const Text(
            "Aplikasi ini dirancang untuk membantu pencatatan absensi rutin.",
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          // Checklist items
          _buildCheckItem("Absensi berbasis aplikasi"),
          const SizedBox(height: 12),
          _buildCheckItem("Terdata secara digital"),
          const SizedBox(height: 12),
          _buildCheckItem("Memantau kehadiran murid"),
          const SizedBox(height: 12),
          _buildCheckItem("Mudah, cepat dan simple"),
        ],
      ),
    );
  }

  // Konten Halaman 2
  Widget _buildPage2() {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text(
            "Absensi ekskul panahan jadi lebih praktis! Cukup pakai ponsel pintarmu, nggak perlu ribet bawa alat tulis atau buku absensi. Simpel, cepat, dan bebas repot!",
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
