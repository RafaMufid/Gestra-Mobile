class DetectionResult {
  final String label;
  final double confidence;

  DetectionResult({required this.label, required this.confidence});
}

class VideoPageState {
  String detectedText;
  String sentenceBuffer;
  bool isRecording;
  bool isBusy;
  bool isSaving;
  bool isCameraInitialized;

  VideoPageState({
    this.detectedText = "TIDAK ADA",
    this.sentenceBuffer = "",
    this.isRecording = false,
    this.isBusy = false,
    this.isSaving = false,
    this.isCameraInitialized = false,
  });
}