import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService{
    static Future<File>downloadFile(String fileName, String operation, Response<dynamic>response) async {
        final directory = await getApplicationDocumentsDirectory();
        final outputFilePath = join(directory.path, '${fileName}_${operation}_${DateTime.now().toIso8601String()}.pdf');
        final File outputFile = File(outputFilePath);
        await outputFile.writeAsBytes(response.data);
        print("✅ File saved to: $outputFilePath");
        return outputFile;
    }
}