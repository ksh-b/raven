import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';

abstract class Trend {
  String get name;

  String get url;

  String get locator;

  Future<List<String>> get topics async {
    List<String> topics = [];

    var response = await dio().get(url);
    if (response.successful) {
      Document document = html_parser.parse(response.data);
      topics = document.querySelectorAll(locator).map((e) => e.text).toList();
    }
    return topics;
  }
}
