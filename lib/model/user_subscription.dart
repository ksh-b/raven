import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_subscription.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class UserSubscription extends HiveObject {
  @HiveField(0)
  String publisher;

  @HiveField(1)
  String categoryPath;

  @HiveField(2)
  String categoryLabel;

  @HiveField(3)
  bool isCustom;

  UserSubscription(this.publisher, this.categoryLabel, this.categoryPath,
      {this.isCustom = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSubscription &&
          runtimeType == other.runtimeType &&
          publisher == other.publisher &&
          categoryPath == other.categoryPath &&
          categoryLabel == other.categoryLabel;

  @override
  int get hashCode => publisher.hashCode ^ categoryPath.hashCode;

  factory UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$UserSubscriptionToJson(this);

}
