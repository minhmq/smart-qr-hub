import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/qr_parser.dart';
import '../../core/services/share_service.dart';

class SmartActionSheet extends StatelessWidget {
  final ParsedQr parsed;
  final String rawCode;
  final VoidCallback onClose;

  const SmartActionSheet({
    super.key,
    required this.parsed,
    required this.rawCode,
    required this.onClose,
  });

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
            onTap: () async {
              try {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open URL: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Link'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied')),
                );
              }
            },
          ),
        ]);
        break;

      case QrType.wifi:
        final ssid = parsed.data['ssid'] ?? '';
        final password = parsed.data['password'] ?? '';
        actions.addAll([
          ListTile(
            leading: const Icon(Icons.wifi),
            title: Text('SSID: $ssid'),
            subtitle: Text('Auth: ${parsed.data['auth'] ?? 'Unknown'}'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: ssid));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SSID copied')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Copy Password'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: password));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied')),
                );
              }
            },
          ),
        ]);
        break;

      case QrType.vcard:
      case QrType.mecard:
        actions.add(
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Save Contact (vCard)'),
            onTap: () async {
              await ShareService.shareVCard(parsed.data['content']!);
            },
          ),
        );
        break;

      case QrType.event:
        actions.add(
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Add to Calendar (.ics)'),
            onTap: () async {
              await ShareService.shareIcs(parsed.data['content']!);
            },
          ),
        );
        break;

      case QrType.text:
        final text = parsed.data['text'] ?? '';
        actions.addAll([
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Text'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Text copied')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Text'),
            onTap: () async {
              await ShareService.shareText(text);
            },
          ),
        ]);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 4,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                parsed.displayTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ...actions,
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onClose,
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

