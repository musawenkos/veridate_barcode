// lib/services/api/product_validation_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ProductValidationApi {
  // Validate product by barcode
  static Future<Map<String, dynamic>?> validateProduct(String barcode) async {
    final url = Uri.parse("${Config.goUPCApiBaseUrl}/code/$barcode");

    try {
      // Make the API request
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${Config.goUPCApiKey}", // Use your API key from config
          "Content-Type": "application/json",
        },
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Map the product data to a simplified structure
        final productData = {
          "code": data["code"],
          "codeType": data["codeType"],
          "name": data["product"]["name"] ?? "No name found",
          "description": data["product"]["description"] ?? "No description found",
          "region": data["product"]["region"] ?? "Unknown region",
          "imageUrl": data["product"]["imageUrl"],
          "brand": data["product"]["brand"] ?? "No brand found",
          "category": data["product"]["category"] ?? "Uncategorized",
          "categoryPath": data["product"]["categoryPath"] ?? [],
          "ean": data["product"]["ean"]
        };

        return productData;
      } else {
        // Handle non-200 responses
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      // Handle request errors
      print("Exception occurred: $e");
      return null;
    }
  }
}
