import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestra/profile.dart';
import 'package:http/http.dart' as http;
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
  List<dynamic> lastTodayActivity = [];
  bool isLoadingHistory = true;

  final String baseUrl = 'http://10.150.100.232:8000/api';
  // GANTI IP kalau pakai HP asli
  // final String baseUrl = "http://10.0.2.2:8000/api";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUserData();
    await _loadTodayHistory();
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

  Future<void> _loadTodayHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() => isLoadingHistory = false);
        return;
      }

      final res = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        List<dynamic> todayActivities = [];
        if (data['today'] != null) {
          todayActivities = List.from(data['today']);
        }

        List<dynamic> twoLastest = todayActivities.take(2).toList();

        if (mounted) {
          setState(() {
            lastTodayActivity = twoLastest;
            isLoadingHistory = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingHistory = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching last activity: $e");
      if (mounted) {
        setState(() {
          isLoadingHistory = false;
        });
      }
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
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
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
                    label: "Speech-to-Text",
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
                    "Aktivitas Terakhir Hari Ini",
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

              if (isLoadingHistory)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (lastTodayActivity.isEmpty)
                _buildEmptyPlaceholder(cardColor, isDarkMode)
              else
                Column(
                  children: lastTodayActivity.map((activity) {
                    String gestureName =
                        activity['gesture_name'] ?? 'Tidak Diketahui';
                    String source = activity['source'] == 'speech'
                        ? 'Suara'
                        : 'Video';
                    String time = _formatTimeAgo(activity['created_at']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildRecentItem(
                        gestureName,
                        source,
                        time,
                        cardColor,
                        textColor,
                        activeColor,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      Duration diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return '${diff.inDays} hari lalu';
      if (diff.inHours > 0) return '${diff.inHours} jam lalu';
      if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
      return 'Baru saja';
    } catch (e) {
      return '';
    }
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

  Widget _buildEmptyPlaceholder(Color cardColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 40,
            color: isDark ? Colors.white24 : Colors.grey[300],
          ),
          const SizedBox(height: 10),
          Text(
            "Belum ada aktivitas hari ini.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Ayo mulai terjemahkan bahasa isyarat!",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white30 : Colors.grey[400],
            ),
          ),
        ],
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
