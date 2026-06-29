import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/user_session_provider.dart';

/// Mekan sahibi panel placeholder ekranı.
/// İleride mekan profili oluşturma, etkinlik ekleme ve istatistikler buraya gelecek.
class VenueOwnerScreen extends ConsumerWidget {
  const VenueOwnerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: BiCikalimTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context, ref),
            ),

            // Özellik Kartları
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 32),
                  _buildComingSoonCard(
                    icon: Icons.storefront_outlined,
                    title: 'Mekan Profili Oluştur',
                    description:
                        'Mekanını ekle, aktivitelerini listele ve fotoğraflarını paylaş.',
                    color: const Color(0xFFFFF3F0),
                    iconColor: BiCikalimTheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildComingSoonCard(
                    icon: Icons.event_outlined,
                    title: 'Etkinlik Ekle',
                    description:
                        'Masa oyunu gecesi, turnuva veya karaoke etkinliği oluştur.',
                    color: const Color(0xFFFFF8F0),
                    iconColor: const Color(0xFFFF8C00),
                  ),
                  const SizedBox(height: 12),
                  _buildComingSoonCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Aktivite Envanteri',
                    description:
                        'Mekanında hangi oyunlar ve aktiviteler var? Müşterilerin görsün.',
                    color: const Color(0xFFF0F8FF),
                    iconColor: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 12),
                  _buildComingSoonCard(
                    icon: Icons.bar_chart_outlined,
                    title: 'İstatistikler ve Analitik',
                    description:
                        'Profilinizi kaç kişi gördü, en çok hangi aktiviteler ilgi çekti.',
                    color: const Color(0xFFF0FFF0),
                    iconColor: BiCikalimTheme.success,
                  ),
                  const SizedBox(height: 12),
                  _buildComingSoonCard(
                    icon: Icons.verified_outlined,
                    title: 'Mekanını Sahiplen',
                    description:
                        'Mekanın zaten listede mi? Sahiplenerek bilgilerini yönet.',
                    color: const Color(0xFFFAF0FF),
                    iconColor: const Color(0xFF9C27B0),
                  ),
                  const SizedBox(height: 32),
                  _buildContactSection(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BiCikalimTheme.primary,
            BiCikalimTheme.primaryDark,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    await ref.read(userSessionProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go(AppConstants.onboardingRoute);
                    }
                  },
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Geliştiriliyor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.storefront,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mekan Sahibi Paneli',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'BiÇıkalım\'ın mekan sahibi özellikleri yakında burada.\nŞimdilik keşif modunu kullanabilirsin.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Keşfet moduna git
          GestureDetector(
            onTap: () {
              ref.read(userTypeProvider.notifier).setUserType(UserType.normalUser);
              context.go(AppConstants.discoverRoute);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore,
                    color: BiCikalimTheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Keşfet moduna geç',
                    style: TextStyle(
                      color: BiCikalimTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          
                          color: BiCikalimTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Yakında',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: BiCikalimTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: BiCikalimTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BiCikalimTheme.primary.withValues(alpha: 0.05),
            BiCikalimTheme.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BiCikalimTheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: BiCikalimTheme.primary,
            size: 28,
          ),
          const SizedBox(height: 12),
          const Text(
            'Mekanını BiÇıkalım\'a eklemek ister misin?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              
              color: BiCikalimTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Instagram üzerinden bize ulaş,\nmekanını öncelikli olarak ekleyelim.',
            style: TextStyle(
              fontSize: 13,
              color: BiCikalimTheme.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: BiCikalimTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  '@bicikalim',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
