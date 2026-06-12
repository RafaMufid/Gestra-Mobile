import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestra/Theme/ThemeManager.dart'; 

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WBT: FR15-Logika Dark Mode (TC15-01 & TC15-02)', () {
    test('TC15-01: toggleTheme(true) harus mengubah themeMode menjadi ThemeMode.dark', () {
      final themeManager = ThemeManager();
      
      // Dark mode diaktifkan
      themeManager.toggleTheme(true);
      
      // themeMode berubah menjadi ThemeMode.dark
      expect(themeManager.themeMode, ThemeMode.dark);
    });

    test('TC15-02: toggleTheme(false) harus mengubah themeMode menjadi ThemeMode.light', () {
      final themeManager = ThemeManager();
      themeManager.toggleTheme(true);
      
      // Dark mode dimatikan
      themeManager.toggleTheme(false);
      
      // themeMode kembali menjadi ThemeMode.light
      expect(themeManager.themeMode, ThemeMode.light);
    });
  });
}