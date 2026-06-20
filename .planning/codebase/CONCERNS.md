# Codebase Concerns & Risks

**Analysis Date:** 2026-06-20

## Technical Debt & Fragile Areas

Since the Flutter project has just been initialized, there is no legacy code or technical debt in the codebase. However, there are architectural decisions that must be resolved early to prevent future debt.

## Architecture & Scalability Risks

**State Management Selection:**
- **Concern:** Currently, the application uses local screen-level state (`setState`) in `lib/main.dart`. This does not scale for multi-screen navigation, caching, or shared global state.
- **Risk:** High. Writing features without a structured state management solution will lead to coupled widgets and hard-to-maintain state flows.
- **Mitigation:** Choose a state management solution (e.g., Riverpod, BLoC, or Provider) and establish it in Phase 1 before building real business features.

**Monolithic Main File:**
- **Concern:** Both the theme configuration (`MyApp`), widget UI (`MyHomePage`), and local state (`_MyHomePageState`) reside in a single `lib/main.dart` file.
- **Risk:** Medium. As code grows, `lib/main.dart` will become a monolithic file, making collaboration and reviews difficult.
- **Mitigation:** Establish a feature-first or layer-first directory structure (e.g. splitting views, models, and controllers/states) early in the development process.

## Known Bugs & Issues

- No active bugs are registered in this fresh layout.

---

*Concerns audit: 2026-06-20*
*Update when new debt or risks are identified*
