// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSubscriptionAdapter extends TypeAdapter<UserSubscription> {
  @override
  final int typeId = 0;

  @override
  UserSubscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSubscription(
      fields[0] as String,
      fields[2] as String,
      fields[1] as String,
      isCustom: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserSubscription obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.publisher)
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
      other is UserSubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSubscription _$UserSubscriptionFromJson(Map<String, dynamic> json) =>
    UserSubscription(
      json['publisher'] as String,
      json['categoryLabel'] as String,
      json['categoryPath'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSubscriptionToJson(UserSubscription instance) =>
    <String, dynamic>{
      'publisher': instance.publisher,
      'categoryPath': instance.categoryPath,
      'categoryLabel': instance.categoryLabel,
      'isCustom': instance.isCustom,
    };
