import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clean_architecture_flutter/main.dart';
import 'package:clean_architecture_flutter/core/providers/core_providers.dart';

void main() {
  testWidgets('Initial route load test', (WidgetTester tester) async {
    // Mock shared preferences values
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for the GoRouter initialization and initial frame rendering
    await tester.pumpAndSettle();

    // Verify that our initial screen shows the 'Store Verification' text.
    expect(find.text('Store Verification'), findsOneWidget);
  });
}
