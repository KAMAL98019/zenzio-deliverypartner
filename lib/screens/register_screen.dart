import 'package:delivery_partner/utils/api_client.dart';
import 'package:dio/dio.dart';
import 'package:delivery_partner/utils/theme.dart';
import 'package:delivery_partner/utils/token_storage.dart';
import 'package:delivery_partner/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async'; // Import for Timer
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:delivery_partner/screens/email_verification_sent_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1;
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  // Step 1: Personal Details
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _dob;
  String? _selectedGender;
  final _referralController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  int _otpResendTimer = 0;
  Timer? _timer;
  final _aadharNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  File? _profilePhotoFile;

  // Step 2: Address
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressSecondaryController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();
  final _emergencyAddressController = TextEditingController();
  final _emergencyCityController = TextEditingController();
  final _emergencyStateController = TextEditingController();
  final _emergencyPincodeController = TextEditingController();

  // Emergency Contact
  final _emergencyNameController = TextEditingController();
  final _emergencyMobileController = TextEditingController();

  // Step 3: Vehicle Details
  String? _selectedVehicleType;
  final _vehicleModelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  File? _rcFile;
  File? _dlFile;
  final _registrationNumberController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _insuranceNoController = TextEditingController();
  final _engineNoController = TextEditingController();
  final _frameNoController = TextEditingController();
  File? _fileAadhar;
  File? _filePan;
  File? _fileInsurance;
  File? _fileOther;

  // Step 4: Work Type
  List<Map<String, dynamic>> _workTypes = [];
  String? _selectedWorkTypeUid;
  TimeOfDay _breakStartTime = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay _breakEndTime = const TimeOfDay(hour: 17, minute: 0);

  // Step 5: Payout Details
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  String? _selectedAccountType;
  bool _agreeToTerms = false;
  LatLng? _selectedLocation;
  String _locationAddress = '';

  final ImagePicker _imagePicker = ImagePicker();
  bool _isPickingImage = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _emergencyNameController.dispose();
    _emergencyMobileController.dispose();
    _vehicleModelController.dispose();
    _licensePlateController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _aadharNumberController.dispose();
    _panNumberController.dispose();
    _addressSecondaryController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyAddressController.dispose();
    _emergencyCityController.dispose();
    _emergencyStateController.dispose();
    _emergencyPincodeController.dispose();
    _registrationNumberController.dispose();
    _vehicleColorController.dispose();
    _insuranceNoController.dispose();
    _engineNoController.dispose();
    _frameNoController.dispose();
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchWorkTypes();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle the case where the user doesn't grant permission
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle the case where the user doesn't grant permission
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      _getAddressFromLatLng(_selectedLocation!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get current location: $e')),
        );
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      Placemark place = placemarks.first;
      setState(() {
        _locationAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        _addressController.text = _locationAddress;
        _cityController.text = place.locality ?? '';
        _stateController.text = place.administrativeArea ?? '';
        _pincodeController.text = place.postalCode ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to get address: $e')));
      }
    }
  }

  Future<void> _pickFile(Function(File) onFilePicked) async {
    if (_isPickingImage) return; // Prevent multiple calls
    setState(() {
      _isPickingImage = true;
    });
    try {
      final XFile? result = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (result != null) {
        onFilePicked(File(result.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _sendOtp() async {
    if (_mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile number')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.sendOtp(
        mobileNumber: _mobileController.text,
      );
      if (response.success) {
        setState(() {
          _isOtpSent = true;
          _otpResendTimer = 60;
        });
        _startOtpTimer(); // Start the timer
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'OTP sent successfully!'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'Failed to send OTP')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending OTP: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.verifyOtp(
        mobileNumber: _mobileController.text,
        otp: _otpController.text,
      );
      if (response.success) {
        setState(() {
          _isOtpVerified = true;
          _timer?.cancel(); // Cancel the timer on successful OTP verification
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'OTP verified successfully!'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'Failed to verify OTP')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error verifying OTP: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _breakStartTime : _breakEndTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _breakStartTime = picked;
        } else {
          _breakEndTime = picked;
        }
      });
    }
  }

  bool _validateStep1() {
    if (_fullNameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _aadharNumberController.text.isEmpty ||
        _panNumberController.text.isEmpty ||
        _profilePhotoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields and upload profile photo',
          ),
        ),
      );
      return false;
    }

    // if (_fullNameController.text.trim().split(' ').length < 2) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please enter both first and last name')),
    //   );
    //   return false;
    // }

    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters long'),
        ),
      );
      return false;
    }

    // Basic email validation regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return false;
    }

    if (!_isOtpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your mobile number with OTP'),
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _emergencyNameController.text.isEmpty ||
        _emergencyMobileController.text.isEmpty ||
        _emergencyRelationshipController.text.isEmpty ||
        _emergencyAddressController.text.isEmpty ||
        _emergencyCityController.text.isEmpty ||
        _emergencyStateController.text.isEmpty ||
        _emergencyPincodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    if (_selectedVehicleType == null ||
        _vehicleModelController.text.isEmpty ||
        _licensePlateController.text.isEmpty ||
        _registrationNumberController.text.isEmpty ||
        _vehicleColorController.text.isEmpty ||
        _insuranceNoController.text.isEmpty ||
        _engineNoController.text.isEmpty ||
        _frameNoController.text.isEmpty ||
        _rcFile == null ||
        _dlFile == null ||
        _fileInsurance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and upload documents'),
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateStep4() {
    if (_selectedWorkTypeUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a work type')),
      );
      return false;
    }
    return true;
  }

  bool _validateStep5() {
    if (_bankNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _ifscController.text.isEmpty ||
        _fileAadhar == null ||
        _filePan == null ||
        !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields and upload documents and agree to terms',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select Location',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter:
                          _selectedLocation ?? LatLng(20.5937, 78.9629),
                      initialZoom: 10.0,
                      onTap: (tapPosition, latLng) {
                        setState(() {
                          _selectedLocation = latLng;
                        });
                        _getAddressFromLatLng(latLng);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      if (_selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: _selectedLocation!,
                              child: Icon(
                                Icons.location_on,
                                color: AppTheme.primaryRed,
                                size: 40.0,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(_locationAddress),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Confirm Location'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitRegistration() async {
    if (!_validateStep5()) return;

    setState(() => _isLoading = true);

    try {
      // The post-registration flow requires the user object and tokens.
      // Pass placeholder URLs in the first step (as per payload example),
      // and handle the actual file uploads after successful registration.

      final firstName = _fullNameController.text.split(' ').first;
      final lastName = _fullNameController.text.split(' ').length > 1
          ? _fullNameController.text.split(' ').sublist(1).join(' ')
          : _fullNameController.text.split(' ').first;

      final Map<String, dynamic> registrationPayload = {
        "firstName": firstName,
        "lastName": lastName,
        "photo": _profilePhotoFile != null
            ? 'https://placeholder.com/profile.jpg'
            : null,
        "email": _emailController.text,
        "phoneNumber": _mobileController.text,
        "password": _passwordController.text,
        "dob": _dob != null ? DateFormat('yyyy-MM-dd').format(_dob!) : null,
        "gender": _selectedGender,
        "refferal_code": _referralController.text,
        "work_type_uid": _selectedWorkTypeUid,
        "address": {
          "city": _cityController.text,
          "state": _stateController.text,
          "pincode": _pincodeController.text,
          "address": _addressController.text,
          "address_secondary": _addressSecondaryController.text,
          "land_mark": _addressSecondaryController.text.isNotEmpty
              ? _addressSecondaryController.text
              : _addressController
                    .text, // Using secondary address/address as landmark placeholder
          "lat": _selectedLocation?.latitude ?? 0.0,
          "lng": _selectedLocation?.longitude ?? 0.0,
        },
        "bank_details": {
          "bank_name": _bankNameController.text,
          "account_number": _accountNumberController.text,
          "ifsc_code": _ifscController.text,
          "account_type": _selectedAccountType ?? 'Savings',
        },
        "documents": {
          "aadharNumber": _aadharNumberController.text,
          "licenseNumber": _licensePlateController.text,
          "vehicle_type": _selectedVehicleType ?? '',
          "registrationNumber": _registrationNumberController.text,
          "model": _vehicleModelController.text,
          "vehicleColor": _vehicleColorController.text,
          "insuranceNo": _insuranceNoController.text,
          "engineNo": _engineNoController.text,
          "frameNo": _frameNoController.text,
          "file_aadhar": _fileAadhar != null
              ? 'https://placeholder.com/aadhar.jpg'
              : null,
          "file_pan": _filePan != null
              ? 'https://placeholder.com/pan.jpg'
              : null,
          "file_rc": _rcFile != null ? 'https://placeholder.com/rc.pdf' : null,
          "file_insurance": _fileInsurance != null
              ? 'https://placeholder.com/insurance.pdf'
              : null,
          "file_other": _fileOther != null
              ? 'https://placeholder.com/other.pdf'
              : null,
          // Assuming _dlFile is not strictly required in the first step if registration passes
        },
        "emergencyContacts": [
          {
            "contact_person": _emergencyNameController.text,
            "relationship": _emergencyRelationshipController.text,
            "primary_contact": true,
            "secondary_contact": false,
            "address": _emergencyAddressController.text,
            "city": _emergencyCityController.text,
            "state": _emergencyStateController.text,
            "pincode": _emergencyPincodeController.text,
            // The emergency contact payload in the example response does not show phone number, but it is in the request payload, so I will include it
            "phoneNumber": _emergencyMobileController.text,
          },
        ],
      };

      final response = await _apiClient.register(data: registrationPayload);

      if (response.success && response.data != null) {
        final data = response.data!;
        final tokens = data['tokens'];
        final fleetUid = data['user']?['uid'] as String?;

        if (tokens != null && tokens is Map<String, dynamic>) {
          await TokenStorage.saveTokens(
            accessToken: tokens['accessToken'] as String,
            refreshToken: tokens['refreshToken'] as String,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Uploading documents...'),
            ),
          );
        }

        if (fleetUid != null) {
          await _postRegistrationUploads(fleetUid);
        }

        // Send email verification link
        await _apiClient.sendEmailVerification(email: _emailController.text);

        if (mounted) {
          // Navigate to the email verification sent screen
          Navigator.pushReplacementNamed(
            context,
            EmailVerificationSentScreen.routeName,
            arguments: _emailController.text,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${response.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _postRegistrationUploads(String fleetUid) async {
    // 1. Upload Profile Image
    if (_profilePhotoFile != null) {
      await _apiClient.uploadSingleImage(
        fleetUid: fleetUid,
        filePath: _profilePhotoFile!.path,
        key: 'photo',
      );
    }

    // 2. Upload Documents (Aadhar, PAN, RC, Insurance, Other, DL)
    final docFiles = {
      'aadhar': _fileAadhar,
      'pan': _filePan,
      'rc': _rcFile,
      'insurance': _fileInsurance,
      'other': _fileOther,
      'license': _dlFile, // Assuming 'dl' is a document type
    };

    for (final entry in docFiles.entries) {
      final docType = entry.key;
      final file = entry.value;
      if (file != null) {
        await _apiClient.uploadDocuments(
          fleetUid: fleetUid,
          docType: docType,
          filePath: file.path,
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 1 && !_validateStep1()) return;
    if (_currentStep == 2 && !_validateStep2()) return;
    if (_currentStep == 3 && !_validateStep3()) return;
    if (_currentStep == 4 && !_validateStep4()) return;

    if (_currentStep < 5) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.primaryRed,
                      ),
                      onPressed: _currentStep > 1
                          ? _previousStep
                          : () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Register as a Partner',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Step $_currentStep of 5',
                  style: const TextStyle(
                    color: AppTheme.primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                StepIndicator(currentStep: _currentStep),
                const SizedBox(height: 32),
                if (_currentStep == 1) _buildStep1(),
                if (_currentStep == 2) _buildStep2(),
                if (_currentStep == 3) _buildStep3(),
                if (_currentStep == 4) _buildStep4(),
                if (_currentStep == 5) _buildStep5(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryRed),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _previousStep,
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: AppTheme.primaryRed,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : (_currentStep == 5
                                  ? _submitRegistration
                                  : _nextStep),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _currentStep == 5
                                    ? 'Submit Registration'
                                    : 'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Personal Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 20),
        _buildFileUpload(
          'Profile Photo',
          'Upload Profile Photo',
          _profilePhotoFile != null,
          () {
            _pickFile((file) => setState(() => _profilePhotoFile = file));
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Full Name',
          _fullNameController,
          'Enter your full name',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Mobile Number',
          _mobileController,
          'Enter your mobile number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        if (!_isOtpVerified)
          SizedBox(
            width: double.infinity, // full width
            child: ElevatedButton(
              onPressed: _isOtpSent ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isOtpSent
                  ? Text(
                      'Resend in $_otpResendTimer s',
                      style: const TextStyle(color: Colors.white),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),

        if (_isOtpSent && !_isOtpVerified) ...[
          const SizedBox(height: 16),
          _buildTextField(
            'OTP',
            _otpController,
            'Enter OTP',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, // full width
            child: ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Verify OTP',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
        if (_isOtpVerified)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Mobile number verified!',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        _buildTextField(
          'Email Address',
          _emailController,
          'Enter your email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        _buildGenderDropdown(),
        const SizedBox(height: 16),
        _buildTextField(
          'Referral Code (Optional)',
          _referralController,
          'Enter referral code if you have one',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Password',
          _passwordController,
          'Enter your password',
          isPassword: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Aadhar Number',
          _aadharNumberController,
          'Enter your Aadhar number',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'PAN Number',
          _panNumberController,
          'Enter your PAN number',
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Address',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Address',
          _addressController,
          'Enter your full address',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Secondary Address (Optional)',
          _addressSecondaryController,
          'Enter your secondary address',
        ),
        const SizedBox(height: 16),
        _buildTextField('City', _cityController, 'Enter your city'),
        const SizedBox(height: 16),
        _buildTextField('State', _stateController, 'Enter your state'),
        const SizedBox(height: 16),
        _buildTextField(
          'Pincode',
          _pincodeController,
          'Enter your pincode',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          icon: const Icon(Icons.location_on, color: AppTheme.primaryRed),
          label: const Text('Locate on Map'),
          onPressed: _showLocationPicker,
        ),
        const SizedBox(height: 20),
        const Text(
          'Emergency Contact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Contact Person Name',
          _emergencyNameController,
          'Enter emergency contact name',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Relationship',
          _emergencyRelationshipController,
          'e.g., Brother, Mother, Friend',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Mobile Number',
          _emergencyMobileController,
          'Enter emergency contact number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Address',
          _emergencyAddressController,
          'Enter emergency contact address',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'City',
          _emergencyCityController,
          'Enter emergency contact city',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'State',
          _emergencyStateController,
          'Enter emergency contact state',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Pincode',
          _emergencyPincodeController,
          'Enter emergency contact pincode',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        const Text(
          'This person will be contacted in case of emergency',
          style: TextStyle(fontSize: 12, color: AppTheme.placeholderGrey),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Vehicle Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 20),
        _buildVehicleTypeDropdown(),
        const SizedBox(height: 16),
        _buildTextField(
          'Vehicle Model',
          _vehicleModelController,
          'e.g., Hero Splendor, Honda Activa',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Vehicle Color',
          _vehicleColorController,
          'Enter vehicle color',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'License Plate Number',
          _licensePlateController,
          'Enter license plate number',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Registration Number',
          _registrationNumberController,
          'Enter vehicle registration number',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Insurance Number',
          _insuranceNoController,
          'Enter insurance number',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Engine Number',
          _engineNoController,
          'Enter engine number',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Frame Number',
          _frameNoController,
          'Enter frame number',
        ),
        const SizedBox(height: 20),
        _buildFileUpload(
          'Vehicle Registration Certificate (RC)',
          'Upload RC Certificate',
          _rcFile != null,
          () {
            _pickFile((file) => setState(() => _rcFile = file));
          },
        ),
        const SizedBox(height: 16),
        _buildFileUpload(
          'Driving License',
          'Upload Driving License',
          _dlFile != null,
          () {
            _pickFile((file) => setState(() => _dlFile = file));
          },
        ),
        const SizedBox(height: 16),
        _buildFileUpload(
          'Insurance Document',
          'Upload Insurance Document',
          _fileInsurance != null,
          () {
            _pickFile((file) => setState(() => _fileInsurance = file));
          },
        ),
        const SizedBox(height: 16),
        _buildFileUpload(
          'Other Document (Optional)',
          'Upload Other Document',
          _fileOther != null,
          () {
            _pickFile((file) => setState(() => _fileOther = file));
          },
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Work Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 20),
        _buildWorkTypeDropdown(),
        const SizedBox(height: 16),
        if (_selectedWorkTypeUid != null &&
            _workTypes.any(
              (element) => element['work_type_uid'] == _selectedWorkTypeUid,
            ))
          _buildBreakTimeModifier(),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payout Details & Agreement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Bank Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Bank Account Name',
          _bankNameController,
          'Enter account holder name',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Account Number',
          _accountNumberController,
          'Enter account number',
        ),
        const SizedBox(height: 16),
        _buildTextField('IFSC Code', _ifscController, 'Enter IFSC code'),
        const SizedBox(height: 16),
        _buildAccountTypeDropdown(),
        const SizedBox(height: 20),
        _buildFileUpload(
          'Aadhaar Card',
          'Upload Aadhaar Card',
          _fileAadhar != null,
          () {
            _pickFile((file) => setState(() => _fileAadhar = file));
          },
        ),
        const SizedBox(height: 16),
        _buildFileUpload('PAN Card', 'Upload PAN Card', _filePan != null, () {
          _pickFile((file) => setState(() => _filePan = file));
        }),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _agreeToTerms,
              onChanged: (value) =>
                  setState(() => _agreeToTerms = value ?? false),
              activeColor: AppTheme.primaryRed,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(color: AppTheme.darkText),
                      ),
                      const TextSpan(
                        text: 'Delivery Partner Terms & Conditions',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' and ',
                        style: TextStyle(color: AppTheme.darkText),
                      ),
                      const TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Type',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedAccountType,
          items: ['Savings', 'Current']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) => setState(() => _selectedAccountType = value),
          decoration: InputDecoration(
            hintText: 'Select account type',
            hintStyle: const TextStyle(color: AppTheme.placeholderGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.placeholderGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGrey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dob != null
                      ? DateFormat('dd/MM/yyyy').format(_dob!)
                      : 'DD / MM / YYYY',
                  style: TextStyle(
                    color: _dob != null
                        ? AppTheme.darkText
                        : AppTheme.placeholderGrey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: AppTheme.lightGrey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          items: ['Male', 'Female', 'Other']
              .map(
                (gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedGender = value),
          decoration: InputDecoration(
            hintText: 'Select gender',
            hintStyle: const TextStyle(color: AppTheme.placeholderGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Type',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedVehicleType,
          items: ['Bike', 'Scooter', 'Car', 'Auto', 'Cycle']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) => setState(() => _selectedVehicleType = value),
          decoration: InputDecoration(
            hintText: 'Select vehicle type',
            hintStyle: const TextStyle(color: AppTheme.placeholderGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(
    String label,
    String buttonText,
    bool isUploaded,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isPickingImage ? null : onTap, // Disable tap while picking
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightGrey,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _isPickingImage
                  ? const CircularProgressIndicator() // Show loading indicator
                  : Column(
                      children: [
                        Icon(
                          isUploaded
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          color: isUploaded ? Colors.green : AppTheme.lightGrey,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          buttonText,
                          style: TextStyle(
                            color: isUploaded
                                ? Colors.green
                                : AppTheme.darkText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PDF/JPG/PNG format',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.placeholderGrey,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

extension _RegisterScreenStateExtension on _RegisterScreenState {
  void _startOtpTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpResendTimer == 0) {
        setState(() {
          _isOtpSent = false;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _otpResendTimer--;
        });
      }
    });
  }

  Future<void> _fetchWorkTypes() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.getWorkTypes();
      if (response.success && response.data != null) {
        setState(() {
          _workTypes = response.data!;
          if (_workTypes.isNotEmpty) {
            _selectedWorkTypeUid = _workTypes.first['work_type_uid'];
            _updateBreakTimes(_selectedWorkTypeUid!);
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to load work types'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading work types: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateBreakTimes(String workTypeUid) {
    final selectedWorkType = _workTypes.firstWhere(
      (element) => element['work_type_uid'] == workTypeUid,
      orElse: () => {},
    );
    if (selectedWorkType.isNotEmpty) {
      final startTimeString = selectedWorkType['break_start_time'];
      final endTimeString = selectedWorkType['break_end_time'];

      if (startTimeString != null && endTimeString != null) {
        final startParts = startTimeString.split(':');
        final endParts = endTimeString.split(':');
        setState(() {
          _breakStartTime = TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: int.parse(startParts[1]),
          );
          _breakEndTime = TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: int.parse(endParts[1]),
          );
        });
      }
    }
  }

  Widget _buildWorkTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Type',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedWorkTypeUid,
          items: _workTypes
              .map(
                (workType) => DropdownMenuItem(
                  value: workType['work_type_uid'] as String,
                  child: Text(workType['name'] as String),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedWorkTypeUid = value;
              if (value != null) {
                _updateBreakTimes(value);
              }
            });
          },
          decoration: InputDecoration(
            hintText: 'Select work type',
            hintStyle: const TextStyle(color: AppTheme.placeholderGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.lightGrey),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakTimeModifier() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Modify Break Time'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.lightGrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${_breakStartTime.format(context)}'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.lightGrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${_breakEndTime.format(context)}'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
