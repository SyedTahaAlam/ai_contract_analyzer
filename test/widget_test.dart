import 'package:flutter_test/flutter_test.dart';
import 'package:proof/main.dart';

void main() {
  testWidgets('ProofApp renders input view by default', (WidgetTester tester) async {
    await tester.pumpWidget(const ProofApp());
    await tester.pump();

    // The input view should show the 'Proof' title
    expect(find.text('Proof'), findsWidgets);
    // The headline should appear
    expect(find.textContaining("Know what you're signing."), findsOneWidget);
    // The analyze button should appear
    expect(find.text('Analyze contract'), findsOneWidget);
    // The load sample button should appear
    expect(find.text('Load sample contract'), findsOneWidget);
  });
}
