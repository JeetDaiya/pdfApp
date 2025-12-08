import 'package:hive_ce/hive.dart';

part 'processed_file_model.g.dart';
@HiveType(typeId: 0)
class ProcessedFile extends HiveObject{
  @HiveField(0)
  late final String path;

  @HiveField(1)
  late final DateTime date;

  @HiveField(2)
  late final String filename;

  ProcessedFile({
    required this.path,
    required this.date,
    required this.filename,
  });


}