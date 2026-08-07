import 'package:bi_cikalim/shared/utils/app_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  const failureMessage = 'Bağlantı açılamadı.';

  testWidgets('rejects invalid and unapproved URLs without launching', (
    tester,
  ) async {
    var launchCount = 0;
    final context = await _pumpContext(tester);

    final rejectedScheme = await launchAppExternalUrl(
      context: context,
      rawUrl: ' javascript:alert(1) ',
      allowedSchemes: webUrlSchemes,
      failureMessage: failureMessage,
      launcher: (uri, {mode = LaunchMode.platformDefault}) async {
        launchCount++;
        return true;
      },
    );
    final rejectedMissingHost = await launchAppExternalUrl(
      context: context,
      rawUrl: 'https:///missing-host',
      allowedSchemes: webUrlSchemes,
      failureMessage: failureMessage,
      launcher: (uri, {mode = LaunchMode.platformDefault}) async {
        launchCount++;
        return true;
      },
    );
    await tester.pump();

    expect(rejectedScheme, isFalse);
    expect(rejectedMissingHost, isFalse);
    expect(launchCount, 0);
    expect(find.text(failureMessage), findsOneWidget);
  });

  testWidgets('reports a false launcher result without crashing', (
    tester,
  ) async {
    final context = await _pumpContext(tester);

    final launched = await launchAppExternalUrl(
      context: context,
      rawUrl: '  https://example.com/path  ',
      allowedSchemes: webUrlSchemes,
      failureMessage: failureMessage,
      launcher: (uri, {mode = LaunchMode.platformDefault}) async {
        expect(uri.toString(), 'https://example.com/path');
        expect(mode, LaunchMode.externalApplication);
        return false;
      },
    );
    await tester.pump();

    expect(launched, isFalse);
    expect(find.text(failureMessage), findsOneWidget);
  });

  testWidgets('catches launcher exceptions and reports the failure', (
    tester,
  ) async {
    final context = await _pumpContext(tester);

    final launched = await launchAppExternalUrl(
      context: context,
      rawUrl: 'https://example.com',
      allowedSchemes: webUrlSchemes,
      failureMessage: failureMessage,
      launcher: (uri, {mode = LaunchMode.platformDefault}) async {
        throw StateError('platform failure');
      },
    );
    await tester.pump();

    expect(launched, isFalse);
    expect(find.text(failureMessage), findsOneWidget);
  });

  testWidgets('allows tel only when explicitly requested', (tester) async {
    var launchCount = 0;
    final context = await _pumpContext(tester);

    final rejected = await launchAppExternalUrl(
      context: context,
      rawUrl: 'tel:+905551112233',
      allowedSchemes: webUrlSchemes,
      failureMessage: failureMessage,
      launcher: (uri, {mode = LaunchMode.platformDefault}) async {
        launchCount++;
        return true;
      },
    );
    final accepted = await launchAppExternalUrl(
      context: context,
      rawUrl: 'tel:+905551112233',
      allowedSchemes: phoneUrlSchemes,
      failureMessage: failureMessage,
      launcher: (uri, {mode = LaunchMode.platformDefault}) async {
        launchCount++;
        return true;
      },
    );

    expect(rejected, isFalse);
    expect(accepted, isTrue);
    expect(launchCount, 1);
  });
}

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (builderContext) {
            context = builderContext;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return context;
}
