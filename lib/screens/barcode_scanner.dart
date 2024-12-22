import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../UI/app_colors.dart';
import '../screens/maual_barcode_entry.dart';
import '../screens/product_information.dart';
import '../services/api/product_validation_api.dart';
import '../services/firebase/auth/auth_service.dart';
import '../services/firebase/store/product.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductFireStore _productFireStore = ProductFireStore();
  final AuthService _authService = AuthService();

  String? _selectedSpaza;
  bool _isScanning = false;
  bool _showScanner = false;
  String? _barcodeResult;
  String? _barcodeFormat;
  String? _gtin;
  String? _expiryDate;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _startScanning() {
    if (_selectedSpaza == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a spaza shop before scanning.")),
      );
      return;
    }

    setState(() {
      _showScanner = true;
      _barcodeResult = null;
      _barcodeFormat = null;
      _gtin = null;
      _expiryDate = null;
    });
    _scannerController.start();
  }

  String _getBarcodeFormat(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.ean13:
        return "EAN-13";
      case BarcodeFormat.ean8:
        return "EAN-8";
      case BarcodeFormat.code128:
        return "CODE-128";
      case BarcodeFormat.qrCode:
        return "QR Code";
      default:
        return "Unknown Format";
    }
  }

  Map<String, String> _parseGS1Barcode(String data) {
    final Map<String, String> parsedData = {};

    int gtinIndex = data.indexOf("01");
    if (gtinIndex != -1 && gtinIndex + 16 <= data.length) {
      String gtin = data.substring(gtinIndex + 2, gtinIndex + 16);
      if (RegExp(r'^\d{14}$').hasMatch(gtin)) {
        parsedData["GTIN"] = gtin;
      }
    }

    int expiryIndex = data.indexOf("17");
    if (expiryIndex != -1 && expiryIndex + 8 <= data.length) {
      String expiryRaw = data.substring(expiryIndex + 2, expiryIndex + 8);
      if (RegExp(r'^\d{6}$').hasMatch(expiryRaw)) {
        parsedData["Expiry Date"] = _formatExpiryDate(expiryRaw);
      }
    }

    return parsedData;
  }

  String _formatExpiryDate(String expiryData) {
    if (expiryData.length != 6) {
      throw const FormatException('Invalid date format: must be 6 digits');
    }

    final year = "20${expiryData.substring(0, 2)}";
    final month = expiryData.substring(2, 4);
    final day = expiryData.substring(4, 6);
    return "$year-$month-$day";
  }

  void _handleScan(BarcodeCapture capture) async {
    if (_selectedSpaza == null) return;

    final barcode = capture.barcodes.first;
    final String? rawValue = barcode.rawValue;
    if (rawValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Could not read barcode. Please try scanning again.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _showScanner = false;
      _barcodeResult = rawValue;
      _barcodeFormat = _getBarcodeFormat(barcode.format);
      _gtin = null;
      _expiryDate = null;
    });

    // Handle unknown format
    if (_barcodeFormat == "Unknown Format") {
      _scannerController.stop();
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unknown barcode format. Please try a different barcode.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Handle QR Code
    if (_barcodeFormat == "QR Code") {
      if (rawValue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Empty QR code content. Please try a different code.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      _scannerController.stop();
      setState(() => _isScanning = false);
      return;
    }

    // Handle CODE-128
    if (_barcodeFormat == "CODE-128") {
      final parsedData = _parseGS1Barcode(rawValue);
      if (parsedData.isEmpty) {
        _scannerController.stop();
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Could not parse barcode data. Please check the barcode format.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      setState(() {
        _gtin = parsedData["GTIN"];
        _expiryDate = parsedData["Expiry Date"];
      });
    } else if (_barcodeFormat == "EAN-13" || _barcodeFormat == "EAN-8") {
      if (!RegExp(r'^\d+$').hasMatch(rawValue)) {
        _scannerController.stop();
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid EAN format. Please try scanning again.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      setState(() {
        _gtin = rawValue;
      });
    }

    if (_gtin != null) {
      try {
        final productData = await _productFireStore.getProductByBarcode(
          _gtin!,
          spazaId: _selectedSpaza!,
        );

        if (productData != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "This product has already been scanned and exists in the system.",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "New product scanned.",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error checking product: $e",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    _scannerController.stop();
    setState(() => _isScanning = false);
  }

  Future<void> viewProductInformation() async {
    if (_gtin == null) return;

    try {
      final productData = await _productFireStore.getProductByBarcode(
        _gtin!,
        spazaId: _selectedSpaza!,
      );

      if (productData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductInformationScreen(productData: productData),
          ),
        );
      } else {
        final apiData = await ProductValidationApi.validateProduct(_gtin!);
        if (apiData != null) {
          if (_expiryDate != null) {
            apiData["expirationDate"] = _expiryDate;
          }
          final addedProduct = await _productFireStore.addProduct(
            apiData,
            _authService.getCurrentUser()!.email.toString(),
            _selectedSpaza!,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductInformationScreen(productData: addedProduct),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error fetching product information.")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Barcode Scanner',
          style: TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.primaryText,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Spaza Shop Dropdown
                FutureBuilder<QuerySnapshot>(
                  future: _firestore.collection('spazaShops').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text(
                        "No spaza shops available.",
                        style: TextStyle(color: AppColors.primaryText),
                      );
                    }

                    final spazaShops = snapshot.data!.docs;

                    return DropdownButton<String>(
                      value: _selectedSpaza,
                      hint: const Text("Select Spaza Shop"),
                      isExpanded: true,
                      items: spazaShops.map((shop) {
                        return DropdownMenuItem<String>(
                          value: shop.id,
                          child: Text(shop['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSpaza = value;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Scan Button
                if (!_showScanner)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedSpaza != null ? _startScanning : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSpaza != null
                            ? AppColors.primaryText
                            : AppColors.grayLight,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Scan Barcode",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Scanner or Results
                if (_showScanner)
                  SizedBox(
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MobileScanner(
                        controller: _scannerController,
                        onDetect: _handleScan,
                      ),
                    ),
                  )
                else if (_isScanning)
                  const CircularProgressIndicator()
                else if (_barcodeFormat == "QR Code" && _barcodeResult != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "QR Code Scanned:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _barcodeResult!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_gtin != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "GTIN: $_gtin",
                            style: const TextStyle(fontSize: 16, color: AppColors.primaryText),
                          ),
                          if (_expiryDate != null)
                            Text(
                              "Expiry Date: $_expiryDate",
                              style: const TextStyle(fontSize: 16, color: AppColors.primaryText),
                            ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: viewProductInformation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryText,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "View Information",
                              style: TextStyle(
                                color: AppColors.background,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          // Manual Entry Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSpaza != null
                        ? AppColors.primaryText
                        : AppColors.grayLight,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManualEntryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Enter Barcode Manually",
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}