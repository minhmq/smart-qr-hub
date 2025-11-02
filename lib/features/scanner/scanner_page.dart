import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/qr_parser.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/models/scan_entry.dart';
import 'smart_action_sheet.dart';

final scannerControllerProvider = Provider((ref) => MobileScannerController());

final autoSaveToHistoryProvider = StateProvider<bool>((ref) => true);

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  bool _hasScanned = false;
  String? _lastScannedCode;

  @override
  void dispose() {
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!mounted || _hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code == _lastScannedCode) return;

    _lastScannedCode = code;
    _hasScanned = true;

    final parsed = parseQr(code);
    final controller = ref.read(scannerControllerProvider);
    controller.stop();

    if (ref.read(autoSaveToHistoryProvider)) {
      _saveToHistory(code, parsed);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SmartActionSheet(
        parsed: parsed,
        rawCode: code,
        onClose: () {
          Navigator.pop(context);
          setState(() {
            _hasScanned = false;
            _lastScannedCode = null;
          });
          controller.start();
        },
      ),
    );
  }

  void _saveToHistory(String code, ParsedQr parsed) {
    final entry = ScanEntry.fromDateTime(
      id: const Uuid().v4(),
      raw: code,
      type: parsed.type.name,
      title: parsed.displayTitle,
      createdAt: DateTime.now(),
    );
    HiveBoxes.history.add(entry);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(scannerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final autoSave = ref.watch(autoSaveToHistoryProvider);
              return Switch(
                value: autoSave,
                onChanged: (value) {
                  ref.read(autoSaveToHistoryProvider.notifier).state = value;
                },
              );
            },
          ),
          const SizedBox(width: 8),
          const Text('Auto-save', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Position QR code within frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

