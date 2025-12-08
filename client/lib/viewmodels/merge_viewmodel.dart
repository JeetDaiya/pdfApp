import 'dart:io';
import 'package:client/utils/ensure_storage_permission.dart';

import '../services/merge_service.dart';
import 'package:flutter/foundation.dart';

class MergeViewModel extends ChangeNotifier {
  final PdfMergeService _service = PdfMergeService();

  late List<File> selectedFiles;
  File? mergedFile;
  bool isLoading = false;
  String? errorMessage ;


  Future<void>selectFile(List<File> inputFiles) async{
    selectedFiles = inputFiles;
    mergedFile = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }



  Future<void> merge() async{
    if(selectedFiles.isEmpty){
      errorMessage = 'No File Selected';
      notifyListeners();
      return;
    }

    final hasPermission = await StoragePermission.ensureStoragePermission();

    if(!hasPermission){
      errorMessage = 'Storage permission denied';
      notifyListeners();
      return;
    }

    try{
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      mergedFile = await _service.mergePdf(selectedFiles);

      if(mergedFile == null){
        errorMessage = 'Failed to merge PDF';
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
