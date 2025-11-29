import 'package:flutter/material.dart';
import 'package:delivery_partner/models/profile.dart';
import 'package:delivery_partner/services/profile_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final NotificationSettings settings;

  const NotificationSettingsScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late NotificationSettings _currentSettings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await profileService.updateNotificationSettings(_currentSettings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update settings: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Push Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildToggleTile(
                    title: 'New Delivery Assignments',
                    subtitle: 'Receive real-time alerts for new orders',
                    value: _currentSettings.newDeliveryAssignments,
                    onChanged: (bool newValue) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(newDeliveryAssignments: newValue);
                      });
                    },
                  ),
                  _buildToggleTile(
                    title: 'Order Status Updates',
                    subtitle: 'Get updates when customer marks order as received',
                    value: _currentSettings.orderStatusUpdates,
                    onChanged: (bool newValue) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(orderStatusUpdates: newValue);
                      });
                    },
                  ),
                  _buildToggleTile(
                    title: 'Earnings Updates',
                    subtitle: 'Receive daily and weekly earnings summaries',
                    value: _currentSettings.earningsUpdates,
                    onChanged: (bool newValue) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(earningsUpdates: newValue);
                      });
                    },
                  ),
                  _buildToggleTile(
                    title: 'Promotional Offers',
                    subtitle: 'Get alerts about bonuses and marketing offers',
                    value: _currentSettings.promotionalOffers,
                    onChanged: (bool newValue) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(promotionalOffers: newValue);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SMS Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildToggleTile(
                    title: 'Critical Alerts (e.g., account issues)',
                    subtitle: 'Important notifications about your account',
                    value: _currentSettings.criticalAlerts,
                    onChanged: (bool newValue) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(criticalAlerts: newValue);
                      });
                    },
                  ),
                  _buildToggleTile(
                    title: 'Weekly Earnings Summary',
                    subtitle: 'Receive your earnings report via SMS',
                    value: _currentSettings.weeklyEarningsSummary,
                    onChanged: (bool newValue) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(weeklyEarningsSummary: newValue);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Email Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildToggleTile(
                    title: 'Monthly Earnings Statement',
                    subtitle: 'Detailed monthly financial report',
                    value: _currentSettings.monthlyEarningsStatement,
                    onChanged: (bool newValue) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(monthlyEarningsStatement: newValue);
                      });
                    },
                  ),
                  _buildToggleTile(
                    title: 'Platform Announcements',
                    subtitle: 'Updates about platform changes and improvements',
                    value: _currentSettings.platformAnnouncements,
                    onChanged: (bool newValue) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(platformAnnouncements: newValue);
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}