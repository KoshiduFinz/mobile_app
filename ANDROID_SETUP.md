# Android Development Setup

This document provides information about the Android configuration for Agasthi Mobile.

## Android Configuration

### Package Name
- **Application ID:** `com.agasthi.mobile`
- **Package:** `com.agasthi.mobile`

### App Details
- **App Name:** Agasthi Mobile
- **Version:** 1.0.0+1
- **Min SDK:** Defined by Flutter (typically 21+)
- **Target SDK:** Defined by Flutter (latest stable)

### Project Structure

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

### Building for Android

#### Debug Build
```bash
flutter build apk --debug
# or
flutter run
```

#### Release Build
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### Android Permissions

Currently configured permissions:
- `INTERNET` - Required for network requests

To add more permissions, edit `android/app/src/main/AndroidManifest.xml`

### Signing Configuration

⚠️ **Important:** The release build currently uses debug signing. For production, you need to:
1. Create a keystore file
2. Configure signing in `android/app/build.gradle.kts`
3. Add `key.properties` file (and add it to `.gitignore`)

### Testing on Android

1. **Physical Device:**
   - Enable Developer Options and USB Debugging
   - Connect device via USB
   - Run `flutter devices` to verify connection
   - Run `flutter run`

2. **Emulator:**
   - Create an Android Virtual Device (AVD) in Android Studio
   - Start the emulator
   - Run `flutter run`

### Next Steps

1. Add required dependencies in `pubspec.yaml`
2. Implement features and screens
3. Set up API integration
4. Configure app icons and splash screen
5. Set up signing for release builds

