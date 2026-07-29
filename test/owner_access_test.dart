import 'package:bi_cikalim/features/auth/presentation/providers/user_session_provider.dart';
import 'package:bi_cikalim/features/auth/presentation/screens/venue_owner_screen.dart';
import 'package:bi_cikalim/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppUser userWithRole(String role) => AppUser(
    id: role,
    displayName: 'Test',
    email: '$role@example.com',
    roles: [role],
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  Widget appFor(AppUser user) => ProviderScope(
    overrides: [
      currentUserProvider.overrideWith(() => _TestUserNotifier(user)),
    ],
    child: const MaterialApp(home: VenueOwnerScreen()),
  );

  testWidgets('normal kullanıcı işletme görsel yükleme aracını göremez', (
    tester,
  ) async {
    await tester.pumpWidget(appFor(userWithRole('user')));
    expect(find.text('Mekan görseli yükle'), findsNothing);
    expect(
      find.text('Bu alan yalnızca doğrulanmış işletme sahiplerine açıktır.'),
      findsOneWidget,
    );
  });

  testWidgets('venue_owner görsel yükleme aracını görür', (tester) async {
    await tester.pumpWidget(appFor(userWithRole('venue_owner')));
    expect(find.text('Mekan görseli yükle'), findsOneWidget);
    expect(find.text('İşletmeye özel'), findsOneWidget);
  });
}

class _TestUserNotifier extends CurrentUserNotifier {
  final AppUser initialUser;

  _TestUserNotifier(this.initialUser);

  @override
  AppUser? build() => initialUser;
}
