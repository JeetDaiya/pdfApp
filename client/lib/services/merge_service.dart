import 'dart:io';
import 'package:client/utils/download_file.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class PdfMergeService {
  final Dio _dio = Dio();


  Future<File> mergePdf(List<File> files) async {
    var filePath = files[0].path;
    List<MultipartFile> multipartFiles = [];
    for (var file in files) {
      multipartFiles.add(await MultipartFile.fromFile(file.path));
    }

    FormData formData = FormData.fromMap({
      'files' : multipartFiles,
    });

    final response = await _dio.post(
        'http://10.0.2.2:4000/api/pdf/merge',
      data: formData,
      options: Options(
        responseType: ResponseType.bytes
      )
    );
    final fileName = basenameWithoutExtension(filePath);
    return await DownloadService.downloadFile(fileName, 'merged', response);

  }
}
