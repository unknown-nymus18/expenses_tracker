// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsStateAdapter extends TypeAdapter<SettingsState> {
  @override
  final int typeId = 3;

  @override
  SettingsState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Handle migration from old format (3 fields) to new format (2 fields)
    // Old format: 0=isDarkMode, 1=isBiometric, 2=fontSize
    // New format: 0=isDarkMode, 1=fontSize
    if (numOfFields == 3) {
      // Old format - field 2 is fontSize, skip field 1 (isBiometric)
      return SettingsState(
        isDarkMode: fields[0] as bool,
        fontSize: fields[2] as int,
      );
    } else {
      // New format
      return SettingsState(
        isDarkMode: fields[0] as bool,
        fontSize: fields[1] as int,
      );
    }
  }

  @override
  void write(BinaryWriter writer, SettingsState obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.fontSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
