import 'package:flutter/material.dart';
import 'package:panah_presensi/screen/dashboard/dashboard_screen.dart';
import 'package:panah_presensi/screen/profil/profil_screen.dart';

class AbsensiScreen extends StatefulWidget {
  @override
  _AbsensiScreenState createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  int _selectedIndex = 1; // Presensi di tengah

  final TextEditingController nomorAnggotaController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController kodeAbsensiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set tanggal hari ini sebagai default
    tanggalController.text = _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
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

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        tanggalController.text = _formatDate(pickedDate);
      });
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

  void _submitHadir() {
    // TODO: Implementasi submit absensi ke Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Absensi berhasil dicatat!"),
        backgroundColor: Colors.green,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  children: [
                    // Icon Person
                    Icon(Icons.account_circle,
                        size: 80, color: Colors.grey[800]),
                    const SizedBox(height: 30),

                    // Form Fields
                    TextField(
                      controller: nomorAnggotaController,
                      decoration: _inputDecoration("Nomor anggota"),
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: namaController,
                      decoration: _inputDecoration("Nama"),
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: tanggalController,
                      readOnly: true,
                      decoration: _inputDecoration("Tanggal").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today,
                              color: Colors.grey[600]),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Poppins'),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: kodeAbsensiController,
                      decoration: _inputDecoration("Kode Absensi"),
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Hadir
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitHadir,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
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
