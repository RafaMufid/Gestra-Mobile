import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool showPassword = false;

  Uint8List? profileImageBytes;

  final TextEditingController nameController = TextEditingController(
    text: "Bella",
  );
  final TextEditingController emailController = TextEditingController(
    text: "bellaaa@gmail.com",
  );
  final TextEditingController passwordController = TextEditingController(
    text: "lalallala",
  );

  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      profileImageBytes = bytes;
    });
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
      body: SafeArea(
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
                            : null,
                        child: profileImageBytes == null
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
                buildInfoBox(controller: nameController, isEditing: isEditing),
                const SizedBox(height: 20),

                buildLabel("Email"),
                buildInfoBox(controller: emailController, isEditing: isEditing),
                const Icon(Icons.account_circle_outlined, size: 100, color: Colors.black),
                const SizedBox(height: 30),

                buildLabel("Name"),
                buildInfoBox(controller: nameController, isEditing: isEditing),
                const SizedBox(height: 20),

                buildLabel("Username"),
                buildInfoBox(controller: usernameController, isEditing: isEditing),
                const SizedBox(height: 20),

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
                  onPressed: () {
                    if (isEditing) {
                      if (nameController.text.trim().isEmpty ||
                          emailController.text.trim().isEmpty ||
                          passwordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Semua data harus diisi"),
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
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (isEditing) {
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profile berhasil di edit"),
                            backgroundColor: Color(0xFF1E40AF),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile berhasil di edit"),
                          backgroundColor: Color(0xFF1E40AF),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      FocusScope.of(context).unfocus();
                    }

                    setState(() {
                      }
                      isEditing = !isEditing;
                    });
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
              obscureText: isPassword ? false : false,
              obscureText: isPassword && !isEditing,
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
              child: Text(
                isPassword ? "••••••••" : controller.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}
