
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:raven/model/source/watch_dart.dart';

part 'watch.g.dart';

@JsonSerializable()
@HiveType(typeId: 17)
class Watch {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final WatchImport watch;

  Watch({
    required this.id,
    required this.watch,
  });

  factory Watch.fromJson(Map<String, dynamic> json) => _$WatchFromJson(json);

  Map<String, dynamic> toJson() => _$WatchToJson(this);

}
