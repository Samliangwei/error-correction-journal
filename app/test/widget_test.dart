import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    
    expect(find.text('错题记录'), findsOneWidget);
  });
}
