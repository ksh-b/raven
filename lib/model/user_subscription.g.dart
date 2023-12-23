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
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserSubscription obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.publisher)
      ..writeByte(1)
      ..write(obj.category);
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
