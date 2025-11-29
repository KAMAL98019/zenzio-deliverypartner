import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Orders'),
      ),
      body: const Center(
        child: Text(
          'No active orders at the moment.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}