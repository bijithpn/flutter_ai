// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_point.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KeyPointAdapter extends TypeAdapter<KeyPoint> {
  @override
  final int typeId = 1;

  @override
  KeyPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KeyPoint(
      name: fields[0] as String,
      x: fields[1] as double,
      y: fields[2] as double,
      confidence: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, KeyPoint obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.x)
      ..writeByte(2)
      ..write(obj.y)
      ..writeByte(3)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
