import 'package:flutter/material.dart';
import 'package:panah_presensi/screen/absensi/absensi_screen.dart';

 // Import halaman DashboardScreen

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedIndex = 1; // Menyimpan tab yang dipilih (1 untuk Akun)

  // Fungsi untuk menangani perubahan tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Jika tab Dashboard dipilih, arahkan ke halaman DashboardScreen
    if (_selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AbsensiScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header dengan logo dan judul
          Container(
            color: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 100),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/image/logo.png', fit: BoxFit.contain),
                ),
                SizedBox(height: 10),
                Text(
                  'PANAH PRESENSI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Selamat datang dan motivasi
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang, Nama!',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '"Fokus adalah kunci, bidik tujuanmu. Selamat berlatih!"',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Informasi akun
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // ID Anggota
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Text(
                    'ID ANGGOTA',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ),
                // Nama Anggota
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Text(
                    'NAMA ANGGOTA',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Peserta
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Text(
                    'PESERTA',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Kelas
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Text(
                    'KELAS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Keluar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                // Tambahkan logika keluar jika diperlukan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                 foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Center(
                child: Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Menyinkronkan tab yang dipilih
        onTap: _onItemTapped, // Fungsi yang dipanggil saat tab ditekan
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akun',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
