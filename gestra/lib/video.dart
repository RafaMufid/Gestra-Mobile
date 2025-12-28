import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  bool _isRecording = false;
  String _detectedText = 'TIDAK ADA'; 
  String _confidence = "";

  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isModelLoaded = false;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _setupSystem();
  }

  @override
  void dispose() {
    _controller?.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> _setupSystem() async {
    await Permission.camera.request();

    await _loadModel();

    await _initializeCamera();
  }

  Future<void> _loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model_sibi.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
      setState(() {
        _isModelLoaded = res == "success";
      });
      debugPrint("Model Loaded: $res");
    } catch (e) {
      debugPrint("Gagal memuat model: $e");
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Cari kamera depan
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });

      _controller!.startImageStream((CameraImage img) {
        if (_isRecording && !_isBusy && _isModelLoaded) {
          _isBusy = true;
          _runModelOnFrame(img);
        }
      });
    } catch (e) {
      debugPrint('Error kamera: $e');
    }
  }

  Future<void> _runModelOnFrame(CameraImage img) async {
    try {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 127.5, // YOLO biasanya inputnya 0-1 atau 0-255, coba 0 atau 127.5
        imageStd: 127.5, // Normalisasi pixel 0-1
        rotation: 270,
        numResults: 1,
        threshold: 0.4,
        asynch: true,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        setState(() {
          String label = recognitions[0]['label'];
          _detectedText = label.replaceAll(RegExp(r'[0-9]'), '').trim(); 
          
          double confValue = recognitions[0]['confidence'];
          _confidence = "${(confValue * 100).toStringAsFixed(0)}%";
        });
      }
    } catch (e) {
      debugPrint("Error deteksi: $e");
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video'),
        automaticallyImplyLeading: false,
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white :Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraPreview(),
            _buildGestureOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return CameraPreview(_controller!);
  }

  Widget _buildGestureOverlay() {
    final Color statusColor = _isRecording ? Colors.green : Colors.grey;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(150, 0, 0, 0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Text(
              'Posisikan tangan Anda di depan kamera',
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          
          if (_isRecording && _confidence.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "Akurasi: $_confidence",
                style: const TextStyle(color: Colors.yellow, fontSize: 16),
              ),
            ),

          _buildButtonRow(
            onStart: () {
              setState(() {
                _isRecording = true;
                _detectedText = "Mendeteksi...";
              });
            },
            onStop: () {
              setState(() {
                _isRecording = false;
                _detectedText = "TIDAK ADA";
                _confidence = "";
              });
            },
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(180, 0, 0, 0),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: statusColor, width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  'GESTUR TERDETEKSI:',
                  style: TextStyle(
                    color: Color.fromARGB(150, 255, 255, 255),
                    fontSize: 14.0,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  _detectedText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 40.0,
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

  Widget _buildButtonRow({required VoidCallback onStart, required VoidCallback onStop}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          label: const Text('Start', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: onStop,
          icon: const Icon(Icons.stop, color: Colors.white),
          label: const Text('Stop', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
        ),
      ],
    );
  }
}