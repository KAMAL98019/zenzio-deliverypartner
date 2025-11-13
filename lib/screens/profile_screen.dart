import 'package:flutter/material.dart';
import 'package:delivery_partner/utils/api_client.dart'; // Assuming this path
import 'package:shared_preferences/shared_preferences.dart'; // For partnerId
import 'package:delivery_partner/screens/edit_profile_screen.dart';
import 'package:delivery_partner/screens/bank_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _partnerDetails;
  bool _isLoading = true;
  String? _errorMessage;
  String? _partnerId; // To store the partner ID

  @override
  void initState() {
    super.initState();
    _loadPartnerIdAndFetchDetails();
  }

  Future<void> _loadPartnerIdAndFetchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _partnerId = prefs.getString('partnerId'); // Assuming 'partnerId' is stored in SharedPreferences

    if (_partnerId != null) {
      _fetchPartnerDetails();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Partner ID not found. Please log in again.';
      });
    }
  }

  Future<void> _fetchPartnerDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _apiClient.getPartnerDetails(partnerId: _partnerId!);

    if (response.success && response.data != null) {
      setState(() {
        _partnerDetails = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message ?? 'Failed to load profile data.';
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
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.person, size: 60, color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _partnerDetails?['fullName'] ?? 'N/A',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_partnerDetails?['rating']?.toStringAsFixed(1) ?? 'N/A'),
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                if (_partnerDetails != null) {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        partnerDetails: _partnerDetails!,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchPartnerDetails(); // Refresh data if changes were saved
                                  }
                                }
                              },
                              child: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileOption(context, Icons.person, 'Personal Details', () async {
                        if (_partnerDetails != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                partnerDetails: _partnerDetails!,
                              ),
                            ),
                          );
                          if (result == true) {
                            _fetchPartnerDetails(); // Refresh data if changes were saved
                          }
                        }
                      }),
                      _buildProfileOption(context, Icons.work, 'Work Type & Schedule', () {
                        // Navigate to Work Type & Schedule screen
                      }),
                      _buildProfileOption(context, Icons.account_balance, 'Bank Account Details', () async {
                        if (_partnerDetails != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BankDetailsScreen(
                                partnerDetails: _partnerDetails!,
                              ),
                            ),
                          );
                          if (result == true) {
                            _fetchPartnerDetails(); // Refresh data if changes were saved
                          }
                        }
                      }),
                      _buildProfileOption(context, Icons.notifications, 'Notifications', () {
                        // Navigate to Notifications screen
                      }),
                      _buildProfileOption(context, Icons.help, 'Help & Support', () {
                        // Navigate to Help & Support screen
                      }),
                      _buildProfileOption(context, Icons.lock, 'Change Password', () {
                        // Navigate to Change Password screen
                      }),
                      const SizedBox(height: 30),
                      TextButton.icon(
                        onPressed: () {
                          // Handle logout
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