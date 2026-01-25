import 'package:flutter/material.dart';
import 'package:panah_presensi/screen/halaman1/halaman1_screen.dart';
import 'package:panah_presensi/screen/halaman3/halaman3_scrren.dart';


class Halaman2Screen extends StatefulWidget {
  const Halaman2Screen({super.key});

  @override
  State<Halaman2Screen> createState() => _Halaman2ScreenState();
}

class _Halaman2ScreenState extends State<Halaman2Screen> {
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
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          //Navigasi kembali
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => Halaman1Screen())
            );
        },
      ),
      actions: [
         IconButton(
        icon: Icon(Icons.arrow_forward),
        onPressed: () {
          //Navigasi kembali
          Navigator.pop(
            context, 
            MaterialPageRoute(builder: (context) => Halaman3Scrren())
            );
        },
      ),
      ],
    )
    );
  }
}