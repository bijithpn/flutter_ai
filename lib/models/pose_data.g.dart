// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pose_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PoseDataAdapter extends TypeAdapter<PoseData> {
  @override
  final int typeId = 2;

  @override
  PoseData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PoseData(
      keyPoints: (fields[0] as List).cast<KeyPoint>(),
      confidence: fields[1] as double,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PoseData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.keyPoints)
      ..writeByte(1)
      ..write(obj.confidence)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoseDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
