import 'package:flutter/material.dart';
import 'package:panah_presensi/screen/absensi/absensi_screen.dart';
import 'package:panah_presensi/screen/register/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // TODO: Ganti dengan Web Client ID dari Google Cloud Console
  static const String webClientId =
      '229312233486-kli5atno31233jagqgaa3isoubh4d3tq.apps.googleusercontent.com';

  Future<void> login() async {
    setState(() => _isLoading = true);

    try {
      final authResponse =
          await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      if (authResponse.session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AbsensiScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email atau password salah")),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      // Cek jika error karena email belum dikonfirmasi
      if (e.code == 'email_not_confirmed') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(Icons.email_outlined,
                size: 50, color: Colors.orange),
            title: const Text(
              "Verifikasi Email",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              "Verifikasi email dulu di Gmail!",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins'),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login gagal: ${e.message}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login gagal: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User membatalkan login
        setState(() => _isGoogleLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Gagal mendapatkan ID Token dari Google');
      }

      // Login ke Supabase dengan Google ID Token
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AbsensiScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login dengan Google gagal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isGoogleLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
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

            // Ikon profil
            const Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.black,
            ),
            const SizedBox(height: 10),

            const Text(
              "Silahkan masuk menggunakan akun anggota atau pengurus",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),

            // 📝 Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email
                  TextField(
                    controller: emailController,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(fontFamily: 'Poppins'),
                      hintText: "Masukkan email",
                      hintStyle: const TextStyle(fontFamily: 'Poppins'),
                      filled: true,
                      fillColor: Colors.grey[200],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      labelText: "Kata Sandi",
                      labelStyle: const TextStyle(fontFamily: 'Poppins'),
                      hintText: "Masukkan kata sandi",
                      hintStyle: const TextStyle(fontFamily: 'Poppins'),
                      filled: true,
                      fillColor: Colors.grey[200],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Lupa kata sandi
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // fungsi lupa password nanti di sini
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(50, 20),
                      ),
                      child: const Text(
                        "Lupa kata sandi ?",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tombol login
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Masuk"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider dengan teks "atau"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "atau",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tombol Login dengan Google
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isGoogleLoading ? null : signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _isGoogleLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[600],
                              ),
                            )
                          : Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.g_mobiledata,
                                      size: 24, color: Colors.red),
                            ),
                      label: Text(
                        _isGoogleLoading
                            ? "Memproses..."
                            : "Masuk dengan Google",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Daftar
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()));
                      },
                      child: const Text(
                        "Belum punya akun? Daftar",
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
          ],
        ),
      ),
    );
  }
}
