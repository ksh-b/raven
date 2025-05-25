// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'morss.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MorssAdapter extends TypeAdapter<Morss> {
  @override
  final int typeId = 30;

  @override
  Morss read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Morss(
      id: fields[0] as String,
      name: fields[1] as String,
      homePage: fields[2] as String,
      hasSearchSupport: fields[3] as bool,
      siteCategories: (fields[6] as List).cast<String>(),
      hasCustomSupport: true,
      iconUrl: '',
    )..otherVersions = (fields[8] as List).cast<Source>();
  }

  @override
  void write(BinaryWriter writer, Morss obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.homePage)
      ..writeByte(3)
      ..write(obj.hasSearchSupport)
      ..writeByte(6)
      ..write(obj.siteCategories)
      ..writeByte(7)
      ..write(obj.nest)
      ..writeByte(8)
      ..write(obj.otherVersions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MorssAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
