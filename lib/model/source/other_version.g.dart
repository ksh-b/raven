// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_version.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OtherVersionAdapter extends TypeAdapter<OtherVersion> {
  @override
  final int typeId = 12;

  @override
  OtherVersion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OtherVersion(
      name: fields[0] as String,
      file: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OtherVersion obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.file);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtherVersionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
