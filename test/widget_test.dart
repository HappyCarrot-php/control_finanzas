import 'package:flutter_test/flutter_test.dart';
import 'package:control_finanzas/main.dart';

void main() {
  testWidgets('WealthVault app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WealthVaultApp());

    // Verify that our app loads with the title
    expect(find.text('WealthVault'), findsOneWidget);
  });
}
