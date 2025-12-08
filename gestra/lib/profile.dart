import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gestra/Controller/AuthController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool showPassword = false;

  Uint8List? profileImageBytes;

  final AuthService authService = AuthService();
  bool isLoading = true;

  String? photoUrl;
  String? pickedImagePath;

  final TextEditingController nameController = TextEditingController(text: "");
  final TextEditingController emailController = TextEditingController(text: "");
  final TextEditingController passwordController = TextEditingController(
    text: "",
  );

  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      profileImageBytes = bytes;
      pickedImagePath = image.path;
    });
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Token tidak ditemukan");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final res = await authService.getProfile(token);
      final user = res['user'];
      photoUrl = res['photo_url'];
      final savedPassword = prefs.getString('password');

      setState(() {
        nameController.text = user['username'] ?? '';
        emailController.text = user['email'] ?? '';
        passwordController.text = savedPassword ?? "";
        photoUrl = res['photo_url'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
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
                              backgroundImage: profileImageBytes != null
                                  ? MemoryImage(profileImageBytes!)
                                  : (photoUrl != null
                                        ? NetworkImage(photoUrl!)
                                              as ImageProvider
                                        : null),
                              child:
                                  profileImageBytes == null && photoUrl == null
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
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(55, 0, 0, 0),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Edit Foto",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

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

                      ElevatedButton(
                        onPressed: () async {
                          if (isEditing) {
                            if (nameController.text.trim().isEmpty ||
                                emailController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Nama dan email harus diisi"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            if (!emailController.text.contains('@')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Email tidak valid"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token');

                            if (token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Token tidak ditemukan, silakan login ulang",
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            try {
                              await authService.updateProfile(
                                token: token,
                                username: nameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text.trim().isEmpty
                                    ? null
                                    : passwordController.text.trim(),
                              );

                              if (passwordController.text.trim().isNotEmpty) {
                                await prefs.setString(
                                  "password",
                                  passwordController.text.trim(),
                                );
                              }

                              await loadProfile();

                              if (pickedImagePath != null) {
                                final photoRes = await authService.updatePhoto(
                                  token: token,
                                  filePath: pickedImagePath!,
                                );

                                setState(() {
                                  photoUrl = photoRes['photo_url'];
                                });
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Profile berhasil diperbarui"),
                                  backgroundColor: Color(0xFF1E40AF),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              FocusScope.of(context).unfocus();

                              setState(() {
                                isEditing = false;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Gagal update profile: $e"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            setState(() {
                              isEditing = !isEditing;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E40AF),
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

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  static Widget buildInfoBox({
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
        border: Border.all(color: Color(0xFF1E40AF)),
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
