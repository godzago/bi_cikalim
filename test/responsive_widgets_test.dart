import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:bi_cikalim/shared/widgets/app_empty_state.dart';
import 'package:bi_cikalim/shared/widgets/app_refreshable_content.dart';
import 'package:bi_cikalim/shared/widgets/category_card.dart';
import 'package:bi_cikalim/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void configureCompactView(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
  }

  Widget testApp(Widget child) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(1.35),
        ),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('kategori kartı dar alanda taşma üretmez', (tester) async {
    configureCompactView(tester);

    const category = ApiCategory(
      id: 'category',
      name: 'Masaüstü Oyunları ve Turnuvalar',
      slug: 'masaustu-oyunlari',
      iconName: 'casino',
      description: 'Arkadaşlarınla oynayabileceğin etkinlikler',
      isActive: true,
      sortOrder: 0,
    );

    await tester.pumpWidget(
      testApp(
        const Center(
          child: SizedBox(
            width: 142,
            height: 152,
            child: CategoryCard(category: category, onTap: _noop),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('uzun buton etiketi büyütülmüş yazıda taşmaz', (tester) async {
    configureCompactView(tester);

    await tester.pumpWidget(
      testApp(
        const Padding(
          padding: EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: PrimaryButton(
              label: 'Sıfırlama E-postası Gönder',
              onPressed: _noop,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('boş durum kısa ekranda kaydırılabilir', (tester) async {
    configureCompactView(tester);

    await tester.pumpWidget(
      testApp(
        const AppEmptyState(
          icon: Icons.cloud_off,
          message:
              'İçerik şu anda yüklenemedi. Bağlantını kontrol edip tekrar deneyebilirsin.',
          actionLabel: 'Tekrar Dene',
          onAction: _noop,
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scroll içermeyen durumda aşağı çekme yenilemeyi çalıştırır', (
    tester,
  ) async {
    configureCompactView(tester);
    var refreshed = false;

    await tester.pumpWidget(
      testApp(
        AppRefreshableContent(
          onRefresh: () async => refreshed = true,
          child: const AppEmptyState(icon: Icons.refresh, message: 'Yenile'),
        ),
      ),
    );

    await tester.drag(find.text('Yenile'), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(refreshed, isTrue);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
