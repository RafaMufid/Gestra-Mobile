import 'package:flutter_test/flutter_test.dart';
import 'package:gestra/Model/detection_model.dart';

void main() {
  group('DetectionResult', () {
    test('DetectionResult creation with required parameters', () {
      final result = DetectionResult(
        label: 'A',
        confidence: 0.95,
      );

      expect(result.label, 'A');
      expect(result.confidence, 0.95);
    });

    test('DetectionResult with different confidence values', () {
      final lowConfidence = DetectionResult(label: 'B', confidence: 0.1);
      final highConfidence = DetectionResult(label: 'B', confidence: 0.99);

      expect(lowConfidence.confidence, 0.1);
      expect(highConfidence.confidence, 0.99);
    });

    test('DetectionResult with various label values', () {
      final labels = ['A', 'B', 'C', 'SPACE', 'BACKSPACE'];
      
      for (String label in labels) {
        final result = DetectionResult(label: label, confidence: 0.5);
        expect(result.label, label);
      }
    });
  });

  group('VideoPageState', () {
    test('VideoPageState default values', () {
      final state = VideoPageState();

      expect(state.detectedText, 'TIDAK ADA');
      expect(state.sentenceBuffer, '');
      expect(state.isRecording, false);
      expect(state.isBusy, false);
      expect(state.isSaving, false);
      expect(state.isCameraInitialized, false);
    });

    test('VideoPageState with custom values', () {
      final state = VideoPageState(
        detectedText: 'A 95%',
        sentenceBuffer: 'Hello',
        isRecording: true,
        isBusy: true,
        isSaving: false,
        isCameraInitialized: true,
      );

      expect(state.detectedText, 'A 95%');
      expect(state.sentenceBuffer, 'Hello');
      expect(state.isRecording, true);
      expect(state.isBusy, true);
      expect(state.isSaving, false);
      expect(state.isCameraInitialized, true);
    });

    test('VideoPageState can be modified after creation', () {
      final state = VideoPageState();
      
      state.detectedText = 'B 87%';
      state.sentenceBuffer = 'Modified';
      state.isRecording = true;

      expect(state.detectedText, 'B 87%');
      expect(state.sentenceBuffer, 'Modified');
      expect(state.isRecording, true);
    });

    test('Multiple VideoPageState instances are independent', () {
      final state1 = VideoPageState();
      final state2 = VideoPageState();

      state1.detectedText = 'State1';
      state2.detectedText = 'State2';

      expect(state1.detectedText, 'State1');
      expect(state2.detectedText, 'State2');
    });
  });
}
