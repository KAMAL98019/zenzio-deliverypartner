import 'package:delivery_partner/screens/delivery_success_screen.dart';
import 'package:delivery_partner/screens/problem_with_order_screen.dart';
import 'package:delivery_partner/utils/theme.dart';
import 'package:flutter/material.dart';

class ConfirmDeliveryScreen extends StatelessWidget {
  static const String routeName = '/confirm-delivery';

  const ConfirmDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirm Delivery',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order ID: #ORD12345',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'John Smith',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              '123 Park Avenue, Uptown',
              style: TextStyle(fontSize: 16, color: AppTheme.placeholderGrey),
            ),
            const SizedBox(height: 30),
            const Text(
              'Proof of Delivery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement logic to take photo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  'Take Photo of Delivery',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the final success screen
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    DeliverySuccessScreen.routeName,
                    (route) => route.settings.name == '/dashboard',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Delivery Successful',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Add Delivery Notes (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Left at reception',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}