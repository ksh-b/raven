// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_repo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoredRepoAdapter extends TypeAdapter<StoredRepo> {
  @override
  final int typeId = 15;

  @override
  StoredRepo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoredRepo(
      id: fields[0] as String,
      url: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String,
      lastChecked: fields[4] as int,
      lastUpdated: fields[5] as int,
      directory: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StoredRepo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.lastChecked)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.directory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredRepoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
