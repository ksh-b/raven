

abstract class SearchSuggestions {
  String get name;

  Future<List<String>> suggestions(String query);

}
