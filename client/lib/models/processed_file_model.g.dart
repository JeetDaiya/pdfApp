// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processed_file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProcessedFileAdapter extends TypeAdapter<ProcessedFile> {
  @override
  final typeId = 0;

  @override
  ProcessedFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProcessedFile(
      path: fields[0] as String,
      date: fields[1] as DateTime,
      filename: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProcessedFile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.filename);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessedFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
