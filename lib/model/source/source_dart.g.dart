// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_dart.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExternalSourceAdapter extends TypeAdapter<ExternalSource> {
  @override
  final int typeId = 5;

  @override
  ExternalSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExternalSource(
      name: fields[0] as String,
      homePage: fields[1] as String,
      iconUrl: fields[5] as String,
      category: (fields[2] as List).cast<String>(),
      categories: fields[3] as Categories,
      categoryUrl: fields[4] as String,
      supportsCustomCategory: fields[6] as bool,
      categoryArticles: fields[7] as SourceArticle,
      searchUrl: fields[9] as String,
      searchArticles: fields[10] as SourceArticle,
      article: fields[8] as SourceArticle,
      headers: fields[11] as Headers,
      ads: (fields[12] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExternalSource obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.homePage)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.categories)
      ..writeByte(4)
      ..write(obj.categoryUrl)
      ..writeByte(5)
      ..write(obj.iconUrl)
      ..writeByte(6)
      ..write(obj.supportsCustomCategory)
      ..writeByte(7)
      ..write(obj.categoryArticles)
      ..writeByte(8)
      ..write(obj.article)
      ..writeByte(9)
      ..write(obj.searchUrl)
      ..writeByte(10)
      ..write(obj.searchArticles)
      ..writeByte(11)
      ..write(obj.headers)
      ..writeByte(12)
      ..write(obj.ads);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoriesAdapter extends TypeAdapter<Categories> {
  @override
  final int typeId = 6;

  @override
  Categories read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Categories(
      extractor: fields[0] as String,
      locator: (fields[1] as List).cast<String>(),
      include: fields[2] as Include,
      exclude: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Categories obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.extractor)
      ..writeByte(1)
      ..write(obj.locator)
      ..writeByte(2)
      ..write(obj.include)
      ..writeByte(3)
      ..write(obj.exclude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SourceArticleAdapter extends TypeAdapter<SourceArticle> {
  @override
  final int typeId = 7;

  @override
  SourceArticle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SourceArticle(
      extractor: fields[0] as String,
      locators: fields[1] as Locators,
      timezone: fields[2] as String,
      dateFormat: fields[3] as String,
      modifications: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SourceArticle obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.extractor)
      ..writeByte(1)
      ..write(obj.locators)
      ..writeByte(2)
      ..write(obj.timezone)
      ..writeByte(3)
      ..write(obj.dateFormat)
      ..writeByte(4)
      ..write(obj.modifications);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocatorsAdapter extends TypeAdapter<Locators> {
  @override
  final int typeId = 8;

  @override
  Locators read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Locators(
      container: fields[0] as String,
      title: fields[1] as String,
      content: (fields[9] as List).cast<String>(),
      url: fields[5] as String,
      excerpt: fields[2] as String,
      author: fields[3] as String,
      time: fields[6] as String,
      category: fields[8] as String,
      tags: (fields[7] as List).cast<String>(),
      thumbnail: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Locators obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.container)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.excerpt)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.thumbnail)
      ..writeByte(5)
      ..write(obj.url)
      ..writeByte(6)
      ..write(obj.time)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocatorsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HeadersAdapter extends TypeAdapter<Headers> {
  @override
  final int typeId = 10;

  @override
  Headers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Headers(
      json_: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Headers obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.json_);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeadersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IncludeAdapter extends TypeAdapter<Include> {
  @override
  final int typeId = 9;

  @override
  Include read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Include(
      json_: (fields[0] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Include obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.json_);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncludeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
