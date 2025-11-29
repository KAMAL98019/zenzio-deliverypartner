import 'package:delivery_partner/map_screen.dart';
import 'package:delivery_partner/screens/complete_delivery_screen.dart'; // This file now contains OtpScreen
import 'package:delivery_partner/screens/delivery_success_screen.dart';
import 'package:delivery_partner/screens/confirm_delivery_screen.dart';
import 'package:delivery_partner/screens/dashboard_screen.dart';
import 'package:delivery_partner/screens/delivery_details_screen.dart';
import 'package:delivery_partner/screens/current_delivery_screen.dart';
import 'package:delivery_partner/screens/delivery_request_screen.dart';
import 'package:delivery_partner/screens/email_verification_sent_screen.dart';
import 'package:delivery_partner/screens/forgot_password_screen.dart';
import 'package:delivery_partner/screens/login_screen.dart';
import 'package:delivery_partner/screens/my_earnings_screen.dart';
import 'package:delivery_partner/screens/problem_with_order_screen.dart';
import 'package:delivery_partner/screens/register_screen.dart';
import 'package:delivery_partner/screens/profile_screen.dart';
import 'package:delivery_partner/screens/order_history_screen.dart';
import 'package:delivery_partner/screens/orders_screen.dart';
import 'package:delivery_partner/screens/attendance_screen.dart'; // New
import 'package:delivery_partner/utils/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenzio Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        EmailVerificationSentScreen.routeName: (context) =>
            const EmailVerificationSentScreen(),
        ConfirmDeliveryScreen.routeName: (context) =>
            const ConfirmDeliveryScreen(),
        DeliveryDetailsScreen.routeName: (context) =>
            const DeliveryDetailsScreen(),
        MyEarningsScreen.routeName: (context) => const MyEarningsScreen(),
        OtpScreen.routeName: (context) => const OtpScreen(),
        DeliverySuccessScreen.routeName: (context) =>
            const DeliverySuccessScreen(),
        ProblemWithOrderScreen.routeName: (context) =>
            const ProblemWithOrderScreen(),
        AttendanceScreen.routeName: (context) =>
            const AttendanceScreen(), // New
        '/orders': (context) => const OrdersScreen(),
        '/order-history': (context) => const OrderHistoryScreen(),
        '/delivery-request': (context) => const DeliveryRequestScreen(),
        '/current-delivery': (context) => const CurrentDeliveryScreen(),
      },
    );
  }
}
