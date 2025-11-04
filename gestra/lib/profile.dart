import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  final TextEditingController nameController = TextEditingController(text: "Bella");
  final TextEditingController usernameController = TextEditingController(text: "bellaaa");
  final TextEditingController passwordController = TextEditingController(text: "lalallala");

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
                      }
                      isEditing = !isEditing;
                    });
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
              child: Text(
                isPassword ? "••••••••" : controller.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}