import 'source_json.dart';

class ExternalSources {
  String name = "";
  String description = "";
  String changelog = "";
  List<ExternalSourceMeta> sources = [];

  ExternalSources({
    required this.name,
    required this.description,
    required this.changelog,
    required this.sources,
  });

  ExternalSources.fromJson(dynamic json_) {
    name = json_['name'];
    description = json_['description'];
    changelog = json_['changelog'];
    if (json_['sources'] != null) {
      sources = [];
      json_['sources'].forEach((v) {
        sources.add(ExternalSourceMeta.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['description'] = description;
    map['changelog'] = changelog;
    map['sources'] = sources.map((v) => v.toJson()).toList();
      return map;
  }
}
