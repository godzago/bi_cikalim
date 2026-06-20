# Testing Standards

**Analysis Date:** 2026-06-20

## Testing Frameworks

We use the standard Flutter testing toolchain:
- **Core Library:** `flutter_test` (included in Flutter SDK)

## Test Structure

- All test files are located in the `test/` directory.
- Test files must mirror the structure of the `lib/` directory and match the file name with a `_test.dart` suffix.
  - Source: `lib/main.dart`
  - Test: `test/widget_test.dart`

## Execution Commands

### Run all tests:
```bash
flutter test
```

### Run a single test file:
```bash
flutter test test/widget_test.dart
```

### Run tests with coverage:
```bash
flutter test --coverage
```
This generates a `coverage/lcov.info` file which can be viewed using code coverage display extensions.

## Coding Standards in Tests

- **Widget Tests:** Use `testWidgets` instead of standard `test` to initialize the Flutter widget binding environment.
- **Finder & Matchers:** Use standard Finders (e.g. `find.text`, `find.byIcon`) and Matchers (e.g. `findsOneWidget`, `findsNothing`) to test user interaction.
- **Pump & Settle:** Always use `tester.pump()` or `tester.pumpAndSettle()` after interactions (like taps or text inputs) to trigger animations and UI rebuilding before asserting results.

---

*Testing analysis: 2026-06-20*
*Update when testing strategy changes*
