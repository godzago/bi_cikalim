import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/router/router.dart';
import 'core/config/api_config_loader.dart';
import 'core/network/api_client.dart';

/// Uygulama giriş noktası.
/// Firebase bağımlılıkları kaldırıldı.
/// Backend: FastAPI + PostgreSQL + PostGIS entegrasyonu.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Localhost API yapılandırmasını yükle
  await ApiConfigLoader.initialize();

  runApp(const ProviderScope(child: BiCikalimApp()));
}

/// Kök uygulama widget'ı.
class BiCikalimApp extends StatefulWidget {
  const BiCikalimApp({super.key});

  @override
  State<BiCikalimApp> createState() => _BiCikalimAppState();
}

class _BiCikalimAppState extends State<BiCikalimApp> {
  StreamSubscription<void>? _sessionExpiredSubscription;

  @override
  void initState() {
    super.initState();
    _sessionExpiredSubscription = ApiClient.instance.sessionExpired.listen((_) {
      appRouter.go('/sign-in');
    });
  }

  @override
  void dispose() {
    _sessionExpiredSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BiÇıkalım',
      theme: BiCikalimTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
