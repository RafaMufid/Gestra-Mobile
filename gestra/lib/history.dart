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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconBgColor = isDarkMode
        ? (Colors.grey[800] ?? Colors.grey)
        : Colors.grey.shade300;
    final iconColor = isDarkMode ? Colors.white : Colors.black87;
    final dividerColor = isDarkMode
        ? (Colors.grey[800] ?? Colors.grey)
        : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('History'),
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 1,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ListView(
            children: [
              _sectionTitle('Today', textColor),
              _divider(dividerColor),
              for (int i = 0; i < today.length; i++)
                _historyItem(
                  today[i]["type"]!,
                  today[i]["text"]!,
                  textColor,
                  iconBgColor,
                  iconColor,
                  () {
                    _showHistoryPopup(today[i], isToday: true, index: i);
                  },
                ),

              const SizedBox(height: 20),
              _sectionTitle('Previous 7 days', textColor),
              _divider(dividerColor),

              for (int i = 0; i < previous.length; i++)
                _historyItem(
                  previous[i]["type"]!,
                  previous[i]["text"]!,
                  textColor,
                  iconBgColor,
                  iconColor,
                  () {
                    _showHistoryPopup(previous[i], isToday: false, index: i);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _divider(Color color) => Divider(thickness: 1, color: color);

  Widget _historyItem(
    String type,
    String text,
    Color textColor,
    Color iconBg,
    Color iconColor,
    VoidCallback onTap,
  ) {
    IconData iconData = type == "video" ? Icons.videocam : Icons.graphic_eq;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text('"$text"', style: TextStyle(fontSize: 14, color: textColor)),
    );
  }

  void _showHistoryPopup(
    Map<String, String> item, {
    required bool isToday,
    required int index,
  }) {
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
              ),
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
            child: const Text('Ya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
