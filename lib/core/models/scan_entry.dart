import 'package:hive/hive.dart';

part 'scan_entry.g.dart';

@HiveType(typeId: 1)
class ScanEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String raw;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final int createdAtMillis;

  ScanEntry({
    required this.id,
    required this.raw,
    required this.type,
    required this.title,
    required this.createdAtMillis,
  });

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMillis);

  factory ScanEntry.fromDateTime({
    required String id,
    required String raw,
    required String type,
    required String title,
    required DateTime createdAt,
  }) {
    return ScanEntry(
      id: id,
      raw: raw,
      type: type,
      title: title,
      createdAtMillis: createdAt.millisecondsSinceEpoch,
    );
  }
}

