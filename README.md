# Agasthi Mobile

A Flutter mobile application for Android.

## Project Status

✅ Android version is configured and ready for development.

## Current Setup

- **Flutter SDK:** ^3.9.2
- **Package Name:** `com.agasthi.mobile`
- **App Name:** Agasthi Mobile
- **Version:** 1.0.0+1

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/              # App screens
│   └── home_screen.dart  # Home screen
├── widgets/              # Reusable widgets
├── utils/                # Utility functions
├── constants/            # App constants
│   └── app_constants.dart
├── services/             # API services
└── models/               # Data models
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Android Studio or VS Code with Flutter extensions
- Android SDK (for Android development)

### Running the App

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run on Android device/emulator:
   ```bash
   flutter run
   ```

3. Build Android APK:
   ```bash
   flutter build apk --release
   ```

## Android Development

See [ANDROID_SETUP.md](ANDROID_SETUP.md) for detailed Android configuration and setup information.

## Development

### Adding New Features

- **Screens:** Add new screens in `lib/screens/`
- **Widgets:** Create reusable widgets in `lib/widgets/`
- **Services:** Add API services in `lib/services/`
- **Models:** Add data models in `lib/models/`

### Testing

Run tests with:
```bash
flutter test
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
