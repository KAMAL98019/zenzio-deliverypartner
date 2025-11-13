import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CurrentDeliveryScreen extends StatefulWidget {
  const CurrentDeliveryScreen({Key? key}) : super(key: key);

  @override
  State<CurrentDeliveryScreen> createState() => _CurrentDeliveryScreenState();
}

class _CurrentDeliveryScreenState extends State<CurrentDeliveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Delivery'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(12.9716, 77.5946), // Default to Bangalore for now
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(12.9716, 77.5946),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
