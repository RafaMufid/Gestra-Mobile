import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Pastikan import ini sesuai dengan struktur folder Anda.
// Jika error, coba ganti jadi: import 'Controller/AuthController.dart';
import 'package:gestra/Controller/AuthController.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State Variables
  bool isEditing = false;
  bool showPassword = false;
  bool isLoading = true;

  Uint8List? profileImageBytes; // Untuk gambar yang baru dipilih dari galeri
  String? photoUrl; // Untuk gambar dari server
  String? pickedImagePath; // Path file lokal untuk upload

  final AuthService authService = AuthService();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // --- FUNGSI UTAMA: LOAD PROFILE (YANG DIPERBAIKI) ---
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // 1. Ambil Password dari HP DULU (Supaya langsung muncul)
    final savedPassword = prefs.getString('password');
    if (mounted) {
      setState(() {
        passwordController.text = savedPassword ?? "";
      });
    }

    if (token == null) {
      print("Token tidak ditemukan");
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      // 2. Coba ambil data Nama & Email dari Server
      final res = await authService.getProfile(token);
      
      if (mounted) {
        setState(() {
          // Gunakan null coalescing (??) agar tidak crash jika data kosong
          nameController.text = res['user']['username'] ?? '';
          emailController.text = res['user']['email'] ?? '';
          photoUrl = res['photo_url']; // URL foto dari server
          isLoading = false;
        });
      }
    } catch (e) {
      print("Gagal load dari server: $e");
      // Jika server gagal, matikan loading agar user tetap bisa melihat password
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal terhubung ke server (Cek koneksi)")),
        );
      }
    }
  }

  // --- FUNGSI PILIH GAMBAR ---
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      profileImageBytes = bytes;
      pickedImagePath = image.path;
    });
  }

  // --- HELPER: MENENTUKAN GAMBAR MANA YANG DIPAKAI ---
  ImageProvider? _getProfileImageProvider() {
    // 1. Jika user baru pilih gambar dari galeri, pakai itu
    if (profileImageBytes != null) {
      return MemoryImage(profileImageBytes!);
    }
    // 2. Jika ada URL dari server, pakai itu
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return NetworkImage(photoUrl!);
    }
    // 3. Jika tidak ada keduanya, return null (nanti jadi Icon orang)
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // --- BAGIAN FOTO PROFIL ---
                      GestureDetector(
                        onTap: () {
                          if (isEditing) pickImage();
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey.shade300,
                              // Panggil fungsi helper gambar di sini
                              backgroundImage: _getProfileImageProvider(),
                              // Jika gambar null/gagal, tampilkan Icon
                              onBackgroundImageError: (exception, stackTrace) {
                                print("Gagal memuat gambar: $exception");
                                setState(() => photoUrl = null);
                              },
                              child: _getProfileImageProvider() == null
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                            
                            // Overlay tulisan "Edit Foto" saat mode edit
                            if (isEditing)
                              Container(
                                width: 110,
                                height: 110,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(80, 0, 0, 0),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.camera_alt, color: Colors.white),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- FORM INPUT ---
                      buildLabel("Nama"),
                      buildInfoBox(
                        controller: nameController,
                        isEditing: isEditing,
                      ),
                      const SizedBox(height: 20),

                      buildLabel("Email"),
                      buildInfoBox(
                        controller: emailController,
                        isEditing: isEditing,
                      ),
                      const SizedBox(height: 30),

                      buildLabel("Password"),
                      buildInfoBox(
                        controller: passwordController,
                        isEditing: isEditing,
                        isPassword: true,
                        showPassword: showPassword,
                        onTogglePassword: () {
                          setState(() => showPassword = !showPassword);
                        },
                      ),

                      const SizedBox(height: 30),

                      // --- TOMBOL SAVE / EDIT ---
                      ElevatedButton(
                        onPressed: () async {
                          // JIKA SEDANG EDIT -> TOMBOL JADI "SAVE"
                          if (isEditing) {
                            await _handleSaveProfile(); // Panggil fungsi simpan
                          } else {
                            // JIKA TIDAK EDIT -> TOMBOL JADI "EDIT"
                            setState(() {
                              isEditing = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E40AF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: Text(
                          isEditing ? "Save" : "Edit Profile",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
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

  // --- LOGIKA SIMPAN DATA (Dipisah agar rapi) ---
  Future<void> _handleSaveProfile() async {
    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan email harus diisi"), backgroundColor: Colors.red),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sesi habis, silakan login ulang")),
      );
      return;
    }

    setState(() => isLoading = true); // Mulai loading saat simpan

    try {
      // 1. Update Text (Nama, Email, Password)
      await authService.updateProfile(
        token: token,
        username: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim().isEmpty ? null : passwordController.text.trim(),
      );

      // Simpan password baru ke HP jika diubah
      if (passwordController.text.trim().isNotEmpty) {
        await prefs.setString("password", passwordController.text.trim());
      }

      // 2. Update Foto (Jika ada yang dipilih)
      if (pickedImagePath != null) {
        await authService.updatePhoto(
          token: token,
          filePath: pickedImagePath!,
        );
      }

      // 3. Refresh Data
      await _loadProfile(); 

      if (mounted) {
        setState(() => isEditing = false); // Kembali ke mode lihat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile berhasil diperbarui!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false); // Matikan loading jika error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- WIDGET HELPER ---
  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget buildInfoBox({
    required TextEditingController controller,
    required bool isEditing,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1E40AF)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: isEditing
          ? TextField(
              controller: controller,
              obscureText: isPassword && !showPassword,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 13.5),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isPassword
                        ? (showPassword ? controller.text : "••••••••")
                        : controller.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (isPassword)
                    GestureDetector(
                      onTap: onTogglePassword,
                      child: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}