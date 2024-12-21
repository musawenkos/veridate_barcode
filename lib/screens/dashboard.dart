import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veridate_barcode/screens/inventory_screen.dart';
import 'package:veridate_barcode/screens/spaza_shop.dart';
import 'package:veridate_barcode/test_screen/barcode_scan.dart';
import '../services/firebase/auth/auth_service.dart';
import 'barcode_check.dart';
import 'barcode_history.dart';
import '../UI/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  String? _subscriptionPlan;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionPlan();
  }

  Future<void> _fetchSubscriptionPlan() async {
    final userEmail = _authService.getCurrentUser()?.email;

    if (userEmail != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('subscriptions')
            .where('userEmail', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final data = doc.data();

          setState(() {
            _subscriptionPlan = data['plan'];
          });

          //print("Subscription data: $data");
        } else {
          print("No subscription found for the user.");
          setState(() {
            _subscriptionPlan = null;
          });
        }
      } catch (e) {
        print("Error fetching subscription plan: $e");
      }
    } else {
      print("No user is authenticated.");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _subscriptionPlan == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    style: TextStyle(
                        fontSize: 16, color: AppColors.primaryText),
                  ),
                ],
              ),
            ),
            // Header image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/header_image.png', // Replace with header image path
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
                  label: "Scan Item",
                  onTap: _isFeatureEnabled("Scan Item")
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const BarcodeScan()),
                    );
                  }
                      : null,
                  enabled: _isFeatureEnabled("Scan Item"),
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.inventory,
                  label: "My Inventory",
                  onTap: _isFeatureEnabled("My Inventory")
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          InventoryScreen(
                            userEmail: _authService
                                .getCurrentUser()!
                                .email
                                .toString(),
                          )),
                    );
                  }
                      : null,
                  enabled: _isFeatureEnabled("My Inventory"),
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.location_on,
                  label: "Find My Spaza",
                  onTap: _isFeatureEnabled("Find My Spaza")
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const SpazaShopScreen()),
                    );
                  }
                      : null,
                  enabled: _isFeatureEnabled("Find My Spaza"),
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.history,
                  label: "Scan History",
                  onTap: _isFeatureEnabled("Scan History")
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BarcodeHistoryScreen(
                          userEmail: _authService
                              .getCurrentUser()!
                              .email
                              .toString(),
                        ),
                      ),
                    );
                  }
                      : null,
                  enabled: _isFeatureEnabled("Scan History"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback? onTap,
        required bool enabled}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5, // Dim disabled buttons
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryText, // Black button background
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: AppColors.background), // Yellow icon
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.defaultText, // White text color
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFeatureEnabled(String feature) {
    switch (_subscriptionPlan) {
      case "basic":
        return feature == "Scan Item" ||
            feature == "Find My Spaza" ||
            feature == "Scan History";
      case "business":
        return feature == "Scan Item" ||
            feature == "Find My Spaza" ||
            feature == "Scan History" ||
            feature == "My Inventory";
      case "premium":
        return true; // All features enabled
      default:
        return false; // No plan or unknown plan
    }
  }
}
