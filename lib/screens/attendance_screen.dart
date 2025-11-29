import 'package:flutter/material.dart';
import 'package:delivery_partner/utils/api_client.dart';
import 'package:delivery_partner/services/attendance_service.dart';
import 'package:delivery_partner/models/attendance.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  static const String routeName = '/attendance';

  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _attendanceStatus = 'Loading...'; // Initial status
  bool _isLoading = true;
  late final ApiClient _apiClient;
  late final AttendanceService _attendanceService;
  List<AttendanceEvent> _attendanceEvents = [];

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _attendanceService = AttendanceService(_apiClient);
    _fetchAttendanceStatus();
  }

  // Utility to show a simple Snackbar
  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  // API Call for Punch action
  Future<void> _punch(String eventType) async {
    setState(() {
      _isLoading = true;
    });
    
    // Capture the date at the moment of the punch operation for consistency
    final punchDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Assume current location is not required for a simple punch
    final response = await _apiClient.punchAttendance(eventType: eventType);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        // After a successful punch, re-fetch the status for the exact date the punch occurred
        _fetchAttendanceStatus(punchDate);
      } else {
        _showSnackbar(response.message ?? 'Punch failed', isError: true);
      }
    }
  }
  
  // API Call to fetch initial attendance status
  Future<void> _fetchAttendanceStatus([String? date]) async {
    setState(() {
      _isLoading = true;
      _attendanceStatus = 'Loading...';
    });

    final dateToFetch = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await _attendanceService.fetchDailyLogs(dateToFetch);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (response.success && response.data != null) {
        String? apiStatus = response.data!.data.status;
        _attendanceEvents = response.data!.data.logs.events ?? []; // Populate the events list

        if (apiStatus == null && _attendanceEvents.isNotEmpty) {
          // If status is null, deduce the current state from the last event type
          String lastEventType = _attendanceEvents.last.type;
          switch (lastEventType) {
            case 'PUNCH_IN':
            case 'BREAK_END':
              apiStatus = 'PUNCHED_IN';
              break;
            case 'BREAK_START':
              apiStatus = 'ON_BREAK';
              break;
            case 'PUNCH_OUT':
              apiStatus = 'PUNCHED_OUT';
              break;
            default:
              // Fallback to the event type itself if it's an unknown type
              apiStatus = lastEventType;
          }
        }

        if (apiStatus != null) {
          // Convert to a more readable format, e.g., 'Punched In'
          String displayStatus = apiStatus.replaceAll('_', ' ').toLowerCase();
          // Capitalize the first letter of each word for display
          _attendanceStatus = displayStatus.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
        } else {
          // No status and no events, assume 'Not Punched'
          _attendanceStatus = 'Not Punched';
        }

        _showSnackbar('Current status loaded: $_attendanceStatus');
      } else {
        // If the daily log fails (e.g., no log for today), assume 'Not Punched'
        _attendanceStatus = 'Not Punched';
        _attendanceEvents = []; // Clear events if status is not available
        _showSnackbar(response.message ?? 'Failed to load status. Assuming Not Punched.', isError: true);
      }
    }
  }

  // Helper method to build an action button
  Widget _buildActionButton({
    required String label,
    required String eventType,
    required bool isEnabled,
    Color color = Colors.blue,
    String? tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Tooltip(
        message: tooltip ?? '',
        child: ElevatedButton(
          onPressed: isEnabled && !_isLoading ? () => _punch(eventType) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? color : Colors.grey,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine button states based on current attendance status
    bool canPunchIn = _attendanceStatus == 'Not Punched' || _attendanceStatus == 'Punched Out';
    bool canBreakStart = _attendanceStatus == 'Punched In';
    bool canBreakEnd = _attendanceStatus == 'On Break';
    // Punch Out is allowed from Punched In or On Break state.
    bool canPunchOut = _attendanceStatus == 'Punched In' || _attendanceStatus == 'On Break'; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Current Status:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _attendanceStatus,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _attendanceStatus == 'Punched In' ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 40),
            if (_isLoading)
              const Center(child: LinearProgressIndicator())
            else
              Column(
                children: <Widget>[
                  // PUNCH_IN Button
                  // PUNCH_IN Button
                  _buildActionButton(
                    label: 'PUNCH IN',
                    eventType: 'PUNCH_IN',
                    isEnabled: canPunchIn,
                    color: Colors.green,
                    tooltip: canPunchIn ? 'Start your working day' : 'You are already punched in or on break',
                  ),
                  // BREAK_START Button
                  _buildActionButton(
                    label: 'START BREAK',
                    eventType: 'BREAK_START',
                    isEnabled: canBreakStart,
                    color: Colors.orange,
                    tooltip: canBreakStart ? 'Start a break' : 'You must be Punched In to start a break',
                  ),
                  // BREAK_END Button
                  _buildActionButton(
                    label: 'END BREAK',
                    eventType: 'BREAK_END',
                    isEnabled: canBreakEnd,
                    color: Colors.deepOrange,
                    tooltip: canBreakEnd ? 'End your current break' : 'You must be On Break to end it',
                  ),
                  // PUNCH_OUT Button
                  _buildActionButton(
                    label: 'PUNCH OUT',
                    eventType: 'PUNCH_OUT',
                    isEnabled: canPunchOut,
                    color: Colors.red,
                    tooltip: canPunchOut ? 'End your working day' : 'You must be Punched In or On Break to punch out',
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Text(
              'Attendance Logs:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _attendanceEvents.isEmpty
                  ? Center(
                      child: Text(
                        'No attendance logs for today.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _attendanceEvents.length,
                      itemBuilder: (context, index) {
                        final event = _attendanceEvents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Icon(
                              event.type.contains('PUNCH_IN')
                                  ? Icons.login
                                  : event.type.contains('PUNCH_OUT')
                                      ? Icons.logout
                                      : Icons.watch_later,
                              color: event.type.contains('PUNCH_IN')
                                  ? Colors.green
                                  : event.type.contains('PUNCH_OUT')
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                            title: Text(
                              '${event.type.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ')} at ${DateFormat('h:mm a').format(DateTime.parse(event.time).toLocal())}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(event.time).toLocal())}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}