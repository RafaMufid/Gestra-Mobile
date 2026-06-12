import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestra/register.dart';

void main() {
  group('RegisterPage', () {
    testWidgets('renders register form with all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('shows error when fields are empty and register is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      await tester.tap(find.text('Register'));
      await tester.pump();
      
      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'username');
      await tester.enterText(fields.at(1), 'user@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password456');
      
      await tester.tap(find.text('Register'));
      await tester.pump();
      
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('allows text input in all fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'testuser');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), 'password');
      await tester.enterText(fields.at(3), 'password');
      
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password fields are obscured by default', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      final fields = find.byType(TextField);
      final passField = tester.widget<TextField>(fields.at(2));
      final confirmPassField = tester.widget<TextField>(fields.at(3));
      
      expect(passField.obscureText, true);
      expect(confirmPassField.obscureText, true);
    });

    testWidgets('password visibility can be toggled', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      final visibilityIcons = find.byIcon(Icons.visibility_off);
      expect(visibilityIcons, findsWidgets);
      
      await tester.tap(visibilityIcons.first);
      await tester.pump();
      
      expect(find.byIcon(Icons.visibility), findsWidgets);
    });
  });
}
