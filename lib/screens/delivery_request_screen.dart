import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_partner/utils/theme.dart';

class DeliveryRequestScreen extends StatefulWidget {
  const DeliveryRequestScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryRequestScreen> createState() => _DeliveryRequestScreenState();
}

class _DeliveryRequestScreenState extends State<DeliveryRequestScreen> {
  final MapController _mapController = MapController();

  // Dummy data for a delivery request
  final String _restaurantName = 'Burger Palace';
  final String _restaurantAddress = '123 Main St, Downtown';
  final String _customerAddress = '456 Park Avenue, Uptown';
  final double _estimatedDistance = 5.2;
  final int _estimatedTime = 25;
  final double _potentialEarning = 120.0;

  final LatLng _restaurantLocation = const LatLng(12.9716, 77.5946);
  final LatLng _customerLocation = const LatLng(12.9816, 77.6046);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: AppTheme.primaryYellow,
              child: const Text(
                'NEW DELIVERY REQUEST!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
      
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _restaurantName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
      
                      const SizedBox(height: 8),
      
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.placeholderGrey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _restaurantAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.placeholderGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
      
                      const SizedBox(height: 4),
      
                      Row(
                        children: [
                          const Icon(
                            Icons.person_pin_circle,
                            color: AppTheme.placeholderGrey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Customer: $_customerAddress',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.placeholderGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
      
                      const SizedBox(height: 16),
      
                      /// -------------------------
                      /// FIXED OVERFLOW ROW HERE
                      /// -------------------------
                      Row(
                        children: [
                          const Icon(
                            Icons.near_me,
                            color: AppTheme.primaryRed,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
      
                          Expanded(
                            child: Text(
                              'Estimated Distance: ${_estimatedDistance.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.darkText,
                              ),
                            ),
                          ),
      
                          const SizedBox(width: 12),
      
                          const Icon(
                            Icons.timer,
                            color: AppTheme.primaryRed,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
      
                          Expanded(
                            child: Text(
                              'Estimated Time: $_estimatedTime min',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
      
                      const SizedBox(height: 16),
      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wallet_travel,
                              color: AppTheme.primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Potential Earning: ₹${_potentialEarning.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
      
                      const SizedBox(height: 16),
      
                      SizedBox(
                        height: 200,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              (_restaurantLocation.latitude +
                                      _customerLocation.latitude) /
                                  2,
                              (_restaurantLocation.longitude +
                                      _customerLocation.longitude) /
                                  2,
                            ),
                            initialZoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                              userAgentPackageName:
                                  'com.example.delivery_partner',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _restaurantLocation,
                                  width: 80,
                                  height: 80,
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                                Marker(
                                  point: _customerLocation,
                                  width: 80,
                                  height: 80,
                                  child: const Icon(
                                    Icons.home,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: [
                                    _restaurantLocation,
                                    _customerLocation,
                                  ],
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
      
                      const SizedBox(height: 16),
      
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryRed,
                                  width: 2,
                                ),
                              ),
                              child: const Text(
                                '00:15',
                                style: TextStyle(
                                  color: AppTheme.primaryRed,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Accept in',
                              style: TextStyle(
                                color: AppTheme.placeholderGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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
                            Navigator.of(context).pushReplacementNamed('/current-delivery');
                          },
                          child: const Text(
                            'Accept Order',
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
                          onPressed: () {},
                          child: const Text(
                            'Reject Order',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
