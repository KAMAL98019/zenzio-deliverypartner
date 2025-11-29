import 'package:flutter/material.dart';
import 'package:delivery_partner/models/order.dart';
import 'package:delivery_partner/services/order_service.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  static const String routeName = '/order-history';
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Order>> _orderHistoryFuture;

  @override
  void initState() {
    super.initState();
    _orderHistoryFuture = orderService.getOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _orderHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No order history found.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Customer',
                          order.customerName,
                        ),
                        _buildDetailRow(
                          'Delivery Date',
                          DateFormat('MMM d, yyyy - h:mm a').format(order.deliveryDate),
                        ),
                        _buildDetailRow(
                          'Status',
                          order.status,
                          color: order.status == 'Completed' ? Colors.green : Colors.orange,
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(
                          'Earning',
                          '₹${order.earning.toStringAsFixed(2)}',
                          isEarning: true,
                        ),
                        _buildDetailRow(
                          'Amount Collected',
                          '₹${order.amountCollected.toStringAsFixed(2)}',
                        ),
                        const Divider(height: 16),
                        _buildAddressRow(
                          Icons.location_on,
                          'Pickup',
                          order.pickupAddress,
                        ),
                        _buildAddressRow(
                          Icons.flag,
                          'Delivery',
                          order.deliveryAddress,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color, bool isEarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isEarning ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String label, String address) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label Address',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(address),
              ],
            ),
          ),
        ],
      ),
    );
  }
}