// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteSummaryAdapter extends TypeAdapter<NoteSummary> {
  @override
  final int typeId = 3;

  @override
  NoteSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteSummary(
      id: fields[0] as String,
      originalText: fields[1] as String,
      summary: fields[2] as String,
      keyPoints: (fields[3] as List).cast<String>(),
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NoteSummary obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalText)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.keyPoints)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
