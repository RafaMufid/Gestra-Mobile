import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controller/AuthController.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool showPassword = false;
  bool isLoading = true;

  Uint8List? profileImageBytes;
  String? photoUrl;
  String? pickedImagePath;

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

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

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
      final res = await authService.getProfile(token);

      if (mounted) {
        setState(() {
          nameController.text = res['user']['username'] ?? '';
          emailController.text = res['user']['email'] ?? '';
          photoUrl = res['photo_url'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Gagal load dari server: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal terhubung ke server (Cek koneksi)"),
          ),
        );
      }
    }
  }

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

  ImageProvider? _getProfileImageProvider() {
    if (profileImageBytes != null) {
      return MemoryImage(profileImageBytes!);
    }
    if (photoUrl != null && photoUrl!.isNotEmpty && photoUrl != "0") {
    // Pastikan URL valid (mengandung http)
    if (photoUrl!.startsWith("http")) {
       // Tambahkan timestamp agar cache refresh otomatis
       return NetworkImage("$photoUrl?v=${DateTime.now().millisecondsSinceEpoch}");
    }
  }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color primaryBlue = const Color(0xFF1E40AF);
    final Color activeBlue = isDarkMode ? Colors.blueAccent : primaryBlue;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color borderColor = isDarkMode ? Colors.grey[600]! : primaryBlue;
    final imageProvider = _getProfileImageProvider();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
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
                              backgroundImage: imageProvider,
                              onBackgroundImageError: imageProvider != null
                                  ? (exception, stackTrace) {
                                      print("Gagal memuat gambar: $exception");
                                      setState(() => photoUrl = null);
                                    }
                                  : null,
                              child: _getProfileImageProvider() == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),

                            if (isEditing)
                              Container(
                                width: 110,
                                height: 110,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(80, 0, 0, 0),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      buildLabel("Nama", textColor),
                      buildInfoBox(
                        controller: nameController,
                        isEditing: isEditing,
                        textColor: textColor,
                        borderColor: borderColor,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 20),

                      buildLabel("Email", textColor),
                      buildInfoBox(
                        controller: emailController,
                        isEditing: isEditing,
                        textColor: textColor,
                        borderColor: borderColor,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 30),

                      buildLabel("Password", textColor),
                      buildInfoBox(
                        controller: passwordController,
                        isEditing: isEditing,
                        isPassword: true,
                        showPassword: showPassword,
                        textColor: textColor,
                        borderColor: borderColor,
                        isDarkMode: isDarkMode,
                        onTogglePassword: () {
                          setState(() => showPassword = !showPassword);
                        },
                      ),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: () async {
                          if (isEditing) {
                            await _handleSaveProfile();
                          } else {
                            setState(() {
                              isEditing = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        child: Text(
                          isEditing ? "Save" : "Edit Profile",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
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

  Future<void> _handleSaveProfile() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama dan email harus diisi"),
          backgroundColor: Colors.red,
        ),
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

    setState(() => isLoading = true);

    try {
      // 1. Update Text (Nama, Email, Password)
      await authService.updateProfile(
        token: token,
        username: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim().isEmpty
            ? null
            : passwordController.text.trim(),
      );

      if (passwordController.text.trim().isNotEmpty) {
        await prefs.setString("password", passwordController.text.trim());
      }

      // 2. Update Foto (Jika ada yang dipilih)
      if (pickedImagePath != null) {
        print("Mulai upload foto...");
        try {
          final resPhoto = await authService.updatePhoto(
            token: token,
            filePath: pickedImagePath!,
          );
          print("HASIL UPLOAD FOTO: $resPhoto"); // <--- Cek log ini nanti!
        } catch (e) {
          print("ERROR UPLOAD FOTO: $e");
        }
      }

      // 3. Refresh Data
      await _loadProfile();

      if (mounted) {
        setState(() => isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget buildLabel(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      ),
    );
  }

  Widget buildInfoBox({
    required TextEditingController controller,
    required bool isEditing,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
    required Color textColor,
    required Color borderColor,
    required bool isDarkMode,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: isEditing
          ? TextField(
              controller: controller,
              obscureText: isPassword && !showPassword,
              style: TextStyle(fontSize: 16, color: textColor),
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
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  if (isPassword)
                    GestureDetector(
                      onTap: onTogglePassword,
                      child: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                        color: isDarkMode ? Colors.white70 : Colors.grey,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
