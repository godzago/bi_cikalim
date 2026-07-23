import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../../core/theme/theme.dart';

/// Kategori kartı — görsel/icon destekli, dokunması kolay, mobil ergonomiye uygun.
/// Her kategoriye sabit gradyan renk atanır.
class CategoryCard extends StatelessWidget {
  final ApiCategory category;
  final VoidCallback onTap;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.width = 130,
    this.margin = const EdgeInsets.only(right: 10),
  });

  /// Kategori ID'sine göre gradyan renk çifti döner.
  static List<Color> _gradientFor(String categoryId) {
    switch (categoryId) {
      case 'masaustu_oyunlar':
        return [const Color(0xFFFF7043), const Color(0xFFFF5722)];
      case 'dijital_oyunlar':
        return [const Color(0xFF7E57C2), const Color(0xFF5C35C4)];
      case 'salon_eglenceleri':
        return [const Color(0xFFEF5350), const Color(0xFFB71C1C)];
      case 'saha_sporlari':
        return [const Color(0xFF26A69A), const Color(0xFF00796B)];
      case 'bireysel_sporlar':
        return [const Color(0xFF42A5F5), const Color(0xFF1565C0)];
      case 'macera_deneyim':
        return [const Color(0xFFFFCA28), const Color(0xFFF57F17)];
      default:
        return [BiCikalimTheme.primary, BiCikalimTheme.primaryDark];
    }
  }

  /// Kategori ID'sine göre açıklama metni döner.
  static String _subtitleFor(String categoryId) {
    switch (categoryId) {
      case 'masaustu_oyunlar':
        return 'Catan, Tabu, Azul…';
      case 'dijital_oyunlar':
        return 'PS5, Switch, VR…';
      case 'salon_eglenceleri':
        return 'Bilardo, Karaoke…';
      case 'saha_sporlari':
        return 'Halı saha, Tenis…';
      case 'bireysel_sporlar':
        return 'Fitness, Yoga…';
      case 'macera_deneyim':
        return 'Boulder, Escape…';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientFor(category.id);
    final subtitle = _subtitleFor(category.id);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: width,
          margin: margin,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dekoratif daire
              Positioned(
                right: -16,
                top: -16,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // İçerik
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İkon
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    // Kategori adı
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
