
import 'package:klaws/model/publisher.dart';
import 'package:raven/repository/news/custom/morss.dart';
import 'package:raven/repository/news/custom/rss.dart';
import 'package:raven/repository/preferences/content.dart';

List<Source> _publishers = [
  Morss(
    id: "morss",
    name: "morss",
    homePage: '',
    hasSearchSupport: false,
    hasCustomSupport: true,
    iconUrl: '',
    siteCategories: ['Custom'],
  ),
  RSSFeed(
    id: "rss",
    name: "RSS Feed",
    homePage: '',
    hasSearchSupport: false,
    hasCustomSupport: true,
    iconUrl: '',
    siteCategories: ['Custom'],
  )
];


Map<String, Source> publishers() {
  return {
    for (var publisher in _publishers+ContentPref.feedSources)
      publisher.id: publisher
  };
}
