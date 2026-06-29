import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/router/router.dart';

/// Uygulama giriş noktası.
/// Firebase bağımlılıkları kaldırıldı.
/// Backend: İleride FastAPI + PostgreSQL + PostGIS entegre edilecek.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: BiCikalimApp(),
    ),
  );
}

/// Kök uygulama widget'ı.
class BiCikalimApp extends StatelessWidget {
  const BiCikalimApp({super.key});

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
