import 'package:flutter/material.dart';

import '../../core/theme/app_density.dart';
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
    this.width,
    this.margin = const EdgeInsets.only(right: 10),
  });

  @override
  Widget build(BuildContext context) {
    final description = category.description?.trim();
    final cardWidth =
        width ?? AppDensity.clamp(context, factor: 0.34, min: 112, max: 130);
    final radius = AppDensity.cardRadius(context);

    return AppPressableScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: cardWidth,
          margin: margin,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: BiCikalimTheme.primary.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -20,
                child: Container(
                  width: AppDensity.scaled(context, 76, min: 66),
                  height: AppDensity.scaled(context, 76, min: 66),
                  decoration: BoxDecoration(
                    color: BiCikalimTheme.primary.withValues(alpha: 0.045),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(
                  AppDensity.value(context, compact: 9, standard: 10, wide: 11),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: AppDensity.scaled(context, 44, min: 40),
                          height: AppDensity.scaled(context, 44, min: 40),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                BiCikalimTheme.primary,
                                BiCikalimTheme.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
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
                            size: AppDensity.scaled(context, 22, min: 19),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: AppDensity.scaled(context, 26, min: 22),
                          height: AppDensity.scaled(context, 26, min: 22),
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
                        fontSize: 13,
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
