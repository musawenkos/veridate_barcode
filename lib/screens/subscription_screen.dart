import 'package:flutter/material.dart';
import 'package:veridate_barcode/screens/subscription_payment.dart';
import '../UI/app_colors.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selectedPlan;
  String? _paymentMethod;
  final TextEditingController _paymentDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryText,
        title: const Text(
          "Subscription",
          style: TextStyle(color: AppColors.background),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose a Subscription Plan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 10),

            // Subscription Plans
            _buildPlanCard("Basic Plan", "R10/month", "Scan expiration dates, verify items, and locate spaza shops", "basic"),
            _buildPlanCard("Business Plan", "R100/month", "Manage inventory and track stock expiration dates", "business"),
            _buildPlanCard("Premium Plan", "Custom Pricing", "Access reports for government entities", "premium"),

            const SizedBox(height: 20),
            const Text(
              "Choose Payment Method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 10),

            // Payment Methods
            _buildPaymentMethod("Card Payment"),
            _buildPaymentMethod("Airtime"),

            const SizedBox(height: 20),

            // Payment Details Input
            if (_paymentMethod != null)
              TextField(
                controller: _paymentDetailsController,
                decoration: InputDecoration(
                  hintText: _paymentMethod == "Card Payment"
                      ? "Enter your card details"
                      : "Enter your mobile number",
                  border: const OutlineInputBorder(),
                ),
              ),

            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: AppColors.primaryText,
                ),
                onPressed: _submitSubscription,
                child: const Text(
                  "Subscribe",
                  style: TextStyle(color: AppColors.background, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, String description, String planId) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planId;
        });
      },
      child: Card(
        color: _selectedPlan == planId ? AppColors.primaryText : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _selectedPlan == planId ? AppColors.background : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                price,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _selectedPlan == planId ? AppColors.background : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedPlan == planId ? AppColors.background : AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String method) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = method;
        });
      },
      child: Card(
        color: _paymentMethod == method ? AppColors.primaryText : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                method,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _paymentMethod == method ? AppColors.background : AppColors.primaryText,
                ),
              ),
              if (_paymentMethod == method)
                const Icon(Icons.check, color: AppColors.background),
            ],
          ),
        ),
      ),
    );
  }

  void _submitSubscription() {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a subscription plan.")),
      );
      return;
    }

    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method.")),
      );
      return;
    }

    if (_paymentDetailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your payment details.")),
      );
      return;
    }

    // Navigate to the payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionPaymentScreen(
          selectedPlan: _selectedPlan!,
          paymentMethod: _paymentMethod!,
          paymentDetails: _paymentDetailsController.text.trim(),
        ),
      ),
    );
  }
}
