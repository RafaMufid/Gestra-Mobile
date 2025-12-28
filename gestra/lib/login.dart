import 'package:flutter/material.dart';
import 'register.dart';
import 'home.dart';
import 'Controller/AuthController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryBlue = const Color.fromRGBO(30, 64, 175, 1);
    final Color activeBlue = isDarkMode ? Colors.blueAccent : primaryBlue;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/images/gestra.png', height: 80),
                const SizedBox(height: 20),
                Text(
                  "Welcome back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: nameController,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: activeBlue,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: activeBlue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passController,
                  obscureText: _obscure,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: isDarkMode ? Colors.white70 : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: activeBlue,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: activeBlue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {},
                //     child: const Text(
                //       "Forget password?",
                //       style: TextStyle(color: Color.fromRGBO(30, 64, 175, 1)),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                      String email = nameController.text.trim();
                      String password = passController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Email dan password wajib diisi"),
                          ),
                        );
                        return;
                      }

                      try {
                        print("coba login yah sabar...");
                        final auth = AuthService();
                        final result = await auth.login(email, password);

                        if (result["token"] != null) {
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          await prefs.setString("token", result["token"]);
                          await prefs.setString("password", password);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result["message"] ?? "Login gagal"),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Terjadi kesalahan: $e")),
                        );
                      }
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: activeBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
