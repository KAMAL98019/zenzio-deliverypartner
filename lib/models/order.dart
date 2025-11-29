class Order {
  final String id;
  final String customerName;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String deliveryAddress;
  final double deliveryLat;
  final double deliveryLng;
  final double amountCollected;
  final double earning;
  final DateTime deliveryDate;
  final String status;

  Order({
    required this.id,
    required this.customerName,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.deliveryAddress,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.amountCollected,
    required this.earning,
    required this.deliveryDate,
    required this.status,
  });
}