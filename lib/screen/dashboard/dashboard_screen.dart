import 'package:flutter/material.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:panah_presensi/screen/Riwayat%20absen/riwayat_absen.dart';
import 'package:panah_presensi/screen/jadwal/jadwal_screen.dart';
import 'package:panah_presensi/screen/main_screen.dart';
import 'package:panah_presensi/utils/lightweight_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _nextJadwal;
  bool _loadingJadwal = true;

  @override
  void initState() {
    super.initState();
    _loadNextJadwal();
  }

  Future<void> _loadNextJadwal() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final r = await Supabase.instance.client
          .from('jadwal')
          .select('*')
          .gte('date', today)
          .order('date', ascending: true)
          .limit(1)
          .maybeSingle();
      if (mounted) setState(() { _nextJadwal = r; _loadingJadwal = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingJadwal = false);
    }
  }

  String _fmtDate(String? d) {
    if (d == null) return "-";
    try {
      final dt = DateTime.parse(d);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(dt.year, dt.month, dt.day);
      final diff = target.difference(today).inDays;
      if (diff == 0) return "Hari Ini";
      if (diff == 1) return "Besok";
      const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
      const mo = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
      return "${days[dt.weekday % 7]}, ${dt.day} ${mo[dt.month - 1]}";
    } catch (_) {
      return d;
    }
  }

  String _fmtTime(String? s, String? e) {
    if (s == null) return "";
    final a = s.substring(0, 5);
    final b = e?.substring(0, 5) ?? "";
    return b.isNotEmpty ? "$a - $b WIB" : "$a WIB";
  }

  String _badgeLabel(String? d) {
    if (d == null) return "";
    try {
      final dt = DateTime.parse(d);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final diff = DateTime(dt.year, dt.month, dt.day).difference(today).inDays;
      if (diff == 0) return "Hari Ini";
      if (diff == 1) return "Besok";
      if (diff <= 7) return "Segera";
      return "";
    } catch (_) {
      return "";
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══ TOP BAR ═══
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.coral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset('assets/image/logo.png',
                            width: 36, height: 36),
                      ),
                      const SizedBox(width: 12),
                      Text("Panah Presensi",
                          style: AppTheme.h3.copyWith(fontSize: 16)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.snow,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.ultraSoft,
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: AppTheme.slate, size: 22),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ═══ GREETING ═══
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.coralGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.coralGlow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Selamat Datang! 👋",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Poppins',
                                      color: Colors.white)),
                              const SizedBox(height: 6),
                              Text("Siap latihan panahan hari ini?",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: Colors.white
                                          .withValues(alpha: 0.85))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.gps_fixed_rounded,
                              color: Colors.white, size: 36),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ═══ MENU HORIZONTAL SCROLL ═══
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text("Menu", style: AppTheme.h3),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _menuItem(
                          "Profil",
                          Icons.person_rounded,
                          AppTheme.teal,
                          AppTheme.mint,
                          () => context
                              .findAncestorStateOfType<MainScreenState>()
                              ?.switchToTab(2)),
                      _menuItem(
                          "Riwayat",
                          Icons.history_rounded,
                          AppTheme.info,
                          AppTheme.skyBlue,
                          () =>
                              lightPush(context, const RiwayatAbsensiScreen())),
                      _menuItem(
                          "Jadwal",
                          Icons.calendar_month_rounded,
                          AppTheme.warning,
                          const Color(0xFFFFF8E1),
                          () => lightPush(context, const JadwalScreen())),
                      _menuItem(
                          "Presensi",
                          Icons.fingerprint_rounded,
                          AppTheme.coral,
                          AppTheme.peach,
                          () => context
                              .findAncestorStateOfType<MainScreenState>()
                              ?.switchToTab(1)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ═══ PENGINGAT ═══
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pengingat", style: AppTheme.h3),
                      const SizedBox(height: 12),
                      _loadingJadwal
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                    color: AppTheme.coral, strokeWidth: 2),
                              ))
                          : _nextJadwal == null
                              ? AccentCard(
                                  accentColor: AppTheme.slate,
                                  child: Row(children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.slate.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.event_busy_rounded,
                                          color: AppTheme.slate, size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text("Belum ada jadwal mendatang",
                                          style: AppTheme.bodyLarge.copyWith(
                                              color: AppTheme.slate)),
                                    ),
                                  ]),
                                )
                              : AccentCard(
                                  accentColor: AppTheme.warning,
                                  child: Row(children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warning.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.notifications_active_rounded,
                                          color: AppTheme.warning,
                                          size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              _nextJadwal!['title'] ?? 'Latihan Berikutnya',
                                              style: AppTheme.bodyLarge.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.navy)),
                                          Text(
                                              "${_fmtDate(_nextJadwal!['date'])}  •  ${_fmtTime(_nextJadwal!['time_start'], _nextJadwal!['time_end'])}",
                                              style: AppTheme.body),
                                        ],
                                      ),
                                    ),
                                    if (_badgeLabel(_nextJadwal!['date']).isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.warning.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(_badgeLabel(_nextJadwal!['date']),
                                            style: const TextStyle(
                                                color: AppTheme.warning,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                                fontSize: 12)),
                                      ),
                                  ]),
                                ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
      String title, IconData icon, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.ultraSoft,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navy,
                )),
          ],
        ),
      ),
    );
  }
}
