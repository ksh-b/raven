import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

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

  static Map<String, String> languageFlags = {
    "Afrikaans": "\uD83C\uDDE6\uD83C\uDDFF",    // Flag of South Africa
    "Albanian": "\uD83C\uDDEA\uD83C\uDDF8",    // Flag of Albania
    "Amharic": "\uD83C\uDDEA\uD83C\uDDF9",     // Flag of Ethiopia
    "Arabic": "\uD83C\uDDE6\uD83C\uDDEA",      // Flag of Saudi Arabia
    "Armenian": "\uD83C\uDDE6\uD83C\uDDF2",    // Flag of Armenia
    "Assamese": "\uD83C\uDDEE\uD83C\uDDF3",    // Flag of India
    "Aymara": "\uD83C\uDDEB\uD83C\uDDF2",      // Flag of Bolivia
    "Azerbaijani": "\uD83C\uDDEB\uD83C\uDDF7", // Flag of Azerbaijan
    "Bambara": "\uD83C\uDDE7\uD83C\uDDEE",     // Flag of Mali
    "Basque": "\uD83C\uDDEA\uD83C\uDDF8",      // Flag of Spain
    "Belarusian": "\uD83C\uDDEB\uD83C\uDDFE",  // Flag of Belarus
    "Bengali": "\uD83C\uDDEE\uD83C\uDDF1",     // Flag of Bangladesh
    "Bhojpuri": "\uD83C\uDDEE\uD83C\uDDF3",    // Flag of India
    "Bosnian": "\uD83C\uDDEB\uD83C\uDDF7",     // Flag of Bosnia and Herzegovina
    "Bulgarian": "\uD83C\uDDEB\uD83C\uDDEC",   // Flag of Bulgaria
    "Catalan": "\uD83C\uDDEA\uD83C\uDDF8",     // Flag of Spain
    "Cebuano": "\uD83C\uDDEE\uD83C\uDDF9",     // Flag of Philippines
    "Chichewa": "\uD83C\uDDE6\uD83C\uDDFC",    // Flag of Malawi
    "Chinese (Simplified)": "\uD83C\uDDE8\uD83C\uDDF3", // Flag of China
    "Chinese (Traditional)": "\uD83C\uDDE8\uD83C\uDDF3", // Flag of China
    "Corsican": "\uD83C\uDDE8\uD83C\uDDF7",     // Flag of France
    "Croatian": "\uD83C\uDDED\uD83C\uDDF7",    // Flag of Croatia
    "Czech": "\uD83C\uDDE8\uD83C\uDDFF",       // Flag of Czech Republic
    "Danish": "\uD83C\uDDE9\uD83C\uDDF0",       // Flag of Denmark
    "Dhivehi": "\uD83C\uDDE9\uD83C\uDDF3",      // Flag of Maldives
    "Dogri": "\uD83C\uDDEE\uD83C\uDDF3",        // Flag of India
    "Dutch": "\uD83C\uDDEB\uD83C\uDDF7",        // Flag of Netherlands
    "English": "\uD83C\uDDEC\uD83C\uDDE7",      // Flag of United States
    "Esperanto": "\uD83C\uDDEA\uD83C\uDDF9",    // Flag of Esperanto (constructed)
    "Estonian": "\uD83C\uDDEA\uD83C\uDDEA",     // Flag of Estonia
    "Ewe": "\uD83C\uDDEA\uD83C\uDDFC",          // Flag of Togo
    "Filipino": "\uD83C\uDDED\uD83C\uDDF7",     // Flag of Philippines
    "Finnish": "\uD83C\uDDEB\uD83C\uDDEE",      // Flag of Finland
    "French": "\uD83C\uDDEB\uD83C\uDDF7",       // Flag of France
    "Frisian": "\uD83C\uDDEB\uD83C\uDDF7",      // Flag of Netherlands
    "Galician": "\uD83C\uDDEC\uD83C\uDDE6",     // Flag of Spain
    "Georgian": "\uD83C\uDDEC\uD83C\uDDEA",     // Flag of Georgia
    "German": "\uD83C\uDDE9\uD83C\uDDEA",       // Flag of Germany
    "Greek": "\uD83C\uDDEC\uD83C\uDDF7",        // Flag of Greece
    "Guarani": "\uD83C\uDDEC\uD83C\uDDE6",      // Flag of Paraguay
    "Gujarati": "\uD83C\uDDEC\uD83C\uDDF7",     // Flag of India
    "Haitian Creole": "\uD83C\uDDED\uD83C\uDDF9", // Flag of Haiti
    "Hausa": "\uD83C\uDDED\uD83C\uDDF3",        // Flag of Nigeria
    "Hawaiian": "\uD83C\uDDED\uD83C\uDDF0",     // Flag of United States (Hawaii)
    "Hebrew": "\uD83C\uDDED\uD83C\uDDF1",       // Flag of Israel
    "Hindi": "\uD83C\uDDED\uD83C\uDDF7",        // Flag of India
    "Hmong": "\uD83C\uDDED\uD83C\uDDF2",        // Flag of China
    "Hungarian": "\uD83C\uDDED\uD83C\uDDFA",    // Flag of Hungary
    "Icelandic": "\uD83C\uDDEE\uD83C\uDDF8",    // Flag of Iceland
    "Igbo": "\uD83C\uDDEE\uD83C\uDDEC",         // Flag of Nigeria
    "Ilocano": "\uD83C\uDDEE\uD83C\uDDF9",      // Flag of Philippines
    "Indonesian": "\uD83C\uDDEE\uD83C\uDDE9",   // Flag of Indonesia
    "Irish": "\uD83C\uDDEE\uD83C\uDDEA",        // Flag of Ireland
    "Italian": "\uD83C\uDDEE\uD83C\uDDF9",      // Flag of Italy
    "Japanese": "\uD83C\uDDEF\uD83C\uDDF5",     // Flag of Japan
    "Javanese": "\uD83C\uDDEF\uD83C\uDDF5",     // Flag of Indonesia
    "Kannada": "\uD83C\uDDEE\uD83C\uDDF3",      // Flag of India
    "Kazakh": "\uD83C\uDDF0\uD83C\uDDFF",       // Flag of Kazakhstan
    "Khmer": "\uD83C\uDDF0\uD83C\uDDF2",        // Flag of Cambodia
    "Kinyarwanda": "\uD83C\uDDF0\uD83C\uDDEB",  // Flag of Rwanda
    "Konkani": "\uD83C\uDDEE\uD83C\uDDF3",      // Flag of India
    "Korean": "\uD83C\uDDF0\uD83C\uDDF7",       // Flag of South Korea
    "Krio": "\uD83C\uDDF0\uD83C\uDDF3",         // Flag of Sierra Leone
    "Kurdish (Kurmanji)": "\uD83C\uDDF0\uD83C\uDDEA", // Flag of Kurdistan
    "Kurdish (Sorani)": "\uD83C\uDDF0\uD83C\uDDEB",  // Flag of Kurdistan
    "Kyrgyz": "\uD83C\uDDF0\uD83C\uDDFE",       // Flag of Kyrgyzstan
    "Lao": "\uD83C\uDDF1\uD83C\uDDF8",          // Flag of Laos
    "Latin": "\uD83C\uDDF1\uD83C\uDDED",        // Flag of Vatican City (Latin is not spoken natively in any country)
    "Latvian": "\uD83C\uDDF1\uD83C\uDDFB",      // Flag of Latvia
    "Lingala": "\uD83C\uDDF1\uD83C\uDDEC",      // Flag of Democratic Republic of the Congo
    "Lithuanian": "\uD83C\uDDF1\uD83C\uDDF9",   // Flag of Lithuania
    "Luganda": "\uD83C\uDDF1\uD83C\uDDEC",      // Flag of Uganda
    "Luxembourgish": "\uD83C\uDDF1\uD83C\uDDEA", // Flag of Luxembourg
    "Macedonian": "\uD83C\uDDF2\uD83C\uDDF0",  // Flag of North Macedonia
    "Maithili": "\uD83C\uDDF2\uD83C\uDDE6",     // Flag of India
    "Malagasy": "\uD83C\uDDF2\uD83C\uDDEC",     // Flag of Madagascar
    "Malay": "\uD83C\uDDF2\uD83C\uDDFE",        // Flag of Malaysia
    "Malayalam": "\uD83C\uDDF2\uD83C\uDDF5",    // Flag of India
    "Maltese": "\uD83C\uDDF2\uD83C\uDDF9",      // Flag of Malta
    "Maori": "\uD83C\uDDF2\uD83C\uDDFF",        // Flag of New Zealand (Maori is an official language)
    "Marathi": "\uD83C\uDDF2\uD83C\uDDF5",      // Flag of India
    "Meiteilon (Manipuri)": "\uD83C\uDDF2\uD83C\uDDEE", // Flag of India
    "Mizo": "\uD83C\uDDF2\uD83C\uDDFF",         // Flag of India
    "Mongolian": "\uD83C\uDDF2\uD83C\uDDF3",    // Flag of Mongolia
    "Myanmar (Burmese)": "\uD83C\uDDF2\uD83C\uDDF2", // Flag of Myanmar
    "Nepali": "\uD83C\uDDF3\uD83C\uDDF5",      // Flag of Nepal
    "Norwegian": "\uD83C\uDDF3\uD83C\uDDF4",    // Flag of Norway
    "Odia (Oriya)": "\uD83C\uDDF3\uD83C\uDDF4", // Flag of India
    "Oromo": "\uD83C\uDDF4\uD83C\uDDF2",        // Flag of Ethiopia
    "Pashto": "\uD83C\uDDF5\uD83C\uDDF4",       // Flag of Afghanistan
    "Persian": "\uD83C\uDDF5\uD83C\uDDF7",      // Flag of Iran
    "Polish": "\uD83C\uDDF5\uD83C\uDDF1",       // Flag of Poland
    "Portuguese": "\uD83C\uDDF5\uD83C\uDDF9",   // Flag of Portugal
    "Punjabi": "\uD83C\uDDF5\uD83C\uDDF3",      // Flag of Pakistan
    "Quechua": "\uD83C\uDDF5\uD83C\uDDEA",      // Flag of Peru
    "Romanian": "\uD83C\uDDF7\uD83C\uDDF4",     // Flag of Romania
    "Russian": "\uD83C\uDDF7\uD83C\uDDFA",      // Flag of Russia
    "Samoan": "\uD83C\uDDF8\uD83C\uDDF2",       // Flag of Samoa
    "Sanskrit": "\uD83C\uDDF8\uD83C\uDDF3",     // Flag of India
    "Scots Gaelic": "\uD83C\uDDEC\uD83C\uDDE7",  // Flag of United Kingdom (Scotland)
    "Sepedi": "\uD83C\uDDEB\uD83C\uDDEA",       // Flag of South Africa
    "Serbian": "\uD83C\uDDF7\uD83C\uDDF8",      // Flag of Serbia
    "Sesotho": "\uD83C\uDDEB\uD83C\uDDEA",      // Flag of Lesotho
    "Shona": "\uD83C\uDDF8\uD83C\uDDF3",        // Flag of Zimbabwe
    "Sindhi": "\uD83C\uDDF8\uD83C\uDDE6",       // Flag of Pakistan
    "Sinhala": "\uD83C\uDDF1\uD83C\uDDF0",      // Flag of Sri Lanka
    "Slovak": "\uD83C\uDDF8\uD83C\uDDF0",       // Flag of Slovakia
    "Slovenian": "\uD83C\uDDF8\uD83C\uDDF0",    // Flag of Slovenia
    "Somali": "\uD83C\uDDF8\uD83C\uDDF4",       // Flag of Somalia
    "Spanish": "\uD83C\uDDEA\uD83C\uDDF8",      // Flag of Spain
    "Sundanese": "\uD83C\uDDF8\uD83C\uDDE9",    // Flag of Indonesia
    "Swahili": "\uD83C\uDDEA\uD83C\uDDF8",      // Flag of Tanzania
    "Swedish": "\uD83C\uDDF8\uD83C\uDDEA",      // Flag of Sweden
    "Tajik": "\uD83C\uDDF9\uD83C\uDDEF",        // Flag of Tajikistan
    "Tamil": "\uD83C\uDDF9\uD83C\uDDF2",        // Flag of India
    "Tatar": "\uD83C\uDDF9\uD83C\uDDF7",        // Flag of Russia
    "Telugu": "\uD83C\uDDF9\uD83C\uDDF1",       // Flag of India
    "Thai": "\uD83C\uDDF9\uD83C\uDDED",         // Flag of Thailand
    "Tigrinya": "\uD83C\uDDF9\uD83C\uDDF0",     // Flag of Eritrea
    "Tsonga": "\uD83C\uDDF9\uD83C\uDDF4",       // Flag of South Africa
    "Turkish": "\uD83C\uDDF9\uD83C\uDDF7",      // Flag of Turkey
    "Turkmen": "\uD83C\uDDF9\uD83C\uDDF2",      // Flag of Turkmenistan
    "Twi": "\uD83C\uDDF9\uD83C\uDDEA",          // Flag of Ghana
    "Ukrainian": "\uD83C\uDDFA\uD83C\uDDE6",    // Flag of Ukraine
    "Urdu": "\uD83C\uDDFA\uD83C\uDDF8",         // Flag of Pakistan
    "Uyghur": "\uD83C\uDDFA\uD83C\uDDFE",       // Flag of China
    "Uzbek": "\uD83C\uDDFA\uD83C\uDDFF",        // Flag of Uzbekistan
    "Vietnamese": "\uD83C\uDDFB\uD83C\uDDF3",   // Flag of Vietnam
    "Welsh": "\uD83C\uDDFC\uD83C\uDDEA",        // Flag of Wales
    "Xhosa": "\uD83C\uDDFD\uD83C\uDDEA",        // Flag of South Africa
    "Yiddish": "\uD83C\uDDFA\uD83C\uDDF8",      // Flag of Israel
    "Yoruba": "\uD83C\uDDF9\uD83C\uDDF3",       // Flag of Nigeria
    "Zulu": "\uD83C\uDDFF\uD83C\uDDFA"          // Flag of South Africa
  };


  Future<String> translate(String inputText, String language) async {
    if (!languages.containsKey(language)) {
      return inputText;
    }
    String translatedText = "";
    String url = 'https://simplytranslate.org/?engine=google';
    inputText = removeHtmlAttributes(inputText);
    List<String> inputTextParts = splitString(inputText, 500);
    for (String inputTextPart in inputTextParts) {
      Map<String, String> payload = {
        'from': 'auto',
        'to': languages[language]!,
        'text': inputTextPart
      };
      var response = await http.post(Uri.parse(url), body: payload);
      var document = parse(response.body);
      translatedText += document.getElementById('output')?.text ?? "";
    }
    return translatedText;
  }

  List<String> splitString(String text, int wordsPerString) {
    List<String> result = [];
    List<String> words = text.split(' ');
    int start = 0;

    while (start < words.length) {
      int end = start + wordsPerString;
      if (end > words.length) {
        end = words.length;
      }
      result.add(words.sublist(start, end).join(' '));
      start = end;
    }

    return result;
  }

  String removeHtmlAttributes(String htmlString) {
    RegExp exp = RegExp(r'<[^>]+>');
    return htmlString.replaceAllMapped(exp, (match) {
      String tag = match.group(0)!;
      return tag.replaceAll(
          RegExp(r'\s\S+?="[^"]*?"'), ''); // Removes attributes
    });
  }
}
