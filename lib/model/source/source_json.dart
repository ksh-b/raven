import 'package:hive/hive.dart';

import 'other_version.dart';

part 'source_json.g.dart';

@HiveType(typeId: 11)
class ExternalSourceMeta {
  @HiveField(0)
  String name = "";
  @HiveField(1)
  String file = "";
  @HiveField(2)
  List<OtherVersion> otherversions = [];

  ExternalSourceMeta({
    required this.name,
    required this.file,
    required this.otherversions,
  });

  ExternalSourceMeta.fromJson(dynamic json) {
    name = json['name'];
    file = json['file'];
    if (json['other-versions'] != null) {
      otherversions = [];
      json['other-versions'].forEach((v) {
        otherversions.add(OtherVersion.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['file'] = file;
    map['other-versions'] = otherversions.map((v) => v.toJson()).toList();
      return map;
  }

}
