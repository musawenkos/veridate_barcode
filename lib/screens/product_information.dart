import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veridate_barcode/screens/dashboard.dart';
import '../UI/app_colors.dart';
import 'package:intl/intl.dart';

import 'main_screen.dart';

class ProductInformationScreen extends StatelessWidget {
  final Map<String, dynamic>? productData;

  const ProductInformationScreen({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    DateTime? expirationDate;
    if (productData?['expirationDate'] is Timestamp) {
      expirationDate = (productData?['expirationDate'] as Timestamp).toDate();
    } else if (productData?['expirationDate'] is String) {
      try {
        expirationDate = DateTime.parse(productData?['expirationDate']);
      } catch (isoError) {
        try {
          expirationDate = DateFormat("dd/MM/yyyy").parse(productData?['expirationDate']);
        } catch (customError) {
          print("Error parsing expiration date: $customError");
        }
      }
    }

    // Calculate days left and expiration status
    final daysLeft = expirationDate?.difference(DateTime.now()).inDays;
    final isExpired = daysLeft != null && daysLeft < 0;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryText,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
          ),
          title: const Text(
            'Product Information',
            style: TextStyle(color: AppColors.background),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product Image
                  Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(
                          productData?['imageUrl'] ?? 'https://via.placeholder.com/180',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Product Name
                  Text(
                    productData?['name'] ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Product Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      productData?['description'] ?? 'No description available.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryText,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Additional Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primaryText),
                      const SizedBox(width: 8),
                      Text(
                        'Region: ${productData?['region'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.category, color: AppColors.primaryText),
                      const SizedBox(width: 8),
                      Text(
                        'Category: ${productData?['category'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Spaza Shop Name and Address
                  if (productData?['spazaId'] != null)
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('spazaShops')
                          .doc(productData?['spazaId'])
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text(
                            'Spaza shop information unavailable.',
                            style: TextStyle(color: AppColors.secondaryText),
                          );
                        }

                        final spazaData = snapshot.data!.data() as Map<String, dynamic>;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.store, color: AppColors.primaryText),
                                const SizedBox(width: 8),
                                Text(
                                  'Shop: ${spazaData['name'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_city, color: AppColors.primaryText),
                                const SizedBox(width: 8),
                                Text(
                                  'Address: ${spazaData['address'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 20),

                  // Expiration Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isExpired ? Colors.red : Colors.green,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isExpired
                              ? "Product Expired ${daysLeft!.abs()} ${daysLeft.abs() == 1 ? 'day ago' : 'days ago'}"
                              : "Product Valid for $daysLeft ${daysLeft == 1 ? 'day' : 'days'}",
                          style: TextStyle(
                            color: isExpired ? Colors.red : Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (expirationDate != null)
                          Text(
                            "Expires on: ${DateFormat('MMM dd, yyyy').format(expirationDate)}",
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
