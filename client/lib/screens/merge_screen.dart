import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../viewmodels/merge_viewmodel.dart';



class MergeScreen extends StatefulWidget {
  const MergeScreen({super.key});

  @override
  State<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  final MergeViewModel _viewModel = MergeViewModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _viewModel.selectedFiles = [];
  }
  Future<void> pickPDF() async {
    setState(() {});
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _viewModel.selectedFiles.add(File(result.files.single.path!));
      });
    }
    setState(() {});
  }

  Future<void> mergePDF() async {
    setState(() {_viewModel.isLoading = false;});
    await _viewModel.merge();
    setState(() {_viewModel.isLoading = true;});
  }
  @override
  Widget build(BuildContext context) {
    final mergedFile = _viewModel.mergedFile;
    return Scaffold(
      appBar: AppBar(title: const Text("Merge PDFs")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Pick Files Button
            ElevatedButton.icon(
              onPressed: pickPDF,
              icon: const Icon(Icons.upload_file),
              label: const Text("Select PDF"),
            ),

            const SizedBox(height: 16),

            /// List of Selected Files
            Expanded(
              child: ListView.builder(
                itemCount: _viewModel.selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = _viewModel.selectedFiles[index];
                  return ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(file.path.split("/").last),
                  );
                },
              ),
            ),

            /// If loading, show progress
            if (_viewModel.isLoading) const CircularProgressIndicator(),

            const SizedBox(height: 16),

            /// Merge Button (enabled only when >=2 files selected)
            ElevatedButton(
              onPressed: _viewModel.selectedFiles.length >= 2 && !_viewModel.isLoading
                  ? mergePDF
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text("Merge Files"),
            ),

            const SizedBox(height: 10),

            /// Open merged file button
            if (mergedFile != null)
              TextButton.icon(
                onPressed: () => OpenFile.open(mergedFile.path),
                icon: const Icon(Icons.open_in_new),
                label: const Text("Open Merged PDF"),
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

