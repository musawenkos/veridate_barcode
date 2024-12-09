import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../UI/app_colors.dart';
import 'product_information.dart';

class SpazaScannedItemsScreen extends StatelessWidget {
  final String spazaId;
  final String spazaName;
  final String userEmail;

  const SpazaScannedItemsScreen({
    super.key,
    required this.spazaId,
    required this.spazaName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Items for $spazaName",
          style: const TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.primaryText,
      ),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('spazaId', isEqualTo: spazaId) // Filter by spazaId
            .where('scannedBy', isEqualTo: userEmail) // Filter by user email
            .orderBy('scannedAt', descending: false) // Order by scannedAt
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No scanned items found for $spazaName.",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryText,
                ),
              ),
            );
          }

          final scannedItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: scannedItems.length,
            itemBuilder: (context, index) {
              final item = scannedItems[index].data() as Map<String, dynamic>;
              final scannedAt = item['scannedAt'] != null
                  ? (item['scannedAt'] as Timestamp).toDate()
                  : null;
              final expirationDate = item['expirationDate'] != null
                  ? DateTime.tryParse(item['expirationDate'])
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
                child: ListTile(
                  leading: item['imageUrl'] != null && item['imageUrl'] != ''
                      ? Image.network(
                    item['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(
                    item['name'] ?? "Unknown Item",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['description']?.length > 30
                            ? "${item['description']?.substring(0, 30)}..."
                            : item['description'] ?? "No description available.",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      if (scannedAt != null)
                        Text(
                          "Scanned on: ${DateFormat('MMM dd, yyyy, HH:mm').format(scannedAt)}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
                    // Navigate to Product Information Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductInformationScreen(productData: item),
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
