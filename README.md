# LoveAll - Badminton Score Keeper (Flutter)

LoveAll is a Flutter app to track badminton matches in real time.
It supports singles and doubles, rally-by-rally scoring, undo, and basic match stats.

## Current Features

- Match setup:
  - `Singles` or `Doubles`
  - Match format: `Single`, `Best of 3`, `Best of 5`
  - Team names and player names
- Live scoring:
  - Increment points for Team A / Team B
  - Server indicator
  - Court-side tracking for doubles (`L` / `R`)
  - Undo last point
  - Match reset
- Match progression:
  - Game win rules: first to 21 with 2-point lead, capped at 30
  - Automatic next-game start until match winner is decided
  - Match winner based on format:
    - `Single` -> 1 game to win
    - `Best of 3` -> 2 games to win
    - `Best of 5` -> 3 games to win
- Stats:
  - Total points by team
  - Rally event model with win-reason support (reason-wise UI breakdown is planned)

## Project Structure

```text
lib/
  main.dart                    # App entry, Provider + router setup
  models/match_state.dart      # Domain models, enums, and immutable state
  providers/match_provider.dart# Scoring, serving, game/match logic, undo/reset
  router/app_router.dart       # go_router routes
  screens/
    match_setup_screen.dart    # Match configuration
    match_screen.dart          # Live scoring UI
    stats_screen.dart          # Match statistics view
test/
  match_provider_test.dart     # Core scoring and match-format logic tests
  widget_test.dart             # Basic app startup UI test
```

## Tech Stack

- Flutter (Material 3)
- `provider` for state management
- `go_router` for navigation
- `uuid` for rally event IDs
- `intl` and `google_fonts` available in dependencies

## How to Run

1. Install Flutter SDK and ensure `flutter doctor` is clean.
2. From project root, install dependencies:

```powershell
flutter pub get
```

3. Run on a connected device/emulator:

```powershell
flutter devices
flutter run -d <device-id>
```

Example for a running Android emulator:

```powershell
flutter run -d emulator-5554
```

## Quality Checks

Run static analysis:

```powershell
flutter analyze
```

Run tests:

```powershell
flutter test
```

## Notes and Roadmap

- The app is under active development.
- Planned improvements:
  - Richer statistics UI (reason-wise breakdown charts/tables)
  - Stronger input validation in setup
  - Expanded tests for additional edge cases and UI flows
