// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 5;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as ThemeMode,
      offlineMode: fields[1] as bool,
      preferredLanguage: fields[2] as String,
      enableHapticFeedback: fields[3] as bool,
      enableNotifications: fields[4] as bool,
      aiConfidenceThreshold: fields[5] as double,
      maxRecipeHistory: fields[6] as int,
      maxWorkoutHistory: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.offlineMode)
      ..writeByte(2)
      ..write(obj.preferredLanguage)
      ..writeByte(3)
      ..write(obj.enableHapticFeedback)
      ..writeByte(4)
      ..write(obj.enableNotifications)
      ..writeByte(5)
      ..write(obj.aiConfidenceThreshold)
      ..writeByte(6)
      ..write(obj.maxRecipeHistory)
      ..writeByte(7)
      ..write(obj.maxWorkoutHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThemeModeAdapterAdapter extends TypeAdapter<ThemeModeAdapter> {
  @override
  final int typeId = 6;

  @override
  ThemeModeAdapter read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeModeAdapter.system;
      case 1:
        return ThemeModeAdapter.light;
      case 2:
        return ThemeModeAdapter.dark;
      default:
        return ThemeModeAdapter.system;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeModeAdapter obj) {
    switch (obj) {
      case ThemeModeAdapter.system:
        writer.writeByte(0);
        break;
      case ThemeModeAdapter.light:
        writer.writeByte(1);
        break;
      case ThemeModeAdapter.dark:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
