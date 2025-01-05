// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_item_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchItemHistoryAdapter extends TypeAdapter<WatchItemHistory> {
  @override
  final int typeId = 22;

  @override
  WatchItemHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchItemHistory(
      watch: fields[0] as Watch,
      lastUpdate: fields[1] as int,
      itemsHistory: (fields[2] as List).cast<Items>(),
    );
  }

  @override
  void write(BinaryWriter writer, WatchItemHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.watch)
      ..writeByte(1)
      ..write(obj.lastUpdate)
      ..writeByte(2)
      ..write(obj.itemsHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchItemHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchItemHistory _$WatchItemHistoryFromJson(Map<String, dynamic> json) =>
    WatchItemHistory(
      watch: Watch.fromJson(json['watch'] as Map<String, dynamic>),
      lastUpdate: (json['lastUpdate'] as num).toInt(),
      itemsHistory: (json['itemsHistory'] as List<dynamic>)
          .map((e) => Items.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WatchItemHistoryToJson(WatchItemHistory instance) =>
    <String, dynamic>{
      'watch': instance.watch,
      'lastUpdate': instance.lastUpdate,
      'itemsHistory': instance.itemsHistory,
    };
