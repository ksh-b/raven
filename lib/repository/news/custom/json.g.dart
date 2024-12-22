// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JsonSourceAdapter extends TypeAdapter<JsonSource> {
  @override
  final int typeId = 14;

  @override
  JsonSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JsonSource(
      id: fields[0] as String,
      name: fields[1] as String,
      homePage: fields[2] as String,
      hasSearchSupport: fields[3] as bool,
      hasCustomSupport: fields[4] as bool,
      iconUrl: fields[5] as String,
      siteCategories: (fields[6] as List).cast<String>(),
      externalSource: fields[7] as ExternalSource?,
    )..otherVersions = (fields[8] as List).cast<Source>();
  }

  @override
  void write(BinaryWriter writer, JsonSource obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.homePage)
      ..writeByte(3)
      ..write(obj.hasSearchSupport)
      ..writeByte(4)
      ..write(obj.hasCustomSupport)
      ..writeByte(5)
      ..write(obj.iconUrl)
      ..writeByte(6)
      ..write(obj.siteCategories)
      ..writeByte(7)
      ..write(obj.externalSource)
      ..writeByte(8)
      ..write(obj.otherVersions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
