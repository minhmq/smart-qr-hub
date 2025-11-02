import 'package:flutter_test/flutter_test.dart';
import 'package:smart_qr_hub/core/services/qr_parser.dart';

void main() {
  group('QR Parser', () {
    test('detects URL QR codes', () {
      final parsed = parseQr('https://example.com');
      expect(parsed.type, QrType.url);
      expect(parsed.data['url'], 'https://example.com');
    });

    test('detects Wi-Fi QR codes', () {
      final parsed = parseQr('WIFI:T:WPA;S:MyNetwork;P:mypassword;;');
      expect(parsed.type, QrType.wifi);
      expect(parsed.data['ssid'], 'MyNetwork');
      expect(parsed.data['password'], 'mypassword');
    });

    test('detects vCard QR codes', () {
      final parsed = parseQr('BEGIN:VCARD\nFN:John Doe\nEND:VCARD');
      expect(parsed.type, QrType.vcard);
      expect(parsed.data['content'], contains('BEGIN:VCARD'));
    });

    test('detects plain text', () {
      final parsed = parseQr('Just some plain text');
      expect(parsed.type, QrType.text);
      expect(parsed.data['text'], 'Just some plain text');
    });
  });
}

