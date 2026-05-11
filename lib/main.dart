import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const AITextScannerApp());
}

class AITextScannerApp extends StatelessWidget {
  const AITextScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Text Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TextScannerPage(),
    );
  }
}

class TextScannerPage extends StatefulWidget {
  const TextScannerPage({super.key});

  @override
  State<TextScannerPage> createState() => _TextScannerPageState();
}

class _TextScannerPageState extends State<TextScannerPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  File? selectedImage;
  String extractedText = '';
  bool isScanning = false;

  Future<void> scanTextFromCamera() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        selectedImage = File(pickedImage.path);
        extractedText = '';
        isScanning = true;
      });

      final InputImage inputImage = InputImage.fromFilePath(pickedImage.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      setState(() {
        extractedText = recognizedText.text.trim().isEmpty
            ? 'No text detected. Try taking a clearer photo.'
            : recognizedText.text.trim();
        isScanning = false;
      });
    } catch (error) {
      setState(() {
        extractedText = 'Error while scanning text: $error';
        isScanning = false;
      });
    }
  }

  Future<void> scanTextFromGallery() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        selectedImage = File(pickedImage.path);
        extractedText = '';
        isScanning = true;
      });

      final InputImage inputImage = InputImage.fromFilePath(pickedImage.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      setState(() {
        extractedText = recognizedText.text.trim().isEmpty
            ? 'No text detected. Try using a clearer image.'
            : recognizedText.text.trim();
        isScanning = false;
      });
    } catch (error) {
      setState(() {
        extractedText = 'Error while scanning text: $error';
        isScanning = false;
      });
    }
  }

  void copyText() {
    if (extractedText.trim().isEmpty) {
      return;
    }

    Clipboard.setData(ClipboardData(text: extractedText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard'),
      ),
    );
  }

  void clearResult() {
    setState(() {
      selectedImage = null;
      extractedText = '';
      isScanning = false;
    });
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = extractedText.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI Text Scanner'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: Colors.black,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Camera-Based OCR App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Take a photo of text and the AI will extract it automatically.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: selectedImage == null
                          ? const Center(
                              child: Text(
                                'No image selected yet',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isScanning ? null : scanTextFromCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Open Camera'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isScanning ? null : scanTextFromGallery,
                            icon: const Icon(Icons.image),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: hasText ? copyText : null,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Text'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: clearResult,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: isScanning
                          ? const Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Scanning text...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              hasText
                                  ? extractedText
                                  : 'Extracted text will appear here.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color:
                                    hasText ? Colors.white : Colors.white54,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}