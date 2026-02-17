import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:panah_presensi/screen/Login/LoginScreen.dart';
import 'package:panah_presensi/utils/lightweight_route.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> register() async {
    final email = emailController.text.trim();
    final nama = namaController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty ||
        nama.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi sandi tidak sesuai")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 6 karakter")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Buat akun di Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final userId = response.user?.id;

      if (userId != null) {
        // 2. Insert ke tabel anggota
        await Supabase.instance.client.from("anggota").insert({
          'user_id': userId,
          'nama': nama,
        });

        // 3. Tampilkan popup sukses
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(Icons.check_circle, size: 50, color: Colors.green),
            title: const Text(
              "Registrasi Berhasil!",
              style:
                  TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Silakan cek email untuk verifikasi, lalu login.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // tutup dialog
                  lightPushReplacement(context, LoginScreen());
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi gagal, coba lagi")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontFamily: 'Poppins'),
      hintStyle: const TextStyle(fontFamily: 'Poppins'),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header merah
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            color: Colors.red,
            child: Column(
              children: [
                Image.asset(
                  'assets/image/logo.png',
                  fit: BoxFit.contain,
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 10),
                const Text(
                  "PANAH PRESENSI",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.black54),
                  const SizedBox(height: 5),
                  const Center(
                    child: Text(
                      "Silahkan daftar",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextField(
                    controller: emailController,
                    decoration: _inputDecoration("Email", "Masukkan email"),
                  ),
                  const SizedBox(height: 15),

                  // Nama
                  TextField(
                    controller: namaController,
                    decoration:
                        _inputDecoration("Nama", "Masukkan nama anggota"),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration:
                        _inputDecoration("Kata Sandi", "Masukkan kata sandi"),
                  ),
                  const SizedBox(height: 15),

                  // Konfirmasi Password
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration(
                        "Konfirmasi Sandi", "Masukkan kata sandi kembali"),
                  ),
                  const SizedBox(height: 25),

                  // Tombol daftar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Daftar"),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Sudah punya akun
                  Center(
                    child: TextButton(
                      onPressed: () {
                        lightPushReplacement(context, LoginScreen());
                      },
                      child: const Text(
                        "Sudah punya akun? Masuk",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
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
    );
  }
}
