import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechToTextPage extends StatefulWidget {
  @override
  State<SpeechToTextPage> createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  bool isRecording = false;
  late stt.SpeechToText _speech;
  String recognizedText = "";
  Timer? _timer;
  int _seconds = 0;
  bool isSpeechAvailable = false;

  @override
  void initState() {
    super.initState();
    requestMicPermission();
    _speech = stt.SpeechToText();
  }

  Future<void> saveSpeechResult() async {
    if (recognizedText.isEmpty) return;

    // ambil token dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print(token);
    if (token == null) {
      return;
    }

    final url = Uri.parse("http://192.168.1.101:8000/api/speech");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"text": recognizedText, "duration": _seconds}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await http.post(
          Uri.parse("http://192.168.1.101:8000/api/history"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "gesture_name": recognizedText,
            "accuracy": 1.0,          // atau pakai confidence kalau ada
            "source": "speech",
          }),
        );
        print("Berhasil disimpan");
      } else {
        print("Gagal simpan: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> requestMicPermission() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      debugPrint("Mic permission denied");
      return;
    }

    isSpeechAvailable = await _speech.initialize(
      onError: (e) => debugPrint("STT Error: $e"),
      onStatus: (s) => debugPrint("ℹSTT Status: $s"),
    );

    debugPrint("Speech available: $isSpeechAvailable");
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void _startTimer() {
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _toggleRecording() async {
    if (!isSpeechAvailable) return;

    if (!isRecording) {
      setState(() {
        isRecording = true;
        recognizedText = "";
      });

      _startTimer();

   
      await _speech.listen(
        localeId: "id_ID",
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: false,
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            recognizedText = result.recognizedWords;
          });
        },
        onSoundLevelChange: (level) {
          debugPrint("🎤 Sound level: $level");
        },
      );
    } else {
      setState(() => isRecording = false);
      _speech.stop();
      _stopTimer();

      if (recognizedText.trim().isNotEmpty) {
      await saveSpeechResult();
    }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Speech to Text'), elevation: 1),
      body: Column(
        children: [
          Container(
            height: 140,
            color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
            child: Center(
              child: Text(
                _formatTime(_seconds),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.black26,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recognizedText.isEmpty
                      ? "Mulai bicara untuk melihat hasil..."
                      : recognizedText,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  color: isRecording ? Theme.of(context).cardColor : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: isRecording ? Colors.red : Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
