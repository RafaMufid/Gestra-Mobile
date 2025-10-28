import 'package:flutter/material.dart';
import 'video.dart';
import 'profile.dart';
import 'history.dart';
import 'stt.dart';
import 'setting.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const VideoPage(),
      SpeechToTextPage(),
      const HistoryPage(),
      const ProfilePage(),
      const SettingsPage(),
    ];

    final List<String> _titles = [
      "Video",
      "Speech-to-Text",
      "History",
      "Profile",
      "Settings"
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E40AF),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "GESTRA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Divider(color: Colors.white24),

              // ✅ daftar menu
              _drawerItem(Icons.video_library, "Video", 0),
              _drawerItem(Icons.mic, "Speech-to-text", 1),
              _drawerItem(Icons.history, "History", 2),
              _drawerItem(Icons.person, "Profile", 3),
              _drawerItem(Icons.settings, "Settings", 4),

              const Spacer(),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text("Log Out", style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pushReplacementNamed(context, '/'),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _drawerItem(IconData icon, String text, int index) {
    final bool selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      selected: selected,
      selectedTileColor: Colors.white24,
      onTap: () => _onDrawerItemTapped(index),
    );
  }
}
