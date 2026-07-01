import 'package:flutter_test/flutter_test.dart';
import 'package:neon_breakout/main.dart';

void main() {
  testWidgets('Neon Breakout smoke test - check start menu elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NeonBreakoutApp());

    // Verify that the title "NEON" and "BREAKOUT" is displayed on the menu
    expect(find.text('NEON'), findsOneWidget);
    expect(find.text('BREAKOUT'), findsOneWidget);
    
    // Verify that the "START GAME" button is present
    expect(find.text('START GAME'), findsOneWidget);
  });
}
