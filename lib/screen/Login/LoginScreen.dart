import 'package:flutter/material.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:panah_presensi/screen/main_screen.dart';
import 'package:panah_presensi/screen/register/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:panah_presensi/utils/lightweight_route.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _showPass = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  Future<void> login() async {
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      if (res.session != null) {
        lightPushReplacement(context, const MainScreen());
      } else {
        _showError(Icons.error_outline, AppTheme.error, "Login Gagal",
            "Email atau password salah.");
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'email_not_confirmed') {
        _showError(Icons.email_outlined, AppTheme.warning, "Verifikasi Email",
            "Verifikasi email dulu di Gmail!");
      } else if (e.code == 'invalid_credentials') {
        _showError(Icons.error_outline, AppTheme.error, "Login Gagal",
            "Email atau password salah.");
      } else {
        _showError(Icons.warning_amber_rounded, AppTheme.warning,
            "Terjadi Kesalahan", "Terjadi gangguan, silakan coba lagi.");
      }
    } catch (e) {
      if (!mounted) return;
      _showError(Icons.error_outline, AppTheme.error, "Error",
          "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.");
    }
    setState(() => _isLoading = false);
  }

  Future<void> signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception('Gagal mendapatkan ID Token');
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      if (response.session != null) {
        lightPushReplacement(context, const MainScreen());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login dengan Google gagal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login Google gagal. Periksa koneksi internet Anda.")));
    }
    setState(() => _isGoogleLoading = false);
  }

  void _forgotPassword() {
    final resetEmailC = TextEditingController(text: emailController.text.trim());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          decoration: const BoxDecoration(
            color: AppTheme.snow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.lock_reset_rounded,
                  color: AppTheme.warning, size: 36),
            ),
            const SizedBox(height: 16),
            const Text("Reset Kata Sandi", style: AppTheme.h3),
            const SizedBox(height: 8),
            const Text(
                "Masukkan email untuk menerima link reset password.",
                textAlign: TextAlign.center,
                style: AppTheme.body),
            const SizedBox(height: 20),
            TextField(
              controller: resetEmailC,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.navy),
              decoration: AppTheme.inputDecoration(
                label: "",
                hint: "nama@email.com",
                prefixIcon: const Icon(Icons.email_outlined,
                    color: AppTheme.coral, size: 20),
              ),
            ),
            const SizedBox(height: 20),
            CoralButton(
              onPressed: () async {
                final email = resetEmailC.text.trim();
                if (email.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await Supabase.instance.client.auth
                      .resetPasswordForEmail(email);
                  if (!mounted) return;
                  _showError(Icons.check_circle_rounded, AppTheme.success,
                      "Email Terkirim!",
                      "Link reset password sudah dikirim ke $email. Cek inbox atau folder spam.");
                } catch (e) {
                  if (!mounted) return;
                  _showError(Icons.error_outline, AppTheme.error, "Gagal",
                      "Gagal mengirim email. Periksa koneksi internet Anda.");
                }
              },
              child: const Text("Kirim Link Reset"),
            ),
          ]),
        ),
      ),
    );
  }

  void _showError(IconData icon, Color color, String title, String msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.h3),
            const SizedBox(height: 8),
            Text(msg, textAlign: TextAlign.center, style: AppTheme.body),
            const SizedBox(height: 24),
            CoralButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Coba Lagi"),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Logo + title
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.peach,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/image/logo.png',
                            width: 100, height: 100, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 16),
                      Text("Selamat Datang! 👋", style: AppTheme.h1),
                      const SizedBox(height: 4),
                      Text("Masuk ke akun Panah Presensi",
                          style: AppTheme.body),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Email
                Text("Email",
                    style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.navy, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.navy),
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppTheme.inputDecoration(
                    label: "",
                    hint: "nama@email.com",
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppTheme.coral, size: 20),
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                Text("Kata Sandi",
                    style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.navy, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: !_showPass,
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.navy),
                  onSubmitted: (_) => _isLoading ? null : login(),
                  decoration: AppTheme.inputDecoration(
                    label: "",
                    hint: "••••••••",
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: AppTheme.coral, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _showPass ? Icons.visibility : Icons.visibility_off,
                          color: AppTheme.slate,
                          size: 20),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text("Lupa kata sandi?",
                        style:
                            AppTheme.caption.copyWith(color: AppTheme.coral)),
                  ),
                ),
                const SizedBox(height: 12),

                // Login button
                CoralButton(
                  onPressed: _isLoading ? null : login,
                  isLoading: _isLoading,
                  child: const Text("Masuk"),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(children: [
                  Expanded(
                      child: Container(
                          height: 1,
                          color: AppTheme.slate.withValues(alpha: 0.15))),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("atau", style: AppTheme.caption)),
                  Expanded(
                      child: Container(
                          height: 1,
                          color: AppTheme.slate.withValues(alpha: 0.15))),
                ]),
                const SizedBox(height: 24),

                // Google
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isGoogleLoading ? null : signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.navy,
                      side: BorderSide(
                          color: AppTheme.slate.withValues(alpha: 0.2)),
                      backgroundColor: AppTheme.snow,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.slate))
                        : Image.network('https://www.google.com/favicon.ico',
                            width: 22,
                            height: 22,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.g_mobiledata, size: 22)),
                    label: Text(
                        _isGoogleLoading
                            ? "Memproses..."
                            : "Masuk dengan Google",
                        style:
                            AppTheme.bodyLarge.copyWith(color: AppTheme.navy)),
                  ),
                ),
                const SizedBox(height: 32),

                // Register
                Center(
                  child: GestureDetector(
                    onTap: () => lightPush(context, RegisterScreen()),
                    child: RichText(
                        text: TextSpan(
                      text: "Belum punya akun? ",
                      style: AppTheme.body,
                      children: [
                        TextSpan(
                            text: "Daftar",
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
      ),
    );
  }
}
