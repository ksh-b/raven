// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchAdapter extends TypeAdapter<Watch> {
  @override
  final int typeId = 17;

  @override
  Watch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Watch(
      id: fields[0] as String,
      watch: fields[1] as WatchImport,
    );
  }

  @override
  void write(BinaryWriter writer, Watch obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.watch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Watch _$WatchFromJson(Map<String, dynamic> json) => Watch(
      id: json['id'] as String,
      watch: WatchImport.fromJson(json['watch'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WatchToJson(Watch instance) => <String, dynamic>{
      'id': instance.id,
      'watch': instance.watch,
    };
