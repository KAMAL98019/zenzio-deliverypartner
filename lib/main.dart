import 'package:delivery_partner/map_screen.dart';
import 'package:delivery_partner/screens/dashboard_screen.dart';
import 'package:delivery_partner/screens/forgot_password_screen.dart';
import 'package:delivery_partner/screens/login_screen.dart';
import 'package:delivery_partner/screens/register_screen.dart';
import 'package:delivery_partner/screens/profile_screen.dart';
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
      // home: const LoginScreen(),
      home: const MapScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(partnerId: 'dummy_partner_id'),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
