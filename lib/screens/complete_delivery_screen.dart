import 'package:delivery_partner/screens/confirm_delivery_screen.dart';
import 'package:delivery_partner/utils/theme.dart';
import 'package:delivery_partner/widgets/otp_input_field.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = '/complete-delivery';

  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpValid = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    // Dummy verification logic: assume OTP is 1234 for now
    if (_otpController.text == '1234') {
      Navigator.of(context).pushNamed(ConfirmDeliveryScreen.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

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
          'Complete delivery',
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
              'Complete delivery',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '123 Main Street, Downtown', // Dummy address
              style: TextStyle(fontSize: 16, color: AppTheme.placeholderGrey),
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text(
                'Order Items',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('2x Classic Burger', style: TextStyle(color: AppTheme.darkText, fontSize: 14)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('1x Fries', style: TextStyle(color: AppTheme.darkText, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Enter the 4-digit code sent to',
              style: TextStyle(fontSize: 16, color: AppTheme.darkText),
            ),
            const SizedBox(height: 4),
            const Text(
              '+91 XXXXX XXXXX', // Dummy phone number
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
            ),
            const SizedBox(height: 20),
            OtpInputField(
              controller: _otpController,
              length: 4,
              onChanged: (value) {
                setState(() {
                  _isOtpValid = value.length == 4;
                });
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isOtpValid ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}