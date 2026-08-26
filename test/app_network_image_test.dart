import 'package:bi_cikalim/shared/widgets/app_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const imageUrl = 'https://example.invalid/image.jpg';

  Widget testApp({required Widget child, double devicePixelRatio = 1}) {
    return MediaQuery(
      data: MediaQueryData(devicePixelRatio: devicePixelRatio),
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  CachedNetworkImage cachedImage(WidgetTester tester) {
    return tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
  }

  testWidgets('uses tight bounded layout constraints for memory cache size', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        devicePixelRatio: 2,
        child: const SizedBox(
          width: 120,
          height: 80,
          child: AppNetworkImage(imageUrl: imageUrl),
        ),
      ),
    );

    expect(cachedImage(tester).memCacheWidth, 240);
    expect(cachedImage(tester).memCacheHeight, 160);
  });

  testWidgets('prefers explicit finite dimensions over loose constraints', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        child: const Center(
          child: AppNetworkImage(imageUrl: imageUrl, width: 96, height: 64),
        ),
      ),
    );

    expect(cachedImage(tester).memCacheWidth, 96);
    expect(cachedImage(tester).memCacheHeight, 64);
  });

  testWidgets('scales decode dimensions for high device pixel ratios', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        devicePixelRatio: 3.5,
        child: const AppNetworkImage(
          imageUrl: imageUrl,
          width: 100,
          height: 60,
        ),
      ),
    );

    expect(cachedImage(tester).memCacheWidth, 350);
    expect(cachedImage(tester).memCacheHeight, 210);
  });

  testWidgets('leaves cache dimensions unset in an unbounded layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        devicePixelRatio: 3,
        child: const UnconstrainedBox(
          child: AppNetworkImage(imageUrl: imageUrl),
        ),
      ),
    );

    expect(cachedImage(tester).memCacheWidth, isNull);
    expect(cachedImage(tester).memCacheHeight, isNull);
  });

  testWidgets('uses local fallback for empty image urls', (tester) async {
    await tester.pumpWidget(
      testApp(
        child: const SizedBox(
          width: 120,
          height: 80,
          child: AppNetworkImage(imageUrl: ' '),
        ),
      ),
    );

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });
}
