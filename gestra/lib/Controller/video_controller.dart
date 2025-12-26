import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestra/Model/detection_model.dart';
import 'package:gestra/Controller/AuthController.dart';

class VideoController extends ChangeNotifier {
  VideoPageState state = VideoPageState();
  
  CameraController? cameraController;
  final AuthService _authService = AuthService();
  
  String _lastDetectedLabel = "";
  int _consecutiveFrames = 0;
  bool _isModelLoaded = false;

  String _lastAddedChar = "";

  Function(String message, bool isError)? onShowMessage;

  Future<void> initializeSystem() async {
    await _requestPermission();
    await _loadModel();
    await _initializeCamera();
  }

  Future<void> _requestPermission() async {
    await Permission.camera.request();
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
      _isModelLoaded = res != null;
      print("Model Loaded: $res");
    } catch (e) {
      print("Error loading model: $e");
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

    cameraController!.startImageStream((CameraImage img) {
      if (state.isRecording && !state.isBusy && _isModelLoaded) {
        state.isBusy = true;
        _runModelOnFrame(img);
      }
    });
  }

  Future<void> _runModelOnFrame(CameraImage img) async {
    try {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 270,
        numResults: 1,
        threshold: 0.4,
        asynch: true,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        String rawLabel = recognitions[0]['label'].toString();
        String label = rawLabel.replaceAll(RegExp(r'[0-9]'), '').trim();
        double confidence = recognitions[0]['confidence'];

        state.detectedText = "$label ${(confidence * 100).toStringAsFixed(0)}%";
        
        _processDetectionLogic(label, confidence);
      }
    } catch (e) {
      print("Error running model: $e");
    } finally {
      state.isBusy = false;
      notifyListeners();
    }
  }

  // Save Detection Logic
  void _processDetectionLogic(String label, double confidence) {
    if (confidence > 0.5) {
      if (label == _lastDetectedLabel) {
        _consecutiveFrames++;
      } else {
        _consecutiveFrames = 0;
        _lastDetectedLabel = label;
      }

      // Jika terdeteksi stabil 10 frame
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
      state.sentenceBuffer = state.sentenceBuffer.substring(0, state.sentenceBuffer.length - 1);
      _lastAddedChar = ""; // Reset State setelah Save
      notifyListeners();
    }
  }

  void addSpace() {
    if (state.sentenceBuffer.isNotEmpty && !state.sentenceBuffer.endsWith(" ")) {
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
      bool success = await _authService.saveHistory(token, state.sentenceBuffer, 1.0);
      
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
    Tflite.close();
    cameraController?.dispose();
    super.dispose();
  }
}