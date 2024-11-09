import 'package:flutter/material.dart';
import '../UI/app_colors.dart';

class ProductInformationScreen extends StatelessWidget {
  final Map<String, dynamic>? productData;

  ProductInformationScreen({required this.productData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryText,
        elevation: 0,
        title: Text(
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
            ],
          ),
        ),
      ),
    );
  }
}
