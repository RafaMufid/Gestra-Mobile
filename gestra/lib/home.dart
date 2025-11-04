import 'package:flutter/material.dart';
import 'history.dart';
import 'video.dart';
import 'home_content.dart';
import 'stt.dart';
import 'setting.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Default index = HomeContentPage
  int _selectedIndex = 2; 

  late final List<Widget> _widgetOptions;
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      HistoryPage(),
      VideoPage(),
      HomeContentPage(onNavigate: _navigateToPage),
      SpeechToTextPage(),
      SettingsPage(onNavigate: _navigateToPage),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Jika index 5 (Profile) aktif, kita tetap tandai Settings (4) sebagai aktif.
    final int navBarIndex = (_selectedIndex == 5) ? 4 : _selectedIndex;
    
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Speech to Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        currentIndex: navBarIndex,
        selectedItemColor: const Color(0xFF1E40AF),
        unselectedItemColor: Colors.grey,
        onTap: _navigateToPage,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}