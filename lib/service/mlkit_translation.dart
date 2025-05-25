import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:klaws/model/article.dart';
import 'package:raven/model/translation_service.dart';
import 'package:raven/repository/preferences/content.dart';

class MLKitTranslation extends TranslationService {
  @override
  Map<String, dynamic> languages() {
    Map<String, dynamic> languages = {};
    for (TranslateLanguage language in TranslateLanguage.values) {
      languages.putIfAbsent(language.name, () => language);
    }
    return languages;
  }

  @override
  Future<Article> translateArticle(Article article) async {
    if (!ContentPref.shouldTranslate) {
      return article;
    }

    String content = article.content;
    String title = article.title;
    String excerpt = article.excerpt;
    String author = article.author;
    String publishedAtString = article.publishedAtString;
    String category = article.category;
    String sourceName = article.sourceName;
    List<String> tags = article.tags;

    // identify source language
    String identifiedLanguageCode = await identifySourceLanguage(content);
    TranslateLanguage? sourceLanguage = confirmSourceLanguage(identifiedLanguageCode);
    // undetermined
    if (identifiedLanguageCode == "und" || sourceLanguage == null) {
      return article;
    }

    // download models
    await downloadModels(sourceLanguage);

    // clean html
    dom.Document document = html_parser.parse(content);
    document.querySelectorAll('script,noscript').forEach((tag) {
      tag.remove();
    });
    content = document.body?.text ?? content;

    // translate
    final onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: languages()[ContentPref.translateTo]!,
    );
    content = await onDeviceTranslator.translateText(content);
    title = await onDeviceTranslator.translateText(title);
    excerpt = await onDeviceTranslator.translateText(excerpt);
    author = await onDeviceTranslator.translateText(author);
    publishedAtString =
        await onDeviceTranslator.translateText(publishedAtString);
    category = await onDeviceTranslator.translateText(category);
    sourceName = await onDeviceTranslator.translateText(sourceName);
    for (String tag in tags) {
      tag = await onDeviceTranslator.translateText(tag);
    }

    // translated article
    return Article(
      source: article.source,
      sourceName: sourceName,
      title: title,
      content: content,
      excerpt: excerpt,
      author: author,
      url: article.url,
      thumbnail: article.thumbnail,
      category: category,
      tags: tags,
      publishedAt: article.publishedAt,
      publishedAtString: publishedAtString,
    );
  }

  Future<dom.Document> translateDocument(dom.Document document) async {
    Future<void> processNode(dom.Node node, TranslateLanguage? sourceLanguage) async {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        String originalText = node.text?.trim() ?? '';
        if (originalText.isNotEmpty) {
          String translatedText = await translate(originalText, sourceLanguage: sourceLanguage);
          node.text = translatedText;
        }
      } else {
        for (dom.Node child in node.nodes) {
          await processNode(child, sourceLanguage);
        }
      }
    }

    if (document.body != null) {
      document.querySelectorAll('script,noscript').forEach((tag) {
        tag.remove();
      });
      String identifiedLanguageCode = await identifySourceLanguage(document.text??"");
      TranslateLanguage? sourceLanguage = confirmSourceLanguage(identifiedLanguageCode);
      await processNode(document.body!, sourceLanguage);
    }
    return document;
  }

  @override
  Future<String> translate(String text, {bool isHtml=false, TranslateLanguage? sourceLanguage}) async {
    // todo: identify this automatically. make it more clean
    // clean html
    if(isHtml) {
      dom.Document document = html_parser.parse(text);
      return (await translateDocument(document)).body!.outerHtml;
    }

    // identify source language
    String identifiedLanguageCode = await identifySourceLanguage(text);
    if(sourceLanguage==null) {
      sourceLanguage = confirmSourceLanguage(identifiedLanguageCode);
      // und = undetermined
      if (identifiedLanguageCode == "und" || sourceLanguage == null) {
        return text;
      }
    }

    // download models
    await downloadModels(sourceLanguage);

    final onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: languages()[ContentPref.translateTo]!,
    );

    return await onDeviceTranslator.translateText(text);
  }

  TranslateLanguage? confirmSourceLanguage(String identifiedLanguageCode) {
    var sourceLanguage = TranslateLanguage.values
        .where((lang) => lang.bcpCode == identifiedLanguageCode)
        .firstOrNull;
    return sourceLanguage;
  }

  Future<String> identifySourceLanguage(String text) async {
    final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    final String identifiedLanguageCode =
        await languageIdentifier.identifyLanguage(text);
    return identifiedLanguageCode;
  }

  Future<void> downloadModels(TranslateLanguage sourceLanguage) async {
    // download models
    final modelManager = OnDeviceTranslatorModelManager();
    TranslateLanguage targetLanguage = languages()[ContentPref.translateTo]!;

    var targetModelDownloaded =
    await modelManager.isModelDownloaded(targetLanguage.bcpCode);
    if (!targetModelDownloaded) {
      modelManager.downloadModel(targetLanguage.bcpCode);
    }

    var sourceModelDownloaded =
    await modelManager.isModelDownloaded(sourceLanguage.bcpCode);
    if (!sourceModelDownloaded) {
      modelManager.downloadModel(sourceLanguage.bcpCode);
    }
    return;
  }
}
