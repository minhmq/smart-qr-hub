import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/scan_entry.dart';
import '../../core/services/qr_parser.dart';

class HistoryItemTile extends StatelessWidget {
  final ScanEntry entry;
  final VoidCallback onTap;

  const HistoryItemTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'url':
        return Icons.link;
      case 'wifi':
        return Icons.wifi;
      case 'vcard':
      case 'mecard':
        return Icons.person;
      case 'event':
        return Icons.event;
      default:
        return Icons.text_fields;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(_getIconForType(entry.type)),
      ),
      title: Text(entry.title),
      subtitle: Text(
        DateFormat('h:mm a').format(entry.createdAt),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

