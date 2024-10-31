// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FilterAdapter extends TypeAdapter<Filter> {
  @override
  final int typeId = 2;

  @override
  Filter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Filter(
      publisher: fields[0] as String,
      keyword: fields[1] as String,
      inAny: fields[2] as bool,
      inUrl: fields[3] as bool,
      inTitle: fields[4] as bool,
      inTags: fields[5] as bool,
      inAuthor: fields[6] as bool,
      inContent: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Filter obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.publisher)
      ..writeByte(1)
      ..write(obj.keyword)
      ..writeByte(2)
      ..write(obj.inAny)
      ..writeByte(3)
      ..write(obj.inUrl)
      ..writeByte(4)
      ..write(obj.inTitle)
      ..writeByte(5)
      ..write(obj.inTags)
      ..writeByte(6)
      ..write(obj.inAuthor)
      ..writeByte(7)
      ..write(obj.inContent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
