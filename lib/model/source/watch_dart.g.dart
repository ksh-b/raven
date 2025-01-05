// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_dart.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchImportAdapter extends TypeAdapter<WatchImport> {
  @override
  final int typeId = 16;

  @override
  WatchImport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchImport(
      name: fields[0] as String,
      description: fields[1] as String,
      category: fields[2] as String,
      url: fields[3] as String,
      options: (fields[4] as List).cast<Option>(),
      items: fields[5] as Items?,
    );
  }

  @override
  void write(BinaryWriter writer, WatchImport obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.options)
      ..writeByte(5)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchImportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemsAdapter extends TypeAdapter<Items> {
  @override
  final int typeId = 21;

  @override
  Items read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Items(
      extractor: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String,
      leading: fields[3] as Ing,
      trailing: fields[4] as Ing,
      thumbnail: fields[5] as String,
      notes: (fields[6] as List).cast<String>(),
      url: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Items obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.extractor)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.leading)
      ..writeByte(4)
      ..write(obj.trailing)
      ..writeByte(5)
      ..write(obj.thumbnail)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IngAdapter extends TypeAdapter<Ing> {
  @override
  final int typeId = 19;

  @override
  Ing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ing(
      top: fields[0] as String,
      bottom: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Ing obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.top)
      ..writeByte(1)
      ..write(obj.bottom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OptionAdapter extends TypeAdapter<Option> {
  @override
  final int typeId = 18;

  @override
  Option read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Option(
      name: fields[0] as String,
      description: fields[1] as String,
      optionDefault: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Option obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.optionDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
