import 'dart:io';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart';


class SaveToDeviceService{
    static Future<bool>saveToDevice(File file)async {
      try{
        final params = SaveFileDialogParams(
          sourceFilePath: file.path,
          fileName: basename(file.path)
        );
        final result = await FlutterFileDialog.saveFile(params : params);
        if(result != null){
          if(await file.exists()){
            await file.delete();
          }
          return true;
        }else {
          return false;
        }
      }catch(error){
        throw Exception('Failed to save file to device $error');
      }
    }
}