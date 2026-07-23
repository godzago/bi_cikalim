import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../../core/theme/theme.dart';
import 'app_pressable_scale.dart';

/// API kategori bilgisini gösteren modern keşif kartı.
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

  @override
  Widget build(BuildContext context) {
    final description = category.description?.trim();

    return AppPressableScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          margin: margin,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: BiCikalimTheme.primary.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -22,
                bottom: -24,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: BiCikalimTheme.primary.withValues(alpha: 0.045),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                BiCikalimTheme.primary,
                                BiCikalimTheme.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: BiCikalimTheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            category.icon,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: BiCikalimTheme.primary.withValues(
                              alpha: 0.07,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            color: BiCikalimTheme.primary,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: BiCikalimTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: BiCikalimTheme.textSecondary,
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
