// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanEntryAdapter extends TypeAdapter<ScanEntry> {
  @override
  final int typeId = 1;

  @override
  ScanEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanEntry(
      id: fields[0] as String,
      raw: fields[1] as String,
      type: fields[2] as String,
      title: fields[3] as String,
      createdAtMillis: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScanEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.raw)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.createdAtMillis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
