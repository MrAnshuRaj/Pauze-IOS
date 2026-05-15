# Pauze

Pauze is a Flutter-based digital wellbeing app focused on helping users reduce compulsive social media use with intentional blocking, unlock challenges, calmer browsing modes, and a brain-health themed dashboard.

## Current app scope

- Multi-step onboarding flow
- Legal consent flow
- Dashboard with:
  - Pau mascot state
  - Brain Load, Time Spent, and Pickups summary
  - Brain Health Calendar
  - day-details popup
  - Safe Social Mode section
- Analytics screen
- Settings/blocked apps management screen
- Android blocking via Accessibility-driven app monitoring
- iOS blocking foundations via Apple Screen Time frameworks
- Deterministic fallback dashboard sample data so Android and unbridged iOS builds still render a complete experience

## Platform behavior

### Android

- Uses Accessibility-based app blocking and usage integration where available
- Dashboard currently uses deterministic sample brain stats so the UI stays visually complete and stable
- Supports safe in-app browsing flows for supported social apps

### iOS

- Intended to use Apple Screen Time / FamilyControls / ManagedSettings / DeviceActivity APIs
- Apple APIs do not provide exact Reels/Shorts scroll counts
- `Brain Load` is therefore a computed score derived from available metrics such as:
  - time spent
  - pickups
  - notifications
  - limit hits
  - completed breaks
- If the iOS usage bridge is unavailable, Pauze safely falls back to deterministic sample data

## Dashboard notes

The current dashboard is intentionally designed to preview the future iOS experience on both platforms.

- Top summary uses:
  - Brain Load
  - Time Spent
  - Pickups
- Calendar and popup states are based on Brain Load score
- Android sample values are deterministic, not random
- Sample fallback keeps the dashboard non-empty and stable during development

## Safe Social Mode

Pauze includes a Safe Social Mode section on the dashboard.

- Toggle Safe Social Mode on or off
- Launch safer in-app versions of supported social apps
- Current safe-mode targets in the app:
  - Instagram
  - YouTube
  - Facebook

## Project structure

Key areas in the codebase:

- `lib/main.dart`
  - app entry and root provider setup
- `lib/providers/app_state.dart`
  - main app state and platform coordination
- `lib/screens/home_screen.dart`
  - dashboard/home screen
- `lib/features/dashboard/`
  - dashboard data models and reusable widgets
- `lib/screens/analytics_screen.dart`
  - analytics UI
- `lib/screens/blocked_apps_screen.dart`
  - blocked apps/settings UI
- `lib/screens/onboarding/`
  - onboarding flow and steps
- `lib/services/`
  - analytics persistence, Android blocking, iOS blocking, safe web logic

## Requirements

- Flutter SDK
- Dart SDK
- Android Studio and/or Xcode for platform builds

Recommended:

- latest stable Flutter
- iOS 16+ for Apple Screen Time framework testing

## Getting started

```bash
flutter pub get
flutter run
```

## Useful commands

```bash
flutter analyze
flutter test
flutter pub run flutter_launcher_icons
```

## App identity

- App name: `Pauze`
- Launcher icon: Pauze logo asset

## Privacy and permissions

Pauze is a digital wellbeing app and depends on platform permissions for core features.

- Android: Accessibility access may be needed for blocking and usage detection
- iOS: FamilyControls / Screen Time authorization is used for blocking and scheduling flows

See the in-app legal/consent screens for current privacy policy and terms text.

## Development status

This repository currently contains active product work, including dashboard redesign, onboarding iterations, app rebrand updates, and launcher/icon assets. Some internal class names may still reflect older project naming, but visible user-facing branding has been updated to Pauze.
