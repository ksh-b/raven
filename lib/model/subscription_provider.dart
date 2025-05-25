import 'package:hive_ce/hive.dart';

@HiveType(typeId: 3)
class SubscriptionsProvider {
  @HiveField(0)
  String url;
  @HiveField(1)
  String description;
  @HiveField(2)
  int lastUpdateCheck;
  @HiveField(3)
  int lastUpdateDownloaded;
  @HiveField(4)
  int repoLastCommit;

  SubscriptionsProvider({
    required this.url,
    required this.description,
    required this.lastUpdateCheck,
    required this.lastUpdateDownloaded,
    required this.repoLastCommit,
  });
}
