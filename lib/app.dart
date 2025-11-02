import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/theme.dart';
import 'features/scanner/scanner_page.dart';
import 'features/history/history_page.dart';
import 'features/settings/settings_page.dart';
import 'core/storage/hive_boxes.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_loadThemeMode()) {
    state = _loadThemeMode();
  }

  static ThemeMode _loadThemeMode() {
    try {
      final box = HiveBoxes.prefs;
      final mode = box.get('theme_mode', defaultValue: 'system');
      switch (mode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    HiveBoxes.prefs.put('theme_mode', modeStr);
  }
}

class SmartQrApp extends ConsumerWidget {
  const SmartQrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Smart QR Hub',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const MainTabsPage(),
    );
  }
}

class MainTabsPage extends ConsumerStatefulWidget {
  const MainTabsPage({super.key});

  @override
  ConsumerState<MainTabsPage> createState() => _MainTabsPageState();
}

class _MainTabsPageState extends ConsumerState<MainTabsPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ScannerPage(),
          HistoryPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

