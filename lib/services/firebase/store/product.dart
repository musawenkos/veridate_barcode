import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../../util.dart';

class ProductFireStore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add product data to Firestore
  Future<Map<String, dynamic>?> addProduct(
      Map<String, dynamic>? productData,
      String scannedBy,
      String spazaId,
      ) async {
    try {
      final newProduct = {
        'name': productData?['name'] ?? 'Unknown Product',
        'description': productData?['description'] ?? 'No description available.',
        'region': productData?['region'] ?? 'Unknown region',
        'imageUrl': productData?['imageUrl'] ?? '',
        'brand': productData?['brand'] ?? 'Unknown brand',
        'category': productData?['category'] ?? 'Uncategorized',
        'code': productData?['code'],
        'expirationDate': productData?['expirationDate'] ?? Utils.getRandomizedDate().toIso8601String(),
        'scannedBy': scannedBy,
        'scannedAt': FieldValue.serverTimestamp(), // Store the scan time
        'spazaId': spazaId, // Link the product to a specific spaza shop
      };

      // Use the barcode as the document ID to prevent duplicates
      await _firestore.collection('products').doc(productData?['code']).set(newProduct);

      // Return the added product
      return {
        ...newProduct,
        'scannedAt': DateTime.now().toIso8601String(), // Approximate scan time for immediate return
      };
    } catch (e) {
      print("Error adding product: $e");
      return null;
    }
  }


  Future<Map<String, dynamic>?> getProductByBarcode(String barcode, {String? spazaId}) async {
    try {
      // Fetch product by barcode
      DocumentSnapshot doc = await _firestore.collection('products').doc(barcode).get();

      if (doc.exists) {
        final productData = doc.data() as Map<String, dynamic>;

        // If a spazaId is provided, check if it matches the product's spazaId
        if (spazaId != null && productData['spazaId'] != spazaId) {
          print("Product found, but it does not belong to the selected spaza shop.");
          return null;
        }

        return productData;
      } else {
        print("No product found with barcode: $barcode");
      }
    } catch (e) {
      print("Error fetching product by barcode: $e");
    }

    return null;
  }


}
