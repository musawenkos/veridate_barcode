import 'package:flutter/material.dart';
import 'package:veridate_barcode/screens/product_information.dart';

import '../UI/app_colors.dart';
import '../services/api/product_validation_api.dart';
import '../services/firebase/auth/auth_service.dart';
import '../services/firebase/store/product.dart';
import 'dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main_screen.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  final ProductFireStore _productFireStore = ProductFireStore();
  final AuthService _authService = AuthService();

  String? _selectedSpaza; // Holds the selected spaza shop ID

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Enter Barcode Manually",
            style: TextStyle(color: AppColors.background),
          ),
          backgroundColor: AppColors.primaryText,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Spaza Shop:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
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
              const SizedBox(height: 20),
              const Text(
                "Enter Barcode:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter the barcode",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: AppColors.primaryText, // Button background color
                  ),
                  onPressed: () async {
                    final barcode = _barcodeController.text.trim();

                    if (_selectedSpaza == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a spaza shop")),
                      );
                      return;
                    }

                    if (barcode.isNotEmpty) {
                      // Fetch product data from Firestore or API
                      var productData = await _productFireStore.getProductByBarcode(
                        barcode,
                        spazaId: _selectedSpaza,
                      );

                      if (productData != null) {
                        print("Product found in Firestore.");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductInformationScreen(productData: productData),
                          ),
                        );
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
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error fetching product from API.")),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a barcode")),
                      );
                    }
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: AppColors.background, fontSize: 16), // Button text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
