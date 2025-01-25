import 'package:raven/model/search_suggestion.dart';
import 'package:raven/model/trend.dart';
import 'package:raven/repository/search_suggestions/duckduckgo.dart';
import 'package:raven/repository/trend/google.dart';
import 'package:raven/repository/trend/none.dart';
import 'package:raven/repository/trend/yahoo.dart';

Map<String, SearchSuggestions> searchSuggestions = {
  for (var searchSuggestions in [
    DuckDuckGoSearch(),
  ])
    searchSuggestions.name: searchSuggestions,
};
