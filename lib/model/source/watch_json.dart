import 'package:hive/hive.dart';

part 'watch_json.g.dart';

@HiveType(typeId: 16)
class ExternalWatchMeta {
  @HiveField(0)
  String name = "";
  @HiveField(1)
  String file = "";

  ExternalWatchMeta({
    required this.name,
    required this.file,
  });

  ExternalWatchMeta.fromJson(dynamic json) {
    name = json['name'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['file'] = file;
    return map;
  }
}
