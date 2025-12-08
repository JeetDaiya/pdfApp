import 'package:permission_handler/permission_handler.dart';

class StoragePermission{
    static Future<bool>ensureStoragePermission() async{
      final status = await Permission.storage.isGranted;
      if(status) {
        return true;
      } else{
        final result = await Permission.storage.request();
        return result == PermissionStatus.granted;
      }
    }
}