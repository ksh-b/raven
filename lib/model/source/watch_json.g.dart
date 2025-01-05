// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_json.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExternalWatchMetaAdapter extends TypeAdapter<ExternalWatchMeta> {
  @override
  final int typeId = 16;

  @override
  ExternalWatchMeta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExternalWatchMeta(
      name: fields[0] as String,
      file: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExternalWatchMeta obj) {
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
      other is ExternalWatchMetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
