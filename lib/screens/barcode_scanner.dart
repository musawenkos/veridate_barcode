import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veridate_barcode/screens/product_information.dart';
import '../UI/app_colors.dart';
import '../services/firebase/auth/auth_service.dart';
import '../services/firebase/store/product.dart';
import '../services/api/product_validation_api.dart';
import 'barcode_history.dart';
import 'maual_barcode_entry.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final ProductFireStore _productFireStore = ProductFireStore();
  final AuthService _authService = AuthService();

  String? _selectedSpaza;

  void _handleBarcode(BarcodeCapture code) async {
    if (_selectedSpaza == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Spaza Shop before scanning.")),
      );
      return;
    }

    String? barcode = code.barcodes.first.rawValue;
    if (barcode == null) {
      return;
    }

    // Pause scanning to prevent multiple triggers
    _scannerController.stop();

    // Fetch product data from Firestore or API
    var productData = await _productFireStore.getProductByBarcode(barcode,spazaId: _selectedSpaza!);

    if (productData != null) {
      print("Product found in Firestore.");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductInformationScreen(productData: productData),
        ),
      ).then((_) => _scannerController.start()); // Resume scanning when returning
    } else {
      productData = await ProductValidationApi.validateProduct(barcode);

      if (productData != null) {
        // Add product to Firestore
        final addedProduct = await _productFireStore.addProduct(
          productData,
          _authService.getCurrentUser()!.email.toString(),
          _selectedSpaza!,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductInformationScreen(productData: addedProduct),
          ),
        ).then((_) => _scannerController.start()); // Resume scanning when returning
      } else {
        print("Error fetching product from API.");
        _scannerController.start(); // Resume scanning on error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryText, // Use primary text color for the AppBar
        title: const Text(
          "Scan Barcode or QR Code",
          style: TextStyle(color: AppColors.background), // App title color
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.background),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarcodeHistoryScreen(userEmail: _authService.getCurrentUser()!.email.toString(),)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown for selecting Spaza Shop
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('spazaShops').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
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
          ),
          // Scanner View
          Expanded(
            child: MobileScanner(
              onDetect: _handleBarcode,
              controller: _scannerController,
            ),
          ),
          // Manual Entry Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: AppColors.primaryText, // Button background color
                ),
                onPressed: () {
                  // Navigate to a screen for manual entry
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
                    color: AppColors.background, // Button text color
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose(); // Dispose controller when the widget is removed
    super.dispose();
  }
}
