import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:veridate_barcode/screens/product_information.dart';
import '../UI/app_colors.dart';
import '../services/firebase/auth/auth_service.dart';

class BarcodeHistoryScreen extends StatelessWidget {
  final String userEmail;

  const BarcodeHistoryScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    print(userEmail);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan History",
          style: TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.primaryText, // App primary text color
      ),
      backgroundColor: AppColors.background, // App background color
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('scannedBy', isEqualTo: userEmail) // Filter by authenticated user email
            .orderBy('scannedAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No scanned products found.",
                style: TextStyle(fontSize: 16, color: AppColors.primaryText),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final scannedAt = product['scannedAt'] != null
                  ? (product['scannedAt'] as Timestamp).toDate()
                  : null;
              final expirationDate = product['expirationDate'] != null
                  ? DateTime.tryParse(product['expirationDate'])
                  : null;

              // Check expiration status
              final daysLeft = expirationDate?.difference(DateTime.now()).inDays;
              final isExpired = daysLeft != null && daysLeft < 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: ListTile(
                  leading: product['imageUrl'] != null && product['imageUrl'] != ''
                      ? Image.network(
                    product['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(
                    product['name'] ?? "Unknown Product",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['description']?.length > 30
                            ? "${product['description']?.substring(0, 30)}..." // Shorten description
                            : product['description'] ?? "No description available.",
                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      ),
                      if (scannedAt != null)
                        Text(
                          "Scanned on: ${DateFormat('MMM dd, yyyy, HH:mm').format(scannedAt)}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      if (expirationDate != null)
                        Text(
                          isExpired
                              ? "Expired on: ${DateFormat('MMM dd, yyyy').format(expirationDate)}"
                              : "Expires on: ${DateFormat('MMM dd, yyyy').format(expirationDate)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isExpired ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Handle tap on product (e.g., navigate to product details)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductInformationScreen(productData: product),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
