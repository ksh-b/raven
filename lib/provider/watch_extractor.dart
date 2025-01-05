import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:raven/model/source/watch_dart.dart';
import 'package:raven/model/watch.dart';
import 'package:raven/service/http_client.dart';

class WatchExtractor {
  Future<Items?> extractWatchContent(
    Watch watch,
    String url,
  ) async {
    var items = watch.watch.items;
    if (items != null && items.extractor == "css") {
      final response = await dio().get(url);
      final document = html.parse(response.data);

      final items_ = Items(
        extractor: items.extractor,
        title: _getText(document, items.title),
        subtitle: _getText(document, items.subtitle),
        leading: _getLeading(document, items.leading),
        trailing: _getTrailing(document, items.trailing),
        thumbnail: _getText(document, items.thumbnail),
        notes: _getNotes(document, items.notes),
        url: _getText(document, items.url),
      );

      items_.url = url;
      return items_;
    }
    return null;
  }

  Ing _getLeading(Document document, Ing leading) {
    final ing = Ing(
      top: _getIngValue(document, leading.top),
      bottom: _getIngValue(document, leading.bottom),
    );
    return ing;
  }

  Ing _getTrailing(Document document, Ing trailing) {
    final ing = Ing(
      top: _getIngValue(document, trailing.top),
      bottom: _getIngValue(document, trailing.bottom),
    );
    return ing;
  }

  String _getIngValue(Document document, String selector) {
    if(selector.isEmpty) return "";
    final element = document.querySelector(selector);
    if (element?.localName == "img") {
      final src = element?.attributes["src"];
      return src != null && src.startsWith("//") ? "https:$src" : src ?? "";
    } else {
      return element?.text ?? "";
    }
  }

  String _getText(Document document, String selector) {
    if(selector.isEmpty) return "";
    return document.querySelector(selector)?.text ?? "";
  }

  List<String> _getNotes(Document document, List<String> notes) {
    return notes
        .map((note) => document.querySelector(note)?.outerHtml ?? "")
        .toList();
  }
}
