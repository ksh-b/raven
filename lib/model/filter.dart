import 'package:hive_ce/hive.dart';

part 'filter.g.dart';

@HiveType(typeId: 2)
class Filter {
  @HiveField(0)
  String publisher;

  @HiveField(1)
  String keyword;

  @HiveField(2)
  bool inAny;
  @HiveField(3)
  bool inUrl;
  @HiveField(4)
  bool inTitle;
  @HiveField(5)
  bool inTags;
  @HiveField(6)
  bool inAuthor;
  @HiveField(7)
  bool inContent;

  Filter({
    required this.publisher,
    required this.keyword,
    required this.inAny,
    required this.inUrl,
    required this.inTitle,
    required this.inTags,
    required this.inAuthor,
    required this.inContent,
  });

}
