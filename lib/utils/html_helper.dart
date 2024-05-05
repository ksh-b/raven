import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

List<String> cleanHtml(String htmlString) {
  Document document = html_parser.parse(htmlString);

  document.querySelectorAll('*').forEach((element) {
    List<String> attributesToKeep = [];
    List<String> attributesToRemove = [];
    if ((!element.hasContent() ||
        element.text.isEmpty ||
        element.localName == "noscript")) {
      element.remove();
    }
    element.attributes.forEach((key, value) {
      if (!attributesToKeep.contains(key)) {
        attributesToRemove.add("$key");
      }
    });
    attributesToRemove.forEach((key) {
      element.attributes.remove(key);
    });
  });

  var splitHtml = document.querySelectorAll("html body").first.children.map(
    (e) {
      if (e.attributes.containsKey("href") &&
          e.attributes["href"]!.contains("&"))
        e.attributes["href"] = e.attributes["href"]!.split("&")[0];
      return e.outerHtml;
    },
  ).toList();
  return chunks(splitHtml);
}

List<String> chunks(List<String> sentences) {
  List<String> result = [];
  int threshold = 100;
  for (int i = 0; i < sentences.length; i++) {
    String currentSentence = sentences[i];
    if (currentSentence.split(' ').length > threshold) {
      List<String> words = currentSentence.split(' ');
      for (int j = 0; j < words.length; j += threshold) {
        int endIndex = j + threshold;
        if (endIndex > words.length) {
          endIndex = words.length;
        }
        result.add(words.sublist(j, endIndex).join(' '));
      }
    } else {
      if (i + 1 < sentences.length) {
        String nextSentence = sentences[i + 1];
        if ((currentSentence.split(' ').length +
                nextSentence.split(' ').length) <=
            threshold) {
          currentSentence += ' ' + nextSentence;
          i++;
        }
      }
      result.add(currentSentence);
    }
  }

  return result;
}
