import 'package:flutter/material.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AbsensiScreen extends StatefulWidget {
  @override
  _AbsensiScreenState createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  final TextEditingController kodeC = TextEditingController();
  bool _isLoading = false;
  String? _userName;
  String? _anggotaId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final r = await Supabase.instance.client
          .from('anggota')
          .select('id, nama')
          .eq('user_id', user.id)
          .maybeSingle();
      if (r != null && mounted) {
        setState(() {
          _userName = r['nama'];
          _anggotaId = r['id'];
        });
      }
    }
  }

  Future<void> _submit() async {
    final kode = kodeC.text.trim().toUpperCase();
    if (kode.isEmpty) {
      _snack("Masukkan kode absensi");
      return;
    }
    if (_anggotaId == null) {
      _snack("Data anggota tidak ditemukan");
      return;
    }
    setState(() => _isLoading = true);
    try {
      final sesi = await Supabase.instance.client
          .from('sesi_absensi')
          .select('id, status, waktu_mulai')
          .eq('kode', kode)
          .maybeSingle();
      if (sesi == null) {
        _snack("Kode tidak ditemukan");
        setState(() => _isLoading = false);
        return;
      }
      if (sesi['status'] != 'aktif') {
        _snack("Sesi sudah ditutup");
        setState(() => _isLoading = false);
        return;
      }

      final existing = await Supabase.instance.client
          .from('absensi')
          .select('id')
          .eq('sesi_id', sesi['id'])
          .eq('anggota_id', _anggotaId!)
          .maybeSingle();
      if (existing != null) {
        _snack("Sudah tercatat hadir");
        setState(() => _isLoading = false);
        return;
      }

      final now = DateTime.now();
      final diff =
          now.difference(DateTime.parse(sesi['waktu_mulai'])).inMinutes;
      final status = diff > 15 ? 'Terlambat' : 'Hadir';
      final user = Supabase.instance.client.auth.currentUser;

      await Supabase.instance.client.from('absensi').insert({
        'sesi_id': sesi['id'],
        'anggota_id': _anggotaId,
        'user_id': user?.id,
        'status': status,
        'waktu_hadir': now.toIso8601String(),
      });

      if (!mounted) return;
      kodeC.clear();
      final isOk = status == 'Hadir';
      _showResult(isOk);
    } catch (e) {
      _snack("Gagal mencatat absensi. Periksa koneksi internet Anda.");
    }
    setState(() => _isLoading = false);
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m,
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
      backgroundColor: AppTheme.navy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  void _showResult(bool isOk) {
    final color = isOk ? AppTheme.success : AppTheme.warning;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: const BoxDecoration(
            color: AppTheme.snow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
                  color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(
                  isOk ? Icons.check_circle_rounded : Icons.access_time_rounded,
                  size: 48,
                  color: color)),
          const SizedBox(height: 16),
          Text(isOk ? "Berhasil Hadir!" : "Tercatat Terlambat",
              style: AppTheme.h3),
          const SizedBox(height: 8),
          Text(
              isOk
                  ? "Kehadiran berhasil dicatat."
                  : "Dicatat sebagai terlambat.",
              textAlign: TextAlign.center,
              style: AppTheme.body),
          const SizedBox(height: 24),
          CoralButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: AppTheme.coral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Image.asset('assets/image/logo.png',
                          width: 36, height: 36),
                    ),
                    const SizedBox(width: 12),
                    Text("Presensi", style: AppTheme.h3.copyWith(fontSize: 16)),
                  ]),
                ),
                const SizedBox(height: 32),

                // Avatar + name
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: AppTheme.peach, shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded,
                      size: 56, color: AppTheme.coral),
                ),
                const SizedBox(height: 12),
                if (_userName != null) Text(_userName!, style: AppTheme.h2),
                const SizedBox(height: 8),
                Text("Masukkan kode untuk absensi", style: AppTheme.body),
                const SizedBox(height: 28),

                // Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: AccentCard(
                    accentColor: AppTheme.info,
                    child: Row(children: [
                      Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text("Minta kode absensi dari admin/pelatih.",
                              style: AppTheme.body
                                  .copyWith(color: AppTheme.info))),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),

                // Code input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.snow,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.ultraSoft,
                    ),
                    child: TextField(
                      controller: kodeC,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 8,
                        color: AppTheme.navy,
                      ),
                      decoration: InputDecoration(
                        hintText: "KODE",
                        hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppTheme.slate.withValues(alpha: 0.3),
                            fontSize: 22,
                            letterSpacing: 6),
                        filled: true,
                        fillColor: AppTheme.snow,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: AppTheme.coral, width: 2)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: CoralButton(
                    onPressed: _isLoading ? null : _submit,
                    isLoading: _isLoading,
                    child: const Text("HADIR ✓"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
