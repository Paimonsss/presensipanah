import 'package:flutter/material.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatAbsensiScreen extends StatefulWidget {
  const RiwayatAbsensiScreen({super.key});
  @override
  State<RiwayatAbsensiScreen> createState() => _RiwayatAbsensiScreenState();
}

class _RiwayatAbsensiScreenState extends State<RiwayatAbsensiScreen> {
  List<Map<String, dynamic>> list = [];
  bool _isLoading = true;
  String? _anggotaId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final u = Supabase.instance.client.auth.currentUser;
      if (u == null) {
        setState(() => _isLoading = false);
        return;
      }
      final a = await Supabase.instance.client
          .from('anggota')
          .select('id')
          .eq('user_id', u.id)
          .maybeSingle();
      if (a == null) {
        setState(() => _isLoading = false);
        return;
      }
      _anggotaId = a['id'];
      final r = await Supabase.instance.client
          .from('absensi')
          .select('''
            id, waktu_hadir, status,
            sesi_absensi:sesi_id (id, kode, tanggal)
          ''')
          .eq('anggota_id', _anggotaId!)
          .order('waktu_hadir', ascending: false);
      if (mounted)
        setState(() {
          list = List<Map<String, dynamic>>.from(r);
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Gagal memuat riwayat. Periksa koneksi internet Anda.")));
      }
    }
  }

  String _fmtDate(String? d) {
    if (d == null) return "-";
    try {
      final dt = DateTime.parse(d);
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (_) {
      return d;
    }
  }

  String _fmtTime(String? d) {
    if (d == null) return "-";
    try {
      final dt = DateTime.parse(d);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "-";
    }
  }

  Color _sColor(String? s) {
    switch (s) {
      case 'Hadir':
        return AppTheme.success;
      case 'Terlambat':
        return AppTheme.warning;
      case 'Izin':
        return AppTheme.info;
      default:
        return AppTheme.slate;
    }
  }

  IconData _sIcon(String? s) {
    switch (s) {
      case 'Hadir':
        return Icons.check_circle;
      case 'Terlambat':
        return Icons.access_time;
      case 'Izin':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: AppTheme.snow,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.ultraSoft),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppTheme.navy, size: 22))),
                const Spacer(),
                Text("Riwayat", style: AppTheme.h3),
                const Spacer(),
                IconButton(
                    onPressed: _load,
                    icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: AppTheme.snow,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.ultraSoft),
                        child: const Icon(Icons.refresh_rounded,
                            color: AppTheme.navy, size: 22))),
              ]),
            ),
            const SizedBox(height: 12),

            // Stats pills
            if (!_isLoading && list.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  _pill("Total", list.length.toString(), AppTheme.navy,
                      AppTheme.cloud),
                  const SizedBox(width: 10),
                  _pill(
                      "Hadir",
                      list
                          .where((r) => r['status'] == 'Hadir')
                          .length
                          .toString(),
                      AppTheme.success,
                      AppTheme.mint),
                  const SizedBox(width: 10),
                  _pill(
                      "Terlambat",
                      list
                          .where((r) => r['status'] == 'Terlambat')
                          .length
                          .toString(),
                      AppTheme.warning,
                      const Color(0xFFFFF8E1)),
                ]),
              ),
            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.coral))
                  : list.isEmpty
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: AppTheme.peach,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.history,
                                      size: 48, color: AppTheme.coral)),
                              const SizedBox(height: 16),
                              Text("Belum ada riwayat",
                                  style: AppTheme.bodyLarge),
                            ]))
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: AppTheme.coral,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: list.length,
                            itemBuilder: (context, i) {
                              final item = list[i];
                              final sesi =
                                  item['sesi_absensi'] as Map<String, dynamic>?;
                              final status = item['status'] ?? '-';
                              final color = _sColor(status);
                              return AccentCard(
                                accentColor: color,
                                child: Row(children: [
                                  Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      child: Icon(_sIcon(status),
                                          color: color, size: 26)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text("Sesi ${sesi?['kode'] ?? '-'}",
                                            style: AppTheme.bodyLarge.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.navy)),
                                        Text(
                                            "${_fmtDate(sesi?['tanggal'])}  •  ${_fmtTime(item['waktu_hadir'])}",
                                            style: AppTheme.caption),
                                      ])),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Text(status,
                                          style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Poppins',
                                              fontSize: 12))),
                                ]),
                              );
                            },
                          )),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _pill(String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.ultraSoft),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins')),
          Text(label, style: AppTheme.caption),
        ]),
      ),
    );
  }
}
