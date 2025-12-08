import 'dart:io';
import '../services/merge_service.dart';
import 'package:flutter/foundation.dart';

import '../utils/file_info_storage_service.dart';
import '../utils/save_to_device.dart';

class MergeViewModel extends ChangeNotifier {
  final PdfMergeService _service = PdfMergeService();

  late List<File> selectedFiles = [];
  File? mergedFile;
  bool isLoading = false;
  String? errorMessage ;

  void removeFile(int index){
    selectedFiles.removeAt(index);
    notifyListeners();
  }

  Future<void>selectFiles(List<File> inputFiles) async{
    selectedFiles = inputFiles;
    mergedFile = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }



  Future<bool> merge() async{
    if(selectedFiles.isEmpty){
      errorMessage = 'No File Selected';
      notifyListeners();
      return false;
    }

    try{
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      mergedFile = await _service.mergePdf(selectedFiles);

      if(mergedFile == null){
        errorMessage = 'Failed to merge PDF';
        notifyListeners();
        return false;
      }else{
        await FileInfoStorageService.saveFile(mergedFile!.path);
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
    final success = await SaveToDeviceService.saveToDevice(mergedFile!);

    if (success) {
      // Since SaveToDevice deletes the temp file, we should clear
      // compressedFile so the UI doesn't try to "Open" a deleted file.
      mergedFile = null;
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
