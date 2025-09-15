import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Hive adapter for Duration
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 10;

  @override
  Duration read(BinaryReader reader) {
    final milliseconds = reader.readInt();
    return Duration(milliseconds: milliseconds);
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMilliseconds);
  }
}

/// Hive adapter for ThemeMode
class ThemeModeHiveAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 11;

  @override
  ThemeMode read(BinaryReader reader) {
    final index = reader.readInt();
    return ThemeMode.values[index];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeInt(obj.index);
  }
}
