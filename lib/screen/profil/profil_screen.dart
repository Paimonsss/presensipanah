import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panah_presensi/screen/dashboard/dashboard_screen.dart';
import 'package:panah_presensi/screen/absensi/absensi_screen.dart';
import 'package:panah_presensi/screen/Login/LoginScreen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  int _selectedIndex = 2; // 0 = Dashboard, 1 = Presensi, 2 = Profil

  // Data user
  String _nama = "Memuat...";
  String _email = "Memuat...";
  String _userId = "";
  String _tanggalBergabung = "-";
  String? _photoUrl;
  File? _localPhoto;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        setState(() {
          _email = user.email ?? "-";
          _userId = user.id.substring(0, 8).toUpperCase();
          _tanggalBergabung = _formatDate(user.createdAt);
          _photoUrl = user.userMetadata?['avatar_url'];
        });

        // Ambil nama dari tabel anggota
        final response = await Supabase.instance.client
            .from('anggota')
            .select('nama, photo_url')
            .eq('user_id', user.id)
            .maybeSingle();

        if (response != null) {
          setState(() {
            if (response['nama'] != null) {
              _nama = response['nama'];
            }
            if (response['photo_url'] != null) {
              _photoUrl = response['photo_url'];
            }
          });
        } else {
          setState(() {
            _nama = user.email?.split('@')[0] ?? "Anggota";
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return "-";
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _localPhoto = File(pickedFile.path);
        });
        await _uploadPhoto(pickedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memilih foto: $e")),
        );
      }
    }
  }

  Future<void> _uploadPhoto(XFile photo) async {
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileExt = photo.path.split('.').last.toLowerCase();
      final fileName = '${user.id}/profile.$fileExt';
      final bytes = await photo.readAsBytes();

      // Upload ke Supabase Storage
      await Supabase.instance.client.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Dapatkan URL publik
      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update tabel anggota
      await Supabase.instance.client
          .from('anggota')
          .update({'photo_url': publicUrl}).eq('user_id', user.id);

      setState(() {
        _photoUrl = publicUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error uploading photo: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal upload foto: $e")),
        );
      }
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Ganti Foto Profil",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.red),
                ),
                title: const Text(
                  "Ambil Foto",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                subtitle: const Text(
                  "Gunakan kamera untuk mengambil foto baru",
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.red),
                ),
                title: const Text(
                  "Pilih dari Galeri",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                subtitle: const Text(
                  "Pilih foto dari galeri perangkat",
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Keluar",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar?",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              "Keluar",
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
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AbsensiScreen()),
      );
    }
    // index == 2 sudah di Profil
  }

  // Widget untuk menampilkan foto profil
  Widget _buildProfilePhoto() {
    ImageProvider? imageProvider;

    if (_localPhoto != null) {
      imageProvider = FileImage(_localPhoto!);
    } else if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_photoUrl!);
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? const Icon(Icons.person, size: 60, color: Colors.red)
              : null,
        ),
        // Tombol edit foto
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploadingPhoto ? null : _showPhotoOptions,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _isUploadingPhoto
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== HEADER MERAH DENGAN LOGO =====
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/image/logo.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Teks PANAH PRESENSI
                    const Text(
                      "PANAH PRESENSI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== CARD PROFIL =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: Colors.red),
                          ),
                        )
                      : Column(
                          children: [
                            // Foto profil dengan opsi ganti
                            _buildProfilePhoto(),
                            const SizedBox(height: 16),
                            Text(
                              _nama,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              "ID: $_userId",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Informasi tambahan
                            _buildInfoRow(
                                Icons.email_outlined, "Email", _email),
                            _buildInfoRow(Icons.calendar_today_outlined,
                                "Tanggal Bergabung", _tanggalBergabung),

                            const SizedBox(height: 24),

                            // Tombol Ganti Foto
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _isUploadingPhoto
                                    ? null
                                    : _showPhotoOptions,
                                icon: _isUploadingPhoto
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.red,
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt),
                                label: Text(
                                  _isUploadingPhoto
                                      ? "Mengupload..."
                                      : "Ganti Foto Profil",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Tombol Edit Profil
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  // aksi edit profil
                                },
                                child: const Text(
                                  "Edit Profil",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Tombol Logout
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _logout,
                                child: const Text(
                                  "Keluar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ===== NAVIGATION BAR (KONSISTEN: Dashboard - Presensi - Profil) =====
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/image/logo.png',
                  width: 28,
                  height: 28,
                ),
              ),
              label: 'Presensi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
