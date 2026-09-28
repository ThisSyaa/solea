import 'package:flutter_test/flutter_test.dart';

import 'package:demo/main.dart';

void main() {
  testWidgets('SOLEA app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
