import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veridate_barcode/screens/spaza_scanned_items.dart';

import '../UI/app_colors.dart';

class SpazaShopScreen extends StatefulWidget {
  const SpazaShopScreen({super.key});

  @override
  State<SpazaShopScreen> createState() => _SpazaShopScreenState();
}

class _SpazaShopScreenState extends State<SpazaShopScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final List<String> _existingShops = [];
  String? _selectedShop;

  @override
  void initState() {
    super.initState();
    _fetchExistingShops();
  }

  Future<void> _fetchExistingShops() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('spazaShops').get();
    setState(() {
      _existingShops.addAll(querySnapshot.docs.map((doc) => doc['name'] as String));
    });
  }

  Future<void> _addSpazaShop() async {
    final shopName = _shopNameController.text.trim();
    final address = _addressController.text.trim();

    if (shopName.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final createdBy = user?.email ?? "Unknown User";
      await FirebaseFirestore.instance.collection('spazaShops').add({
        'name': shopName,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy, // Replace with actual user email
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Spaza shop added successfully!")),
      );

      _shopNameController.clear();
      _addressController.clear();
      _fetchExistingShops(); // Refresh the list
    } catch (e) {
      print("Error adding spaza shop: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add spaza shop.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spaza Shops",style: TextStyle(color: AppColors.defaultText),),
        backgroundColor: AppColors.primaryText,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Autocomplete or Add Spaza Shop
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _existingShops.where((shop) =>
                    shop.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                setState(() {
                  _selectedShop = selection;
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: _shopNameController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: "Search or Add Spaza Shop",
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryText,
              ),
              onPressed: _addSpazaShop,
              child: const Text(
                "Add Spaza Shop",
                style: TextStyle(color: AppColors.background),
              ),
            ),
            const SizedBox(height: 24),
            // List of Spaza Shops
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('spazaShops').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No spaza shops found."));
                  }

                  final spazaShops = snapshot.data!.docs;
                  final user = FirebaseAuth.instance.currentUser;

                  return ListView.builder(
                    itemCount: spazaShops.length,
                    itemBuilder: (context, index) {
                      final shop = spazaShops[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(shop['name']),
                          subtitle: Text(shop['address']),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpazaScannedItemsScreen(
                                  spazaId: spazaShops[index].id,
                                  spazaName: shop['name'],
                                  userEmail: user!.email.toString(), // Pass the authenticated user email
                                ),
                              ),
                            );
                          },
                        ),

                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
