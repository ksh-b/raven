// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserFeedSubscriptionAdapter extends TypeAdapter<UserFeedSubscription> {
  @override
  final int typeId = 0;

  @override
  UserFeedSubscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserFeedSubscription(
      fields[0] as Source,
      fields[2] as String,
      fields[1] as String,
      isCustom: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserFeedSubscription obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.source)
      ..writeByte(1)
      ..write(obj.categoryPath)
      ..writeByte(2)
      ..write(obj.categoryLabel)
      ..writeByte(3)
      ..write(obj.isCustom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFeedSubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserFeedSubscription _$UserFeedSubscriptionFromJson(
        Map<String, dynamic> json) =>
    UserFeedSubscription(
      Source.fromJson(json['source'] as Map<String, dynamic>),
      json['categoryLabel'] as String,
      json['categoryPath'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
    );

Map<String, dynamic> _$UserFeedSubscriptionToJson(
        UserFeedSubscription instance) =>
    <String, dynamic>{
      'source': instance.source,
      'categoryPath': instance.categoryPath,
      'categoryLabel': instance.categoryLabel,
      'isCustom': instance.isCustom,
    };
