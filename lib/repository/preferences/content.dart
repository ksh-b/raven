import 'package:raven/model/filter.dart';
import 'package:raven/repository/store.dart';
import 'package:raven/repository/trends.dart';

enum ContentPrefType {
  searchSuggestionsProvider,
  shouldLoadImages,
  shouldFilterContent,
  shouldTranslate,
  translator,
  translateTo,
  translatorInstance,
  translatorEngine,
  country,
  filters,
  shouldCollapseFiltered,
  shouldShowFilterReason
}

/// any,title,url,tag
enum FilterType { any, title, url, tag, author, content }

// default values
final _searchSuggestionsProvider = trends.values.first.name;
final _shouldLoadImages = true;
final _shouldFilterContent = false;
final _shouldTranslate = false;
final _translator = "SimplyTranslate";
final _translateTo = "English";
final _translatorInstance = "simplytranslate.org";
final _translatorEngine = "google";
final List<Map<String, List<String>>> filters = [];

class ContentPref {
  static String get searchSuggestionsProvider {
    return Store.settings.get(ContentPrefType.searchSuggestionsProvider.name,
        defaultValue: _searchSuggestionsProvider);
  }

  static set searchSuggestionsProvider(String provider) {
    Store.settings
        .put(ContentPrefType.searchSuggestionsProvider.name, provider);
  }

  static bool get shouldLoadImages {
    return Store.settings.get(ContentPrefType.shouldLoadImages.name,
        defaultValue: _shouldLoadImages);
  }

  static set shouldLoadImages(bool shouldLoad) {
    Store.settings.put(ContentPrefType.shouldLoadImages.name, shouldLoad);
  }

  static bool get shouldFilterContent {
    return Store.settings.get(ContentPrefType.shouldFilterContent.name,
        defaultValue: _shouldFilterContent);
  }

  static set shouldFilterContent(bool shouldFilter) {
    Store.settings.put(ContentPrefType.shouldFilterContent.name, shouldFilter);
  }

  static bool get shouldTranslate {
    return Store.settings.get(ContentPrefType.shouldTranslate.name,
        defaultValue: _shouldTranslate);
  }

  static set shouldTranslate(bool shouldTranslate) {
    Store.settings.put(ContentPrefType.shouldTranslate.name, shouldTranslate);
  }

  static String get translator {
    return Store.settings
        .get(ContentPrefType.translator.name, defaultValue: _translator);
  }

  static set translator(String translator) {
    Store.settings.put(ContentPrefType.translator.name, translator);
  }

  static String get translateTo {
    return Store.settings
        .get(ContentPrefType.translateTo.name, defaultValue: _translateTo);
  }

  static set translateTo(String translateTo) {
    Store.settings.put(ContentPrefType.translateTo.name, translateTo);
  }

  static String get translatorInstance {
    return Store.settings.get(ContentPrefType.translatorInstance.name,
        defaultValue: _translatorInstance);
  }

  static set translatorInstance(String translatorInstance) {
    Store.settings
        .put(ContentPrefType.translatorInstance.name, translatorInstance);
  }

  static String get translatorEngine {
    return Store.settings.get(ContentPrefType.translatorEngine.name,
        defaultValue: _translatorEngine);
  }

  static set translatorEngine(String translatorEngine) {
    Store.settings.put(ContentPrefType.translatorEngine.name, translatorEngine);
  }

  static String get country {
    return Store.settings
        .get(ContentPrefType.country.name, defaultValue: "United States");
  }

  static set country(String country) {
    Store.settings.put(ContentPrefType.country.name, country);
  }

  static List<Filter> get filters {
    return List<Filter>.from(Store.settings.get(
      ContentPrefType.filters.name,
      defaultValue: [],
    ));
  }

  static set filters(List<Filter> filters) {
    Store.settings.put(ContentPrefType.filters.name, filters);
  }
}
