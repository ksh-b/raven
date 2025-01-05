import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:raven/model/article.dart';
import 'package:raven/model/source/source_dart.dart';
import 'package:raven/model/source/util.dart';
import 'package:raven/repository/news/custom/json.dart';
import 'package:raven/service/http_client.dart';

Future<Map<String, String>> extractCategoriesCss(JsonSource source) async {
  Map<String, String> categories = {};
  final response =
      await dio().get(source.externalSource!.homePage, queryParameters: source.externalSource!.headers.json_);
  var locators = source.externalSource!.categories.locator;
  var locatorsExclude = source.externalSource!.categories.exclude;
  Include? locatorsInclude = source.externalSource!.categories.include;

  var document = html.parse(response.data);
  for (String locator in locators) {
    List<Element> elements = document.querySelectorAll(locator);
    for (var element in elements) {
      if (!element.attributes.containsKey("href")) {
        continue;
      }
      if (locatorsExclude.contains(element.text) ||
          locatorsExclude.contains(element.attributes["href"])) {
        continue;
      }
      if (element.attributes["href"] == "#") {
        categories.addAll({element.text: "${source.externalSource!.homePage}/#"});
        continue;
      }
      categories.addAll({element.text: element.attributes["href"]!});
    }
  }
  locatorsInclude.toJson().entries.forEach((e) {
    categories.addAll({e.key: e.value});
  });
  categories.updateAll((key, value) {
    return value.toString().replaceFirst("${source.externalSource!.homePage}/", "");
  });
  return categories;
}

bool isOnePage(JsonSource source) {
  var isOnePage = !RegExp(r'\{page\}|\{offset\}').hasMatch(source.externalSource!.categoryUrl);
  return isOnePage;
}

Future<List<Article>> extractCategoryArticlesCss(
  JsonSource source,
  String category,
  int page,
) async {
  if (isOnePage(source) && page > 1) {
    return [];
  }
  String? url = source.externalSource!.categoryUrl
      .replaceAll("{home-page}", source.externalSource!.homePage)
      .replaceAll("{category}", category)
      .replaceAll("{size}", "10")
      .replaceAll("{offset}", "${(page - 1) * 10}")
      .replaceAll("{page}", "$page");
  var locator = source.externalSource!.categoryArticles.locators;
  return await extractArticlesCss(
    url,
    locator,
    source,
    source.externalSource!.categoryArticles,
  );
}

Future<List<Article>> extractSearchArticlesCss(
  JsonSource source,
  String query,
  int page,
) async {
  if (isOnePage(source) && page > 1) {
    return [];
  }
  String? url = source.externalSource!.searchUrl
      .replaceAll("{home-page}", source.externalSource!.homePage)
      .replaceAll("{query}", query)
      .replaceAll("{size}", "10")
      .replaceAll("{offset}", "${(page - 1) * 10}")
      .replaceAll("{page}", "$page");
  var locator = source.externalSource!.searchArticles.locators;
  return await extractArticlesCss(
    url,
    locator,
    source,
    source.externalSource!.searchArticles,
  );
}

Future<List<Article>> extractArticlesCss(
  String url,
  Locators locator,
  JsonSource source,
  SourceArticle type,
) async {
  List<Article> articleList = [];
  final response = await dio().get(url);
  var document = html.parse(response.data);
  List<Element> articles = [];
  articles.addAll(document.querySelectorAll(locator.container));
  for (var article in articles) {
    var titleElement = article.querySelectorOptional(locator.title);
    var excerptElement = article.querySelectorOptional(locator.excerpt);
    var authorElement = article.querySelectorOptional(locator.author);
    var thumbnailElement = article.querySelectorOptional(locator.thumbnail);
    var urlElement = article.querySelectorOptional(locator.url);
    var timeElement = article.querySelectorOptional(locator.time);
    var categoryElement = article.querySelectorOptional(locator.category);

    var content = "";
    for (var content_ in locator.content) {
      var contentElement = article.querySelectorAll(content_);
      content += contentElement.map((e) => e.text).join();
    }

    var tags = [];
    for (var tag in locator.tags) {
      tags.addAll(article.querySelectorAll(tag).map((e) => e.text).toList());
    }

    var epoch = getEpochTimeFromElement(
      source.externalSource!,
      type.dateFormat,
      timeElement,
    );

    var thumbnail = thumbnailElement?.attributes['src'];
    if (thumbnailElement != null) {
      RegExp urlRegex = RegExp(r'https\S*(?:jpg|jpeg|png|webp|gif|svg)');
      var urlMatch = urlRegex.firstMatch(thumbnailElement.outerHtml.toString());
      if (urlMatch != null) {
        String? url = urlMatch.group(0);
        thumbnail = url!;
      }
    }


    articleList.add(
      Article(
        source: source,
        sourceName: source.name,
        title: titleElement?.text.trim() ?? '',
        author: authorElement?.text.trim() ?? '',
        thumbnail: thumbnail ?? '',
        url: urlElement?.attributes['href'] ?? '',
        publishedAt: epoch,
        publishedAtString: timeElement?.text.trim() ?? '',
        category: categoryElement?.text.trim() ?? '',
        content: content,
        excerpt: excerptElement?.text.trim() ?? '',
        tags: tags.cast<String>(),
      ),
    );
  }
  return articleList;
}

Future<Article> extractArticleCss(
  JsonSource source,
    Article article,
) async {
  // TODO: only extract if not present already

  final response =
      await getResponse(source.externalSource!, completeUrl(source.externalSource!, article.url));
  var document = html.parse(response.data);
  var articleContainer =
      document.body?.querySelector(source.externalSource!.article.locators.container);
  if (articleContainer == null) {
    return article;
  }

  var locator = source.externalSource!.article.locators;
  var titleElement = articleContainer.querySelectorOptional(locator.title);
  var authorElement = articleContainer.querySelectorOptional(locator.author);
  var excerptElement = articleContainer.querySelectorOptional(locator.excerpt);
  var thumbnailElement =
      articleContainer.querySelectorOptional(locator.thumbnail);
  var timeElement = articleContainer.querySelectorOptional(locator.time);
  var categoryElement =
      articleContainer.querySelectorOptional(locator.category);
  var content = "";
  for (var content_ in locator.content) {
    var contentElement = articleContainer.querySelectorAll(content_);
    content += contentElement.map((e) => e.outerHtml).join();

    for (var ad in source.externalSource!.ads) {
      for (var adContent in articleContainer.querySelectorAll(ad)) {
        content.replaceAll(adContent.outerHtml, "");
      }
    }
  }
  var tags = [];
  for (var tag in locator.tags) {
    tags.addAll(
      articleContainer.querySelectorAll(tag).map((e) => e.text).toList(),
    );
  }
  //
  var thumbnail = article.thumbnail;
  if (thumbnailElement != null) {
    RegExp urlRegex = RegExp(r'https\S*(?:jpg|jpeg|png|webp|gif)');
    var urlMatch = urlRegex.firstMatch(thumbnailElement.outerHtml.toString());
    if (urlMatch != null) {
      String? url = urlMatch.group(0);
      thumbnail = url!;
    }
  }

  var title = titleElement?.text.trim() ?? article.title;
  var author = authorElement?.text.trim() ?? article.author;
  var excerpt = excerptElement?.text.trim() ?? article.excerpt;
  var url = article.url;
  var time = timeElement?.text.trim() ?? article.publishedAt;
  var category = categoryElement?.text.trim() ?? article.category;

  int epoch = article.publishedAt;

  // modifications
  // if (source.externalSource!.article.modifications.isNotEmpty) {
  //   source.externalSource!.article.modifications
  //       .join()
  //       .replaceAll("{title}", title)
  //       .replaceAll("{excerpt}", excerpt)
  //       .replaceAll("{author}", author)
  //       .replaceAll("{url}", url)
  //       .replaceAll("{time}", time)
  //       .replaceAll("{category}", category);
  //
  //   String modTime = eval(
  //     source.externalSource!.article.modifications.join().split("=")[1],
  //   );
  //   epoch = getEpochTimeFromString(source.externalSource!.article.dateFormat, modTime);
  // }

  // if (results.containsKey('title')) {
  //   title = results['title'];
  // } else if (results.containsKey('author')) {
  //   author = results['author'];
  // } else if (results.containsKey('excerpt')) {
  //   author = results['excerpt'];
  // } else if (results.containsKey('url')) {
  //   url = results['url'];
  // } else if (results.containsKey('time') && !time.isEmpty()) {
  //   time = results['time'];
  //   epoch = getEpochTimeFromString(source.externalSource!.article.dateFormat, time);
  // } else if (results.containsKey('category')) {
  //   category = results['category'];
  // }

  //
  if (epoch == -1) {
    epoch =
        getEpochTimeFromElement(source.externalSource!, source.externalSource!.article.dateFormat, timeElement);
  }



  return Article(
    source: source,
    sourceName: source.name,
    title: title,
    author: author,
    thumbnail: thumbnail,
    url: url,
    publishedAt: epoch,
    publishedAtString: article.publishedAtString,
    category: category,
    content: content.trim(),
    excerpt: excerpt,
    tags: tags.cast<String>(),
  );
}
