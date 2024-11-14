import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../UI/app_colors.dart';
import 'package:intl/intl.dart';

class ProductInformationScreen extends StatelessWidget {
  final Map<String, dynamic>? productData;

  ProductInformationScreen({required this.productData});

  @override
  Widget build(BuildContext context) {
    DateTime? expirationDate;
    if (productData?['expirationDate'] is Timestamp) {
      expirationDate = (productData?['expirationDate'] as Timestamp).toDate();
    } else if (productData?['expirationDate'] is String) {
      try {
        // Parsing "dd/MM/yyyy" format
        expirationDate = DateFormat("dd/MM/yyyy").parse(productData?['expirationDate']);
      } catch (e) {
        print("Error parsing expiration date: $e");
      }
    }

    final daysLeft = expirationDate?.difference(DateTime.now()).inDays;
    final isExpired = daysLeft != null && daysLeft < 0;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryText,
        elevation: 0,
        title: const Text(
          'Product Information',
          style: TextStyle(color: AppColors.background),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image with rounded corners and shadow
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 5),
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
              SizedBox(height: 20),

              // Product Name in a modern font style
              Text(
                productData?['name'] ?? 'Unknown Product',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              // Product Description in a card with rounded corners
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  productData?['description'] ?? 'No description available.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 20),

              // Additional Details as icon-text rows
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: AppColors.primaryText),
                  SizedBox(width: 8),
                  Text(
                    'Region: ${productData?['region'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category, color: AppColors.primaryText),
                  SizedBox(width: 8),
                  Text(
                    'Category: ${productData?['category'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Expiration Status Box
              Container(
                padding: EdgeInsets.all(16),
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
                          ? "Product Expired in ${daysLeft} ${daysLeft == 1 ? 'day' : 'days'}"
                          : "Product Valid for ${daysLeft} ${daysLeft == 1 ? 'day' : 'days'}",
                      style: TextStyle(
                        color: isExpired ? Colors.red : Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isExpired && expirationDate != null)
                      Text(
                        "Expires on: ${DateFormat('MMM dd, yyyy').format(expirationDate)}",
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 14,
                        ),
                      ),
                    if (isExpired)
                      Text(
                        "Expires on: ${DateFormat('MMM dd, yyyy').format(expirationDate!)}",
                        style: TextStyle(
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
    );
  }
}
