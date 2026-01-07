import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> today = [];
  List<dynamic> previous = [];
  bool isLoading = true;
  String? token;

  //final String baseUrl = 'http://10.0.2.2:8000/api'; 
  // GANTI IP kalau pakai HP asli
  final String baseUrl = 'http://10.150.100.232:8000/api';

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  //  TOKEN 
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      // kalau token hilang → balik login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      loadHistory();
    }
  }

  //  GET HISTORY 
  Future<void> loadHistory() async {
    setState(() => isLoading = true);

    final res = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);

      setState(() {
        today = data['today'];
        previous = data['previous'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }

    print('STATUS: ${res.statusCode}');
    print('BODY: ${res.body}');
  }

  //  DELETE 
  Future<void> deleteHistory(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/history/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    loadHistory();
  }

  //  UI 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadHistory,
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('Today'),
                ...today.map((e) => _item(e)).toList(),
                const SizedBox(height: 20),
                _sectionTitle('Previous 7 days'),
                ...previous.map((e) => _item(e)).toList(),
                if (today.isEmpty && previous.isEmpty)
                  const Center(child: Text('History kosong')),
              ],
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _item(dynamic item) {
    return ListTile(
      leading: Icon(
      item['source'] == 'speech'
          ? Icons.mic
          : Icons.videocam,
     ),

      title: Text(item['gesture_name']),
      subtitle: Text(
        'Accuracy: ${item['accuracy']}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _confirmDelete(item['id']),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus history'),
        content: const Text('Yakin ingin menghapus history ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteHistory(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
