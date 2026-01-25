import 'package:flutter/material.dart';

class PanahPresensi extends StatelessWidget {
  const PanahPresensi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panah Presensi'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: const Text(
          'Halaman Utama',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol panah kiri untuk kembali
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 30),
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
            ),
            // Tombol panah kanan untuk maju ke halaman berikutnya
            IconButton(
              icon: const Icon(Icons.arrow_forward, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NextScreen(),
                  ),
                ); // Menuju ke halaman berikutnya
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NextScreen extends StatelessWidget {
  const NextScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Berikutnya'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: const Text(
          'Ini adalah halaman berikutnya.',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol panah kiri untuk kembali
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 30),
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
            ),
          ],
        ),
      ),
    );
  }
}
