import 'package:flutter/material.dart';
import 'package:gestra/profile.dart';
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
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final userData = await authService.getProfile(token);
        if (mounted) {
          setState(() {
            name = userData['user']['username'] ?? '';
            photoUrl = userData['photo_url'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = const Color(0xFF1E40AF);
    final activeColor = isDarkMode ? Colors.blueAccent : primaryBlue;
    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FD);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTimeGreeting(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name.isEmpty ? "Pengguna" : name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                          ? NetworkImage(photoUrl!)
                          : null,
                      child: (photoUrl == null || photoUrl!.isEmpty)
                          ? Icon(Icons.person, color: Colors.grey.shade600)
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.blue.shade900, Colors.blue.shade800]
                        : [primaryBlue, const Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mulai Terjemahan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Gunakan kamera untuk menerjemahkan bahasa isyarat.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            onPressed: () {
                              widget.onNavigate(1);
                            },
                            child: const Text("Buka Kamera"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/images/gestra.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                      color: Colors.white.withValues(alpha: 0.9),
                      colorBlendMode: BlendMode.modulate,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Menu Cepat",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.mic,
                    label: "Text-to-Speech",
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange.shade800,
                    onTap: () => widget.onNavigate(3),
                    isDark: isDarkMode,
                  ),
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.history,
                    label: "Riwayat",
                    color: Colors.purple.shade100,
                    iconColor: Colors.purple.shade800,
                    onTap: () => widget.onNavigate(0),
                    isDark: isDarkMode,
                  ),
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.settings,
                    label: "Pengaturan",
                    color: Colors.green.shade100,
                    iconColor: Colors.green.shade800,
                    onTap: () => widget.onNavigate(4),
                    isDark: isDarkMode,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Aktivitas Terakhir",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigate(0),
                    child: Text(
                      "Lihat Semua",
                      style: TextStyle(color: activeColor),
                    ),
                  ),
                ],
              ),
              _buildRecentItem(
                "Nama saya adalah John Marston",
                "Terjemahan Kamera",
                "2 menit lalu",
                cardColor,
                textColor,
                activeColor,
              ),
              const SizedBox(height: 10),
              _buildRecentItem(
                "Saya suka membuat robot mainan",
                "Terjemahan Suara",
                "1 jam lalu",
                cardColor,
                textColor,
                activeColor,
              ),
            ],
          ),
        ),
      ),
      // appBar: AppBar(
      //   title: const Text('Home'),
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: primaryColor,
      //   elevation: 0,
      //   centerTitle: true,
      //   titleTextStyle: const TextStyle(
      //     color: Colors.blue,
      //     fontSize: 20,
      //     fontWeight: FontWeight.bold,
      //   ),
      // ),
      // body: Stack(
      //   children: [
      //     //gradient
      //     Container(
      //       decoration: BoxDecoration(
      //         gradient: LinearGradient(
      //           begin: Alignment.topLeft,
      //           end: Alignment.bottomRight,
      //           colors: isDarkMode
      //               ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
      //               : [const Color(0xFFF0F4FF), const Color(0xFFE1E8F5)],
      //         ),
      //       ),
      //     ),

      //     //blobs
      //     Positioned(
      //       top: -100,
      //       right: -100,
      //       child: Container(
      //         width: 300,
      //         height: 300,
      //         decoration: BoxDecoration(
      //           shape: BoxShape.circle,
      //           gradient: RadialGradient(
      //             colors: [
      //               primaryColor.withValues(alpha: 0.2),
      //               primaryColor.withValues(alpha: 0.0),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //     Positioned(
      //       bottom: -50,
      //       left: -80,
      //       child: Container(
      //         width: 350,
      //         height: 350,
      //         decoration: BoxDecoration(
      //           shape: BoxShape.circle,
      //           gradient: RadialGradient(
      //             colors: [
      //               primaryColor.withValues(alpha: 0.15),
      //               primaryColor.withValues(alpha: 0.0),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),

      //     //image gestra
      //     Center(
      //       child: Opacity(
      //         opacity: 0.8,
      //         child: Container(
      //           decoration: const BoxDecoration(
      //             image: DecorationImage(
      //               image: AssetImage('assets/images/gestra.png'),
      //               fit: BoxFit.scaleDown,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),

      //     //isi
      //     SafeArea(
      //       child: Center(
      //         child: Stack(
      //           children: [
      //             Positioned(
      //               top: 30,
      //               left: 0,
      //               right: 0,
      //               bottom: 0,
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.center,
      //                 mainAxisAlignment: MainAxisAlignment.start,
      //                 children: [
      //                   AnimatedSwitcher(
      //                     duration: const Duration(milliseconds: 300),
      //                     child: Text(
      //                       name.isEmpty ? "Halo Pengguna!" : "Halo, $name!",
      //                       key: ValueKey<String>(name),
      //                       style: TextStyle(
      //                         fontSize: 26,
      //                         fontWeight: FontWeight.w800,
      //                         color: primaryColor,
      //                       ),
      //                     ),
      //                   ),
      //                   Text(
      //                     "Selamat Datang di GESTRA",
      //                     style: TextStyle(
      //                       fontSize: 22,
      //                       fontWeight: FontWeight.bold,
      //                       color: primaryColor,
      //                     ),
      //                   ),
      //                   const SizedBox(height: 15),
      //                   Flexible(
      //                     child: Padding(
      //                       padding: const EdgeInsets.symmetric(horizontal: 40),
      //                       child: Text(
      //                         "Tempat di mana Anda dapat berinteraksi lancar dengan teman Tuli, tanpa hambatan bahasa isyarat.",
      //                         textAlign: TextAlign.center,
      //                         style: TextStyle(
      //                           fontSize: 13,
      //                           height: 1.5,
      //                           fontWeight: FontWeight.w500,
      //                           color: subTextColor,
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             Positioned(
      //               bottom: 20,
      //               left: 20,
      //               right: 20,
      //               child: Column(
      //                 children: [
      //                   Text(
      //                     'Last Translated',
      //                     style: TextStyle(
      //                       fontSize: 16,
      //                       fontWeight: FontWeight.bold,
      //                       color: isDarkMode
      //                           ? Colors.white70
      //                           : primaryColor.withValues(alpha: 0.8),
      //                     ),
      //                   ),
      //                   const SizedBox(height: 10),
      //                   Container(
      //                     decoration: BoxDecoration(
      //                       boxShadow: [
      //                         BoxShadow(
      //                           color: isDarkMode
      //                               ? Colors.black.withValues(alpha: 0.3)
      //                               : Colors.blueGrey.withValues(alpha: 0.1),
      //                           blurRadius: 15,
      //                           offset: const Offset(0, 5),
      //                         ),
      //                       ],
      //                     ),
      //                     child: ListTile(
      //                       leading: Icon(
      //                         Icons.history,
      //                         color: textColor,
      //                       ),
      //                       title: const Text(
      //                         'Nama saya adalah John Marston',
      //                         style: TextStyle(fontWeight: FontWeight.w600),
      //                       ),
      //                       subtitle: const Text(
      //                         'Terakhir diterjemahkan: 5 menit lalu',
      //                       ),
      //                       tileColor: Colors.white.withValues(alpha: 0.9),
      //                       shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(15),
      //                         side: BorderSide(
      //                           color: primaryColor.withValues(alpha: 0.1),
      //                         ),
      //                       ),
      //                       onTap: () {
      //                         widget.onNavigate(0);
      //                       },
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  String _getTimeGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? iconColor.withValues(alpha: 0.2) : color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? iconColor.withValues(alpha: 0.8) : iconColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(
    String title,
    String type,
    String time,
    Color cardColor,
    Color textColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              type.contains("Suara") ? Icons.mic : Icons.videocam,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
