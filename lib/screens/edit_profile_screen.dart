import 'package:flutter/material.dart';
import 'package:delivery_partner/models/profile.dart';
import 'package:delivery_partner/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  const EditProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _emailAddressController;
  late TextEditingController _addressController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _licensePlateNumberController;
  String? _selectedVehicleType;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _mobileNumberController = TextEditingController(text: widget.profile.mobileNumber);
    _emailAddressController = TextEditingController(text: widget.profile.emailAddress);
    _addressController = TextEditingController(text: widget.profile.address);
    _vehicleModelController = TextEditingController(text: widget.profile.vehicleModel);
    _licensePlateNumberController = TextEditingController(text: widget.profile.licensePlateNumber);
    _selectedVehicleType = widget.profile.vehicleType;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    _emailAddressController.dispose();
    _addressController.dispose();
    _vehicleModelController.dispose();
    _licensePlateNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final updatedProfile = widget.profile.copyWith(
        fullName: _fullNameController.text,
        mobileNumber: _mobileNumberController.text,
        emailAddress: _emailAddressController.text,
        address: _addressController.text,
        vehicleType: _selectedVehicleType,
        vehicleModel: _vehicleModelController.text,
        licensePlateNumber: _licensePlateNumberController.text,
      );

      try {
        await profileService.updateProfile(updatedProfile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true); // Pop with true to indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
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
        title: const Text('Edit Profile'),
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
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.person, size: 60, color: Colors.white),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle change photo
                                  },
                                  child: const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle change photo
                            },
                            child: const Text('Change Photo'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _emailAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ['bike', 'scooter', 'car', 'van']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a vehicle type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _vehicleModelController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Model',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your vehicle model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _licensePlateNumberController,
                      decoration: const InputDecoration(
                        labelText: 'License Plate Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your license plate number';
                        }
                        return null;
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
            ),
    );
  }
}