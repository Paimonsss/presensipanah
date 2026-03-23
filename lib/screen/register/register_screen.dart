import 'package:flutter/material.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:panah_presensi/screen/Login/LoginScreen.dart';
import 'package:panah_presensi/utils/lightweight_route.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailC = TextEditingController();
  final namaC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();
  bool _isLoading = false;
  bool _hidePass = true;
  bool _hideConfirm = true;

  Future<void> register() async {
    final email = emailC.text.trim();
    final nama = namaC.text.trim();
    final pass = passC.text.trim();
    if (email.isEmpty ||
        nama.isEmpty ||
        pass.isEmpty ||
        confirmC.text.trim().isEmpty) {
      _snack("Semua field harus diisi");
      return;
    }
    if (pass != confirmC.text.trim()) {
      _snack("Konfirmasi sandi tidak sesuai");
      return;
    }
    if (pass.length < 6) {
      _snack("Password minimal 6 karakter");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client.auth
          .signUp(email: email, password: pass);
      if (!mounted) return;
      final uid = res.user?.id;
      if (uid != null) {
        await Supabase.instance.client
            .from("anggota")
            .insert({'user_id': uid, 'nama': nama});
        _showSuccess();
      } else {
        _snack("Registrasi gagal, coba lagi");
      }
    } catch (e) {
      if (!mounted) return;
      _snack("Registrasi gagal. Periksa koneksi internet dan coba lagi.");
    }
    setState(() => _isLoading = false);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
      backgroundColor: AppTheme.navy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  void _showSuccess() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: const BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.slate.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppTheme.success, size: 48),
            ),
            const SizedBox(height: 16),
            const Text("Registrasi Berhasil!", style: AppTheme.h3),
            const SizedBox(height: 8),
            const Text("Silakan cek email untuk verifikasi, lalu login.",
                textAlign: TextAlign.center, style: AppTheme.body),
            const SizedBox(height: 24),
            CoralButton(
              onPressed: () {
                Navigator.pop(ctx);
                lightPushReplacement(context, LoginScreen());
              },
              child: const Text("OK, Ke Login"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppTheme.navy),
                  ),
                  const Spacer(),
                  Text("Daftar", style: AppTheme.h3),
                  const Spacer(),
                  const SizedBox(width: 48),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppTheme.mint, shape: BoxShape.circle),
                          child: const Icon(Icons.person_add_rounded,
                              size: 48, color: AppTheme.teal),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                          child: Text("Buat akun baru", style: AppTheme.body)),
                      const SizedBox(height: 28),
                      _label("Email"),
                      TextField(
                          controller: emailC,
                          keyboardType: TextInputType.emailAddress,
                          style:
                              AppTheme.bodyLarge.copyWith(color: AppTheme.navy),
                          decoration: AppTheme.inputDecoration(
                              label: "",
                              hint: "nama@email.com",
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: AppTheme.coral, size: 20))),
                      const SizedBox(height: 16),
                      _label("Nama"),
                      TextField(
                          controller: namaC,
                          style:
                              AppTheme.bodyLarge.copyWith(color: AppTheme.navy),
                          decoration: AppTheme.inputDecoration(
                              label: "",
                              hint: "Nama lengkap",
                              prefixIcon: const Icon(Icons.person_outlined,
                                  color: AppTheme.teal, size: 20))),
                      const SizedBox(height: 16),
                      _label("Kata Sandi"),
                      TextField(
                          controller: passC,
                          obscureText: _hidePass,
                          style:
                              AppTheme.bodyLarge.copyWith(color: AppTheme.navy),
                          decoration: AppTheme.inputDecoration(
                              label: "",
                              hint: "Min. 6 karakter",
                              prefixIcon: const Icon(Icons.lock_outline_rounded,
                                  color: AppTheme.coral, size: 20),
                              suffixIcon: IconButton(
                                  icon: Icon(
                                      _hidePass
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppTheme.slate,
                                      size: 20),
                                  onPressed: () =>
                                      setState(() => _hidePass = !_hidePass)))),
                      const SizedBox(height: 16),
                      _label("Konfirmasi Sandi"),
                      TextField(
                          controller: confirmC,
                          obscureText: _hideConfirm,
                          style:
                              AppTheme.bodyLarge.copyWith(color: AppTheme.navy),
                          decoration: AppTheme.inputDecoration(
                              label: "",
                              hint: "Ulangi kata sandi",
                              prefixIcon: const Icon(Icons.lock_outline_rounded,
                                  color: AppTheme.teal, size: 20),
                              suffixIcon: IconButton(
                                  icon: Icon(
                                      _hideConfirm
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppTheme.slate,
                                      size: 20),
                                  onPressed: () => setState(
                                      () => _hideConfirm = !_hideConfirm)))),
                      const SizedBox(height: 32),
                      CoralButton(
                        onPressed: _isLoading ? null : register,
                        isLoading: _isLoading,
                        child: const Text("Daftar"),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              lightPushReplacement(context, LoginScreen()),
                          child: RichText(
                              text: TextSpan(
                            text: "Sudah punya akun? ",
                            style: AppTheme.body,
                            children: [
                              TextSpan(
                                  text: "Masuk",
                                  style: AppTheme.bodyLarge.copyWith(
                                      color: AppTheme.coral,
                                      fontWeight: FontWeight.w700))
                            ],
                          )),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: AppTheme.bodyLarge
              .copyWith(color: AppTheme.navy, fontWeight: FontWeight.w600)),
    );
  }
}
