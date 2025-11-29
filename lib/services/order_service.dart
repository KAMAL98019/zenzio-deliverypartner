import '../models/order.dart';
import '../data/dummy_data.dart';

class OrderService {
  Future<List<Order>> getOrderHistory() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, you would filter by partnerId
    return dummyOrderHistory;
  }
}

final orderService = OrderService();