

import 'dart:convert';

import 'package:raven/model/search_suggestion.dart';
import 'package:raven/service/http_client.dart';

class DuckDuckGoSearch extends SearchSuggestions {
  @override
  String get name => "None";

  @override
  Future<List<String>> suggestions(String query) async {
    return [];
  }
}
