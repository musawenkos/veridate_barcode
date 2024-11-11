import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFireStore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add product data to Firestore
  Future<void> addProduct(Map<String, dynamic>? productData) async {
    try {
      // Use the barcode as the document ID to prevent duplicates
      await _firestore.collection('products').doc(productData?['code']).set({
        'name': productData?['name'] ?? 'Unknown Product',
        'description': productData?['description'] ?? 'No description available.',
        'region': productData?['region'] ?? 'Unknown region',
        'imageUrl': productData?['imageUrl'] ?? '',
        'brand': productData?['brand'] ?? 'Unknown brand',
        'category': productData?['category'] ?? 'Uncategorized',
        'code': productData?['code'],
        'expirationDate': productData?['expirationDate'] ?? null,
      });
      print("Product added successfully!");
    } catch (e) {
      print("Error adding product: $e");
    }
  }
}
