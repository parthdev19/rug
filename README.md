# RUG ♣️

> A multiplayer strategic card game revolving around the **3♣ (Three of Clubs)**.

---

## Architecture

This project follows a **Feature-First** architecture with clean separation of concerns.

### Layer Overview

```
lib/
├── main.dart           → Entry point (DI, error boundaries, ProviderScope)
├── app.dart            → Root MaterialApp.router (theme + routing)
├── core/               → Cross-cutting: constants, enums, errors, extensions, types
├── config/             → Environment config (dev/staging/prod), DI setup
├── services/           → Infrastructure: network, storage, audio, notifications, logging
├── shared/             → Shared models, providers, base repository
├── theme/              → Design system: colors, typography, spacing, shadows, radius
├── routes/             → GoRouter configuration, route names, guards
├── animations/         → Reusable animation system (cards, transitions, particles)
├── widgets/            → Shared UI components (buttons, cards, dialogs, inputs)
├── utils/              → Pure utilities (validators, formatters, screen helpers)
├── localization/       → i18n (ARB files)
├── assets/             → Asset path constants
└── features/           → Feature modules (see below)
```

### Feature Module Structure

Each feature follows clean architecture:

```
features/<feature>/
├── data/
│   ├── datasources/    → Remote/local data sources (API calls)
│   └── repositories/   → Repository implementations
├── domain/
│   ├── entities/       → Domain entities (pure business objects)
│   ├── repositories/   → Repository interfaces (contracts)
│   └── usecases/       → Business logic use cases
├── presentation/       → Screens / pages
├── controller/         → Riverpod providers & state management
├── models/             → Data models (Freezed/JSON serializable)
└── widgets/            → Feature-specific widgets
```

### Features

| Feature | Description |
|---------|-------------|
| `splash` | App launch screen |
| `auth` | Login, register, social auth |
| `home` | Main dashboard |
| `profile` | User profile management |
| `settings` | App settings (theme, sound, notifications) |
| `game_lobby` | Browse and join games |
| `private_room` | Create/join private rooms |
| `multiplayer_table` | Active game table UI |
| `online_match` | Online matchmaking |
| `friends` | Friends list and requests |
| `leaderboard` | Rankings and stats |
| `rewards` | Daily rewards and achievements |
| `wallet` | In-game currency management |
| `notifications` | Notification center |

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| **State Management** | Riverpod 3.x |
| **Routing** | GoRouter 17.x |
| **Networking** | Dio 5.x + WebSocket |
| **Local Storage** | Hive + SharedPreferences |
| **Code Gen** | Freezed + JSON Serializable |
| **Animations** | flutter_animate + Lottie + Custom |
| **Audio** | just_audio |
| **Push Notifications** | Firebase Messaging |
| **Theme** | Material 3 (Light + Dark) |
| **Fonts** | Google Fonts (Outfit + Inter) |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation (after adding Freezed models)
dart run build_runner build --delete-conflicting-outputs

# Run in development
flutter run --dart-define=FLAVOR=dev

# Run in staging
flutter run --dart-define=FLAVOR=staging

# Run in production
flutter run --dart-define=FLAVOR=prod
```

## Environment Configuration

The app supports three environments configured via `--dart-define`:

| Flavor | API Base | Logging | Crashlytics |
|--------|----------|---------|-------------|
| `dev` | `dev-api.rug.game` | ✅ | ❌ |
| `staging` | `staging-api.rug.game` | ✅ | ✅ |
| `prod` | `api.rug.game` | ❌ | ✅ |

## Theme System

- **Light & Dark themes** with card-game-inspired palette
- Deep greens (felt table), gold accents, suit-specific colors
- 4px spacing grid, consistent shadows, border radius tokens
- Google Fonts: **Outfit** (headings) + **Inter** (body)

## Project Guidelines

- **State**: All state goes through Riverpod providers
- **Routing**: All navigation uses GoRouter with named routes
- **Errors**: All exceptions extend `AppException`, failures extend `Failure`
- **API calls**: All network requests go through `DioClient` with interceptors
- **Storage**: Keys centralized in `StorageKeys`, accessed via service wrappers
- **Assets**: All paths centralized in `AssetPaths`
- **Linting**: Strict analysis with `require_trailing_commas`, `prefer_const_constructors`, `avoid_print`

---

*Built with Flutter 3.44.4 • Dart 3.12.2*
