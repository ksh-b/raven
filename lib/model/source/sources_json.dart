import 'package:raven/model/source/watch_json.dart';

import 'source_json.dart';

class ExternalSources {
  String name = "";
  String description = "";
  String changelog = "";
  List<ExternalSourceMeta> feeds = [];
  List<ExternalWatchMeta> watches = [];

  ExternalSources({
    required this.name,
    required this.description,
    required this.changelog,
    required this.feeds,
    required this.watches,
  });

  ExternalSources.fromJson(dynamic json_) {
    name = json_['name'];
    description = json_['description'];
    changelog = json_['changelog'];
    if (json_['feeds'] != null) {
      feeds = [];
      json_['feeds'].forEach((v) {
        feeds.add(ExternalSourceMeta.fromJson(v));
      });
    }
    if (json_['watches'] != null) {
      watches = [];
      json_['watches'].forEach((v) {
        watches.add(ExternalWatchMeta.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['description'] = description;
    map['changelog'] = changelog;
    map['sources'] = feeds.map((v) => v.toJson()).toList();
      return map;
  }
}
