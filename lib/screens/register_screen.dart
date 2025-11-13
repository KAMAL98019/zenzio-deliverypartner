import 'package:delivery_partner/utils/api_client.dart';
import 'package:dio/dio.dart';
import 'package:delivery_partner/utils/theme.dart';
import 'package:delivery_partner/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

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

  // Step 2: Address
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Emergency Contact
  final _emergencyNameController = TextEditingController();
  final _emergencyMobileController = TextEditingController();

  // Step 3: Vehicle Details
  String? _selectedVehicleType;
  final _vehicleModelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  File? _rcFile;
  File? _dlFile;

  // Step 4: Work Type
  String? _selectedWorkType = 'full-time';
  TimeOfDay _breakStartTime = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay _breakEndTime = const TimeOfDay(hour: 17, minute: 0);

  // Step 5: Payout Details
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  File? _idProofFile;
  bool _agreeToTerms = false;
  LatLng? _selectedLocation;
  String _locationAddress = '';

  final ImagePicker _imagePicker = ImagePicker();

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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
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
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
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
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get address: $e')),
        );
      }
    }
  }

  Future<void> _pickFile(Function(File) onFilePicked) async {
    final XFile? result = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (result != null) {
      onFilePicked(File(result.path));
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
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_addressController.text.isEmpty ||
        _emergencyNameController.text.isEmpty ||
        _emergencyMobileController.text.isEmpty) {
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
        _rcFile == null ||
        _dlFile == null) {
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
    if (_selectedWorkType == null) {
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
        _idProofFile == null ||
        !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and agree to terms'),
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
                      initialCenter: _selectedLocation ?? LatLng(20.5937, 78.9629),
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
      final formData = FormData.fromMap({
        'fullName': _fullNameController.text,
        'mobile': _mobileController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'dob': _dob != null ? DateFormat('yyyy-MM-dd').format(_dob!) : '',
        'gender': _selectedGender ?? '',
        'referralCode': _referralController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'emergencyName': _emergencyNameController.text,
        'emergencyMobile': _emergencyMobileController.text,
        'vehicleType': _selectedVehicleType ?? '',
        'vehicleModel': _vehicleModelController.text,
        'licensePlate': _licensePlateController.text,
        'workType': _selectedWorkType ?? '',
        'bankName': _bankNameController.text,
        'accountNumber': _accountNumberController.text,
        'ifsc': _ifscController.text,
        if (_rcFile != null)
          'rcFile': await MultipartFile.fromFile(_rcFile!.path, filename: 'rc.jpg'),
        if (_dlFile != null)
          'dlFile': await MultipartFile.fromFile(_dlFile!.path, filename: 'dl.jpg'),
        if (_idProofFile != null)
          'idProofFile': await MultipartFile.fromFile(_idProofFile!.path, filename: 'id_proof.jpg'),
      });

      final response = await _apiClient.register(data: formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.message}')),
        );
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
        ),
        const SizedBox(height: 12),
        const Text(
          "We'll send a verification code to this number",
          style: TextStyle(fontSize: 12, color: AppTheme.placeholderGrey),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Email Address',
          _emailController,
          'Enter your email address',
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
          'Name',
          _emergencyNameController,
          'Enter emergency contact name',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Mobile Number',
          _emergencyMobileController,
          'Enter emergency contact number',
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
          'License Plate Number',
          _licensePlateController,
          'Enter license plate number',
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
        _buildWorkTypeCard(
          'Full-Time',
          '11 AM to 11 PM daily',
          'Lunch break: 3 PM - 5 PM (modifiable)',
          'full-time',
        ),
        const SizedBox(height: 16),
        if (_selectedWorkType == 'full-time')
          Container(
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
          ),
        const SizedBox(height: 16),
        _buildWorkTypeCard(
          'Ultra Full-Time',
          '6 AM to 11 PM daily',
          'Break: 3 PM - 5 PM (modifiable)',
          'ultra-full-time',
        ),
        const SizedBox(height: 16),
        _buildWorkTypeCard(
          'Part-Time Evening',
          '6 AM to 11 PM daily',
          'Break: 3 PM - 5 PM (modifiable)',
          'part-time',
        ),
        const SizedBox(height: 16),
        _buildWorkTypeCard(
          'Weekend Only (Saturday & Sunday only)',
          '11 AM to 11 PM daily',
          'Break: 3 PM - 5 PM (modifiable)',
          'weekend',
        ),
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
        const SizedBox(height: 20),
        _buildFileUpload(
          'Aadhaar Card / Government ID Proof',
          'Upload ID Proof',
          _idProofFile != null,
          () {
            _pickFile((file) => setState(() => _idProofFile = file));
          },
        ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
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
          onTap: onTap,
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
              child: Column(
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
                      color: isUploaded ? Colors.green : AppTheme.darkText,
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

  Widget _buildWorkTypeCard(
    String title,
    String time,
    String breakTime,
    String workType,
  ) {
    final isSelected = _selectedWorkType == workType;
    return GestureDetector(
      onTap: () => setState(() => _selectedWorkType = workType),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryRed : AppTheme.lightGrey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    breakTime,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.placeholderGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryRed,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
