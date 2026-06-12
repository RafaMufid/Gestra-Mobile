import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestra/setting.dart';

void main() {
  group('SettingsPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders settings page with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPage(onNavigate: (_) {}),
        ),
      );
      
      expect(find.text('Pengaturan'), findsOneWidget);
    });

    testWidgets('renders dark mode toggle switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPage(onNavigate: (_) {}),
        ),
      );
      
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('renders settings sections headers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPage(onNavigate: (_) {}),
        ),
      );
      
      expect(find.text('UMUM'), findsOneWidget);
      expect(find.text('AKUN & BANTUAN'), findsOneWidget);
    });

    testWidgets('dark mode toggle can be tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPage(onNavigate: (_) {}),
        ),
      );
      
      final switchTile = find.byType(SwitchListTile);
      expect(switchTile, findsOneWidget);
      
      await tester.tap(switchTile);
      await tester.pumpAndSettle();
      
      expect(switchTile, findsOneWidget);
    });

    testWidgets('renders list items for account management', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPage(onNavigate: (_) {}),
        ),
      );
      
      expect(find.text('Kelola Akun'), findsOneWidget);
    });

    testWidgets('settings page uses scrollable list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPage(onNavigate: (_) {}),
        ),
      );
      
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
