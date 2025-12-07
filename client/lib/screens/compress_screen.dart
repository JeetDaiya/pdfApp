import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../viewmodels/compress_viewmodel.dart';
import 'package:dotted_border/dotted_border.dart';


class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  final CompressViewModel _viewModel = CompressViewModel();

  Future<void>pickPDF() async {
    setState(() {

    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    setState(() {

    });

    if(result != null){
      await _viewModel.selectFile(File(result.files.single.path!));
    }

    setState(() {

    });
  }

  Future<void>compressPDF() async{
    setState(() {
    });
    await _viewModel.compress();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 245, 245, 245),
              Color.fromARGB(255, 39, 245, 245),
              Color.fromARGB(255, 39, 230, 245),
              Color.fromARGB(255, 39, 210, 245)
            ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('PDF Compressor'),
        ),
        body: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 30),
            decoration:  BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap : pickPDF,
                  child: DottedBorder(
                    color: Colors.black,
                    dashPattern: const [10.0, 5.0],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    strokeWidth: 2,
                    child: Container(
                      width: double.infinity,
                      color : Colors.white.withOpacity(0.3),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _viewModel.selectedFile == null ? Icons.file_upload_outlined : Icons.picture_as_pdf_outlined,
                            color: Colors.blue,
                            size: 50,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _viewModel.selectedFile == null
                                ? "Tap to select a PDF file"
                                : _viewModel.selectedFile!.path.split('/').last,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )

                    ),
                  ),
                ),
                if (_viewModel.isLoading) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ]
                else if (_viewModel.selectedFile != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: compressPDF,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Compress PDF'),
                    ),
                  ),
                ],
                if (_viewModel.compressedFile != null) ...[
                  const SizedBox(height: 10),
                  Text("✅ Saved: ${_viewModel.compressedFile!.path.split('/').last}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.green)),
                  TextButton(
                    onPressed: () => OpenFile.open(_viewModel.compressedFile!.path),
                    child: const Text("Open File"),
                  )
                ],

                if (_viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
