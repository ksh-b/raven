String getAsSearchQuery(String category) {
  if (category.startsWith("#")) {
    category = category.replaceFirst("#", "");
  }
  return category;
}
