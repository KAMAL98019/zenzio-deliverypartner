import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryRequestScreen extends StatefulWidget {
  const DeliveryRequestScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryRequestScreen> createState() => _DeliveryRequestScreenState();
}

class _DeliveryRequestScreenState extends State<DeliveryRequestScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(12.9716, 77.5946); // Default to Bangalore

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Request'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 13.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('deliveryLocation'),
            position: _center,
            infoWindow: const InfoWindow(title: 'Delivery Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        },
      ),
    );
  }
}
