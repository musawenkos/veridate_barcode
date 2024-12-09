import 'package:flutter/material.dart';
import 'package:veridate_barcode/screens/spaza_shop.dart';

import '../services/firebase/auth/auth_service.dart';
import 'barcode_history.dart';
import 'barcode_scanner.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
   final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEB218), // Yellow background color
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo and subtitle
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Replace with your logo asset path
                    height: 80,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Access to quality, reimagined",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            // Header image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/header_image.png', // Replace with extracted image path
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Buttons
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildDashboardButton(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: "Scan item",
                  onTap: () {
                    // Navigate to Scan Item Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BarcodeScannerScreen()),
                    );
                  },
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.inventory,
                  label: "My Inventory",
                  onTap: () {
                    // Navigate to My Inventory Screen
                  },
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.location_on,
                  label: "Find My Spaza",
                  onTap: () {
                    // Navigate to Find My Spaza Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SpazaShopScreen()),
                    );
                  },
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.history,
                  label: "Scan History",
                  onTap: () {
                    // Navigate to Scan History Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BarcodeHistoryScreen(userEmail: _authService.getCurrentUser()!.email.toString(),)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFFEEB218)), // Yellow icon
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
