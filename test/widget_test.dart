import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scroll_rok/main.dart';

void main() {
  testWidgets('App renders root shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const ScrollRokApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('ScrollRok iOS'), findsOneWidget);
  });
}
