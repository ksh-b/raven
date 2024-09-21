import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

bool isHTML(String text) {
  RegExp htmlTags = RegExp(r'<[^>]*>');
  return htmlTags.hasMatch(text);
}

// inspired by Readability.js
// https://github.com/mozilla/readability/blob/main/Readability.js
List<String> cleanHtml(String htmlString) {
  if (!isHTML(htmlString)) return [htmlString];

  Document document = html_parser.parse(htmlString);

  document.querySelectorAll('*').forEach((element) {
    List<String> attributesToKeep = ["href", "src"];
    List<String> attributesToRemove = [];

    var unlikelyAttributes = [
      "menu",
      "menubar",
      "complementary",
      "navigation",
      "alert",
      "alertdialog",
      "dialog"
    ];

    var unlikelyTags = [
      "object",
      "embed",
      "footer",
      "aside",
      "iframe",
      "input",
      "textarea",
      "select",
      "button",
      "style",
    ];

    if (!element.hasContent() || element.text.isEmpty) {
      if (element.localName != "br") {
        element.remove();
      }
    }

    for (var ul in unlikelyAttributes) {
      if (element.attributes.toString().contains(ul)) element.remove();
    }

    if (unlikelyTags.contains(element.localName)) element.remove();

    if (element.attributes.containsKey("href")) {
      element.attributes["href"] = element.attributes["href"]!.split("&")[0];
    }
    element.attributes.forEach((key, value) {
      if (!attributesToKeep.contains(key)) {
        attributesToRemove.add("$key");
      }
    });
    for (var key in attributesToRemove) {
      element.attributes.remove(key);
    }
  });

  var splitHtml = document
      .querySelectorAll("html body")
      .map(
        (e) => e.outerHtml,
      )
      .toList();
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
          currentSentence += ' $nextSentence';
          i++;
        }
      }
      result.add(currentSentence);
    }
  }

  return result;
}
