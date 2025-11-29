import 'package:delivery_partner/screens/confirm_delivery_screen.dart';
import 'package:delivery_partner/screens/complete_delivery_screen.dart';
import 'package:delivery_partner/screens/problem_with_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_partner/utils/theme.dart';

class CurrentDeliveryScreen extends StatefulWidget {
  const CurrentDeliveryScreen({Key? key}) : super(key: key);

  @override
  State<CurrentDeliveryScreen> createState() => _CurrentDeliveryScreenState();
}

class _CurrentDeliveryScreenState extends State<CurrentDeliveryScreen> {
  final MapController _mapController = MapController();

  // Dummy data for current delivery
  final String _orderId = '#ORD12345';
  final String _restaurantName = 'The Burger Spot';
  final String _restaurantAddress = '123 Main Street, Downtown';
  final String _restaurantPhone = '9876543210';
  final List<Map<String, dynamic>> _orderItems = [
    {'name': 'Classic Burger', 'quantity': 2},
    {'name': 'Fries', 'quantity': 1},
  ];

  // Dummy coordinates for current location, restaurant, and customer
  final LatLng _currentLocation = const LatLng(12.9716, 77.5946); // Current location
  final LatLng _pickupLocation = const LatLng(12.9750, 77.5980); // Restaurant
  final LatLng _deliveryLocation = const LatLng(12.9800, 77.6050); // Customer

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
          'Current Delivery',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _orderId,
                style: const TextStyle(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  (_pickupLocation.latitude + _deliveryLocation.latitude) / 2,
                  (_pickupLocation.longitude + _deliveryLocation.longitude) / 2,
                ),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.delivery_partner',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.circle, color: Colors.blue, size: 20),
                    ),
                    Marker(
                      point: _pickupLocation,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.restaurant, color: Colors.orange, size: 40),
                    ),
                    Marker(
                      point: _deliveryLocation,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.home, color: Colors.red, size: 40),
                    ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_currentLocation, _pickupLocation],
                      color: Colors.blue,
                      strokeWidth: 4.0,
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                    Polyline(
                      points: [_pickupLocation, _deliveryLocation],
                      color: Colors.red,
                      strokeWidth: 4.0,
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PICK UP from $_restaurantName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _restaurantAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.placeholderGrey,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Handle Get Directions
                    },
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text(
                      'Get Directions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Restaurant: $_restaurantPhone',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppTheme.primaryRed),
                      onPressed: () {
                        // Handle call restaurant
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text(
                    'Order Items',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                  children: _orderItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item['quantity']}x ${item['name']}',
                                style: const TextStyle(
                                  color: AppTheme.darkText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Handle Mark as Picked Up
                      Navigator.of(context).pushNamed(OtpScreen.routeName);
                    },
                    child: const Text(
                      'Complete delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(ProblemWithOrderScreen.routeName);
                    },
                    child: const Text(
                      'Problem with Order?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
