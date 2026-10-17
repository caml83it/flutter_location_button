import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_location_button/flutter_location_button.dart';
import 'package:flutter_location_button_example/main.dart';

void main() {
  testWidgets('Verify LocationButton renders in example app', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(LocationButton), findsOneWidget);
  });
}
