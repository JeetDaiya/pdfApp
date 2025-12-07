import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PdfCompressService{
  final Dio _dio = Dio();

  Future<File> compressPdf(File pdfFile) async {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(pdfFile.path),
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
        final directory = await getApplicationDocumentsDirectory();
        final fileName = basenameWithoutExtension(pdfFile.path);
        final outputFilePath = join(directory.path, '${fileName}_compressed.pdf');
        final File outputFile = File(outputFilePath);
        await outputFile.writeAsBytes(response.data);
        print("✅ File saved to: $outputFilePath");
        return outputFile;
  }


}