import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../UI/app_colors.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, required this.userEmail});

  final String userEmail;
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getSpazaName(String spazaId) async {
    try {
      final spazaDoc = await _firestore.collection('spazaShops').doc(spazaId).get();
      if (spazaDoc.exists) {
        return spazaDoc['name'] ?? "Unknown Spaza";
      }
      return "Unknown Spaza";
    } catch (e) {
      print("Error fetching Spaza Shop name: $e");
      return "Unknown Spaza";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory List", style: TextStyle(color: AppColors.background)),
        backgroundColor: AppColors.primaryText,
      ),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('products') // Fetch from the products collection
            .where('scannedBy', isEqualTo: widget.userEmail)
            .orderBy('expirationDate', descending: false) // Sort by expiration date
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No products found in inventory.",
                style: TextStyle(fontSize: 16, color: AppColors.primaryText),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final expirationDate = DateTime.parse(product['expirationDate']);
              final daysLeft = expirationDate.difference(DateTime.now()).inDays;
              final isExpired = daysLeft < 0;
              final spazaId = product['spazaId'] ?? "Unknown";

              return FutureBuilder<String>(
                future: getSpazaName(spazaId),
                builder: (context, spazaSnapshot) {
                  final spazaName = spazaSnapshot.data ?? "Unknown Spaza";

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        product['name'] ?? "Unknown Product",
                        style: TextStyle(
                          color: isExpired ? Colors.red : AppColors.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExpired
                                ? "Expired in ${daysLeft.abs()} day(s) ago"
                                : "Expires in ${daysLeft.abs()} day(s)",
                            style: TextStyle(
                              color: isExpired ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Scanned at: $spazaName",
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.primaryText),
                        onPressed: () => _removeProduct(products[index].id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _removeProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Product removed successfully!",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
