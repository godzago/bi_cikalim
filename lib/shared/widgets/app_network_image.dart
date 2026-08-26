import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  static const int _maximumMemoryCacheDimension = 4096;

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final trimmedUrl = imageUrl.trim();

    if (trimmedUrl.isEmpty) {
      return _wrapSemantics(
        _ImageFallback(
          width: width,
          height: height,
          borderRadius: borderRadius,
        ),
      );
    }

    final image = LayoutBuilder(
      builder: (context, constraints) {
        final logicalWidth = width == null
            ? _tightDimension(constraints.minWidth, constraints.maxWidth)
            : _finitePositiveDimension(width!);
        final logicalHeight = height == null
            ? _tightDimension(constraints.minHeight, constraints.maxHeight)
            : _finitePositiveDimension(height!);

        return CachedNetworkImage(
          imageUrl: trimmedUrl,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: _memoryCacheDimension(logicalWidth, devicePixelRatio),
          memCacheHeight: _memoryCacheDimension(
            logicalHeight,
            devicePixelRatio,
          ),
          fadeInDuration: const Duration(milliseconds: 180),
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade500,
            ),
          ),
        );
      },
    );

    final clipped = borderRadius == null
        ? image
        : ClipRRect(borderRadius: borderRadius!, child: image);

    return _wrapSemantics(clipped);
  }

  Widget _wrapSemantics(Widget child) {
    if (semanticLabel == null || semanticLabel!.trim().isEmpty) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(image: true, label: semanticLabel, child: child);
  }

  static double? _finitePositiveDimension(double dimension) {
    return dimension.isFinite && dimension > 0 ? dimension : null;
  }

  static double? _tightDimension(double minimum, double maximum) {
    if (minimum != maximum) return null;
    return _finitePositiveDimension(maximum);
  }

  static int? _memoryCacheDimension(
    double? logicalDimension,
    double devicePixelRatio,
  ) {
    if (logicalDimension == null ||
        !devicePixelRatio.isFinite ||
        devicePixelRatio <= 0) {
      return null;
    }

    final physicalDimension = logicalDimension * devicePixelRatio;
    if (!physicalDimension.isFinite || physicalDimension <= 0) return null;

    return physicalDimension
        .ceil()
        .clamp(1, _maximumMemoryCacheDimension)
        .toInt();
  }
}

class _ImageFallback extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const _ImageFallback({this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: Colors.grey.shade500, size: 24),
    );

    if (borderRadius == null) return content;
    return ClipRRect(borderRadius: borderRadius!, child: content);
  }
}
