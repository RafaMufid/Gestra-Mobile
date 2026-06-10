import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gestra/Controller/video_controller.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoController();
    
    _controller.onShowMessage = (message, isError) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    };

    _controller.initializeSystem().then((_) {
      if (mounted) setState(() {});
    });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.state.isCameraInitialized || _controller.cameraController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text("Menyiapkan Kamera...", style: TextStyle(color: Colors.white))
            ],
          ),
        ),
      );
    }

    // MAIN UI
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CameraPreview(_controller.cameraController!),
          ),

          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Sedang Mendeteksi:",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _controller.state.detectedText, 
                        style: const TextStyle(
                          color: Colors.yellowAccent, 
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black54, 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Kalimat Terbentuk:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          
                          if (_controller.state.isRecording)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Text("", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      Container(
                        height: 60,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _controller.state.sentenceBuffer.isEmpty 
                                ? "Menunggu Gerakan..." 
                                : _controller.state.sentenceBuffer,
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold,
                              color: _controller.state.sentenceBuffer.isEmpty ? Colors.white38 : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // MULAI STOP
                            _buildActionButton(
                              icon: _controller.state.isRecording ? Icons.stop : Icons.play_arrow, 
                              label: _controller.state.isRecording ? "STOP" : "MULAI", 
                              color: _controller.state.isRecording ? Colors.redAccent : Colors.greenAccent, 
                              onTap: () => _controller.toggleRecording()
                            ),
                        
                            // SPASI
                            _buildActionButton(
                              icon: Icons.space_bar, 
                              label: "SPASI", 
                              color: Colors.blueAccent, 
                              onTap: () => _controller.addSpace()
                            ),
                        
                            // HAPUS
                            _buildActionButton(
                              icon: Icons.backspace, 
                              label: "HAPUS", 
                              color: Colors.orangeAccent, 
                              onTap: () => _controller.backspace()
                            ),
                        
                            // RESET
                            _buildActionButton(
                              icon: Icons.refresh, 
                              label: "RESET", 
                              color: Colors.redAccent, 
                              onTap: () => _controller.clearSentence()
                            ),

                            // TTS
                            _buildActionButton(
                              icon: Icons.volume_up, 
                              label: "SUARA", 
                              color: Colors.purpleAccent, 
                              onTap: () => _controller.speakSentence()
                            ),
                        
                            // SIMPAN
                            _buildActionButton(
                              icon: Icons.cloud_upload, 
                              label: "SIMPAN", 
                              color: Colors.cyanAccent, 
                              onTap: () => _controller.saveSentenceToBackend(),
                              isLoading: _controller.state.isSaving
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5), width: 1.5)
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(color: color, strokeWidth: 2),
                    )
                  : Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label, 
              style: TextStyle(
                color: color, 
                fontSize: 10,
                fontWeight: FontWeight.bold
              )
            ),
          ],
        ),
      ),
    );
  }
}