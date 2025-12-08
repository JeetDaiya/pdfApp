import 'dart:io';
import 'package:client/utils/download_file.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class PdfMergeService {
  final Dio _dio = Dio();

  Future<File> mergePdf(List<File> files) async {
    _dio.options.connectTimeout = const Duration(minutes: 2);
    _dio.options.receiveTimeout = const Duration(minutes: 2);
    var filePath = files[0].path;
    List<MultipartFile> multipartFiles = [];
    for (var file in files) {
      multipartFiles.add(await MultipartFile.fromFile(file.path));
    }

    FormData formData = FormData.fromMap({
      'files' : multipartFiles,
    });

    final response = await _dio.post(
        'https://pdfapp-xkt4.onrender.com/api/pdf/merge',
      data: formData,
      options: Options(
        responseType: ResponseType.bytes
      )
    );
    final fileName = basenameWithoutExtension(filePath);
    return await DownloadService.downloadFile(fileName, 'merged', response);

  }
}
