import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../viewmodels/compress_viewmodel.dart';



class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  final CompressViewModel _viewModel = CompressViewModel();

  Future<void>pickPDF() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if(result != null){
      await _viewModel.selectFile(File(result.files.single.path!));
    }
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
              Color.fromARGB(255, 39, 245, 245),
              Color.fromARGB(255, 39, 238, 245),
              Color.fromARGB(255, 39, 224, 245)
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
        body: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, child){
            return Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom:
                )
              ),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(onPressed: pickPDF, child: const Text('📄 Select PDF')),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _viewModel.isLoading? null : compressPDF, child: const Text('Compress PDF')),

                      if(_viewModel.isLoading)...[
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      ],

                      if (_viewModel.errorMessage != null)
                        Text(
                          _viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),

                      if (_viewModel.compressedFile != null) ...[
                        const SizedBox(height: 20),
                        Text("✅ Saved: ${_viewModel.compressedFile!.path}"),
                        ElevatedButton(
                          onPressed: () => OpenFile.open(_viewModel.compressedFile!.path),
                          child: const Text("📂 Open File"),
                        ),
                      ],
                    ],
                  )
              ),
            );
          },
        )
      ),
    );
  }
}
