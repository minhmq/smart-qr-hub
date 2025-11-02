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

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}

