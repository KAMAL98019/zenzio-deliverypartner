import 'package:flutter/material.dart';

class ProblemWithOrderScreen extends StatefulWidget {
  static const String routeName = '/problem-with-order';

  const ProblemWithOrderScreen({super.key});

  @override
  State<ProblemWithOrderScreen> createState() => _ProblemWithOrderScreenState();
}

class _ProblemWithOrderScreenState extends State<ProblemWithOrderScreen> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  final List<String> _reasons = [
    'Customer not available',
    'Incorrect address',
    'Order damaged',
    'Payment issue',
    'Other',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem with Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Report an Issue for Order #ZENZIO12345',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select the reason for the problem:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            ..._reasons.map((reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                )),
            const SizedBox(height: 20),
            TextField(
              controller: _detailsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Additional Details (Optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedReason == null
                  ? null
                  : () {
                      // TODO: Implement logic to submit the problem report
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Problem reported: $_selectedReason. Details: ${_detailsController.text}'),
                        ),
                      );
                      // Navigator.of(context).pop(); // Go back to previous screen
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Submit Report',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}