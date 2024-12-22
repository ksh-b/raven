import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/source/source_dart.dart';
import 'package:raven/model/source/sources_json.dart';
import 'package:raven/repository/preferences/content.dart';

import '../repository/publishers.dart';
import '../utils/string.dart';

part 'publisher.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class Source {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String homePage;
  @HiveField(3)
  final bool hasSearchSupport;
  @HiveField(4)
  final bool hasCustomSupport;
  @HiveField(5)
  final String iconUrl;
  @HiveField(6)
  final List<String> siteCategories;
  @HiveField(7)
  final ExternalSource? externalSource;
  @HiveField(8)
  List<Source> otherVersions = [];

  Source({
    required this.id,
    required this.name,
    required this.homePage,
    required this.hasSearchSupport,
    required this.hasCustomSupport,
    required this.iconUrl,
    required this.siteCategories,
    this.externalSource
  });


  Future<Article> article(Article article) {
    throw UnimplementedError();
  }

  Future<Set<Article>> articles({required String category, int page = 1}) {
    return category.startsWith("#")
        ? searchedArticles(searchQuery: getAsSearchQuery(category), page: page)
        : categoryArticles(category: category, page: page);
  }

  Future<Set<Article>> categoryArticles({
    required String category,
    int page = 1,
  }) async {return <Article>{};}

  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {return <Article>{};}

  Future<Map<String, String>> categories() async {return {};}

  factory Source.fromJson(Map<String, dynamic> json) => _$SourceFromJson(json);

  Map<String, dynamic> toJson() => _$SourceToJson(this);

}
