# Coding Conventions

**Analysis Date:** 2026-06-20

## Code Style & Guidelines

We adhere to the official **[Effective Dart](https://dart.dev/effective-dart)** style guidelines.

### Naming Conventions

- **Classes, Enums, Typedefs:** `PascalCase` (e.g., `MyHomePage`, `MyApp`).
- **Files, Directories, Library Prefixes:** `snake_case` (e.g., `main.dart`, `widget_test.dart`).
- **Variables, Parameters, Functions, Methods:** `camelCase` (e.g., `_counter`, `_incrementCounter`).
- **Constants:** `camelCase` preferred (e.g., `defaultTimeout`) or `UPPER_SNAKE_CASE` if match legacy APIs.
- **Private Variables / Methods:** Prefixed with a leading underscore `_` (e.g., `_counter`, `_incrementCounter`).

## Formatting

- **Auto-Formatting:** Run `flutter format .` or `dart format .` before committing code.
- **Trailing Commas:** Use trailing commas for function calls and declarations that take multiple arguments to improve format readability.
- **Line Length:** Kept within 80 characters (default tool behavior).

## Static Analysis & Lint Rules

Lints are configured in `analysis_options.yaml` which extends the standard Flutter lints:
```yaml
include: package:flutter_lints/flutter.yaml
```

Key rules enforced:
- Use `const` constructor calls where possible to optimize widget rebuilding.
- Avoid print statements (`avoid_print: true`) in production code.
- Prefer single quotes (`prefer_single_quotes: true`).

## Error Handling & Robustness

- **Local Exceptions:** Capture local failures with standard `try-catch` blocks.
- **State Guarding:** Ensure checks are made on state stability, e.g. checking `mounted` before executing asynchronous operations in a `StatefulWidget`'s callback.
- **UI Error Safety:** Do not allow exceptions to crash the widget build method; handle default state values robustly.

---

*Conventions analysis: 2026-06-20*
*Update when coding standards change*
