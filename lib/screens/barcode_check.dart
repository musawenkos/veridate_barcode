import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

class BarcodeAnalysisScreen extends StatefulWidget {
  const BarcodeAnalysisScreen({super.key});

  @override
  State<BarcodeAnalysisScreen> createState() => _BarcodeAnalysisScreenState();
}

class _BarcodeAnalysisScreenState extends State<BarcodeAnalysisScreen> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  String _analysisResult = "Scan a barcode to see the result.";

  Future<void> _scanBarcode() async {
    try {
      // Pick an image from the gallery or camera
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) return;

      // Process the image for barcode scanning
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final result = _analyzeBarcode(barcode);
        setState(() {
          _analysisResult = result;
        });
      } else {
        setState(() {
          _analysisResult = "No barcode detected.";
        });
      }
    } catch (e) {
      print("Error scanning barcode: $e");
      setState(() {
        _analysisResult = "Error occurred during scanning.";
      });
    }
  }

  String _analyzeBarcode(Barcode barcode) {
    String analysis = "Type: ${_getBarcodeTypeName(barcode.format)}\n";

    if (barcode.rawValue != null) {
      final data = barcode.rawValue!;
      analysis += "Raw Data: $data\n\n";

      switch (barcode.format) {
        case BarcodeFormat.qrCode:
          analysis += _analyzeQRCode(data);
          break;
        case BarcodeFormat.ean8:
          analysis += _analyzeEAN8(data);
          break;
        case BarcodeFormat.ean13:
          analysis += _analyzeEAN13(data);
          break;
        case BarcodeFormat.code128:
          analysis += _analyzeCode128(data);
          break;
        default:
          analysis += "Analysis not supported for this barcode format.";
      }
    } else {
      analysis += "No raw data found.";
    }

    return analysis;
  }

  String _analyzeQRCode(String data) {
    return "QR Code Analysis:\n- URL/Text: $data\n";
  }

  String _analyzeEAN8(String data) {
    return "EAN-8 Analysis:\n- Encoded Data: $data\n"
        "- GTIN-8: ${data.substring(0, 8)}\n";
  }

  String _analyzeEAN13(String data) {
    final gtin = data.substring(0, 13);
    return "EAN-13 Analysis:\n- Encoded Data: $data\n"
        "- GTIN-13: $gtin\n";
  }

  String _analyzeCode128(String data) {
    String result = "Code 128 Analysis:\n";
    final aiRegex = RegExp(r'\((\d+)\)([^()]+)');
    final matches = aiRegex.allMatches(data);

    for (final match in matches) {
      final ai = match.group(1);
      final value = match.group(2);

      if (ai == "01") {
        result += "- GTIN: $value\n";
      } else if (ai == "17") {
        result += "- Expiry Date: ${_formatExpiryDate(value)}\n";
      } else {
        result += "- AI ($ai): $value\n";
      }
    }

    return result.isEmpty
        ? "No Application Identifiers (AIs) found in Code 128 data."
        : result;
  }

  String _formatExpiryDate(String? expiryData) {
    if (expiryData == null || expiryData.length != 6) return "Invalid Date Format";
    final year = "20${expiryData.substring(0, 2)}";
    final month = expiryData.substring(2, 4);
    final day = expiryData.substring(4, 6);
    return "$year-$month-$day";
  }

  String _getBarcodeTypeName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return "QR Code";
      case BarcodeFormat.ean13:
        return "EAN-13";
      case BarcodeFormat.ean8:
        return "EAN-8";
      case BarcodeFormat.code128:
        return "Code 128";
      default:
        return "Unknown Type";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode Analysis"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _analysisResult,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanBarcode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Scan Barcode",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }
}
