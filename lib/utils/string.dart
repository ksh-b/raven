String getAsSearchQuery(String category) {
  if (category.startsWith("#")) {
    category = category.replaceFirst("#", "");
  }
  return category;
}


String createTag(String inputString) {
  RegExp specialChars = RegExp(r'[^\w\s]', multiLine: true);
  String tag = inputString.replaceAll(specialChars, '').toLowerCase();
  return tag;
}

bool isNumeric(String str) {
  return double.tryParse(str) != null;
}
