import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controller/AuthController.dart';

class HomeContentPage extends StatefulWidget {
  final void Function(int) onNavigate;
  const HomeContentPage({super.key, required this.onNavigate});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final AuthService authService = AuthService();
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final userData = await authService.getProfile(token);
        if (mounted) {
          setState(() {
            name = userData['user']['username'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color.fromRGBO(30, 64, 175, 1);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, 
        foregroundColor: mainBlue,
        elevation: 0,
        centerTitle: true,
         titleTextStyle: const TextStyle(
           color: mainBlue, fontSize: 20, fontWeight: FontWeight.bold
         ),
      ),
      body: Stack(
        children: [
          //gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0F4FF), 
                  Color(0xFFE1E8F5), 
                ],
              ),
            ),
          ),

          //blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    mainBlue.withValues(alpha: 0.2),
                    mainBlue.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withValues(alpha: 0.15),
                    Colors.blueAccent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          //image gestra
          Center(
            child: Opacity(
              opacity: 0.8, 
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/gestra.png'),
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
          ),

          //isi
          SafeArea(
            child: Center(
              child: Stack(
                children: [
                  Positioned(
                    top: 30, 
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            name.isEmpty ? "Halo Pengguna!" : "Halo, $name!",
                            key: ValueKey<String>(name), 
                            style: const TextStyle(
                              fontSize: 26, 
                              fontWeight: FontWeight.w800,
                              color: mainBlue,
                            ),
                          ),
                        ),
                        const Text(
                          "Selamat Datang di GESTRA",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: mainBlue,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              "Tempat di mana Anda dapat berinteraksi lancar dengan teman Tuli, tanpa hambatan bahasa isyarat.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: mainBlue.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                         Text(
                          'Last Translated',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: mainBlue.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.history,
                              color: mainBlue.withValues(alpha: 0.8),
                            ),
                            title: const Text(
                              'Nama saya adalah John Marston',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text(
                              'Terakhir diterjemahkan: 5 menit lalu',
                            ),
                            tileColor: Colors.white.withValues(alpha: 0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: mainBlue.withValues(alpha: 0.1)
                              )
                            ),
                            onTap: () {
                              widget.onNavigate(0);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
