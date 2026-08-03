import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/responsive.dart';
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
    final layout = context.layout;

    return AppPressableScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width ?? layout.fluid(112, 118, 126),
          margin: margin,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(layout.cardRadius),
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
                right: -22,
                bottom: -24,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: BiCikalimTheme.primary.withValues(alpha: 0.045),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(layout.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                BiCikalimTheme.primary,
                                BiCikalimTheme.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(11),
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
                            size: 19,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: BiCikalimTheme.primary.withValues(
                              alpha: 0.07,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            color: BiCikalimTheme.primary,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      category.name,
                      style: TextStyle(
                        color: BiCikalimTheme.textPrimary,
                        fontSize: layout.cardTitleSize,
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
                        style: TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: layout.metadataSize - 1,
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
