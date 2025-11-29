import 'package:flutter/material.dart';
import 'package:delivery_partner/models/profile.dart';
import 'package:delivery_partner/services/profile_service.dart';

class BankDetailsScreen extends StatefulWidget {
  final BankDetails bankDetails;

  const BankDetailsScreen({Key? key, required this.bankDetails}) : super(key: key);

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _bankAccountNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _confirmAccountNumberController;
  late TextEditingController _ifscCodeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bankAccountNameController = TextEditingController(text: widget.bankDetails.bankName);
    _accountNumberController = TextEditingController(text: widget.bankDetails.accountNumber);
    _confirmAccountNumberController = TextEditingController(text: widget.bankDetails.accountNumber); // Pre-fill for confirmation
    _ifscCodeController = TextEditingController(text: widget.bankDetails.ifscCode);
  }

  @override
  void dispose() {
    _bankAccountNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveBankDetails() async {
    if (_formKey.currentState!.validate()) {
      if (_accountNumberController.text != _confirmAccountNumberController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account numbers do not match.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final newBankDetails = BankDetails(
        bankName: _bankAccountNameController.text,
        accountNumber: _accountNumberController.text,
        ifscCode: _ifscCodeController.text,
      );

      try {
        await profileService.updateBankDetails(newBankDetails);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank details updated successfully!')),
        );
        Navigator.pop(context, true); // Pop with true to indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update bank details: $e')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
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
                              'Current Bank Information',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text('Bank Name: ${widget.bankDetails.bankName}'),
                            Text('Account Number: XXXXXX${widget.bankDetails.accountNumber.length > 4 ? widget.bankDetails.accountNumber.substring(widget.bankDetails.accountNumber.length - 4) : widget.bankDetails.accountNumber}'),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      'Update Bank Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _bankAccountNameController,
                      decoration: const InputDecoration(
                        labelText: 'Bank Account Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter bank account name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Account Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _confirmAccountNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Account Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm account number';
                        }
                        if (value != _accountNumberController.text) {
                          return 'Account numbers do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _ifscCodeController,
                      decoration: const InputDecoration(
                        labelText: 'IFSC Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter IFSC code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'For your security, changes may require re-verification.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveBankDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Bank Details',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}