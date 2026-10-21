import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_service_app/main.dart';

void main() {
  testWidgets('JeevanSeva app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const JeevanSevaApp());
    expect(find.byType(JeevanSevaApp), findsOneWidget);

    // Fast-forward splash screen timer
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
