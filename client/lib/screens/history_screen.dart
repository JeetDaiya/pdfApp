import 'dart:io';
import 'package:client/utils/download_file.dart';
import 'package:client/utils/save_to_device.dart';
import 'package:intl/intl.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '../models/processed_file_model.dart';
import '../theme/gradient.dart';
import '../utils/file_info_storage_service.dart';
import 'package:open_file/open_file.dart';




class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void>saveFile(File file, BuildContext context) async{
    bool success = await SaveToDeviceService.saveToDevice(file);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "✅ File saved to Downloads successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // We check the errorMessage to see if it was a real error or just a cancel
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
               "⚠️ Save cancelled"),
          backgroundColor: Colors.orange

        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: const BoxDecoration(
        gradient: MyAppGradient.myAppGradient,
      ),
      child: Scaffold(
        appBar: const MyAppBar(title: 'My Files'),
        body: ValueListenableBuilder(
            valueListenable: FileInfoStorageService.getBox().listenable(),
            builder: (context, box, _){
              final files = FileInfoStorageService.getAllFiles();
              return files.isEmpty ? const Center(child: Text("No files found")) :
                ListView.builder
                  ( itemCount: files.length,
                    itemBuilder: (context, index)
                    {
                final file = files[index];

                bool isExists;

                // 1. Check if it is a Content URI (Android specific)
                if (file.path.startsWith('content://')) {
                  // We cannot check existence of URIs synchronously without native code.
                  // We assume it exists to prevent showing "Deleted" incorrectly.
                  isExists = true;
                } else {
                  // 2. Standard File Check
                  isExists = File(file.path).existsSync();
                }

                return Container(
                  margin : const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // Leading Icon
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      ),
                      title: Text(
                        file.filename,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Text(
                                DateFormat('MMM dd, hh:mm a').format(file.date),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                              if (!isExists) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  child: const Text("Deleted", style: TextStyle(fontSize: 10, color: Colors.deepOrange)),
                                )
                              ]
                            ],
                          ),
                      ),
                      trailing : PopupMenuButton(
                        icon:  const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (value) async {
                          if(value == 'open'){
                            if(isExists){
                              OpenFile.open(file.path);
                            }else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("File no longer exists on device")),
                              );
                            }
                          } else if (value == 'delete'){
                            _showDeleteConfirm(context, file);
                          }else if(value == 'save'){
                            await saveFile(File(file.path), context);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'open',
                            child: Row(
                              children: [Icon(Icons.visibility, size: 20), SizedBox(width: 8), Text('Open')],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'save',
                            child: Row(
                              children: [Icon(Icons.save_alt_rounded, color: Colors.blue, size: 20), SizedBox(width: 8), Text('Save Locally', style: TextStyle(color: Colors.red))],
                            ),
                          ),

                        ],
                      ),
                      onTap: (){
                        if(isExists){
                          OpenFile.open(file.path);
                        }
                      },
                ));
              });
            }),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, ProcessedFile file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove from History?"),
        content: const Text("This will remove the record from the app. It will NOT delete the actual file from your device storage."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FileInfoStorageService.deleteFile(file); // Hive delete
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
