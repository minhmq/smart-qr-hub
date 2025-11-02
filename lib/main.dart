import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/scan_entry.dart';
import 'core/storage/hive_boxes.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScanEntryAdapter());
  await HiveBoxes.init();
  runApp(const ProviderScope(child: SmartQrApp()));
}

