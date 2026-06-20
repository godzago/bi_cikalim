# Technology Stack

**Analysis Date:** 2026-06-20

## Languages

**Primary:**
- Dart 3.12.x (SDK ^3.12.0) - All application and test code

**Secondary:**
- Kotlin 1.8.x - Android native runner
- Swift 5.x - iOS / macOS native runner
- C++ - Windows native runner
- HTML / JavaScript - Web entry point

## Runtime

**Environment:**
- Flutter SDK (Framework runtime)
- Dart VM for local execution / development
- Native compiler for target platforms (Android, iOS, macOS, Windows, Linux, Web)

**Package Manager:**
- Dart Pub (integrated in Flutter CLI)
- Lockfile: `pubspec.lock` present

## Frameworks

**Core:**
- Flutter Framework (Material Design) - Cross-platform UI framework

**Testing:**
- flutter_test - Unit and widget testing framework

**Build/Dev:**
- flutter_lints ^6.0.0 - Coding style and guidelines analysis

## Key Dependencies

**Critical:**
- cupertino_icons ^1.0.8 - Asset package for iOS-style icons

## Configuration

**Environment:**
- No environment variables required out-of-the-box
- Configuration loaded from `pubspec.yaml`

**Build:**
- `pubspec.yaml` - Dependencies and asset configuration
- `analysis_options.yaml` - Linter and static analysis rules

## Platform Requirements

**Development:**
- Windows / macOS / Linux with Flutter SDK installed
- Android SDK (for Android build) / Xcode (for iOS/macOS builds)

**Production:**
- Cross-platform build targets: Android, iOS, Windows, macOS, Linux, Web

---

*Stack analysis: 2026-06-20*
*Update after major dependency changes*
