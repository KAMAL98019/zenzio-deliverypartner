import 'package:delivery_partner/utils/api_client.dart';
import 'package:delivery_partner/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:delivery_partner/screens/email_verification_sent_screen.dart';
import 'package:delivery_partner/utils/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      debugPrint("LOGIN RESPONSE → ${response.data}");

      final email = response.data?['email'] ?? '';
      final verificationLink = response.data?['verificationLink'] ?? '';

      // ----------------------------------------------------------
      // CASE A: EMAIL NOT VERIFIED (firebase sends verificationLink)
      // ----------------------------------------------------------
      if (response.data != null &&
          response.data!.containsKey("verificationLink")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationSentScreen(),
            settings: RouteSettings(arguments: email),
          ),
        );
        return;
      }

      // ----------------------------------------------------------
      // CASE B: STATUS 201 (also means email not verified)
      // ----------------------------------------------------------
      if (response.statusCode == 201 ||
          response.message?.toLowerCase().contains("not verified") == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationSentScreen(),
            settings: RouteSettings(arguments: email),
          ),
        );
        return;
      }

      // ----------------------------------------------------------
      // CASE C: TOO MANY ATTEMPTS
      // ----------------------------------------------------------
      if (response.message?.contains('TOO_MANY_ATTEMPTS_TRY_LATER') == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Too many attempts. Try again later.'),
            ),
          );
        }
        return;
      }

      // ----------------------------------------------------------
      // CASE D: SUCCESS LOGIN (ONLY STATUS 200)
      // ----------------------------------------------------------
      if (response.statusCode == 200 &&
          response.success &&
          response.data != null) {
        final loginData = response.data!;
        final user = loginData['user'];
        final partnerId = user?['id'].toString() ?? '';
        final accessToken = loginData['accessToken'];
        final refreshToken = loginData['refreshToken'];

        if (accessToken != null && refreshToken != null) {
          await TokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('partnerId', partnerId);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));

          Navigator.pushReplacementNamed(context, '/dashboard');
        }
        return;
      }

      // ----------------------------------------------------------
      // CASE E: INVALID CREDENTIALS
      // ----------------------------------------------------------
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed: ${response.message ?? "Unknown error"}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.sendOtp(
        mobileNumber: _phoneController.text,
      );
      if (response.success) {
        _showOtpDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: ${response.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOtpDialog() {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter the 6-digit OTP'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _handleVerifyOtp(otpController.text);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerifyOtp(String otp) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.loginWithOtp(
        phone: _phoneController.text,
        otp: otp,
      );
      if (response.success && response.data != null) {
        final loginData = response.data!;
        final partnerId = loginData['user']['id'].toString();
        final accessToken = loginData['accessToken'] as String?;
        final refreshToken = loginData['refreshToken'] as String?;

        if (accessToken != null && refreshToken != null) {
          await TokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('partnerId', partnerId);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP verification failed: ${response.message}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('assets/icon.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  'Deliver Partner Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 40),
                TabBar(
                  controller: _tabController!,
                  indicatorColor: AppTheme.primaryRed,
                  labelColor: AppTheme.primaryRed,
                  unselectedLabelColor: AppTheme.darkText,
                  tabs: const [
                    Tab(text: 'Email/Password'),
                    Tab(text: 'OTP'),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300, // Adjust height as needed
                  child: TabBarView(
                    controller: _tabController!,
                    children: [_buildEmailLoginUI(), _buildOtpLoginUI()],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_tabController!.index == 0) {
                              _handleEmailLogin();
                            } else {
                              _handleSendOtp();
                            }
                          },
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
                            _tabController!.index == 0 ? 'Login' : 'Send OTP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New to Zenzio? ',
                      style: TextStyle(color: AppTheme.darkText),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Become a Partner',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
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

  Widget _buildEmailLoginUI() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Enter your registered email',
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
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
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
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.placeholderGrey,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: AppTheme.primaryRed, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpLoginUI() {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter your registered mobile number',
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
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
