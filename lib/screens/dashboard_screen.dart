import 'package:delivery_partner/utils/theme.dart';
import 'package:delivery_partner/utils/api_client.dart';
import 'package:delivery_partner/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:delivery_partner/screens/my_earnings_screen.dart';
import 'package:delivery_partner/services/order_service.dart';
import 'package:delivery_partner/screens/order_history_screen.dart';
import 'package:delivery_partner/screens/orders_screen.dart'; // Assuming this screen will be created
import 'package:delivery_partner/screens/attendance_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isOnline = false;
  double _todayEarnings = 0.0;
  int _totalDeliveries = 0;
  String _referralCode = 'RAVI1234';
  bool _isLoadingAttendance = false;
  String? _lastCheckIn;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoadingAttendance = true);
    try {
      // Fetch delivery history for stats from dummy service
      final orders = await orderService.getOrderHistory();

      setState(() {
        _totalDeliveries = orders.length;
        _todayEarnings = orders
            .where((order) => order.deliveryDate.day == DateTime.now().day)
            .fold(0.0, (sum, item) => sum + item.earning);
      });

      // Fetch last check-in time
      final attendanceResponse = await _apiClient.getAttendance();

      if (attendanceResponse.success && attendanceResponse.data != null) {
        setState(() {
          _lastCheckIn = attendanceResponse.data!['lastCheckIn'];
          _isOnline = attendanceResponse.data!['isOnline'] ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAttendance = false);
    }
  }

  Future<void> _toggleOnlineStatus() async {
    setState(() => _isLoadingAttendance = true);

    try {
      // Get current location
      final location = await LocationService.getCurrentLocation();

      final response = await _apiClient.updateAttendanceStatus(
        status: !_isOnline ? 'ONLINE' : 'OFFLINE',
        latitude: location?.latitude,
        longitude: location?.longitude,
      );

      if (response.success) {
        setState(() {
          _isOnline = !_isOnline;
          _lastCheckIn = 'Today, ${TimeOfDay.now().format(context)}'; // Update dynamically
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status: ${_isOnline ? 'Online' : 'Offline'}'),
            backgroundColor: _isOnline ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message ?? 'Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoadingAttendance = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Zenzio Partner',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppTheme.primaryRed),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppTheme.darkText),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Online Status Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: true ? AppTheme.primaryGreen : AppTheme.placeholderGrey,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'You are ${true ? 'Online' : 'Offline'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: _isLoadingAttendance ? null : (value) => _toggleOnlineStatus(),
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Earnings Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Earnings",
                      style: TextStyle(
                        color: AppTheme.placeholderGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_todayEarnings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Deliveries Today: $_totalDeliveries',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.darkText,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, MyEarningsScreen.routeName),
                          child: const Text(
                            'View Earnings History',
                            style: TextStyle(
                              color: AppTheme.primaryRed,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Referral Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Referral Code',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _referralCode,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: AppTheme.primaryRed,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const Text(
                      'Share this code with new partners to earn bonuses!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.placeholderGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Attendance Button
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
                  onPressed: () => Navigator.pushNamed(context, AttendanceScreen.routeName),
                  icon: const Icon(Icons.access_time),
                  label: const Text(
                    'Manage Attendance',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              if (_lastCheckIn != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last check-in: $_lastCheckIn',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.placeholderGrey,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Waiting for Assignments
              GestureDetector(
                onTap: () {
                  // Navigate to the delivery request screen
                  Navigator.pushNamed(context, '/delivery-request');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightYellow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.yellowBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: AppTheme.primaryYellow, size: 16),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Waiting for Assignments...',
                          style: TextStyle(
                            color: AppTheme.darkText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.headset), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Ratings'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Earnings'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: AppTheme.primaryRed,
        unselectedItemColor: AppTheme.placeholderGrey,
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/icon.png',
                  height: 100,
                ),
                const SizedBox(height: 8),
                // const Text(
                //   'Zenzio Partner',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: AppTheme.darkText,
                //   ),
                // ),
                const SizedBox(height: 4),
                Text(
                  // 'Partner ID: ${widget.partnerId.substring(0, 8)}...',
                  "",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.placeholderGrey,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppTheme.primaryRed),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, OrdersScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('My Earnings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, MyEarningsScreen.routeName);
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.star),
          //   title: const Text('Customer Reviews'),
          //   onTap: () => Navigator.pop(context),
          // ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Profile & Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.primaryRed),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
