import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../UI/app_colors.dart';
import '../screens/maual_barcode_entry.dart';
import '../screens/product_information.dart';
import '../services/api/product_validation_api.dart';
import '../services/firebase/auth/auth_service.dart';
import '../services/firebase/store/product.dart';

class BarcodeScan extends StatefulWidget {
  const BarcodeScan({super.key});

  @override
  State<BarcodeScan> createState() => _BarcodeScanState();
}

class _BarcodeScanState extends State<BarcodeScan> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductFireStore _productFireStore = ProductFireStore();
  final AuthService _authService = AuthService();

  String? _selectedSpaza;
  bool _isScanning = false;
  String? _barcodeResult;
  String? _barcodeFormat;
  String? _gtin; // Extracted GTIN
  String? _expiryDate; // Extracted Expiry Date

  Future<void> _handleBarcode() async {
    if (_selectedSpaza == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a spaza shop before scanning.")),
      );
      return;
    }

    try {
      setState(() {
        _isScanning = true;
        _barcodeResult = null;
        _barcodeFormat = null;
        _gtin = null;
        _expiryDate = null;
      });

      String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        "#FF6666",
        "Cancel",
        true,
        ScanMode.DEFAULT,
      );

      setState(() {
        _isScanning = false;
        if (barcodeScanResult != "-1") {
          _barcodeResult = barcodeScanResult;
          _barcodeFormat = identifyBarcodeFormat(barcodeScanResult);

          if (_barcodeFormat == "EAN-13" || _barcodeFormat == "EAN-8" || _barcodeFormat == "CODE-128") {
            final parsedData = parseGS1Barcode(barcodeScanResult);
            _gtin = parsedData["GTIN"];
            _expiryDate = parsedData["Expiry Date"];
          }
        }
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      print("Error occurred while scanning: $e");
    }
  }

  String identifyBarcodeFormat(String data) {
    if (RegExp(r'^\d{13}$').hasMatch(data)) {
      return "EAN-13";
    } else if (RegExp(r'^\d{8}$').hasMatch(data)) {
      return "EAN-8";
    } else if (data.contains("01") || data.contains("17")) {
      return "CODE-128";
    } else if (data.startsWith("http://") || data.startsWith("https://")) {
      return "QR Code";
    } else {
      return "Unknown Format";
    }
  }

  Map<String, String> parseGS1Barcode(String data) {
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
        parsedData["Expiry Date"] = formatExpiryDate(expiryRaw);
      }
    }

    return parsedData;
  }

  String formatExpiryDate(String expiryData) {
    if (expiryData.length != 6) {
      throw const FormatException('Invalid date format: must be 6 digits');
    }

    final year = "20${expiryData.substring(0, 2)}";
    final month = expiryData.substring(2, 4);
    final day = expiryData.substring(4, 6);
    return "$year-$month-$day";
  }

  Future<void> viewProductInformation() async {
    if (_gtin == null) return;

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
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.white,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductInformationScreen(productData: productData),
          ),
        );
      } else {
        final apiData = await ProductValidationApi.validateProduct(_gtin!);
        if (apiData != null) {
          apiData["expirationDate"] = _expiryDate;
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

                _isScanning
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedSpaza != null ? _handleBarcode : null,
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

                if (_barcodeFormat == "QR Code")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "QR Code Content: $_barcodeResult",
                        style: const TextStyle(fontSize: 16, color: AppColors.primaryText),
                      ),
                    ],
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
