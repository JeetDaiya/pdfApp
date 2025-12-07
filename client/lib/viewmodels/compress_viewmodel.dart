import 'dart:io';
import '../services/compress_service.dart';
import 'package:flutter/foundation.dart';

class CompressViewModel extends ChangeNotifier {
  final PdfCompressService _service = PdfCompressService();

  File? selectedFile;
  File? compressedFile;
  bool isLoading = false;
  String? errorMessage ;

  Future<void>selectFile(File inputFile) async{
    selectedFile = inputFile;
    compressedFile = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }


  Future<void> compress() async{
      if(selectedFile == null){
        errorMessage = 'No File Selected';
        notifyListeners();
        return;
      }

      try{
          isLoading = true;
          errorMessage = null;
          notifyListeners();
          compressedFile = await _service.compressPdf(selectedFile!);

          if(compressedFile == null){
            errorMessage = 'Failed to compress PDF';
            notifyListeners();
            return;
          }

          notifyListeners();


      }catch(error){
        errorMessage = 'Failed to compress PDF $error';

      }finally{
        isLoading = false;
        notifyListeners();
      }
  }
}