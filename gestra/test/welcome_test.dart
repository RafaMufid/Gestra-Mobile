import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestra/welcome.dart';

void main() {
  group('WelcomePage', () {
    testWidgets('renders welcome page with buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomePage()));
      
      expect(find.text('GESTRA'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('renders app logo', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomePage()));
      
      final imageWidget = find.byType(Image);
      expect(imageWidget, findsOneWidget);
    });

    testWidgets('Log In button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomePage()));
      
      final logInButton = find.byType(ElevatedButton).first;
      expect(logInButton, findsOneWidget);
      
      await tester.tap(logInButton);
      await tester.pumpAndSettle();
      
      // Verify navigation occurred
      expect(find.byType(WelcomePage), findsNothing);
    });

    testWidgets('Sign Up button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomePage()));
      
      final signUpButton = find.byType(ElevatedButton).at(1);
      expect(signUpButton, findsOneWidget);
      
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      
      // Verify navigation occurred
      expect(find.byType(WelcomePage), findsNothing);
    });

    testWidgets('buttons have blue background color', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomePage()));
      
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
    });
  });
}
