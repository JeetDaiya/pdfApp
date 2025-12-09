import 'package:dio/dio.dart';

class ServerPinger {
  static final _dio = Dio();
  static Future<void> warmUp() async{
    try{
      await _dio.get(
        'https://pdfapp-xkt4.onrender.com/api/ping',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        )
      );
      return;
    }catch(error){
      print('$error');
    }
  }
}