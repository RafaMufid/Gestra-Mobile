import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  final List<Map<String, String>> today = const [
    {"type": "video", "text": "Nama saya adalah John Marston"},
    {"type": "voice", "text": "Saya suka membuat robot mainan"},
    {"type": "video", "text": "Makanan itu terlihat enak"},
    {"type": "voice", "text": "Saya telat masuk sekolah hari ini"},
    {"type": "video", "text": "Cita-cita saya adalah menjadi bajak laut"},
  ];

  final List<Map<String, String>> previous = const [
    {"type": "voice", "text": "Bisakah anda mencarikan pena saya?"},
    {"type": "video", "text": "Kapan kau membeli buku itu?"},
    {"type": "voice", "text": "Saya sudah melakukan apa yang kamu katakan"},
    {"type": "video", "text": "Lihat awan di langit itu"},
    {"type": "voice", "text": "Saya dengar anda tidak memiliki sepatu"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ListView(
            children: [
              _sectionTitle('Today'),
              _divider(),
              ...today.map((item) => _historyItem(item["type"]!, item["text"]!)),
              const SizedBox(height: 20),
              _sectionTitle('Previous 7 days'),
              _divider(),
              ...previous.map((item) => _historyItem(item["type"]!, item["text"]!)),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E40AF),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
              child: Text(
                "G E S T R A",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.white24, thickness: 0.5),
            _drawerItem(context, "Video"),
            _drawerItem(context, "Speech-to-text"),
            _drawerItem(context, "History", selected: true),
            const Spacer(),
            const Divider(color: Colors.white24, thickness: 0.5),
            _drawerBottomItem(Icons.person_outline, "Account"),
            _drawerBottomItem(Icons.logout, "Log Out"),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String title, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          onTap: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _drawerBottomItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _divider() => const Divider(thickness: 1, color: Colors.grey);

  Widget _historyItem(String type, String text) {
    IconData iconData =
        type == "video" ? Icons.videocam : Icons.graphic_eq;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, color: Colors.black87),
      ),
      title: Text(
        '"$text"',
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }
}
