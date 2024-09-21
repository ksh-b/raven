import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class BBC extends Publisher {
  @override
  String get name => "BBC";

  @override
  String get homePage => "https://www.bbc.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => Category.world.name;

  @override
  bool get hasCustomSupport => false;

  Future<Map<String, String>> extractCategories() async {
    return {
      "World": "/world",
      "Asia": "/asia",
      "UK": "/uk",
      "Business": "/business",
      "Technology": "/technology",
      "Science": "/science",
    };
  }

  Map<String, String> uuidMap() {
    return {
      "/world": "8467c0e0-584b-41de-9682-756b311216b5",
      "/asia": "070fca6a-b5c7-4b7f-8834-1c989fd40297",
      "/uk": "082101b1-72b1-4e45-943d-29d6dc6f97b4",
      "/business": "19a1d11b-1755-4f97-8747-0c9534336a47",
    };
  }

  Map<String, Map<String, String>> topicMap() {
    return {
      "/technology": {
        "topic": "cd1qez2v2j2t",
        "urn": "b2790c4d-d5c4-489a-84dc-be0dcd3f5252",
      },
      "/science": {
        "topic": "c43v9644301t",
        "urn": "0e18053e-731e-400a-a5b4-0f4088c74fd0",
      },
    };
  }

  Future<Set<Article>> extractBatch(
    String id,
    int page,
    String category,
  ) async {
    Set<Article> articlesData = {};
    String apiUrl = "https://push.api.bbci.co.uk/batch?"
        "t=/data/bbc-morph-lx-commentary-data-paged/about/$id/"
        "isUk/false/limit/5/nitroKey/lx-nitro/pageNumber/$page/version/1.5.6";
    var response = await dio().get(apiUrl);
    if (response.successful) {
      final Map<String, dynamic> data = (response.data);
      var articles = data["payload"][0]["body"]["results"];
      for (var article in articles) {
        var articleUrl = article['url'];
        if (articleUrl == null) continue;
        var title = article['title'];
        var author = article.containsKey("contributor")
            ? article['contributor']["name"]
            : "";
        var thumbnail =
            article.containsKey("image") ? article["image"]["href"] : "";
        var time = article["lastPublished"];
        var excerpt = article['summary'];
        articlesData.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt,
            author: author ?? "",
            url: articleUrl,
            thumbnail: thumbnail.replaceFirst("http:", "https:") ?? "",
            publishedAt: stringToUnix(time?.trim() ?? ""),
            tags: [category],
            category: category,
          ),
        );
      }
    }
    return articlesData;
  }

  Future<Set<Article>> extractTopic(
    String topicId,
    String groupResourceId,
    int page,
    String category,
  ) async {
    Set<Article> articlesData = {};
    String apiUrl = 'https://www.bbc.com/wc-data/container/topic-stream?'
        'adSlotType=mpu_middle&enableDotcomAds=true&isUk=false'
        '&lazyLoadImages=true&pageNumber=$page&pageSize=5'
        '&promoAttributionsToSuppress=["/news","/news/front_page"]'
        '&showPagination=true&title=Latest News'
        '&tracking={"groupName":"Latest News","groupType":"topic stream",'
        '"groupResourceId":"urn:bbc:vivo:curation:$groupResourceId",'
        '"groupPosition":5,"topicId":"$topicId"}'
        '&urn=urn:bbc:vivo:curation:$groupResourceId';
    var response = await dio().get(apiUrl);

    if (response.successful) {
      final Map<String, dynamic> data = (response.data);
      var articles = data["posts"];
      for (var article in articles) {
        var title = article['headline'];
        var author = article['contributor'] ?? "";
        var thumbnail = article["image"] != null ? article["image"]["src"] : "";
        var time = convertToIso8601(article["timestamp"]);
        var articleUrl = article['url'];
        var excerpt = "";
        articlesData.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt,
            author: author ?? "",
            url: articleUrl,
            thumbnail: thumbnail.replaceFirst("http:", "https:") ?? "",
            publishedAt: stringToUnix(time),
            tags: [category],
            category: category,
          ),
        );
      }
    }

    return articlesData;
  }

  String convertToIso8601(String inputTime) {
    DateTime today = DateTime.now();
    DateFormat inputFormat = DateFormat('HH:mm dd MMMM yyyy');
    DateTime parsedTime;

    try {
      if (inputTime.split(" ").length == 3) {
        // 04:20 20 December
        parsedTime = inputFormat.parse('$inputTime ${today.year.toString()}');
      } else if (inputTime.split(" ").length == 1 && !inputTime.contains(":")) {
        // 20 December
        parsedTime =
            inputFormat.parse('00:00 $inputTime ${today.year.toString()}');
      } else if (inputTime.split(" ").length == 2) {
        // 20 December 2020
        parsedTime = inputFormat.parse('00:00 $inputTime');
      } else {
        // 04:20
        var hhmm = inputTime.split(":");
        var hh = int.parse(hhmm[0]);
        var mm = int.parse(hhmm[1]);
        parsedTime = DateTime(today.year, today.month, today.day, hh, mm);
      }
      String iso8601Format =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(parsedTime);
      return iso8601Format;
    } catch (e) {
      return inputTime;
    }
  }

  String convertString(String input) {
    return '@${input.replaceAll('/', '","')}",'.replaceFirst('@","', '@"');
  }

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get("$homePage${newsArticle.url}");

    if (response.successful) {
      var document = html_parser.parse(response.data);
      var jsonContent = jsonDecode(
          document.querySelector('script[type="application/json"]')?.text ??
              "{}");
      String content = '';
      if (jsonContent is! Map) {
        content = document.querySelector('main article')?.outerHtml ?? "";
      } else {
        content = '<html><body>';
        var blocks = jsonContent["props"]["pageProps"]["page"]
            [convertString(newsArticle.url)]["contents"];
        for (var b in blocks) {
          if (b["type"] == "text") {
            content += '<p>${b["model"]["blocks"][0]["model"]["text"]}</p>';
          }
        }
        content = "$content</body></html>";
      }
      newsArticle.content = content;
    }

    return newsArticle;
  }

  @override
  Future<Set<Article>> categoryArticles({
    required String category,
    int page = 1,
  }) async {
    if (category == "/") {
      category = "/world";
    }
    Map uuidMap_ = uuidMap();
    Map topicMap_ = topicMap();
    if (uuidMap_.containsKey(category)) {
      return extractBatch(uuidMap_[category], page, category);
    } else if (topicMap_.containsKey(category)) {
      return extractTopic(topicMap_[category]["topic"],
          topicMap_[category]["urn"], page, category);
    }
    return {};
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    Set<Article> articles = {};
    var response = await dio().get(
        "https://web-cdn.api.bbci.co.uk/xd/search?terms=$searchQuery&page=$page");

    if (response.successful) {
      var document = response.data['data'];
      for (var element in document) {
        var title = element['title'];
        var thumbnail = element['indexImage']['model']['blocks']['src'];
        var articleUrl = element['path'];
        var excerpt = element['summary'];
        var time = element['lastPublishedAt'];
        var tags = element['topics'].cast<String>();
        var author = "";

        if (time != null) {
          time = convertToIso8601(time);
        }

        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt ?? "",
            author: author,
            url: articleUrl?.replaceFirst("https://www.bbc.co.uk", "").replaceFirst("https://www.bbc.com", "") ?? "",
            thumbnail: thumbnail ?? "",
            publishedAt: stringToUnix(time?.trim() ?? ""),
            tags: tags,
            category: searchQuery,
          ),
        );
      }
    }
    return articles;
  }

  @override
  bool get hasSearchSupport => true;
}
