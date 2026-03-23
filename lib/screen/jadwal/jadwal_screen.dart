import 'package:flutter/material.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});
  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  List<Map<String, dynamic>> jadwalList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final r = await Supabase.instance.client
          .from('jadwal')
          .select('*')
          .order('date', ascending: true);
      if (mounted)
        setState(() {
          jadwalList = List<Map<String, dynamic>>.from(r);
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Gagal memuat jadwal. Periksa koneksi internet Anda.")));
      }
    }
  }

  String _fmtDate(String? d) {
    if (d == null) return "-";
    try {
      final dt = DateTime.parse(d);
      const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
      const mo = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return "${days[dt.weekday % 7]}, ${dt.day} ${mo[dt.month - 1]} ${dt.year}";
    } catch (_) {
      return d;
    }
  }

  String _fmtTime(String? s, String? e) {
    if (s == null) return "-";
    final a = s.substring(0, 5);
    final b = e?.substring(0, 5) ?? "";
    return b.isNotEmpty ? "$a - $b" : a;
  }

  Color _typeColor(String? t) {
    switch (t?.toLowerCase()) {
      case 'pertandingan':
        return AppTheme.info;
      case 'meeting':
        return const Color(0xFF7C4DFF);
      default:
        return AppTheme.coral;
    }
  }

  IconData _typeIcon(String? t) {
    switch (t?.toLowerCase()) {
      case 'pertandingan':
        return Icons.emoji_events;
      case 'meeting':
        return Icons.groups;
      default:
        return Icons.sports;
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
                          color: AppTheme.navy, size: 22)),
                ),
                const Spacer(),
                Text("Jadwal", style: AppTheme.h3),
                const Spacer(),
                IconButton(
                  onPressed: _fetch,
                  icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: AppTheme.snow,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.ultraSoft),
                      child: const Icon(Icons.refresh_rounded,
                          color: AppTheme.navy, size: 22)),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.coral))
                  : jadwalList.isEmpty
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: AppTheme.peach,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.calendar_today,
                                      size: 48, color: AppTheme.coral)),
                              const SizedBox(height: 16),
                              Text("Belum ada jadwal",
                                  style: AppTheme.bodyLarge),
                            ]))
                      : RefreshIndicator(
                          onRefresh: _fetch,
                          color: AppTheme.coral,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: jadwalList.length,
                            itemBuilder: (context, i) {
                              final item = jadwalList[i];
                              final type = item['type'] ?? 'Latihan';
                              final color = _typeColor(type);
                              return AccentCard(
                                accentColor: color,
                                child: Row(children: [
                                  Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      child: Icon(_typeIcon(type),
                                          color: color, size: 26)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Expanded(
                                            child: Text(item["title"] ?? "-",
                                                style: AppTheme.bodyLarge
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppTheme.navy))),
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                                color: color.withValues(
                                                    alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Text(type,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins',
                                                    color: color))),
                                      ]),
                                      const SizedBox(height: 4),
                                      Text(_fmtDate(item["date"]),
                                          style: AppTheme.body),
                                      Text(
                                          _fmtTime(item["time_start"],
                                              item["time_end"]),
                                          style: AppTheme.caption),
                                      if (item["location"] != null)
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Row(children: [
                                              const Icon(Icons.location_on,
                                                  size: 14,
                                                  color: AppTheme.slate),
                                              const SizedBox(width: 4),
                                              Text(item["location"],
                                                  style: AppTheme.caption),
                                            ])),
                                    ],
                                  )),
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
}
