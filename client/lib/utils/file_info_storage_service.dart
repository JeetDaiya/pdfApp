import 'package:hive_ce/hive.dart';
import '../models/processed_file_model.dart';
import 'package:path/path.dart' as p;

class FileInfoStorageService {
  static Box<ProcessedFile> getBox() => Hive.box<ProcessedFile>('processedFiles');

  static Future<void> saveFile(String filePath) async{
    final box = getBox();
    final fileEntry = ProcessedFile(
      path: filePath,
      date: DateTime.now(),
      filename: p.basename(filePath),
    );

    await box.add(fileEntry);
  }

  static List<ProcessedFile> getAllFiles(){
    final box = getBox();
    final files = box.values.toList();
    files.sort((a, b) => b.date.compareTo(a.date));
    return files;
  }

  static Future<void> deleteFile(ProcessedFile file) async {
    await file.delete(); // Hive objects know how to delete themselves!
  }
}