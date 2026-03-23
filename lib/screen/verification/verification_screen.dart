import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:panah_presensi/screen/Login/LoginScreen.dart';
import 'package:panah_presensi/utils/lightweight_route.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String nama;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.nama,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _canResend = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _canResend = false;
      _countdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        setState(() {
          _canResend = true;
        });
        return false;
      }
      return true;
    });
  }

  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpCode;

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan 6 digit kode verifikasi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        token: otp,
        email: widget.email,
      );

      if (response.user != null) {
        await Supabase.instance.client.from("anggota").insert({
          'user_id': response.user!.id,
          'nama': widget.nama,
        });

        await Supabase.instance.client.auth.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verifikasi berhasil! Silakan login.")),
        );

        lightPushReplacement(context, LoginScreen());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verifikasi gagal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Verifikasi gagal. Periksa kode dan coba lagi.")),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode verifikasi telah dikirim ulang")),
      );

      _startCountdown();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Gagal mengirim ulang kode. Coba lagi nanti.")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ═══ TOP BAR ═══
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppTheme.navy),
                  ),
                  const Spacer(),
                  Text("Verifikasi",
                      style: AppTheme.h3.copyWith(fontSize: 16)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ]),
              ),

              const SizedBox(height: 24),

              // ═══ CONTENT ═══
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Email icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.peach,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mark_email_read_rounded,
                            color: AppTheme.coral, size: 48),
                      ),

                      const SizedBox(height: 24),

                      Text("Verifikasi Email", style: AppTheme.h2),
                      const SizedBox(height: 10),
                      Text(
                        "Masukkan kode 6 digit yang telah dikirim ke",
                        textAlign: TextAlign.center,
                        style: AppTheme.body,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.coral,
                            fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 32),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 48,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.cloud,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _focusNodes[index].hasFocus
                                    ? AppTheme.coral
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                color: AppTheme.navy,
                              ),
                              decoration: const InputDecoration(
                                counterText: "",
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                setState(() {});
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      // Verify button
                      CoralButton(
                        onPressed: _isLoading ? null : _verifyOTP,
                        isLoading: _isLoading,
                        child: const Text("Verifikasi"),
                      ),

                      const SizedBox(height: 24),

                      // Resend OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Tidak menerima kode? ",
                              style: AppTheme.body),
                          GestureDetector(
                            onTap: _canResend ? _resendOTP : null,
                            child: Text(
                              _canResend
                                  ? "Kirim Ulang"
                                  : "Kirim Ulang ($_countdown)",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _canResend
                                    ? AppTheme.coral
                                    : AppTheme.slate,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
