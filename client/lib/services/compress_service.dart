import 'dart:io';
import 'package:client/utils/download_file.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class PdfCompressService{
  final Dio _dio = Dio();

  Future<File> compressPdf(File pdfFile, String compressionLevel) async {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(pdfFile.path),
        'compressionLevel': compressionLevel,
      });

      final response = await _dio.post(
        "http://10.0.2.2:4000/api/pdf/compress",
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }
        ),
      );
        final fileName = basenameWithoutExtension(pdfFile.path);
        return await DownloadService.downloadFile(fileName, 'compressed', response);
  }


}