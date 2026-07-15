
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/user_session_provider.dart';

/// Kullanıcı profil ekranı.
/// Mock session yönetimi kullanıyor.
/// İleride FastAPI backend'den gerçek kullanıcı verisi çekilecek.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = ref.watch(userTypeProvider);
    final user = ref.watch(currentUserProvider);

    final displayName = user?.displayName ?? 'Misafir Kullanıcı';
    final email = user?.email ?? 'kullanici@bicikalim.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: BiCikalimTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Kullanıcı tipi badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadge(
                        '📍 Eskişehir',
                        BiCikalimTheme.primary.withValues(alpha: 0.1),
                        BiCikalimTheme.primary,
                      ),
                      const SizedBox(width: 8),
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
            _buildMenuCard(
              context,
              icon: Icons.storefront,
              title: 'Mekan Sahibi misiniz?',
              subtitle: 'Mekanınızı ekleyin veya sahiplenin.',
              onTap: () => context.go('/venue-owner'),
            ),
            const SizedBox(height: 24),

            // Hesap Ayarları
            _buildSectionHeader('Hesap'),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              icon: Icons.location_city,
              title: 'Şehir Değiştir',
              subtitle: 'Aktif şehri değiştir (Eskişehir)',
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
          style: TextStyle( fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Hesabından çıkış yapmak istediğine emin misin?',
        ),
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
}
