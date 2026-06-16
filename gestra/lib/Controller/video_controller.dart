import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestra/Model/detection_model.dart';
import 'package:gestra/Controller/AuthController.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VideoController extends ChangeNotifier {
  VideoPageState state = VideoPageState();

  CameraController? cameraController;
  final AuthService _authService = AuthService();

  FlutterTts flutterTts = FlutterTts();

  Interpreter? _interpreter;
  List<String> _labels = [];

  String _lastDetectedLabel = "";
  int _consecutiveFrames = 0;
  bool _isModelLoaded = false;

  String _lastAddedChar = "";

  // Error message for UI
  String? modelError;

  Function(String message, bool isError)? onShowMessage;

  Future<void> initializeSystem() async {
    await _requestPermission();
    await _initTts();
    await _loadModel();
    await _loadLabels();
    await _initializeCamera();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _requestPermission() async {
    await Permission.camera.request();
  }

  Future<void> _loadModel() async {
    try {
      final byteData = await rootBundle.load('assets/model_sibi.tflite');
      final buffer = byteData.buffer.asUint8List();
      _interpreter = Interpreter.fromBuffer(buffer);
      _isModelLoaded = true;
      debugPrint("Model loaded successfully");
    } catch (e) {
      _isModelLoaded = false;
      modelError = "Gagal memuat model: $e";
      debugPrint("Error loading model: $e");
      if (onShowMessage != null) {
        onShowMessage!("Gagal memuat model deteksi", true);
      }
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
      debugPrint("Labels loaded: ${_labels.length} classes");
    } catch (e) {
      debugPrint("Error loading labels: $e");
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await cameraController!.initialize();
    state.isCameraInitialized = true;
    notifyListeners();

    cameraController!.startImageStream((CameraImage image) {
      if (state.isRecording && !state.isBusy && _isModelLoaded) {
        state.isBusy = true;
        _runModelOnFrame(image);
      }
    });
  }

  /// Convert CameraImage (YUV420) to img.Image, then resize to 224x224
  img.Image _convertCameraImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * yPlane.bytesPerRow + x;
        final int uvIndex = (y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2);

        final int yVal = yPlane.bytes[yIndex];
        final int uVal = uPlane.bytes[uvIndex];
        final int vVal = vPlane.bytes[uvIndex];

        // YUV to RGB conversion
        int r = (yVal + 1.370705 * (vVal - 128)).round().clamp(0, 255);
        int g = (yVal - 0.337633 * (uVal - 128) - 0.698001 * (vVal - 128))
            .round()
            .clamp(0, 255);
        int b = (yVal + 1.732446 * (uVal - 128)).round().clamp(0, 255);

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    // Rotate for front camera (typical Android sensor orientation)
    final rotated = img.copyRotate(image, angle: -90);

    // Resize to model input size
    return img.copyResize(rotated, width: 224, height: 224);
  }

  /// Prepare input tensor from img.Image [1, 224, 224, 3] normalized to [-1, 1]
  Float32List _imageToFloat32(img.Image image) {
    final Float32List buffer = Float32List(1 * 224 * 224 * 3);
    int index = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);
        buffer[index++] = (pixel.r.toDouble() - 127.5) / 127.5;
        buffer[index++] = (pixel.g.toDouble() - 127.5) / 127.5;
        buffer[index++] = (pixel.b.toDouble() - 127.5) / 127.5;
      }
    }
    return buffer;
  }

  Future<void> _runModelOnFrame(CameraImage cameraImage) async {
    try {
      if (_interpreter == null || _labels.isEmpty) return;

      // Convert camera frame to model input
      final image = _convertCameraImage(cameraImage);
      final input = _imageToFloat32(image);

      // Reshape input to [1, 224, 224, 3]
      final inputTensor = input.reshape([1, 224, 224, 3]);

      // Output: [1, numClasses]
      final output = List.filled(
        1 * _labels.length,
        0.0,
      ).reshape([1, _labels.length]);

      _interpreter!.run(inputTensor, output);

      // Find best prediction
      final outputList = output[0] as List<double>;
      double maxScore = 0;
      int maxIndex = -1;
      for (int i = 0; i < outputList.length; i++) {
        if (outputList[i] > maxScore) {
          maxScore = outputList[i];
          maxIndex = i;
        }
      }

      if (maxIndex >= 0 && maxIndex < _labels.length) {
        String label = _labels[maxIndex];
        double confidence = maxScore;

        state.detectedText = "$label ${(confidence * 100).toStringAsFixed(0)}%";
        _processDetectionLogic(label, confidence);
      }
    } catch (e) {
      debugPrint("Error running model: $e");
    } finally {
      state.isBusy = false;
      notifyListeners();
    }
  }

  void _processDetectionLogic(String label, double confidence) {
    if (confidence > 0.5) {
      if (label == _lastDetectedLabel) {
        _consecutiveFrames++;
      } else {
        _consecutiveFrames = 0;
        _lastDetectedLabel = label;
      }

      if (_consecutiveFrames > 10 && !state.isSaving) {
        if (label != _lastAddedChar) {
          _appendLetter(label);
          _consecutiveFrames = 0;
        }
      }
    } else {
      _consecutiveFrames = 0;
    }
  }

  Future<void> speakSentence() async {
    if (state.sentenceBuffer.isNotEmpty) {
      await flutterTts.speak(state.sentenceBuffer);
    } else {
      if (onShowMessage != null) {
        onShowMessage!("Tidak ada teks untuk dibaca", true);
      }
    }
  }

  void _appendLetter(String letter) {
    state.sentenceBuffer += letter;
    _lastAddedChar = letter;
    notifyListeners();
  }

  void toggleRecording() {
    state.isRecording = !state.isRecording;
    if (!state.isRecording) {
      state.detectedText = "TIDAK ADA";
      _consecutiveFrames = 0;
    }
    notifyListeners();
  }

  void backspace() {
    if (state.sentenceBuffer.isNotEmpty) {
      state.sentenceBuffer = state.sentenceBuffer.substring(
        0,
        state.sentenceBuffer.length - 1,
      );
      _lastAddedChar = "";
      notifyListeners();
    }
  }

  void addSpace() {
    if (state.sentenceBuffer.isNotEmpty &&
        !state.sentenceBuffer.endsWith(" ")) {
      state.sentenceBuffer += " ";
      _lastAddedChar = "";
      notifyListeners();
    }
  }

  void clearSentence() {
    state.sentenceBuffer = "";
    _lastAddedChar = "";
    notifyListeners();
  }

  Future<void> saveSentenceToBackend() async {
    if (state.sentenceBuffer.isEmpty) return;

    state.isSaving = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      bool success = await _authService.saveHistory(
        token,
        state.sentenceBuffer,
        1.0,
      );

      if (success && onShowMessage != null) {
        onShowMessage!("Kalimat disimpan!", false);
        state.sentenceBuffer = "";
        _lastAddedChar = "";
      } else if (onShowMessage != null) {
        onShowMessage!("Gagal menyimpan.", true);
      }
    }

    state.isSaving = false;
    notifyListeners();
  }

  void disposeController() {
    _interpreter?.close();
    cameraController?.dispose();
    super.dispose();
  }
}
