import 'package:delivery_partner/services/profile_service.dart';
import 'package:flutter/material.dart';

class DeliverySuccessScreen extends StatefulWidget {
  static const String routeName = '/delivery-success';

  const DeliverySuccessScreen({super.key});

  @override
  State<DeliverySuccessScreen> createState() => _DeliverySuccessScreenState();
}

class _DeliverySuccessScreenState extends State<DeliverySuccessScreen> {
  String? _partnerId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartnerId();
  }

  Future<void> _loadPartnerId() async {
    // Simulate getting partnerId from a service/storage
    final profile = await profileService.getProfile();
    setState(() {
      _partnerId = profile.id;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Complete'),
        automaticallyImplyLeading: false, // Hide back button
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 100,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Delivery Successful!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'You have successfully completed the delivery for Order #ZENZIO12345. Partner ID: $_partnerId',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildDetailRow(label: 'Amount Collected', value: '\$15.50 (Cash)'),
                            _buildDetailRow(label: 'Your Earning', value: '\$10.50'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/dashboard',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Back to Dashboard',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}