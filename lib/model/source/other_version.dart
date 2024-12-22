import 'package:hive/hive.dart';

part 'other_version.g.dart';
@HiveType(typeId: 12)
class OtherVersion {
  @HiveField(0)
  String name = "";
  @HiveField(1)
  String file = "";

  OtherVersion({
    required this.name,
    required this.file,
  });

  OtherVersion.fromJson(dynamic json) {
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
