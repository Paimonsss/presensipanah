import 'package:flutter/material.dart';
import 'package:panah_presensi/screen/register/register_screen.dart';
import 'package:panah_presensi/utils/lightweight_route.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              lightPush(context, RegisterScreen());
            },
            child: Text(
              "",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      //backgroundColor: Color(0xFFFFD65A),
      body: Center(
        child: Text(
          "Selamat datang di aplikasi panah presensi! Dengan aplikasi ini, kamu bisa dengan mudah mencatat setiap sesi latihanmu, memantau progres, dan terhubung dengan komunitas panahan lainnya. Mari sama-sama tingkatkan kemampuan memanah kita!",
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            // Warna diperbaiki
          ),
        ),
      ),
    );
  }
}
