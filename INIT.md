Got it! Here’s a **ready-to-paste “agent spec”** you can drop into your IDE’s AI/agent panel (Cursor/Copilot/JetBrains, etc.). It gives step-by-step instructions to create **Smart QR Hub** from scratch in **Flutter**, optimized for an App Store-compliant v1.

---

# Agent Specification: Build “Smart QR Hub” in Flutter (v1 for App Store)

## 0) Goal & Scope (v1)

Build a lightweight, privacy-respectful **QR scanner** that:

* Scans QR codes (camera) and **auto-detects type**: URL, Wi-Fi, vCard/MeCard, Event (VCALENDAR/VEVENT), plain text.
* Shows a **Smart Action Panel** with safe, user-initiated actions (open URL, copy text/password, save vCard/ICS via share sheet).
* Saves **local scan history** (no login, no cloud, no analytics).
* Includes a small **Settings** screen (clear history, theme, privacy policy).
* Ships for **iOS (App Store)** and **Android**; prioritize iOS requirements.

**App Store compliance (v1):**

* Camera use only; no tracking or hidden data collection.
* Clear purpose strings; privacy policy link in-app.
* All sensitive actions are user-initiated (no auto-redirects).

---

## 1) Project Setup

### 1.1 Create project

```bash
flutter create smart_qr_hub
cd smart_qr_hub
```

### 1.2 SDK & Platforms

* Flutter: latest stable
* Dart SDK: latest stable
* iOS deployment target: **iOS 14.0+**
* Android minSdkVersion: **24**

### 1.3 pubspec.yaml (add deps)

```yaml
name: smart_qr_hub
description: Smart QR Hub – unified QR scanner with context-aware actions
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  # Camera & QR scanning
  mobile_scanner: ^6.0.2
  # State management & DI
  flutter_riverpod: ^2.5.1
  # Local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.4
  # Utilities
  url_launcher: ^6.3.0
  share_plus: ^10.0.2
  intl: ^0.19.0
  clipboard: ^0.1.3 # or flutter services Clipboard
  # Theming
  flex_color_scheme: ^7.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.11
```

### 1.4 iOS configuration

* Open `ios/Runner/Info.plist`. Add:

```xml
<key>NSCameraUsageDescription</key>
<string>Smart QR Hub uses the camera to scan QR codes and show actions.</string>
```

* Set iOS minimum to 14 in `ios/Podfile`:

```ruby
platform :ios, '14.0'
```

* Xcode: set **App Icon** and **Launch Screen** (simple brand color + logo).

### 1.5 Android configuration

* In `android/app/build.gradle`:

  * `minSdkVersion 24`
  * `targetSdkVersion 34`
* Add camera permission in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

---

## 2) Architecture & Folder Structure

**Pattern:** Clean-ish with Riverpod; simple layers, no over-engineering.

```
lib/
  main.dart
  app.dart
  core/
    models/
      scan_entry.dart
    services/
      qr_parser.dart
      share_service.dart
      url_safety.dart
    storage/
      hive_boxes.dart
  features/
    scanner/
      scanner_page.dart
      smart_action_sheet.dart
    history/
      history_page.dart
      history_item_tile.dart
    settings/
      settings_page.dart
  theme/
    theme.dart
```

* **State:** Riverpod providers per feature (scanner state, history store).
* **Storage:** Hive box for `ScanEntry` model (type + content + title + ts).
* **Parsing:** `qr_parser.dart` returns a `ParsedQr` union (type + fields).

---

## 3) Data Models

### 3.1 Hive Model (ScanEntry)

```dart
// lib/core/models/scan_entry.dart
import 'package:hive/hive.dart';

part 'scan_entry.g.dart';

@HiveType(typeId: 1)
class ScanEntry {
  @HiveField(0)
  final String id; // uuid
  @HiveField(1)
  final String raw; // raw scanned text
  @HiveField(2)
  final String type; // url|wifi|vcard|event|text
  @HiveField(3)
  final String title; // derived title for list
  @HiveField(4)
  final DateTime createdAt;

  ScanEntry({
    required this.id,
    required this.raw,
    required this.type,
    required this.title,
    required this.createdAt,
  });
}
```

Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 4) QR Parsing Logic

### 4.1 Parsed Types

```dart
enum QrType { url, wifi, vcard, mecard, event, text }

class ParsedQr {
  final QrType type;
  final Map<String, String> data; // flexible typed fields
  final String displayTitle;

  ParsedQr(this.type, this.data, this.displayTitle);
}
```

### 4.2 Heuristics (regex/startsWith)

```dart
final _urlRegex = RegExp(r'^(https?:\/\/|www\.)', caseSensitive: false);
final _wifiRegex = RegExp(r'^WIFI:.*', caseSensitive: false);
final _vcardRegex = RegExp(r'^(BEGIN:VCARD)', caseSensitive: false);
final _mecardRegex = RegExp(r'^(MECARD:)', caseSensitive: false);
final _veventRegex = RegExp(r'^(BEGIN:VEVENT|BEGIN:VCALENDAR)', caseSensitive: false);

// Optional wallet/url markers to label "payment" later if needed:
// momo:      r'(momoapp|momo\.vn|mservice:)'
// zalopay:   r'(zalopay|zlp:)'
// vietqr:    r'(vietqr|napasqr|emvco)'

ParsedQr parseQr(String raw) {
  raw = raw.trim();

  if (_wifiRegex.hasMatch(raw)) {
    // WIFI:T:WPA;S:MyWifi;P:mypassword;;
    final ssid = RegExp(r'S:([^;]+)').firstMatch(raw)?.group(1) ?? '';
    final pwd  = RegExp(r'P:([^;]+)').firstMatch(raw)?.group(1) ?? '';
    final auth = RegExp(r'T:([^;]+)').firstMatch(raw)?.group(1) ?? '';
    return ParsedQr(QrType.wifi, {'ssid': ssid, 'password': pwd, 'auth': auth}, 'Wi-Fi: $ssid');
  }

  if (_vcardRegex.hasMatch(raw) || _mecardRegex.hasMatch(raw)) {
    final name = RegExp(r'(FN:|N:)(.+)').firstMatch(raw)?.group(2)?.split('\n').first.trim() ?? 'Contact';
    return ParsedQr(_mecardRegex.hasMatch(raw) ? QrType.mecard : QrType.vcard, {'content': raw}, name);
  }

  if (_veventRegex.hasMatch(raw)) {
    return ParsedQr(QrType.event, {'content': raw}, 'Calendar Event');
  }

  if (_urlRegex.hasMatch(raw)) {
    final url = raw.startsWith('www.') ? 'https://$raw' : raw;
    final host = Uri.tryParse(url)?.host ?? 'Link';
    return ParsedQr(QrType.url, {'url': url}, host);
  }

  return ParsedQr(QrType.text, {'text': raw}, raw.length > 32 ? '${raw.substring(0,32)}…' : raw);
}
```

---

## 5) UI & Features

### 5.1 Main Tabs

* **Scanner** (default): live camera view + result bottom sheet.
* **History**: list of past scans (icon, title, timestamp, chevron → details).
* **Settings**: theme, clear history, privacy policy (webview or markdown), feedback mailto.

### 5.2 Scanner Page

* Use `mobile_scanner` full-screen preview.
* On detection (first result only until user closes sheet), **pause** scanning.
* Show **Smart Action Bottom Sheet** based on `ParsedQr`:

| Type         | Actions (user-initiated)                            |
| ------------ | --------------------------------------------------- |
| URL          | Open in browser (url_launcher), Copy link           |
| Wi-Fi        | Copy SSID, Copy Password (no auto-join in v1)       |
| vCard/MeCard | “Save Contact” via share `.vcf` (see Share Service) |
| Event        | “Add to Calendar” via share `.ics`                  |
| Text         | Copy text, Share text                               |

* “Save to History” checkbox defaults to ON; toggle persists preference.

### 5.3 History Page

* List grouped by date; each tile shows icon by type, title, time.
* Tap → detail page showing parsed content + same action buttons.
* AppBar: “Clear All” (confirm dialog).

### 5.4 Settings Page

* Theme: System / Light / Dark (persist via Hive box `app_prefs`).
* Clear Scan History button (confirmation).
* Privacy Policy (load from local markdown `assets/privacy.md`).
* Feedback: `mailto:` link.

---

## 6) Utilities

### 6.1 Share Service (create vCard / ICS and share)

```dart
// lib/core/services/share_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareVCard(String vcardContent, {String fileName = 'contact.vcf'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(vcardContent);
    await Share.shareXFiles([XFile(file.path)], text: 'Contact');
  }

  static Future<void> shareIcs(String icsContent, {String fileName = 'event.ics'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(icsContent);
    await Share.shareXFiles([XFile(file.path)], text: 'Calendar Event');
  }
}
```

> For vCard/ICS inputs that are already provided by the QR, pass through. If missing, generate minimal valid files.

### 6.2 URL Safety (optional nice-to-have)

* If URL lacks scheme, prepend `https://`.
* Show host clearly on action button (“Open example.com”).

---

## 7) App Shell

### 7.1 `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/scan_entry.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScanEntryAdapter());
  await Hive.openBox('app_prefs');
  await Hive.openBox<ScanEntry>('history');
  runApp(const ProviderScope(child: SmartQrApp()));
}
```

### 7.2 `app.dart` & Routing

* BottomNavigation with 3 tabs (Scanner / History / Settings).
* Use `FlexColorScheme` for a polished look.
* Ensure camera permission flow is graceful (show rationale screen if denied).

---

## 8) Permissions & Privacy

* **iOS**: Only `NSCameraUsageDescription`. No calendar/contacts permission in v1 because we **share** `.vcf`/`.ics` to system sheet (user adds manually).
* **Android**: Camera permission only.
* **Privacy policy**: Put a simple markdown at `assets/privacy.md` and display on Settings. Declare **no data collection**.

Example policy (short):

> Smart QR Hub accesses the device camera solely to scan QR codes locally on your device. Scan history is stored locally and never leaves your device. We do not collect, track, or share personal data.

Add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/privacy.md
```

---

## 9) App Icon & Branding

* Create a simple vector logo (rounded square with “QR” motif).
* Generate icons with `flutter_launcher_icons` (optional) or add manually.
* Splash: white background, center logo (native iOS LaunchScreen.storyboard; Android drawable).

---

## 10) Testing & QA

### 10.1 Manual test cases

* Scan: URL, Wi-Fi, vCard, Event, plain text, invalid/garbled.
* Action sheet appears; actions behave correctly; no auto-redirects.
* History records and clears properly.
* Dark/Light/System theme switches.
* Denied camera permission → show friendly guidance screen.

### 10.2 Basic unit tests

* `qr_parser_test.dart` for the regex/heuristics.
* `history_store_test.dart` for Hive save/load/clear.

---

## 11) CI & Build

* Optional GitHub Actions: `flutter test`, `flutter analyze`.
* iOS archive via Xcode; set signing, bundle id: `com.yourorg.smartqrhub`.
* App version: `1.0.0+1`.

---

## 12) App Store Metadata (prepare)

* **Name:** Smart QR Hub
* **Subtitle:** Scan QR codes with smart actions
* **Keywords:** qr, scanner, wifi, vcard, ics, event, link, utility
* **Description (short):** Scan any QR code and instantly get the right action—open links, copy Wi-Fi, save contacts or events. Private by design.
* **Privacy policy URL:** host a simple static page or GitHub Pages; match in-app content.
* **Screenshots:** 6.5”, 6.1”, iPad (simulated with sample QR).

---

## 13) Definition of Done (v1)

* [ ] Scanner works on iOS/Android physical devices.
* [ ] Type detection for URL/Wi-Fi/vCard/MeCard/Event/Text.
* [ ] Smart Action Sheet per type (only user-initiated actions).
* [ ] Local History (list + detail + clear all).
* [ ] Settings: theme, privacy policy, clear history, feedback.
* [ ] App icons & launch screen in place.
* [ ] No analytics/tracking; privacy policy included.
* [ ] Passes `flutter analyze` and basic tests.
* [ ] Archive succeeds; TestFlight build upload OK.

---

## 14) Stretch (post-v1, do NOT block release)

* Scan from gallery image.
* Batch scan mode.
* Mark “Favorites” in history.
* iCloud sync (iOS) / Google Drive backup (Android) after privacy review.
* “Pro” tier: export history CSV, custom tags.

---

## 15) Sample Widgets (snippets)

### Smart Action Sheet (sketch)

```dart
// lib/features/scanner/smart_action_sheet.dart
import 'package:flutter/material.dart';
import '../../core/services/share_service.dart';
import '../../core/services/qr_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class SmartActionSheet extends StatelessWidget {
  final ParsedQr parsed;
  final VoidCallback onClose;

  const SmartActionSheet({super.key, required this.parsed, required this.onClose});

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];

    switch (parsed.type) {
      case QrType.url:
        final url = parsed.data['url']!;
        actions.addAll([
          ListTile(
            leading: const Icon(Icons.open_in_browser),
            title: Text('Open ${Uri.parse(url).host}'),
            onTap: () async { if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Link'),
            onTap: () { Clipboard.setData(ClipboardData(text: url)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied'))); },
          ),
        ]);
        break;

      case QrType.wifi:
        actions.addAll([
          ListTile(
            leading: const Icon(Icons.wifi),
            title: Text('SSID: ${parsed.data['ssid'] ?? ''}'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Copy Password'),
            onTap: () { Clipboard.setData(ClipboardData(text: parsed.data['password'] ?? '')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password copied'))); },
          ),
        ]);
        break;

      case QrType.vcard:
      case QrType.mecard:
        actions.add(
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Save Contact (vCard)'),
            onTap: () async { await ShareService.shareVCard(parsed.data['content']!); },
          ),
        );
        break;

      case QrType.event:
        actions.add(
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Add to Calendar (.ics)'),
            onTap: () async { await ShareService.shareIcs(parsed.data['content']!); },
          ),
        );
        break;

      case QrType.text:
        actions.addAll([
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Text'),
            onTap: () { Clipboard.setData(ClipboardData(text: parsed.data['text'] ?? '')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Text copied'))); },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Text'),
            onTap: () async { await ShareService.shareIcs('BEGIN:VCALENDAR'); }, // replace with Share.share
          ),
        ]);
        break;
    }

    return SafeArea(
      child: Wrap(children: [
        Padding(
          
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(height: 4, width: 44, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 8),
              Text(parsed.displayTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...actions,
              const SizedBox(height: 8),
              TextButton(onPressed: onClose, child: const Text('Close')),
            ],
          ),
        ),
      ]),
    );
  }
}
```

---
