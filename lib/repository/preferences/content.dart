import 'package:klaws/model/publisher.dart';
import 'package:klaws/model/watch.dart';
import 'package:raven/model/filter.dart';
import 'package:raven/model/stored_repo.dart';
import 'package:raven/model/subscription_provider.dart';
import 'package:raven/repository/preferences/internal.dart';
import 'package:raven/repository/search_suggestions.dart';
import 'package:raven/repository/trends.dart';

enum ContentPrefType {
  trendsProvider,
  searchSuggestionsProvider,
  shouldLoadImages,
  shouldFilterContent,
  shouldTranslate,
  autoUpdate,
  translator,
  translateTo,
  translatorInstance,
  translatorEngine,
  country,
  filters,
  subProviders,
  sources,
  watches,
  repos,
  shouldCollapseFiltered,
  shouldShowFilterReason,
}

/// any,title,url,tag
enum FilterType { any, title, url, tag, author, content }

// default values
final _trendsProvider = trends.values.first.name;
final _searchSuggestionsProvider = searchSuggestions.values.first.name;
final _shouldLoadImages = true;
final _shouldFilterContent = false;
final _shouldTranslate = false;
final _autoUpdate = true;
final _translator = "SimplyTranslate";
final _translateTo = "English";
final _translatorInstance = "simplytranslate.org";
final _translatorEngine = "google";
final List<Map<String, List<String>>> filters = [];

class ContentPref {
  static String get trendsProvider {
    return Internal.settings.get(
      ContentPrefType.trendsProvider.name,
      defaultValue: _trendsProvider,
    );
  }

  static set trendsProvider(String provider) {
    Internal.settings.put(
      ContentPrefType.trendsProvider.name,
      provider,
    );
  }

  static String get searchSuggestionsProvider {
    return Internal.settings.get(
      ContentPrefType.searchSuggestionsProvider.name,
      defaultValue: _searchSuggestionsProvider,
    );
  }

  static set searchSuggestionsProvider(String provider) {
    Internal.settings.put(
      ContentPrefType.searchSuggestionsProvider.name,
      provider,
    );
  }

  static bool get shouldLoadImages {
    return Internal.settings.get(ContentPrefType.shouldLoadImages.name,
        defaultValue: _shouldLoadImages);
  }

  static set shouldLoadImages(bool shouldLoad) {
    Internal.settings.put(ContentPrefType.shouldLoadImages.name, shouldLoad);
  }

  static bool get shouldFilterContent {
    return Internal.settings.get(ContentPrefType.shouldFilterContent.name,
        defaultValue: _shouldFilterContent);
  }

  static set shouldFilterContent(bool shouldFilter) {
    Internal.settings
        .put(ContentPrefType.shouldFilterContent.name, shouldFilter);
  }

  static bool get autoUpdate {
    return Internal.settings.get(
      ContentPrefType.autoUpdate.name,
      defaultValue: _autoUpdate,
    );
  }

  static set autoUpdate(bool autoUpdate) {
    Internal.settings.put(
      ContentPrefType.autoUpdate.name,
      autoUpdate,
    );
  }

  static bool get shouldTranslate {
    return Internal.settings.get(
      ContentPrefType.shouldTranslate.name,
      defaultValue: _shouldTranslate,
    );
  }

  static set shouldTranslate(bool shouldTranslate) {
    Internal.settings
        .put(ContentPrefType.shouldTranslate.name, shouldTranslate);
  }

  static String get translator {
    return Internal.settings
        .get(ContentPrefType.translator.name, defaultValue: _translator);
  }

  static set translator(String translator) {
    Internal.settings.put(ContentPrefType.translator.name, translator);
  }

  static String get translateTo {
    return Internal.settings
        .get(ContentPrefType.translateTo.name, defaultValue: _translateTo);
  }

  static set translateTo(String translateTo) {
    Internal.settings.put(ContentPrefType.translateTo.name, translateTo);
  }

  static String get translatorInstance {
    return Internal.settings.get(ContentPrefType.translatorInstance.name,
        defaultValue: _translatorInstance);
  }

  static set translatorInstance(String translatorInstance) {
    Internal.settings
        .put(ContentPrefType.translatorInstance.name, translatorInstance);
  }

  static String get translatorEngine {
    return Internal.settings.get(ContentPrefType.translatorEngine.name,
        defaultValue: _translatorEngine);
  }

  static set translatorEngine(String translatorEngine) {
    Internal.settings
        .put(ContentPrefType.translatorEngine.name, translatorEngine);
  }

  static String get country {
    return Internal.settings
        .get(ContentPrefType.country.name, defaultValue: "United States");
  }

  static set country(String country) {
    Internal.settings.put(ContentPrefType.country.name, country);
  }

  static List<Filter> get filters {
    return List<Filter>.from(Internal.settings.get(
      ContentPrefType.filters.name,
      defaultValue: [],
    ));
  }

  static set filters(List<Filter> filters) {
    Internal.settings.put(ContentPrefType.filters.name, filters);
  }

  static List<SubscriptionsProvider> get subProviders {
    return List<SubscriptionsProvider>.from(
      Internal.settings.get(
        ContentPrefType.subProviders.name,
        defaultValue: [],
      ),
    );
  }

  static set subProviders(List<SubscriptionsProvider> subProviders) {
    Internal.settings.put(ContentPrefType.subProviders.name, subProviders);
  }

  static List<Source> get feedSources {
    return List<Source>.from(
      Internal.settings.get(
        ContentPrefType.sources.name,
        defaultValue: [].cast<Source>(),
      ),
    );
  }

  static set feedSources(List<Source> sources) {
    Internal.settings.put(ContentPrefType.sources.name, sources);
  }

  static List<Watch> get watchSources {
    return List<Watch>.from(
      Internal.settings.get(
        ContentPrefType.watches.name,
        defaultValue: [].cast<Watch>(),
      ),
    );
  }

  static set watchSources(List<Watch> watches) {
    Internal.settings.put(ContentPrefType.watches.name, watches);
  }

  static List<StoredRepo> get repos {
    return List<StoredRepo>.from(
      Internal.settings.get(
        ContentPrefType.repos.name,
        defaultValue: [].cast<StoredRepo>(),
      ),
    );
  }

  static set repos(List<StoredRepo> repos) {
    Internal.settings.put(ContentPrefType.repos.name, repos);
  }
}
