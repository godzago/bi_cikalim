import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/responsive.dart';
import 'app_empty_state.dart';

class AppErrorState extends StatelessWidget {
  final Object error;
  final String? title;
  final String? fallbackMessage;
  final VoidCallback? onRetry;
  final bool showHomeAction;
  final EdgeInsetsGeometry padding;

  const AppErrorState({
    super.key,
    required this.error,
    this.title,
    this.fallbackMessage,
    this.onRetry,
    this.showHomeAction = false,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final message = friendlyErrorMessage(error, fallback: fallbackMessage);
    return AppEmptyState(
      icon: _iconFor(error),
      title: title ?? _titleFor(error),
      message: message,
      actionLabel: onRetry == null ? null : 'Tekrar Dene',
      onAction: onRetry,
      secondaryActionLabel: showHomeAction ? 'Ana Sayfaya Git' : null,
      onSecondaryAction: showHomeAction ? () => context.go('/discover') : null,
      padding: padding,
      semanticLabel: '${title ?? _titleFor(error)}. $message',
    );
  }

  IconData _iconFor(Object error) {
    if (error is ServiceException) {
      if (error.isNotFound) return Icons.search_off_rounded;
      if (error.isForbidden || error.isUnauthorized) {
        return Icons.lock_outline_rounded;
      }
      if (error.isRateLimited) return Icons.hourglass_top_rounded;
    }
    return Icons.cloud_off_rounded;
  }

  String _titleFor(Object error) {
    if (error is ServiceException) {
      if (error.isForbidden) return 'Kullanım yetkin bulunmuyor';
      if (error.isNotFound) return 'İçerik bulunamadı';
      if (error.isRateLimited) return 'Biraz beklemek gerekiyor';
      if (error.isValidationError) return 'Bilgileri kontrol et';
    }
    return 'İçeriği yükleyemedik';
  }
}

String friendlyErrorMessage(Object error, {String? fallback}) {
  if (error is ServiceException) {
    if (error.isForbidden) {
      return 'Bu işlemi yapmak için gerekli yetkin bulunmuyor.';
    }
    if (error.isNotFound) {
      return 'Aradığın içerik artık mevcut olmayabilir.';
    }
    if (error.isConflict) {
      return 'Bu işlem mevcut durumla çakışıyor. Sayfayı yenileyip tekrar deneyebilirsin.';
    }
    if (error.isValidationError) {
      return error.message.isNotEmpty
          ? error.message
          : 'Girdiğin bilgileri kontrol edip tekrar deneyebilirsin.';
    }
    if (error.isRateLimited) {
      return 'Çok sık işlem yaptın. Biraz bekleyip tekrar deneyebilirsin.';
    }
    if (error.message.isNotEmpty && error.statusCode != null) {
      return error.message;
    }
  }

  final text = error.toString().toLowerCase();
  if (text.contains('socket') ||
      text.contains('connection') ||
      text.contains('network') ||
      text.contains('timeout')) {
    return 'Bağlantını kontrol edip tekrar deneyebilirsin.';
  }

  return fallback ?? 'Şu anda bu içeriği yükleyemedik.';
}

class PartialErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const PartialErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.layout.cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.layout.cardRadius),
          border: Border.all(color: const Color(0xFFF0EDE9)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: BiCikalimTheme.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BiCikalimTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
            ],
          ],
        ),
      ),
    );
  }
}
