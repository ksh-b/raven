// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 1;

  @override
  Article read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Article(
      publisher: fields[1] as String,
      title: fields[2] as String,
      content: fields[3] as String,
      excerpt: fields[4] as String,
      author: fields[5] as String,
      url: fields[6] as String,
      thumbnail: fields[7] as String,
      category: fields[8] as String,
      tags: (fields[9] as List).cast<String>(),
      publishedAt: fields[10] as int,
    )..metadata = (fields[11] as Map).cast<String, String>();
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(11)
      ..writeByte(1)
      ..write(obj.publisher)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.excerpt)
      ..writeByte(5)
      ..write(obj.author)
      ..writeByte(6)
      ..write(obj.url)
      ..writeByte(7)
      ..write(obj.thumbnail)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.publishedAt)
      ..writeByte(11)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
      publisher: json['publisher'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String,
      author: json['author'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      publishedAt: (json['publishedAt'] as num).toInt(),
    )..metadata = Map<String, String>.from(json['metadata'] as Map);

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'publisher': instance.publisher,
      'title': instance.title,
      'content': instance.content,
      'excerpt': instance.excerpt,
      'author': instance.author,
      'url': instance.url,
      'thumbnail': instance.thumbnail,
      'category': instance.category,
      'tags': instance.tags,
      'publishedAt': instance.publishedAt,
      'metadata': instance.metadata,
    };
