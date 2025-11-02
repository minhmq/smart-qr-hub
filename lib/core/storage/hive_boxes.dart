import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_entry.dart';

class HiveBoxes {
  static Box<ScanEntry>? _historyBox;
  static Box? _prefsBox;

  static Future<void> init() async {
    _historyBox = await Hive.openBox<ScanEntry>('history');
    _prefsBox = await Hive.openBox('app_prefs');
  }

  static Box<ScanEntry> get history => _historyBox!;
  static Box get prefs => _prefsBox!;
}

