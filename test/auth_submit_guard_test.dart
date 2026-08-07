import 'dart:async';

import 'package:bi_cikalim/features/auth/presentation/providers/user_session_provider.dart';
import 'package:bi_cikalim/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:bi_cikalim/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:bi_cikalim/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign in ignores a second keyboard submit while loading', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        userSessionProvider.overrideWith(_CountingUserSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SignInScreen()),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'password');

    final submit = tester
        .widget<AppTextField>(find.byType(AppTextField).last)
        .onFieldSubmitted!;
    submit('password');
    submit('password');

    final notifier =
        container.read(userSessionProvider.notifier)
            as _CountingUserSessionNotifier;
    expect(notifier.signInCallCount, 1);
  });

  testWidgets('sign up ignores a second keyboard submit while loading', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        userSessionProvider.overrideWith(_CountingUserSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SignUpScreen()),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test_user');
    await tester.enterText(fields.at(2), 'user@example.com');
    await tester.enterText(fields.at(3), 'password');
    await tester.enterText(fields.at(4), 'password');

    final submit = tester
        .widget<AppTextField>(find.byType(AppTextField).last)
        .onFieldSubmitted!;
    submit('password');
    submit('password');

    final notifier =
        container.read(userSessionProvider.notifier)
            as _CountingUserSessionNotifier;
    expect(notifier.signUpCallCount, 1);
  });
}

class _CountingUserSessionNotifier extends UserSessionNotifier {
  final _pending = Completer<void>();
  int signInCallCount = 0;
  int signUpCallCount = 0;

  @override
  Future<void> build() async {}

  @override
  Future<void> signIn({required String email, required String password}) {
    signInCallCount++;
    return _pending.future;
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String role,
  }) {
    signUpCallCount++;
    return _pending.future;
  }
}
