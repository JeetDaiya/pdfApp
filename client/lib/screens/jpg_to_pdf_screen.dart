import 'dart:io';
import 'package:client/theme/gradient.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:dotted_border/dotted_border.dart';
import '../viewmodels/jpg_to_pdf_viewmodel.dart'; // Ensure this path is correct

class JpgToPdfScreen extends StatefulWidget {
  const JpgToPdfScreen({super.key});

  @override
  State<JpgToPdfScreen> createState() => _JpgToPdfScreenState();
}

class _JpgToPdfScreenState extends State<JpgToPdfScreen> {
  final JpgToPdfViewModel _viewModel = JpgToPdfViewModel();

  // 1. Pick Multiple Files
  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg' , 'jpeg'],
      allowMultiple: true, // Crucial for merging!
    );

    if (result != null) {
      // Pass the list of paths to the ViewModel
      List<File> newFiles = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      _viewModel.selectFiles(newFiles);
    }
  }

  // 2. Run Merge
  Future<void> mergePDF() async {
    bool success = await _viewModel.convertToPdf(); // Assumes merge returns Future<bool>

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ PDFs Merged Successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ ${_viewModel.errorMessage ?? 'Merge Failed'}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 3. Save Logic (Optional, if you implemented saveToDevice in MergeViewModel)
  Future<void> saveFile() async {
    await _viewModel.saveToDevice();
  }

  void resetScreen() {
    _viewModel.selectedFiles = [];
    _viewModel.convertedFile = null;
    _viewModel.errorMessage = null;
    FilePicker.platform.clearTemporaryFiles();
    // Force rebuild
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: MyAppGradient.myAppGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const MyAppBar(title: 'Merge PDF'),
        body: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, child) {
            return Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 350,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- FILE LIST (Show selected files) ---
                      if (_viewModel.selectedFiles.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Selected Files (${_viewModel.selectedFiles.length})",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200), // Scrollable list if many files
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _viewModel.selectedFiles.length,
                            itemBuilder: (context, index) {
                              final file = _viewModel.selectedFiles[index];
                              return Card(
                                elevation: 0,
                                color: Colors.blue.shade50,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.image_outlined, color: Colors.red, size: 20),
                                  title: Text(
                                    file.path.split('/').last,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                    onPressed: () => _viewModel.removeFile(index),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // --- DOTTED BORDER (Add Files) ---
                      GestureDetector(
                        onTap: pickImages,
                        child: DottedBorder(
                          color: Colors.black,
                          dashPattern: const [10.0, 5.0],
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(12),
                          strokeWidth: 2,
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey.withOpacity(0.05),
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 40,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _viewModel.selectedFiles.isEmpty
                                      ? "Tap to select Images"
                                      : "Add more images",
                                  style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- ACTIONS ---
                      if (_viewModel.isLoading) ...[
                        const CircularProgressIndicator(),
                      ] else if (_viewModel.selectedFiles.length >= 2) ...[
                        // Merge Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: mergePDF,
                            icon: const Icon(Icons.merge_type),
                            label: const Text('Merge Files'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ] else if (_viewModel.selectedFiles.isNotEmpty) ...[
                        // Hint text if only 1 file is selected
                        const Text(
                          "Select at least 2 files to merge",
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ],

                      // --- SUCCESS STATE ---
                      if (_viewModel.convertedFile != null) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text("✅ Merge Successful!",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: resetScreen,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text("Reset"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => OpenFile.open(_viewModel.convertedFile!.path),
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text("View"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Save Button
                        ElevatedButton.icon(
                          onPressed: saveFile, // Implement save logic in VM if desired
                          icon: const Icon(Icons.download),
                          label: const Text("Save to Device"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],

                      if (_viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            _viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
