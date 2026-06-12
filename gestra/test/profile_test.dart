import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestra/profile.dart';

void main() {
  group('ProfilePage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'token': 'test_token',
        'password': 'test_password',
      });
    });

    testWidgets('renders profile page with loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders profile page as stateful widget', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pump();

      // Verify Scaffold is rendered
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('profile page has app bar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('profile page uses scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pump();

      // Should have SingleChildScrollView for content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('profile page renders circle avatar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pump();

      // Should have CircleAvatar for profile image
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('profile page handles missing token gracefully',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pump();

      // Should still render without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('profile page renders without crashing with valid token',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should have rendered successfully
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('profile page has column layout', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pump();

      // Main layout should be Column or similar
      expect(find.byType(Column), findsWidgets);
    });
  });
}

