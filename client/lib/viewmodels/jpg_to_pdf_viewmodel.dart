import 'dart:io';
import '../services/jpg_to_pdf_service.dart';
import 'package:flutter/foundation.dart';
import '../utils/file_info_storage_service.dart';
import '../utils/save_to_device.dart';

class JpgToPdfViewModel extends ChangeNotifier {
  final JpgToPdfService _service = JpgToPdfService();

  late List<File> selectedFiles = [];
  File? convertedFile;
  bool isLoading = false;
  String? errorMessage ;

  void removeFile(int index){
    selectedFiles.removeAt(index);
    notifyListeners();
  }

  Future<void>selectFiles(List<File> inputFiles) async{
    selectedFiles = inputFiles;
    convertedFile = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }



  Future<bool> convertToPdf() async{
    if(selectedFiles.isEmpty){
      errorMessage = 'No File Selected';
      notifyListeners();
      return false;
    }

    try{
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      convertedFile = await _service.jptToPdf(selectedFiles);

      if(convertedFile == null){
        errorMessage = 'Failed to merge PDF';
        notifyListeners();
        return false;
      }else{
        await FileInfoStorageService.saveFile(convertedFile!.path);
        return true;
      }

    }catch(error){
      errorMessage = 'Failed to compress PDF $error';
      return false;

    }finally{
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool>saveToDevice() async{
    final success = await SaveToDeviceService.saveToDevice(convertedFile!);

    if (success) {
      // Since SaveToDevice deletes the temp file, we should clear
      // compressedFile so the UI doesn't try to "Open" a deleted file.
      convertedFile = null;
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
