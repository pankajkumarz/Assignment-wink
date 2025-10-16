// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:local_pulse_authority/main.dart';

void main() {
  testWidgets('Authority app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LocalPulseAuthorityApp());

    // Verify that our app loads with the splash screen
    expect(find.text('Local Pulse Authority'), findsOneWidget);
    expect(find.text('Efficient Issue Management'), findsOneWidget);
    
    // Wait for the splash screen timer to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));
    
    // Verify navigation to home screen
    expect(find.text('Authority Dashboard'), findsOneWidget);
    expect(find.text('Authority App Under Development'), findsOneWidget);
  });
}
