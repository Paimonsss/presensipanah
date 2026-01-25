import 'package:flutter/material.dart';
import 'package:panah_presensi/screen/dashboard/dashboard_screen.dart';
import 'package:panah_presensi/screen/absensi/absensi_screen.dart';
import 'package:panah_presensi/screen/profil/profil_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  int _selectedIndex =
      0; // Default to Dashboard since Jadwal is accessed from menu

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AbsensiScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> jadwal = [
      {"hari": "Senin", "jam": "16:00 - 18:00", "kegiatan": "Latihan Panahan"},
      {"hari": "Rabu", "jam": "16:00 - 18:00", "kegiatan": "Latihan Fisik"},
      {
        "hari": "Sabtu",
        "jam": "08:00 - 11:00",
        "kegiatan": "Pertandingan Internal"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER MERAH LENGKUNG =====
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(
                  top: 40, bottom: 40, left: 20, right: 20),
              child: Row(
                children: [
                  // Tombol Back
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashboardScreen()),
                      );
                    },
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "JADWAL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44), // biar teks tetap center
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== LIST JADWAL =====
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: jadwal.length,
                itemBuilder: (context, index) {
                  final item = jadwal[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.red, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["hari"] ?? "-",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                item["kegiatan"] ?? "-",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                item["jam"] ?? "-",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ===== NAV BOTTOM (KONSISTEN: Dashboard - Presensi - Profil) =====
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/image/logo.png',
                  width: 28,
                  height: 28,
                ),
              ),
              label: 'Presensi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
