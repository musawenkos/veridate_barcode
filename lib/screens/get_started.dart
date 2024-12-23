// lib/get_started_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veridate_barcode/screens/dashboard.dart';
import 'package:veridate_barcode/screens/main_screen.dart';
import 'package:veridate_barcode/screens/product_information.dart';
import 'package:veridate_barcode/services/firebase/auth/auth_service.dart';
import '../UI/app_colors.dart';
import '../services/firebase/store/product.dart';
import '../services/api/product_validation_api.dart';

class GetStartedScreen extends StatelessWidget {
  final ProductFireStore _productFireStore = ProductFireStore();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Illustration
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 30),

            // App Description
            const Text(
              "Welcome to VeriDate!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            const Text(
              "VeriDate helps you ensure product quality by verifying authenticity and checking expiration dates. Simply scan a barcode to retrieve product information and make safer purchasing decisions.",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            // "Get Started" Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryText, // Black button background
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainScreen()),
                  );




                 /* String barcode = '6001056412919';
                  var productData = await _productFireStore.getProductByBarcode(barcode);
                  if (productData != null) {
                    print("Product found in Firestore.");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductInformationScreen(productData: productData)),
                    );
                  } else {
                    // Product not found, fetch from API
                    print("Product not found in Firestore, fetching from API...");
                    productData = await ProductValidationApi.validateProduct(barcode);

                    if (productData != null) {
                      // Add product to Firestore
                      await _productFireStore.addProduct(productData,_authService.getCurrentUser()!.email.toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductInformationScreen(productData: productData)),
                      );
                    } else {
                      print("Error fetching product from API.");
                    }
                  }*/

                },
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    color: AppColors.background, // Text color matching background
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
