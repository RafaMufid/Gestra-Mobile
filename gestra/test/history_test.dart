import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestra/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HistoryPage', () {
    testWidgets('shows loading indicator and redirects to login when token is missing', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/login': (_) => const Scaffold(body: Center(child: Text('login page'))),
        },
        home: const HistoryPage(),
      ));

      expect(find.text('History'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('login page'), findsOneWidget);
      expect(find.byType(HistoryPage), findsNothing);
    });
  });
}
