import 'package:flutter/material.dart';
import 'package:panah_presensi/screen/dashboard/dashboard_screen.dart';
import 'package:panah_presensi/screen/profil/profil_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AbsensiScreen extends StatefulWidget {
  @override
  _AbsensiScreenState createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  int _selectedIndex = 1; // Presensi di tengah

  final TextEditingController kodeAbsensiController = TextEditingController();

  bool _isLoading = false;
  String? _userName;
  String? _anggotaId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Fetch anggota data
      final response = await Supabase.instance.client
          .from('anggota')
          .select('id, nama')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _userName = response['nama'];
          _anggotaId = response['id'];
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilScreen()),
      );
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Poppins',
        color: Colors.grey[400],
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Future<void> _submitHadir() async {
    final kode = kodeAbsensiController.text.trim().toUpperCase();

    if (kode.isEmpty) {
      _showError("Masukkan kode absensi terlebih dahulu");
      return;
    }

    if (_anggotaId == null) {
      _showError("Data anggota tidak ditemukan. Silakan login ulang.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Cari sesi dengan kode tersebut
      final sesiResponse = await Supabase.instance.client
          .from('sesi_absensi')
          .select('id, status, waktu_mulai')
          .eq('kode', kode)
          .maybeSingle();

      if (sesiResponse == null) {
        _showError("Kode absensi tidak ditemukan");
        setState(() => _isLoading = false);
        return;
      }

      if (sesiResponse['status'] != 'aktif') {
        _showError("Sesi absensi sudah ditutup");
        setState(() => _isLoading = false);
        return;
      }

      final sesiId = sesiResponse['id'];
      final waktuMulai = DateTime.parse(sesiResponse['waktu_mulai']);
      final now = DateTime.now();

      // Tentukan status berdasarkan waktu (terlambat jika > 15 menit dari mulai)
      final diffMinutes = now.difference(waktuMulai).inMinutes;
      final status = diffMinutes > 15 ? 'Terlambat' : 'Hadir';

      // 2. Cek apakah sudah absen di sesi ini
      final existingAbsensi = await Supabase.instance.client
          .from('absensi')
          .select('id')
          .eq('sesi_id', sesiId)
          .eq('anggota_id', _anggotaId!)
          .maybeSingle();

      if (existingAbsensi != null) {
        _showError("Anda sudah tercatat hadir di sesi ini");
        setState(() => _isLoading = false);
        return;
      }

      // 3. Insert absensi
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('absensi').insert({
        'sesi_id': sesiId,
        'anggota_id': _anggotaId,
        'user_id': user?.id,
        'status': status,
        'waktu_hadir': now.toIso8601String(),
      });

      // 4. Tampilkan sukses
      if (!mounted) return;

      kodeAbsensiController.clear();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            status == 'Hadir' ? Icons.check_circle : Icons.access_time,
            size: 50,
            color: status == 'Hadir' ? Colors.green : Colors.orange,
          ),
          title: Text(
            status == 'Hadir' ? "Berhasil Hadir!" : "Tercatat Terlambat",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            status == 'Hadir'
                ? "Kehadiran Anda berhasil dicatat."
                : "Kehadiran Anda dicatat sebagai terlambat.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError("Terjadi kesalahan: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
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
              padding: const EdgeInsets.only(top: 50, bottom: 30),
              child: Column(
                children: [
                  // Logo (tanpa border putih)
                  Image.asset(
                    'assets/image/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "PANAH PRESENSI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            // ===== FORM CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Icon Person
                    Icon(
                      Icons.account_circle,
                      size: 80,
                      color: Colors.grey[800],
                    ),
                    const SizedBox(height: 10),

                    // Nama user
                    if (_userName != null)
                      Text(
                        _userName!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Masukkan kode absensi yang diberikan oleh admin untuk mencatat kehadiran Anda.",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kode Absensi Field
                    TextField(
                      controller: kodeAbsensiController,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                      decoration: _inputDecoration("Masukkan Kode").copyWith(
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[400],
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Hadir
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitHadir,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Hadir",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ===== BOTTOM NAVIGATION 3 TAB =====
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
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
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
