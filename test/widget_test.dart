import 'package:flutter_test/flutter_test.dart';

import 'package:repchamp/app.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RepChampApp());
    expect(find.byType(RepChampApp), findsOneWidget);
  });
}
