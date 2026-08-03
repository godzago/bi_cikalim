import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/user_session_provider.dart';

/// Uygulama onboarding ekranı.
/// 3 slaytlı animasyonlu tanıtım + Kullanıcı / Mekan Sahibi ayrımı.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  static const _slides = [
    _OnboardingSlide(
      emoji: '🗺️',
      title: 'Şehrini Keşfet',
      description:
          'Eskişehir\'deki en iyi mekanları, aktiviteleri ve etkinlikleri\ntek bir yerden keşfet.',
      color: Color(0xFFFFF3F0),
    ),
    _OnboardingSlide(
      emoji: '🎯',
      title: 'Etkinlikleri Kaçırma',
      description:
          'Masa oyunu geceleri, karaoke, turnuvalar…\nYakınındaki etkinlikleri anında öğren.',
      color: Color(0xFFFFF8F0),
    ),
    _OnboardingSlide(
      emoji: '🎮',
      title: 'Aktiviteye Göre Mekan Bul',
      description:
          'Catan mı, bilardo mu, karaoke mi?\nAktiviteyi seç, mekanı biz gösterelim.',
      color: Color(0xFFF0F8FF),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skipOnboarding() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(userSessionProvider.notifier).continueAsGuest();
      if (mounted) context.go(AppConstants.citySelectRoute);
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _continueAsUser() {
    context.go('${AppConstants.signInRoute}?accountType=user');
  }

  void _continueAsVenueOwner() {
    context.go('${AppConstants.signInRoute}?accountType=venue_owner');
  }

  @override
  Widget build(BuildContext context) {
    final compactActions = MediaQuery.sizeOf(context).height < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip butonu
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _isLoading ? null : _skipOnboarding,
                child: const Text(
                  'Geç',
                  style: TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Slaytlar
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  return _buildSlide(context, _slides[index]);
                },
              ),
            ),

            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? BiCikalimTheme.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            SizedBox(height: compactActions ? 12 : 20),

            // Kullanıcı Tipi Seçimi
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.layout.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kullanıcı Olarak Devam Et
                  _UserTypeButton(
                    id: 'btn_continue_as_user',
                    icon: Icons.explore_outlined,
                    title: 'Kullanıcı Olarak Devam Et',
                    subtitle: 'Mekan, aktivite ve etkinlik keşfet',
                    isPrimary: true,
                    isLoading: _isLoading,
                    compact: compactActions,
                    onTap: _continueAsUser,
                  ),
                  SizedBox(height: compactActions ? 8 : 12),

                  // Mekan Sahibi
                  _UserTypeButton(
                    id: 'btn_continue_as_venue_owner',
                    icon: Icons.storefront_outlined,
                    title: 'Mekan Sahibiyim',
                    subtitle: 'Mekanımı ekle, aktivitelerimi paylaş',
                    isPrimary: false,
                    isLoading: _isLoading,
                    compact: compactActions,
                    onTap: _continueAsVenueOwner,
                  ),
                  if (!compactActions) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Devam ederek Kullanım Koşulları\'nı kabul etmiş olursunuz.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: compactActions ? 10 : 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(BuildContext context, _OnboardingSlide slide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 390;
        final illustrationSize = compact
            ? context.layout.fluid(96, 102, 110)
            : context.layout.fluid(136, 146, 158);
        final emojiSize = compact ? 46.0 : 64.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.layout.screenPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: illustrationSize,
                  height: illustrationSize,
                  decoration: BoxDecoration(
                    color: slide.color,
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: Center(
                    child: Text(
                      slide.emoji,
                      style: TextStyle(fontSize: emojiSize),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 16 : 20),
                Text(
                  slide.title,
                  style: TextStyle(
                    fontSize: context.layout.pageTitleSize,
                    fontWeight: FontWeight.bold,
                    color: BiCikalimTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: compact ? 8 : 16),
                Text(
                  slide.description,
                  style: TextStyle(
                    fontSize: context.layout.bodySize,
                    color: BiCikalimTheme.textSecondary,
                    height: compact ? 1.35 : 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Kullanıcı Tipi Butonu
// ---------------------------------------------------------------------------

class _UserTypeButton extends StatelessWidget {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final bool isLoading;
  final bool compact;
  final VoidCallback onTap;

  const _UserTypeButton({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.isLoading,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey(id),
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(context.layout.cardRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 8 : 9,
          ),
          decoration: BoxDecoration(
            color: isPrimary ? BiCikalimTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(context.layout.cardRadius),
            border: Border.all(
              color: isPrimary ? BiCikalimTheme.primary : Colors.grey.shade200,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: BiCikalimTheme.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : BiCikalimTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : BiCikalimTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: context.layout.cardTitleSize,
                        fontWeight: FontWeight.bold,

                        color: isPrimary
                            ? Colors.white
                            : BiCikalimTheme.textPrimary,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPrimary
                              ? Colors.white.withValues(alpha: 0.8)
                              : BiCikalimTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide Model
// ---------------------------------------------------------------------------

class _OnboardingSlide {
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const _OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}
