import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Kullanıcı profil ekranı.
/// Gerçek kullanıcı verisi [currentUserProfileProvider] üzerinden gelir.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

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
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BiCikalimTheme.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
              const SizedBox(height: 12),
              Text(
                'Profil yüklenirken hata oluştu.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentUserProfileProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            // Kullanıcı profili yoksa giriş ekranına yönlendir
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppConstants.onboardingRoute);
            });
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Kullanıcı Avatar & İsim
                Center(
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: BiCikalimTheme.primary,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: user.avatarUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.person,
                                      color: BiCikalimTheme.textLight,
                                      size: 40,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => _buildAvatarPlaceholder(user.displayName),
                                )
                              : _buildAvatarPlaceholder(user.displayName),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Display Name
                      Text(
                        user.displayName.isNotEmpty ? user.displayName : 'İsimsiz Kullanıcı',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: BiCikalimTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Şehir + Rol badge'leri
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (user.city != null && user.city!.isNotEmpty)
                            _buildBadge(
                              '📍 ${user.city}',
                              BiCikalimTheme.primary.withOpacity(0.1),
                              BiCikalimTheme.primary,
                            ),
                          if (user.city != null && user.city!.isNotEmpty)
                            const SizedBox(width: 8),
                          _buildBadge(
                            user.roles.contains(AppConstants.roleVenueOwner)
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
                  onTap: () => _showAddVenueSheet(context),
                ),
                const SizedBox(height: 24),

                // Hesap Ayarları
                _buildSectionHeader('Hesap'),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.location_city,
                  title: 'Şehir Değiştir',
                  subtitle: 'Aktif şehri değiştir (${user.city ?? 'Seçilmedi'})',
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
          );
        },
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String displayName) {
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return Container(
      color: BiCikalimTheme.primary.withOpacity(0.12),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: BiCikalimTheme.primary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
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
          fontFamily: 'Outfit',
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
          color: isDestructive ? BiCikalimTheme.error.withOpacity(0.2) : Colors.grey.shade100,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            color: isDestructive ? BiCikalimTheme.error : BiCikalimTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: BiCikalimTheme.textSecondary),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 18,
          color: isDestructive ? BiCikalimTheme.error.withOpacity(0.5) : BiCikalimTheme.textLight,
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
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
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
              await ref.read(authControllerProvider.notifier).signOut();
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

  void _showAddVenueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mekan Sahibi Başvurusu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mekanınızı sisteme eklemek veya sahiplenmek için başvurun.',
                ),
                const SizedBox(height: 20),
                const TextField(
                  decoration: InputDecoration(hintText: 'Mekan Adı'),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(hintText: 'İlçe / Bölge'),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Aktivite Kategorileri (Örn: Bilardo, Dart)',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Başvurunuz alındı, ekibimiz sizinle iletişime geçecek.'),
                          backgroundColor: BiCikalimTheme.success,
                        ),
                      );
                    },
                    child: const Text('Başvuruyu Gönder'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
