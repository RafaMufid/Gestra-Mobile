import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestra/stt.dart';

void main() {
  group('SpeechToTextPage widget', () {
    testWidgets('renders initial speech page content', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SpeechToTextPage()));

      expect(find.text('Speech to Text'), findsOneWidget);
      expect(find.text('Mulai bicara untuk melihat hasil...'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('renders timer display with 00:00', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SpeechToTextPage()));

      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('mic button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SpeechToTextPage()));

      final micButton = find.byIcon(Icons.mic);
      expect(micButton, findsOneWidget);

      await tester.tap(micButton);
      await tester.pump();

      // Tapping should not crash when permissions are not granted or speech unavailable
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
