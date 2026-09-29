import 'package:buriad_ug/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('аппын нэр харагдана', (tester) async {
    await tester.pumpWidget(const BuriadUgApp());

    expect(find.text('Буриад үг'), findsOneWidget);
  });
}
