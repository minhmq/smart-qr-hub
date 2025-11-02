# Smart QR Hub

A lightweight, privacy-respectful QR scanner app built with Flutter. Smart QR Hub automatically detects QR code types (URL, Wi-Fi, vCard, Event, Text) and provides context-aware actions—all processed locally on your device.

## Features

- **Smart QR Scanning**: Automatically detects URL, Wi-Fi, vCard, MeCard, Calendar Event, and plain text
- **Context-Aware Actions**: Each QR type gets relevant actions (open URL, copy Wi-Fi password, save contact, etc.)
- **Local History**: All scan history stored locally on device
- **Privacy First**: No cloud sync, no analytics, no tracking
- **Dark/Light Theme**: System-aware theme support
- **Settings**: Clear history, privacy policy, feedback

## Requirements

- Flutter SDK: `>=3.4.0 <4.0.0`
- Dart SDK: `>=3.4.0 <4.0.0`
- iOS: 14.0+
- Android: API 24+ (Android 7.0+)

## Build Steps

### Prerequisites

1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Ensure Flutter is in your PATH
3. Run `flutter doctor` to verify setup

### Initial Setup

1. **Get dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate Hive adapters:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Running the App

#### iOS (Simulator or Device)

1. **Open iOS project:**
   ```bash
   open ios/Runner.xcworkspace
   ```
   
   Or run directly:
   ```bash
   flutter run -d ios
   ```

2. **Configure signing in Xcode:**
   - Select your team in Signing & Capabilities
   - Set Bundle Identifier (e.g., `com.yourorg.smartqrhub`)

3. **Build and run:**
   ```bash
   flutter build ios --release
   ```

#### Android (Emulator or Device)

1. **Run on device:**
   ```bash
   flutter run -d android
   ```

2. **Build release APK:**
   ```bash
   flutter build apk --release
   ```

### Building for TestFlight (iOS)

1. **Archive in Xcode:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select "Any iOS Device" as build destination
   - Product → Archive

2. **Distribute to App Store Connect:**
   - In Organizer window, click "Distribute App"
   - Select "App Store Connect"
   - Follow the export wizard
   - Upload via Transporter or Xcode

3. **Alternative: Build via command line:**
   ```bash
   flutter build ipa --release
   ```
   
   This creates `build/ios/ipa/smart_qr_hub.ipa`

4. **Upload to App Store Connect:**
   - Use Transporter app (macOS App Store)
   - Or use Xcode → Window → Organizer → Distribute App

### Project Structure

```
lib/
  main.dart                 # App entry point
  app.dart                  # App shell with theme & navigation
  core/
    models/
      scan_entry.dart      # Hive model for scan history
    services/
      qr_parser.dart       # QR type detection logic
      share_service.dart   # vCard/ICS sharing
      url_safety.dart      # URL normalization
    storage/
      hive_boxes.dart      # Hive box initialization
  features/
    scanner/
      scanner_page.dart    # Camera scanner UI
      smart_action_sheet.dart  # Context-aware actions
    history/
      history_page.dart    # Scan history list
      history_item_tile.dart
      history_detail_page.dart
    settings/
      settings_page.dart   # Settings & preferences
  theme/
    theme.dart             # FlexColorScheme themes
```

## Testing

### Manual Testing Checklist

- [ ] Scan URL QR code → opens in browser
- [ ] Scan Wi-Fi QR code → copy SSID/password works
- [ ] Scan vCard QR code → share contact works
- [ ] Scan Calendar Event → share ICS works
- [ ] Scan plain text → copy/share works
- [ ] History saves and displays correctly
- [ ] Clear history works
- [ ] Theme switching works (Light/Dark/System)
- [ ] Privacy policy displays
- [ ] Camera permission handling

### Run Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

## Configuration

### iOS Configuration

- **Info.plist**: Camera permission description already added
- **Podfile**: iOS 14.0+ minimum deployment target
- **Bundle ID**: Update in Xcode project settings

### Android Configuration

- **AndroidManifest.xml**: Camera permission added
- **build.gradle**: minSdkVersion 24, targetSdkVersion 34
- **Package name**: `com.example.smart_qr_hub` (update as needed)

## Privacy

- Camera: Used only for QR scanning, processed locally
- Storage: All data stored on device, never transmitted
- No analytics, tracking, or ads
- No cloud sync or external services

## Version

**v1.0.0** - Initial release for App Store

## License

See LICENSE file (if applicable)

## Support

For feedback or issues, use the in-app feedback feature or contact: feedback@smartqrhub.app

