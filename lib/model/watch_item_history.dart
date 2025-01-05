
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:raven/model/source/watch_dart.dart';
import 'package:raven/model/watch.dart';

part 'watch_item_history.g.dart';

@JsonSerializable()
@HiveType(typeId: 22)
class WatchItemHistory {
  @HiveField(0)
  Watch watch;
  @HiveField(1)
  int lastUpdate;
  @HiveField(2)
  List<Items> itemsHistory;

  WatchItemHistory({
    required this.watch,
    required this.lastUpdate,
    required this.itemsHistory,
  });

  factory WatchItemHistory.fromJson(Map<String, dynamic> json) => _$WatchItemHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$WatchItemHistoryToJson(this);

}
