import 'package:delivery_partner/screens/confirm_delivery_screen.dart';
import 'package:flutter/material.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  static const String routeName = '/delivery-details';

  const DeliveryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order #ZENZIO12345',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailCard(
              title: 'Customer Information',
              children: [
                _buildDetailRow(label: 'Name', value: 'Jane Doe'),
                _buildDetailRow(label: 'Phone', value: '+1 555-123-4567'),
                _buildDetailRow(label: 'Address', value: '123 Main St, Apt 4B, City, 10001'),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailCard(
              title: 'Order Summary',
              children: [
                _buildDetailRow(label: 'Total Items', value: '3'),
                _buildDetailRow(label: 'Payment Method', value: 'Cash'),
                _buildDetailRow(label: 'Amount to Collect', value: '\$15.50'),
                _buildDetailRow(label: 'Delivery Fee', value: '\$5.00'),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailCard(
              title: 'Items',
              children: [
                _buildItemRow(name: 'Product A', quantity: 1, price: 5.00),
                _buildItemRow(name: 'Product B', quantity: 2, price: 3.50),
                _buildItemRow(name: 'Product C', quantity: 1, price: 3.50),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(ConfirmDeliveryScreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
              ),
              child: const Center(
                child: Text(
                  'Proceed to Delivery Confirmation',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            ...children,
          ],
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
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow({required String name, required int quantity, required double price}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$quantity x $name',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            '\$${(quantity * price).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}