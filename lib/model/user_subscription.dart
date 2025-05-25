import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:klaws/model/publisher.dart';

part 'user_subscription.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class UserFeedSubscription extends HiveObject {
  @HiveField(0)
  Source source;

  @HiveField(1)
  String categoryPath;

  @HiveField(2)
  String categoryLabel;

  @HiveField(3)
  bool isCustom;

  UserFeedSubscription(this.source, this.categoryLabel, this.categoryPath,
      {this.isCustom = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFeedSubscription &&
          runtimeType == other.runtimeType &&
          source.id == other.source.id&&
          categoryPath == other.categoryPath &&
          categoryLabel == other.categoryLabel;

  @override
  int get hashCode => source.id.hashCode ^ categoryPath.hashCode;

  @override
  String toString() {
    return super.toString();
  }

  factory UserFeedSubscription.fromJson(Map<String, dynamic> json) => _$UserFeedSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$UserFeedSubscriptionToJson(this);

}
