import 'package:flutter/material.dart';
import '../UI/app_colors.dart';
import 'main_screen.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String selectedPlan;
  final String paymentMethod;
  final String paymentDetails;

  const SubscriptionPaymentScreen({
    super.key,
    required this.selectedPlan,
    required this.paymentMethod,
    required this.paymentDetails,
  });

  @override
  State<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Process Payment",
          style: TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.primaryText,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Subscription Plan Card
            _buildInfoCard(
              title: "Subscription Plan",
              value: widget.selectedPlan.toUpperCase(),
              icon: Icons.subscriptions,
            ),
            const SizedBox(height: 10),

            // Payment Method Card
            _buildInfoCard(
              title: "Payment Method",
              value: widget.paymentMethod,
              icon: Icons.payment,
            ),
            const SizedBox(height: 10),

            // Payment Details Card
            _buildInfoCard(
              title: "Payment Details",
              value: widget.paymentDetails,
              icon: Icons.credit_card,
            ),
            const Spacer(),

            // Payment Processing or Pay Now Button
            _isProcessing
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: AppColors.primaryText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Pay Now",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required String value, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.grayLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryText, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grayMid,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Assume payment is successful
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment successful!")),
    );

    // Navigate to the MainScreen after success
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
          (route) => false,
    );
  }
}
