import 'package:flutter/material.dart';
import 'package:delivery_partner/screens/edit_profile_screen.dart';
import 'package:delivery_partner/screens/bank_details_screen.dart';
import 'package:delivery_partner/models/profile.dart';
import 'package:delivery_partner/services/profile_service.dart';
import 'package:delivery_partner/screens/work_schedule_screen.dart'; // Assuming this screen will be created
import 'package:delivery_partner/screens/notification_settings_screen.dart'; // Assuming this screen will be created
import 'package:delivery_partner/screens/change_password_screen.dart'; // Assuming this screen will be created
import 'package:delivery_partner/utils/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await profileService.getProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.red,
                              backgroundImage: _profile!.profileImageUrl.isNotEmpty
                                  ? NetworkImage(_profile!.profileImageUrl)
                                  : null,
                              child: _profile!.profileImageUrl.isEmpty
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _profile!.fullName,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_profile!.rating.toStringAsFixed(1)),
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      profile: _profile!,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _fetchProfile(); // Refresh data if changes were saved
                                }
                              },
                              child: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileOption(context, Icons.person, 'Personal Details', () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              profile: _profile!,
                            ),
                          ),
                        );
                        if (result == true) {
                          _fetchProfile(); // Refresh data if changes were saved
                        }
                      }),
                      _buildProfileOption(context, Icons.work, 'Work Type & Schedule', () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkScheduleScreen(
                              profile: _profile!,
                            ),
                          ),
                        );
                        if (result == true) {
                          _fetchProfile(); // Refresh data if changes were saved
                        }
                      }),
                      _buildProfileOption(context, Icons.account_balance, 'Bank Account Details', () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BankDetailsScreen(
                              bankDetails: _profile!.bankDetails,
                            ),
                          ),
                        );
                        if (result == true) {
                          _fetchProfile(); // Refresh data if changes were saved
                        }
                      }),
                      _buildProfileOption(context, Icons.notifications, 'Notifications', () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationSettingsScreen(
                              settings: _profile!.notificationSettings,
                            ),
                          ),
                        );
                        if (result == true) {
                          _fetchProfile(); // Refresh data if changes were saved
                        }
                      }),
                      _buildProfileOption(context, Icons.help, 'Help & Support', () {
                        // Navigate to Help & Support screen
                      }),
                      _buildProfileOption(context, Icons.lock, 'Change Password', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
                      TextButton.icon(
                        onPressed: () async {
                          await TokenStorage.deleteTokens();
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.remove('partnerId');
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}