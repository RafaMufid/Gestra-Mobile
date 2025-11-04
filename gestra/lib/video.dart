import 'package:flutter/material.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraPlaceholder(),
            _buildGestureOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Icon(
          Icons.camera_alt_outlined,
          color: Colors.grey[900],
          size: 150.0,
        ),
      ),
    );
  }

  Widget _buildGestureOverlay() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(60, 0, 0, 0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              'Posisikan tangan Anda di depan kamera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Spacer(),
          _buildRecordButtons(),
          SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(60, 0, 0, 0),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'GESTUR TERDETEKSI:',
                  style: TextStyle(
                    color: const Color.fromARGB(80, 255, 255, 255),
                    fontSize: 14.0,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'JEMPOL KE ATAS',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tombol Start
        ElevatedButton.icon(
          onPressed: () {
            // ini buat logika pas dipencet belom beres pak
          },
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          label: const Text(
            'Start',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 76, 175, 80),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Tombol Stop
        ElevatedButton.icon(
          onPressed: () {
            // ini juga logic buat pas button dipencet tapi belom hehe
          },
          icon: const Icon(Icons.stop, color: Colors.white),
          label: const Text(
            'Stop',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 244, 67, 80),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ],
    );
  }
}