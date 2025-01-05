
import 'package:hive/hive.dart';

part 'watch_dart.g.dart';

@HiveType(typeId: 16)
class WatchImport {
  @HiveField(0)
  String name="";
  @HiveField(1)
  String description="";
  @HiveField(2)
  String category="";
  @HiveField(3)
  String url="";
  @HiveField(4)
  List<Option> options=[];
  @HiveField(5)
  Items? items;

  WatchImport({
    required this.name,
    required this.description,
    required this.category,
    required this.url,
    required this.options,
    required this.items,
  });

  factory WatchImport.fromJson(Map<String, dynamic> json) {
    return WatchImport(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      url: json['url'] ?? '',
      options: (json['options'] as List?)
          ?.map((option) => Option.fromJson(option))
          .toList() ?? [],
      items: json['items'] != null ? Items.fromJson(json['items']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'url': url,
      'options': options.map((option) => option.toJson()).toList(),
      'items': items?.toJson(),
    };
  }

}

@HiveType(typeId: 21)
class Items {
  @HiveField(0)
  String extractor;
  @HiveField(1)
  String title;
  @HiveField(2)
  String subtitle;
  @HiveField(3)
  Ing leading;
  @HiveField(4)
  Ing trailing;
  @HiveField(5)
  String thumbnail;
  @HiveField(6)
  List<String> notes;
  @HiveField(7)
  String url;
  // @HiveField(8)
  // Axis_ axis;

  Items({
    required this.extractor,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.trailing,
    required this.thumbnail,
    required this.notes,
    required this.url,
    // required this.axis,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      extractor: json['extractor'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      leading: Ing.fromJson(json['leading']),
      trailing: Ing.fromJson(json['trailing']),
      thumbnail: json['thumbnail'] ?? '',
      notes: (json['notes'] as List?)
          ?.map((note) => note.toString())
          .toList() ?? [],
      url: json['url'] ?? '',
      // axis: Axis_.fromJson(json['axis']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extractor': extractor,
      'title': title,
      'subtitle': subtitle,
      'leading': leading.toJson(),
      'trailing': trailing.toJson(),
      'thumbnail': thumbnail,
      'notes': notes,
      'url': url,
      // 'axis': axis,
    };
  }

}

// @HiveType(typeId: 20)
// class Axis_ {
//   @HiveField(0)
//   String content;
//   @HiveField(1)
//   String notes;
//
//   Axis_({
//     required this.content,
//     required this.notes,
//   });
//
//   factory Axis_.fromJson(Map<String, dynamic> json) {
//     return Axis_(
//       content: json['content'] ?? '',
//       notes: json['notes'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'content': content,
//       'notes': notes,
//     };
//   }
//
// }

@HiveType(typeId: 19)
class Ing {
  @HiveField(0)
  String top;
  @HiveField(1)
  String bottom;

  Ing({
    required this.top,
    required this.bottom,
  });

  factory Ing.fromJson(Map<String, dynamic> json) {
    return Ing(
      top: json['top'] ?? '',
      bottom: json['bottom'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top,
      'bottom': bottom,
    };
  }

}

@HiveType(typeId: 18)
class Option {
  @HiveField(0)
  String name;
  @HiveField(1)
  String description;
  @HiveField(2)
  String optionDefault;

  Option({
    required this.name,
    required this.description,
    required this.optionDefault,
  });


  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      optionDefault: json['optionDefault'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'optionDefault': optionDefault,
    };
  }

}
