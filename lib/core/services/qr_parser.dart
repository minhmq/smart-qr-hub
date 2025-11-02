enum QrType { url, wifi, vcard, mecard, event, text }

class ParsedQr {
  final QrType type;
  final Map<String, String> data;
  final String displayTitle;

  ParsedQr(this.type, this.data, this.displayTitle);
}

final _urlRegex = RegExp(r'^(https?:\/\/|www\.)', caseSensitive: false);
final _wifiRegex = RegExp(r'^WIFI:.*', caseSensitive: false);
final _vcardRegex = RegExp(r'^(BEGIN:VCARD)', caseSensitive: false);
final _mecardRegex = RegExp(r'^(MECARD:)', caseSensitive: false);
final _veventRegex = RegExp(r'^(BEGIN:VEVENT|BEGIN:VCALENDAR)', caseSensitive: false);

ParsedQr parseQr(String raw) {
  raw = raw.trim();

  if (_wifiRegex.hasMatch(raw)) {
    final ssid = RegExp(r'S:([^;]+)').firstMatch(raw)?.group(1) ?? '';
    final pwd = RegExp(r'P:([^;]+)').firstMatch(raw)?.group(1) ?? '';
    final auth = RegExp(r'T:([^;]+)').firstMatch(raw)?.group(1) ?? '';
    return ParsedQr(QrType.wifi, {'ssid': ssid, 'password': pwd, 'auth': auth}, 'Wi-Fi: $ssid');
  }

  if (_vcardRegex.hasMatch(raw) || _mecardRegex.hasMatch(raw)) {
    final name = RegExp(r'(FN:|N:)(.+)', multiLine: true).firstMatch(raw)?.group(2)?.split('\n').first.trim() ?? 'Contact';
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

  return ParsedQr(QrType.text, {'text': raw}, raw.length > 32 ? '${raw.substring(0, 32)}…' : raw);
}

