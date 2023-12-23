import 'package:hive/hive.dart';

part 'user_subscription.g.dart';

@HiveType(typeId: 0)
class UserSubscription extends HiveObject{
  @HiveField(0)
  String publisher;

  @HiveField(1)
  String category;

  UserSubscription(this.publisher, this.category);

  @override
  String toString() {
    return "$publisher~$category";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSubscription &&
          runtimeType == other.runtimeType &&
          publisher == other.publisher &&
          category == other.category;

  @override
  int get hashCode => publisher.hashCode ^ category.hashCode;
}