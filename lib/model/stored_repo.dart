
import 'package:hive_ce/hive.dart';
part 'stored_repo.g.dart';
@HiveType(typeId: 15)
class StoredRepo {
  @HiveField(0)
  String id;
  @HiveField(1)
  String url;
  @HiveField(2)
  String name;
  @HiveField(3)
  String description;
  @HiveField(4)
  int lastChecked;
  @HiveField(5)
  int lastUpdated;
  @HiveField(6)
  String directory;

  StoredRepo({
    required this.id,
    required this.url,
    required this.name,
    required this.description,
    required this.lastChecked,
    required this.lastUpdated,
    required this.directory,
  });
}
