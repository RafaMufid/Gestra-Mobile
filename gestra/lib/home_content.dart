import 'package:flutter/material.dart';

class HomeContentPage extends StatelessWidget {
  final void Function(int) onNavigate;
  const HomeContentPage({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/gestra.png'),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Hi User!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(30, 64, 175, 1),
                    ),
                  ),
                  const Text(
                    "Selamat Datang di GESTRA",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(30, 64, 175, 1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: const Text(
                        "Tempat di mana Anda dapat berinteraksi lancar dengan teman Tuli, tanpa hambatan bahasa isyarat.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w100,
                          color: Color.fromRGBO(30, 64, 175, 0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  const Text(
                    'Last Translated',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(30, 64, 175, 0.8),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.history,
                      color: Color.fromRGBO(30, 64, 175, 0.8),
                    ),
                    title: const Text('Nama saya adalah John Marston'),
                    subtitle: const Text(
                      'Terakhir diterjemahkan: 5 menit lalu',
                    ),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      onNavigate(0);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
