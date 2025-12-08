import 'dart:io';
import 'package:client/theme/gradient.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../viewmodels/compress_viewmodel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:collection/collection.dart';

typedef CompressionLevelEntry = DropdownMenuEntry<CompressionLevels>;

enum CompressionLevels {
  recommended('Recommended', Icons.recommend),
  low('Low', Icons.compress_outlined),
  extreme('Extreme', Icons.data_saver_on_outlined);

  const CompressionLevels(this.label, this.icon);
  final String label;
  final IconData icon;

  static final List<CompressionLevelEntry> entries =
      UnmodifiableListView<CompressionLevelEntry>(CompressionLevels.values.map(
    (level) => DropdownMenuEntry(value: level, label: level.label),
  ));
}

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  final CompressViewModel _viewModel = CompressViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.compressionLevel = CompressionLevels.recommended.name;
  }

  Future<void> pickPDF() async {
    setState(() {});
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    setState(() {});

    if (result != null) {
      await _viewModel.selectFile(File(result.files.single.path!));
    }

    setState(() {});
  }

  Future<void> compressPDF() async {
    _viewModel.compressedFile = null;
    _viewModel.errorMessage = null;
    bool success = await _viewModel.compress();
  }

  Future<void>saveFile() async{
    bool success = await _viewModel.saveToDevice();
    if (!mounted) return;
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
      bool isCancel = _viewModel.errorMessage == "Save cancelled";
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(isCancel
              ? "⚠️ Save cancelled"
              : "❌ ${_viewModel.errorMessage ?? 'Unknown error'}"),
          backgroundColor: isCancel
              ? Colors.orange
              : Colors.red,
        ),
      );
    }
  }

  void resetScreen() {
    _viewModel.selectedFile = null;
    _viewModel.compressedFile = null;
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
          appBar: const MyAppBar(title: 'Compress PDF'),
          body: AnimatedBuilder(
              animation: _viewModel,
              builder: (context, child) {
                return Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 350,
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 15, bottom: 30),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: pickPDF,
                            child: DottedBorder(
                              color: Colors.black,
                              dashPattern: const [10.0, 5.0],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              strokeWidth: 2,
                              child: Container(
                                  width: double.infinity,
                                  color: Colors.white.withOpacity(0.3),
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _viewModel.selectedFile == null
                                            ? Icons.file_upload_outlined
                                            : Icons.picture_as_pdf_outlined,
                                        color: Colors.blue,
                                        size: 50,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        _viewModel.selectedFile == null
                                            ? "Tap to select a PDF file"
                                            : _viewModel.selectedFile!.path
                                                .split('/')
                                                .last,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          if (_viewModel.isLoading) ...[
                            const SizedBox(height: 30),
                            const CircularProgressIndicator(),
                          ] else if (_viewModel.selectedFile != null) ...[
                            const SizedBox(height: 30),
                            Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 4, bottom: 6),
                                  child: Text(
                                    "Select Compression Level",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                DropdownMenu<CompressionLevels>(
                                  width: 300, // Fixed width fits the layout better than double.infinity
                                  initialSelection: CompressionLevels.recommended,
                                  dropdownMenuEntries: CompressionLevels.entries,

                                  // 1. Style the text shown inside the box
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),

                                  // 2. Icon Styling
                                  leadingIcon: Icon(Icons.tune, color: Colors.blue.shade700),
                                  trailingIcon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),


                                  // 4. Input Box Styling (The main box)
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: Colors.blue.shade50, // Light blue background
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

                                    // Default Border
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none, // Clean look without black lines
                                    ),

                                    // Border when user taps it
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                  ),

                                  // 5. Popup Menu Styling (The list that opens)
                                  menuStyle: MenuStyle(
                                    backgroundColor: const WidgetStatePropertyAll(Colors.white),
                                    elevation: const WidgetStatePropertyAll(4), // Shadow
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    // Limit height so it doesn't cover the whole screen
                                    maximumSize: const WidgetStatePropertyAll(Size.fromHeight(300)),
                                  ),

                                  // 6. Logic
                                  onSelected: (value) {
                                    if (value != null) {
                                      // No setState needed if using ViewModel + AnimatedBuilder
                                      _viewModel.compressionLevel = value.name;
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: compressPDF,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Compress PDF'),
                              ),
                            ),

                          ],
                          if (_viewModel.compressedFile != null) ...[
                            const SizedBox(height: 10),
                            Text(
                                "✅ Saved: ${_viewModel.compressedFile!.path.split('/').last}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.green)),
                            TextButton(
                              onPressed: () =>
                                  OpenFile.open(_viewModel.compressedFile!.path),
                              child: const Text("Open File"),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  onPressed: saveFile,
                                  label: const Text("Save File"),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: resetScreen,
                                  label: const Text("New File"),
                                ),
                              ],
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
                  ),
                );
              })),
    );
  }
}
