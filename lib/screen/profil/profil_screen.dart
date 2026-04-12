import 'dart:io';
import 'package:flutter/material.dart';
import 'package:panah_presensi/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:panah_presensi/screen/Login/LoginScreen.dart';
import 'package:panah_presensi/utils/lightweight_route.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String _nama = "Memuat...", _email = "", _userId = "", _tglBergabung = "-";
  String? _photoUrl;
  File? _localPhoto;
  bool _isLoading = true, _uploading = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final u = Supabase.instance.client.auth.currentUser;
      if (u != null) {
        setState(() {
          _email = u.email ?? "-";
          _userId = u.id.substring(0, 8).toUpperCase();
          _tglBergabung = _fmtDate(u.createdAt);
          _photoUrl = u.userMetadata?['avatar_url'];
        });
        final r = await Supabase.instance.client
            .from('anggota')
            .select('nama, photo_url')
            .eq('user_id', u.id)
            .maybeSingle();
        if (r != null)
          setState(() {
            if (r['nama'] != null) _nama = r['nama'];
            if (r['photo_url'] != null) _photoUrl = r['photo_url'];
          });
        else
          setState(() => _nama = u.email?.split('@')[0] ?? "Anggota");
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const m = [
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
      return "${d.day} ${m[d.month - 1]} ${d.year}";
    } catch (_) {
      return "-";
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final f = await _picker.pickImage(
          source: src, maxWidth: 1024, maxHeight: 1024, imageQuality: 90);
      if (f == null) return;

      // Crop the image
      final cropped = await ImageCropper().cropImage(
        sourcePath: f.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Foto Profil',
            toolbarColor: const Color(0xFF1B2838),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFFFF6B6B),
            cropStyle: CropStyle.circle,
            lockAspectRatio: true,
          ),
        ],
      );

      if (cropped != null) {
        final croppedFile = XFile(cropped.path);
        setState(() => _localPhoto = File(cropped.path));
        _upload(croppedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Gagal memilih foto. Coba lagi.")));
      }
    }
  }

  Future<void> _upload(XFile photo) async {
    setState(() => _uploading = true);
    try {
      final u = Supabase.instance.client.auth.currentUser;
      if (u == null) return;
      // Force jpg extension — cropper may output unusual extensions
      var ext = photo.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) ext = 'jpg';
      final name = '${u.id}/profile.$ext';
      await Supabase.instance.client.storage.from('avatars').uploadBinary(
          name, await photo.readAsBytes(),
          fileOptions: const FileOptions(upsert: true));
      final url =
          Supabase.instance.client.storage.from('avatars').getPublicUrl(name);
      await Supabase.instance.client
          .from('anggota')
          .update({'photo_url': url}).eq('user_id', u.id);
      setState(() => _photoUrl = url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Foto berhasil diperbarui!"),
            backgroundColor: AppTheme.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Upload gagal: $e"), duration: const Duration(seconds: 8)));
      }
    } finally {
    }
  }

  void _showPhotoSheet() {
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
          const SizedBox(height: 20),
          Text("Ganti Foto", style: AppTheme.h3),
          const SizedBox(height: 16),
          ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppTheme.peach, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: AppTheme.coral)),
              title: Text("Kamera",
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.navy)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              }),
          ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppTheme.mint, shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library, color: AppTheme.teal)),
              title: Text("Galeri",
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.navy)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              }),
        ]),
      ),
    );
  }

  void _editName() {
    final c = TextEditingController(text: _nama);
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                decoration: const BoxDecoration(
                    color: AppTheme.snow,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28))),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.slate.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  Text("Edit Nama", style: AppTheme.h3),
                  const SizedBox(height: 16),
                  TextField(
                      controller: c,
                      autofocus: true,
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.navy),
                      decoration: AppTheme.inputDecoration(
                          label: "", hint: "Nama baru")),
                  const SizedBox(height: 20),
                  CoralButton(
                      onPressed: () async {
                        final n = c.text.trim();
                        if (n.isEmpty) return;
                        Navigator.pop(ctx);
                        final u = Supabase.instance.client.auth.currentUser;
                        if (u != null) {
                          await Supabase.instance.client
                              .from('anggota')
                              .update({'nama': n}).eq('user_id', u.id);
                          setState(() => _nama = n);
                        }
                      },
                      child: const Text("Simpan")),
                ]),
              ),
            ));
  }

  void _logout() {
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
                  color: AppTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded,
                  color: AppTheme.error, size: 36)),
          const SizedBox(height: 16),
          const Text("Keluar?", style: AppTheme.h3),
          const SizedBox(height: 8),
          const Text("Apakah yakin ingin keluar?", style: AppTheme.body),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.slate,
                        side: BorderSide(
                            color: AppTheme.slate.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text("Batal",
                        style:
                            AppTheme.button.copyWith(color: AppTheme.slate)))),
            const SizedBox(width: 12),
            Expanded(
                child: CoralButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await Supabase.instance.client.auth.signOut();
                      if (mounted)
                        lightPushAndRemoveAll(context, LoginScreen());
                    },
                    child: const Text("Keluar"))),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? img;
    if (_localPhoto != null)
      img = FileImage(_localPhoto!);
    else if (_photoUrl != null && _photoUrl!.isNotEmpty)
      img = NetworkImage(_photoUrl!);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.coral))
              : Column(
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
                                width: 36, height: 36)),
                        const SizedBox(width: 12),
                        Text("Profil",
                            style: AppTheme.h3.copyWith(fontSize: 16)),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Scrollable content area (fills remaining space)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Photo
                            Stack(children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.coralGradient),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                      color: AppTheme.cloud, shape: BoxShape.circle),
                                  child: CircleAvatar(
                                      radius: 48,
                                      backgroundColor: AppTheme.cloud,
                                      backgroundImage: img,
                                      child: img == null
                                          ? const Icon(Icons.person_rounded,
                                              size: 56, color: AppTheme.slate)
                                          : null),
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: _uploading ? null : _showPhotoSheet,
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          gradient: AppTheme.coralGradient,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppTheme.cloud, width: 3)),
                                      child: _uploading
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white))
                                          : const Icon(Icons.camera_alt_rounded,
                                              size: 16, color: Colors.white)),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 12),
                            Text(_nama, style: AppTheme.h2),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                  color: AppTheme.coral.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text("ID: $_userId",
                                  style: AppTheme.caption.copyWith(
                                      color: AppTheme.coral,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 20),

                            // Info cards
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(children: [
                                _infoTile(Icons.email_outlined, "Email", _email,
                                    AppTheme.coral),
                                _infoTile(Icons.calendar_today_outlined, "Bergabung",
                                    _tglBergabung, AppTheme.teal),
                              ]),
                            ),
                            const SizedBox(height: 20),

                            // Actions
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(children: [
                                CoralButton(
                                    onPressed: _editName,
                                    child: const Text("Edit Profil")),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                        onPressed:
                                            _uploading ? null : _showPhotoSheet,
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: AppTheme.navy,
                                            side: BorderSide(
                                                color: AppTheme.slate
                                                    .withValues(alpha: 0.2)),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(28)),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14)),
                                        child: Text(
                                            _uploading
                                                ? "Mengupload..."
                                                : "Ganti Foto Profil",
                                            style: AppTheme.bodyLarge
                                                .copyWith(color: AppTheme.navy)))),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                        onPressed: _logout,
                                        style: TextButton.styleFrom(
                                            foregroundColor: AppTheme.error,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14)),
                                        child: Text("Keluar",
                                            style: AppTheme.button
                                                .copyWith(color: AppTheme.error)))),
                              ]),
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

  Widget _infoTile(IconData icon, String label, String value, Color color) {
    return AccentCard(
      accentColor: color,
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTheme.caption),
          Text(value,
              style: AppTheme.bodyLarge
                  .copyWith(color: AppTheme.navy, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}
