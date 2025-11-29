import 'package:flutter/material.dart';
import 'package:delivery_partner/models/profile.dart';
import 'package:delivery_partner/services/profile_service.dart';

class WorkScheduleScreen extends StatefulWidget {
  final Profile profile;

  const WorkScheduleScreen({Key? key, required this.profile}) : super(key: key);

  @override
  State<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends State<WorkScheduleScreen> {
  late String _currentWorkType;
  late String _currentWorkShift;
  late TextEditingController _breakStartController;
  late TextEditingController _breakEndController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentWorkType = widget.profile.workType;
    _currentWorkShift = widget.profile.workShift;
    _breakStartController = TextEditingController(text: widget.profile.breakStart);
    _breakEndController = TextEditingController(text: widget.profile.breakEnd);
  }

  @override
  void dispose() {
    _breakStartController.dispose();
    _breakEndController.dispose();
    super.dispose();
  }

  Future<void> _saveBreakTime() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await profileService.updateWorkSchedule(
        workType: _currentWorkType,
        workShift: _currentWorkShift,
        breakStart: _breakStartController.text,
        breakEnd: _breakEndController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Break time updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update break time: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showChangeWorkTypeModal() {
    // Dummy work types for the modal
    final List<Map<String, String>> workTypes = [
      {'type': 'Full-Time', 'shift': '11 AM to 11 PM daily', 'break': 'Lunch break: 3 PM - 5 PM (modifiable)'},
      {'type': 'Ultra Full-Time', 'shift': '6 AM to 11 PM daily', 'break': 'Break: 3 PM - 5 PM (modifiable)'},
      {'type': 'Part-Time Evening', 'shift': '6 PM to 11 PM daily', 'break': ''},
      {'type': 'Short Part-Time', 'shift': '8 AM to 9 AM, 11 AM to 1 PM daily', 'break': ''},
      {'type': 'Weekend Only', 'shift': 'Saturday & Sunday only', 'break': ''},
    ];

    String? selectedType = _currentWorkType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Change Your Work Type',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Current Work Type: $_currentWorkType'),
                  const SizedBox(height: 20),
                  const Text(
                    'Select New Work Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...workTypes.map((typeData) {
                    bool isSelected = selectedType == typeData['type'];
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedType = typeData['type']),
                      child: Card(
                        color: isSelected ? Colors.red.shade50 : null,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: isSelected ? Colors.red : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(typeData['type']!),
                          subtitle: Text('${typeData['shift']}\n${typeData['break']}'),
                          isThreeLine: true,
                          trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.red) : null,
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  const Text(
                    'Set New Break Time (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Start',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'End',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reason for Change (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'e.g., More availability, new commitments',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Your request will be submitted for admin review and approval. You will be notified once approved.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedType != null ? () {
                            // In a real app, this would submit the request to the API
                            // For now, we'll just update the local state and pop
                            final selectedShift = workTypes.firstWhere((element) => element['type'] == selectedType)['shift'] ?? 'N/A';
                            profileService.updateWorkSchedule(
                              workType: selectedType!,
                              workShift: selectedShift,
                              breakStart: widget.profile.breakStart, // Keep old break time for simplicity
                              breakEnd: widget.profile.breakEnd, // Keep old break time for simplicity
                            ).then((_) {
                              Navigator.pop(context, true); // Pop modal with true
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Work type change request submitted!')),
                              );
                            });
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Submit Request', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result == true) {
        // Refresh the screen after a successful update/request
        setState(() {
          _currentWorkType = profileService.currentProfile.workType;
          _currentWorkShift = profileService.currentProfile.workShift;
        });
        Navigator.pop(context, true); // Pop the screen to refresh profile
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Type & Schedule'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Current Work Type',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _currentWorkType,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(_currentWorkShift),
                          const SizedBox(height: 10),
                          Text('Current Break: ${_breakStartController.text} - ${_breakEndController.text}'),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _showChangeWorkTypeModal,
                            child: const Text('Change Work Type'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    'Modify Your Break Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _breakStartController,
                    readOnly: true,
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _breakStartController.text = picked.format(context);
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Break Start Time',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _breakEndController,
                    readOnly: true,
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _breakEndController.text = picked.format(context);
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Break End Time',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Changes will apply from your next shift.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveBreakTime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Break Time',
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
