import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const Set<String> webUrlSchemes = {'http', 'https'};
const Set<String> phoneUrlSchemes = {'tel'};

typedef AppUrlLauncher = Future<bool> Function(Uri uri, {LaunchMode mode});

/// Opens a validated URL outside the app and reports every failure safely.
Future<bool> launchAppExternalUrl({
  required BuildContext context,
  required String? rawUrl,
  required Set<String> allowedSchemes,
  required String failureMessage,
  String? emptyMessage,
  AppUrlLauncher launcher = launchUrl,
}) async {
  final value = rawUrl?.trim() ?? '';
  if (value.isEmpty) {
    _showLaunchError(context, emptyMessage ?? failureMessage);
    return false;
  }

  final uri = Uri.tryParse(value);
  if (uri == null || !_isAllowedUri(uri, allowedSchemes)) {
    _showLaunchError(context, failureMessage);
    return false;
  }

  try {
    final launched = await launcher(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      if (!context.mounted) return false;
      _showLaunchError(context, failureMessage);
    }
    return launched;
  } catch (_) {
    if (!context.mounted) return false;
    _showLaunchError(context, failureMessage);
    return false;
  }
}

bool _isAllowedUri(Uri uri, Set<String> allowedSchemes) {
  final scheme = uri.scheme.toLowerCase();
  if (!allowedSchemes.contains(scheme)) return false;

  if (scheme == 'http' || scheme == 'https') {
    return uri.host.trim().isNotEmpty;
  }
  if (scheme == 'tel') {
    return uri.path.trim().isNotEmpty;
  }
  return false;
}

void _showLaunchError(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.maybeOf(
    context,
  )?.showSnackBar(SnackBar(content: Text(message)));
}
