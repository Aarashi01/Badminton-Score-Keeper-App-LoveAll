import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_score_keeper/main.dart';

void main() {
  testWidgets('App starts with Match Setup screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BadmintonScoreApp());

    // Verify that Match Setup is shown
    expect(find.text('Match Setup'), findsOneWidget);
    expect(find.text('Singles'), findsOneWidget);
    expect(find.text('Doubles'), findsOneWidget);
  });
}
