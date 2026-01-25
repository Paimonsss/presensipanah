import 'package:flutter/material.dart';
import 'package:panah_presensi/screen/halaman2/halaman2_screen.dart';

class Halaman1Screen extends StatefulWidget {
  const Halaman1Screen({super.key});

  @override
  State<Halaman1Screen> createState() => _Halaman1ScreenState();
}

class _Halaman1ScreenState extends State<Halaman1Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
         title: Text('Panah Presensi',
         style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins'
         ),
         ),
        centerTitle: true, // Mengatur teks agar berada di tengah
        leading: IconButton(
        icon: Icon(Icons.arrow_forward),
        onPressed: () {
          //Navigasi kembali
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => Halaman2Screen())
            );
        },
      ),
        
          ),
          );
  }
}