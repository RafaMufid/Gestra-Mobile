import 'package:flutter/material.dart';

class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita tambahkan AppBar di sini agar konsisten dengan halaman lain
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false, // Tidak perlu tombol kembali
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/gestra.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "Selamat Datang di GESTRA",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(30, 64, 175, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}