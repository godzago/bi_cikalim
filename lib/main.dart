import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/router/router.dart';

/// Uygulama giriş noktası.
/// Firebase initialize edilir, ardından Flutter widget ağacı başlatılır.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat.
  // google-services.json (Android) ve GoogleService-Info.plist (iOS)
  // Firebase Console'dan indirilip projeye eklenmelidir.
  await Firebase.initializeApp();

  // Firebase Crashlytics — Flutter hata yakalama
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    const ProviderScope(
      child: BiCikalimApp(),
    ),
  );
}

/// Kök uygulama widget'ı.
class BiCikalimApp extends ConsumerWidget {
  const BiCikalimApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'BiÇıkalım',
      theme: BiCikalimTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
