import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Uygulama onboarding ekranı.
/// 3 slaytlı animasyonlu tanıtım + Giriş Yap / Kayıt Ol butonları.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
          'Quiz geceleri, karaoke gecesi, turnuvalar…\nYakınındaki etkinlikleri anında öğren.',
      color: Color(0xFFFFF8F0),
    ),
    _OnboardingSlide(
      emoji: '🏪',
      title: 'Mekanını Sahiplen',
      description:
          'İşletme sahibi misin? Mekanını ekle,\naktivitelerini paylaş, müşterilerine ulaş.',
      color: Color(0xFFF0F8FF),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip butonu
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(AppConstants.signInRoute),
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
                  return _buildSlide(context, _slides[index], size);
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
            const SizedBox(height: 40),

            // Giriş / Kayıt Butonları
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Giriş Yap
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppConstants.signInRoute),
                      child: const Text('Giriş Yap'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Kayıt Ol
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.go(AppConstants.signUpRoute),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BiCikalimTheme.primary,
                        side: const BorderSide(color: BiCikalimTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      child: const Text('Hesap Oluştur'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kayıt olarak Kullanım Koşulları\'nı kabul etmiş olursunuz.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context,
    _OnboardingSlide slide,
    Size size,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji illustration area
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: slide.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                slide.emoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: BiCikalimTheme.textPrimary,
              fontFamily: 'Outfit',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.description,
            style: const TextStyle(
              fontSize: 15,
              color: BiCikalimTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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
