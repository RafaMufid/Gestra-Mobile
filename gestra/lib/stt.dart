import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    requestMicPermission();
    _speech = stt.SpeechToText();
  }

  Future<void> requestMicPermission() async {
    await Permission.microphone.request();
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
    if (!isRecording) {
      bool available = await _speech.initialize(
        onError: (e) => print("Error: $e"),
        onStatus: (s) => print("Status: $s"),
      );

      if (available) {
        setState(() {
          isRecording = true;
          recognizedText = "";
        });

        _startTimer();

        _speech.listen(
          localeId: "id_ID",
          onResult: (result) {
            if (!mounted) return;
            setState(() => recognizedText = result.recognizedWords);
          },
        );
      }
    } else {
      setState(() => isRecording = false);
      _speech.stop();
      _stopTimer();
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
