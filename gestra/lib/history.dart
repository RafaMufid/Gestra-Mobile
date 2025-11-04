import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Map<String, String>> today = [
    {"type": "video", "text": "Nama saya adalah John Marston"},
    {"type": "voice", "text": "Saya suka membuat robot mainan"},
    {"type": "video", "text": "Makanan itu terlihat enak"},
    {"type": "voice", "text": "Saya telat masuk sekolah hari ini"},
    {"type": "video", "text": "Cita-cita saya adalah menjadi bajak laut"},
  ];

  final List<Map<String, String>> previous = [
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
              for (int i = 0; i < today.length; i++)
              _historyItem(
                today[i]["type"]!,
                today[i]["text"]!,
                () {
                  _showHistoryPopup(today[i], isToday: true, index: i);
                },
              ),

            const SizedBox(height: 20),
            _sectionTitle('Previous 7 days'),
            _divider(),

            for (int i = 0; i < previous.length; i++)
              _historyItem(
                previous[i]["type"]!,
                previous[i]["text"]!,
                () {
                  _showHistoryPopup(previous[i], isToday: false, index: i);
                },
              ),
            ]
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

  Widget _historyItem(String type, String text, VoidCallback onTap) {
    IconData iconData =
        type == "video" ? Icons.videocam : Icons.graphic_eq;

    return ListTile(
      onTap: onTap,
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

  
 void _showHistoryPopup(Map<String, String> item,
      {required bool isToday, required int index}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('History Detail'),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDelete(isToday, index);
                },
              )
            ],
          ),
          content: Text('"${item["text"]!}"'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(bool isToday, int index) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus history'),
      content: const Text('Apakah kamu yakin ingin menghapus history ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tidak'),
        ),
        TextButton(
          onPressed: () {
            final deletedItem = isToday ? today[index] : previous[index];

            setState(() {
              if (isToday) {
                today.removeAt(index);
              } else {
                previous.removeAt(index);
              }
            });

            Navigator.pop(context); 

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('History berhasil dihapus'),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Batalkan',
                  textColor: Colors.blue,
                  onPressed: () {
                    setState(() {
                      if (isToday) {
                        today.insert(index, deletedItem);
                      } else {
                        previous.insert(index, deletedItem);
                      }
                    });
                  },
                ),
              ),
            );
          },
          child: const Text(
            'Ya',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

}

