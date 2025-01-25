

import 'dart:convert';

import 'package:raven/model/search_suggestion.dart';
import 'package:raven/service/http_client.dart';

class DuckDuckGoSearch extends SearchSuggestions {
  @override
  String get name => "DuckDuckGo";

  @override
  Future<List<String>> suggestions(String query) async {
    var response = await dio().get(
        "https://duckduckgo.com/ac/?q=${Uri.encodeQueryComponent(query)}"
    );
    if (response.statusCode!=200) {
      return [];
    }
    var json = jsonDecode(response.data);
    return json.map((it)=>it["phrase"].toString()).toList().cast<String>();
  }
}
