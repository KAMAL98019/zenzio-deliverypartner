import 'package:flutter/material.dart';

class MyEarningsScreen extends StatelessWidget {
  static const String routeName = '/my-earnings';

  const MyEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTotalEarningsCard(),
            const SizedBox(height: 20),
            _buildEarningsSummary(),
            const SizedBox(height: 20),
            _buildRecentDeliveriesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalEarningsCard() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade700,
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Total Earnings (This Week)',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '₹150.75',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            _buildSummaryRow(label: 'Deliveries Completed', value: '15'),
            _buildSummaryRow(label: 'Average Earning per Delivery', value: '₹10.05'),
            _buildSummaryRow(label: 'Total Tips', value: '₹25.00'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({required String label, required String value}) {
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

  Widget _buildRecentDeliveriesList() {
    final List<Map<String, dynamic>> deliveries = [
      {'id': '#1001', 'amount': 12.50, 'date': 'Nov 17'},
      {'id': '#1002', 'amount': 8.25, 'date': 'Nov 17'},
      {'id': '#1003', 'amount': 15.00, 'date': 'Nov 16'},
      {'id': '#1004', 'amount': 9.75, 'date': 'Nov 16'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Deliveries',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ...deliveries.map((delivery) => _buildDeliveryItem(
              id: delivery['id'] as String,
              amount: delivery['amount'] as double,
              date: delivery['date'] as String,
            )),
      ],
    );
  }

  Widget _buildDeliveryItem({required String id, required double amount, required String date}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.delivery_dining, color: Colors.green),
        title: Text('Delivery $id'),
        subtitle: Text('Completed on $date'),
        trailing: Text(
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        onTap: () {
          // TODO: Navigate to Delivery Details or specific earning breakdown
        },
      ),
    );
  }
}