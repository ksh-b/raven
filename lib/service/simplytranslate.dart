import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/parser.dart';
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/utils/store.dart';
import 'package:worker_manager/worker_manager.dart';

class SimplyTranslate {
  Map<String, String> languages = {
    "Afrikaans": "af",
    "Albanian": "sq",
    "Amharic": "am",
    "Arabic": "ar",
    "Armenian": "hy",
    "Assamese": "as",
    "Aymara": "ay",
    "Azerbaijani": "az",
    "Bambara": "bm",
    "Basque": "eu",
    "Belarusian": "be",
    "Bengali": "bn",
    "Bhojpuri": "bho",
    "Bosnian": "bs",
    "Bulgarian": "bg",
    "Catalan": "ca",
    "Cebuano": "ceb",
    "Chichewa": "ny",
    "Chinese (Simplified)": "zh-CN",
    "Chinese (Traditional)": "zh-TW",
    "Corsican": "co",
    "Croatian": "hr",
    "Czech": "cs",
    "Danish": "da",
    "Dhivehi": "dv",
    "Dogri": "doi",
    "Dutch": "nl",
    "English": "en",
    "Esperanto": "eo",
    "Estonian": "et",
    "Ewe": "ee",
    "Filipino": "tl",
    "Finnish": "fi",
    "French": "fr",
    "Frisian": "fy",
    "Galician": "gl",
    "Georgian": "ka",
    "German": "de",
    "Greek": "el",
    "Guarani": "gn",
    "Gujarati": "gu",
    "Haitian Creole": "ht",
    "Hausa": "ha",
    "Hawaiian": "haw",
    "Hebrew": "iw",
    "Hindi": "hi",
    "Hmong": "hmn",
    "Hungarian": "hu",
    "Icelandic": "is",
    "Igbo": "ig",
    "Ilocano": "ilo",
    "Indonesian": "id",
    "Irish": "ga",
    "Italian": "it",
    "Japanese": "ja",
    "Javanese": "jw",
    "Kannada": "kn",
    "Kazakh": "kk",
    "Khmer": "km",
    "Kinyarwanda": "rw",
    "Konkani": "gom",
    "Korean": "ko",
    "Krio": "kri",
    "Kurdish (Kurmanji)": "ku",
    "Kurdish (Sorani)": "ckb",
    "Kyrgyz": "ky",
    "Lao": "lo",
    "Latin": "la",
    "Latvian": "lv",
    "Lingala": "ln",
    "Lithuanian": "lt",
    "Luganda": "lg",
    "Luxembourgish": "lb",
    "Macedonian": "mk",
    "Maithili": "mai",
    "Malagasy": "mg",
    "Malay": "ms",
    "Malayalam": "ml",
    "Maltese": "mt",
    "Maori": "mi",
    "Marathi": "mr",
    "Meiteilon (Manipuri)": "mni-Mtei",
    "Mizo": "lus",
    "Mongolian": "mn",
    "Myanmar (Burmese)": "my",
    "Nepali": "ne",
    "Norwegian": "no",
    "Odia (Oriya)": "or",
    "Oromo": "om",
    "Pashto": "ps",
    "Persian": "fa",
    "Polish": "pl",
    "Portuguese": "pt",
    "Punjabi": "pa",
    "Quechua": "qu",
    "Romanian": "ro",
    "Russian": "ru",
    "Samoan": "sm",
    "Sanskrit": "sa",
    "Scots Gaelic": "gd",
    "Sepedi": "nso",
    "Serbian": "sr",
    "Sesotho": "st",
    "Shona": "sn",
    "Sindhi": "sd",
    "Sinhala": "si",
    "Slovak": "sk",
    "Slovenian": "sl",
    "Somali": "so",
    "Spanish": "es",
    "Sundanese": "su",
    "Swahili": "sw",
    "Swedish": "sv",
    "Tajik": "tg",
    "Tamil": "ta",
    "Tatar": "tt",
    "Telugu": "te",
    "Thai": "th",
    "Tigrinya": "ti",
    "Tsonga": "ts",
    "Turkish": "tr",
    "Turkmen": "tk",
    "Twi": "ak",
    "Ukrainian": "uk",
    "Urdu": "ur",
    "Uyghur": "ug",
    "Uzbek": "uz",
    "Vietnamese": "vi",
    "Welsh": "cy",
    "Xhosa": "xh",
    "Yiddish": "yi",
    "Yoruba": "yo",
    "Zulu": "zu"
  };

  Map<String, List<String>> instances = {
    "simplytranslate.org": [
      "google",
    ],
    "t.opnxng.com": [
      "google",
    ],
    "st.adast.dk": [
      "google",
    ],
    "simplytranslate.ducks.party": [
      "google",
    ],
  };

  Future<List<String>> translateSentences(
    List<String> sentences,
    String language,
  ) async {
    List<String> translated = [];
    var mSentences = mergeSentences(sentences);
    for (var ms in mSentences) {
      var s = await translate(
        ms,
        language,
      );
      translated.addAll(s.split("~~~"));
    }
    return translated;
  }

  Future<String> translate(String inputText, String language) async {
    String url =
        'https://${Store.translatorInstanceSetting}/?engine=${Store.translatorEngineSetting}';
    Map<String, String> payload = {
      'from': 'auto',
      'to': languages[language]!,
      'text': inputText
    };
    return workerManager.execute<String>(() async {
      var response = await dio().post(url, data: FormData.fromMap(payload));
      var document = parse(response.data);
      return document.getElementById('output')?.text ?? inputText;
    });
  }

  List<String> extractTextFromDocument(Document doc) {
    List<String> text = [];

    void extractTextFromNode(Node node) {
      if (node.nodeType == Node.TEXT_NODE) {
        text += [(node.text ?? "")];
      } else if (node.nodeType == Node.DOCUMENT_NODE) {
        Document element = node as Document;
        for (var child in element.nodes) {
          extractTextFromNode(child);
        }
      } else if (node.nodeType == Node.ELEMENT_NODE) {
        Element element = node as Element;
        for (var child in element.nodes) {
          extractTextFromNode(child);
        }
      }
    }

    extractTextFromNode(doc);
    text.removeWhere(
      (element) => element.trim().isEmpty,
    );

    return text;
  }

  List<String> mergeSentences(List<String> sentences) {
    List<String> mergedSentences = [];
    String currentMergedSentence = '';

    for (String sentence in sentences) {
      if (currentMergedSentence.length + sentence.length <= 4000) {
        if (currentMergedSentence.isNotEmpty) {
          currentMergedSentence += "~~~";
        }
        currentMergedSentence += sentence;
      } else {
        mergedSentences.add(currentMergedSentence);
        currentMergedSentence = sentence;
      }
    }

    if (currentMergedSentence.isNotEmpty) {
      mergedSentences.add(currentMergedSentence);
    }

    return mergedSentences
      ..removeWhere(
        (element) => element.isEmpty,
      )
      ..map(
        (e) => e + "~~~",
      );
  }

  Future<String> translateParagraph(
    String paragraph,
    String language,
  ) async {
    // if(paragraph.isEmpty)return paragraph;
    Document document = html_parser.parse(paragraph.replaceAll("<", " <").replaceAll(">", "> "));
    var html = document.outerHtml;
    List<String> smallParas = mergeSentences(extractTextFromDocument(document));
    List<String> translatedSmallParas = List.filled(smallParas.length, '');
    for (int i = 0; i < smallParas.length; i++) {
      translatedSmallParas[i] = await translate(smallParas[i], language);
    }
    for (int i = 0; i < translatedSmallParas.length; i++) {
      for (int j = 0; j < translatedSmallParas[i].split("~~~").length; j++) {
        html = html.replaceFirst(
          smallParas[i].split("~~~")[j],
          translatedSmallParas[i].split("~~~")[j],
        );
      }
    }
    return html;
  }
}
