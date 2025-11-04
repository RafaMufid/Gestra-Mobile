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
      appBar: AppBar(
        title: const Text('History'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      
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