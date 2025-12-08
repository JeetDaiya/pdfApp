import 'dart:io';
import 'package:client/utils/save_to_device.dart';
import '../services/compress_service.dart';
import 'package:flutter/foundation.dart';

import '../utils/ensure_storage_permission.dart';

class CompressViewModel extends ChangeNotifier {
  final PdfCompressService _service = PdfCompressService();

  File? selectedFile;
  File? compressedFile;
  bool isLoading = false;
  String? errorMessage ;
  String compressionLevel = 'recommended';


  Future<void>selectFile(File inputFile) async{
    selectedFile = inputFile;
    compressedFile = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }


  Future<bool> compress() async{
      if(selectedFile == null){
        errorMessage = 'No File Selected';
        notifyListeners();
        return false;
      }
      try{
          isLoading = true;
          errorMessage = null;
          notifyListeners();
          compressedFile = await _service.compressPdf(selectedFile!, compressionLevel);

          if (compressedFile == null) {
            errorMessage = 'Failed to compress PDF (Server returned null)';
            return false; // Return failure
          }

          return true;

      }catch(error){
        errorMessage = 'Error: $error';
        return false;
      }finally{
        isLoading = false;
        notifyListeners();
      }
  }

  Future<bool>saveToDevice() async{
    final isSaved = await SaveToDeviceService.saveToDevice(compressedFile!);

    if (isSaved) {
      // Since SaveToDevice deletes the temp file, we should clear
      // compressedFile so the UI doesn't try to "Open" a deleted file.
      compressedFile = null;
      errorMessage = null; // Clear error if any
      notifyListeners();
      return true;
    } else {
      errorMessage = 'Save Cancelled!';
      notifyListeners();
      return false;
    }
  }

}