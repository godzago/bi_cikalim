import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bi_cikalim/main.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that splash screen content is present
    expect(find.text('BiÇıkalım'), findsOneWidget);
    expect(find.text('Şehrindeki Eğlenceyi Keşfet'), findsOneWidget);
  });
}
