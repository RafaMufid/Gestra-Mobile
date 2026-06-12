import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestra/login.dart';

void main() {
  group('LoginPage', () {
    testWidgets('renders login form with email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('shows error when fields are empty and login is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      await tester.tap(find.text('Log in'));
      await tester.pump();
      
      expect(find.text('Email dan password wajib diisi'), findsOneWidget);
    });

    testWidgets('allows text input in email field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      final emailField = find.byType(TextField).at(0);
      await tester.enterText(emailField, 'test@example.com');
      
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('allows text input in password field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      final passField = find.byType(TextField).at(1);
      await tester.enterText(passField, 'mypassword');
      
      expect(find.text('mypassword'), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      final passField = find.byType(TextField).at(1);
      final textField = tester.widget<TextField>(passField);
      
      expect(textField.obscureText, true);
    });

    testWidgets('password visibility can be toggled', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      expect(visibilityIcon, findsOneWidget);
      
      await tester.tap(visibilityIcon);
      await tester.pump();
      
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
