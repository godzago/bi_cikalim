import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/user_session_provider.dart';

/// Kullanıcı profil ekranı.
/// API oturumu ve kullanıcı profilini gösterir.
/// İleride FastAPI backend'den gerçek kullanıcı verisi çekilecek.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _refreshProfile(WidgetRef ref) async {
    final hadUser = ref.read(currentUserProvider) != null;
    ref.invalidate(selectedCityProvider);

    final futures = <Future<void>>[
      ref.read(selectedCityProvider.future).then((_) {}),
    ];
    if (hadUser) {
      futures.add(
        ref.read(apiAuthServiceProvider).fetchCurrentUser().then((user) async {
          ref.read(currentUserProvider.notifier).setUser(user);
          await ApiClient.instance.saveCachedUser(user);
        }),
      );
    }
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = ref.watch(userTypeProvider);
    final isVenueOwner = ref.watch(isVenueOwnerProvider);
    final user = ref.watch(currentUserProvider);
    final selectedCity = ref.watch(selectedCityProvider).value;

    final displayName = user?.displayName ?? 'Misafir Kullanıcı';
    final email = user?.email ?? 'kullanici@bicikalim.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: user == null
                ? null
                : () => _showEditProfileDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: BiCikalimTheme.primary,
        onRefresh: () => _refreshProfile(ref),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Kullanıcı Avatar & İsim
              Center(
                child: Column(
                  children: [
                    // Avatar placeholder
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BiCikalimTheme.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: BiCikalimTheme.primary,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: BiCikalimTheme.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: BiCikalimTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Kullanıcı tipi badge
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          '📍 ${selectedCity?.name ?? 'Şehir seçilmedi'}',
                          BiCikalimTheme.primary.withValues(alpha: 0.1),
                          BiCikalimTheme.primary,
                        ),
                        _buildBadge(
                          userType == UserType.venueOwner
                              ? '🏪 Mekan Sahibi'
                              : '👤 Üye',
                          Colors.grey.shade100,
                          BiCikalimTheme.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // İşletme Yönetimi
              _buildSectionHeader('İşletme'),
              const SizedBox(height: 12),
              if (isVenueOwner)
                _buildMenuCard(
                  context,
                  icon: Icons.business_center_outlined,
                  title: 'İşletme Araçları',
                  subtitle: 'Mekan görsellerini ve işletme işlemlerini yönet.',
                  onTap: () => context.push('/venue-owner'),
                )
              else
                _buildMenuCard(
                  context,
                  icon: Icons.storefront,
                  title: 'Mekan Sahibi misiniz?',
                  subtitle: 'Mekanınızı ekleyin veya sahiplenin.',
                  onTap: () => context.push('/submissions/ownership'),
                ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.add_location_alt_outlined,
                title: 'Eksik Mekan Öner',
                subtitle: 'Listede olmayan bir mekanı admin ekibine ilet.',
                onTap: () => context.push('/submissions/venue'),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.category_outlined,
                title: 'Aktivite veya Kategori Öner',
                subtitle: 'Yeni taxonomy talebini admin onayına gönder.',
                onTap: () => context.push('/submissions/taxonomy'),
              ),
              const SizedBox(height: 24),

              // Hesap Ayarları
              _buildSectionHeader('Hesap'),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.location_city,
                title: 'Şehir Değiştir',
                subtitle: 'Aktif şehir: ${selectedCity?.name ?? 'Seçilmedi'}',
                onTap: () => context.go(AppConstants.citySelectRoute),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.info_outline,
                title: 'Hakkımızda',
                subtitle: 'BiÇıkalım platformu hakkında bilgi edinin.',
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // Çıkış Yap
              _buildMenuCard(
                context,
                icon: Icons.logout,
                title: 'Çıkış Yap',
                subtitle: 'Hesabından güvenli çıkış yap.',
                isDestructive: true,
                onTap: () => _showSignOutDialog(context, ref),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: BiCikalimTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? BiCikalimTheme.error : BiCikalimTheme.primary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDestructive
              ? BiCikalimTheme.error.withValues(alpha: 0.2)
              : Colors.grey.shade100,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,

            color: isDestructive
                ? BiCikalimTheme.error
                : BiCikalimTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: BiCikalimTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 18,
          color: isDestructive
              ? BiCikalimTheme.error.withValues(alpha: 0.5)
              : BiCikalimTheme.textLight,
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Hesabından çıkış yapmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Vazgeç',
              style: TextStyle(color: BiCikalimTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(userSessionProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppConstants.onboardingRoute);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BiCikalimTheme.error,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final nameController = TextEditingController(text: user.displayName);
    final usernameController = TextEditingController(text: user.username);
    var saving = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Profili Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ad Soyad'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      setDialogState(() => saving = true);
                      try {
                        final updated = await ref
                            .read(userApiServiceProvider)
                            .updateProfile(
                              fullName: nameController.text.trim(),
                              username: usernameController.text.trim(),
                            );
                        ref.read(currentUserProvider.notifier).setUser(updated);
                        await ApiClient.instance.saveCachedUser(updated);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      } catch (error) {
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                          setDialogState(() => saving = false);
                        }
                      }
                    },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      nameController.dispose();
      usernameController.dispose();
    });
  }
}
