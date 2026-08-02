import 'package:flutter/material.dart';

class AppSkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const AppSkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1EFEC), Color(0xFFE7E3DF), Color(0xFFF7F5F3)],
          ),
        ),
      ),
    );
  }
}

class ActivityCardSkeleton extends StatelessWidget {
  const ActivityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonBox(height: 178, radius: 20);
  }
}

class VenueCardSkeleton extends StatelessWidget {
  const VenueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonBox(height: 132, radius: 20);
  }
}

class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonBox(height: 156, radius: 20);
  }
}
