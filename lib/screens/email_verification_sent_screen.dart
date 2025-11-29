import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/api_client.dart';

class EmailVerificationSentScreen extends StatefulWidget {
  static const routeName = '/email-verification-sent';

  const EmailVerificationSentScreen({super.key});

  @override
  State<EmailVerificationSentScreen> createState() =>
      _EmailVerificationSentScreenState();
}

class _EmailVerificationSentScreenState
    extends State<EmailVerificationSentScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _timer;

  String _email = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final email = ModalRoute.of(context)?.settings.arguments as String?;
    if (email != null) {
      _email = email;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _resendCooldown = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        setState(() => _timer?.cancel());
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_email.isEmpty || _resendCooldown > 0) return;

    setState(() => _isResending = true);

    try {
      final response = await _apiClient.sendEmailVerification(email: _email);

      if (response.success) {
        _startCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email resent!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? "Failed to resend")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
    }

    if (mounted) {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Zenzio",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // ICON
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 80,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 30),

            // TITLE
            const Text(
              "Verify Your Email",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 14),

            // DESCRIPTION
            Text(
              "We've sent a verification link to",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 5),

            // EMAIL BOLD
            Text(
              _email,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "Click the link in your email to verify your account.",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            // GREEN SUCCESS BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Verification email sent successfully!",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            // RESEND BUTTON (RED BORDER)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: (_isResending || _resendCooldown > 0)
                    ? null
                    : _resendEmail,
                icon: const Icon(Icons.refresh, color: Colors.red),
                label: _isResending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _resendCooldown > 0
                            ? "Resend in $_resendCooldown s"
                            : "Resend Verification Email",
                        style: const TextStyle(color: Colors.red),
                      ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // GO TO LOGIN (RED BUTTON)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/login");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Go to Login",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // INFO BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 6),
                      Text(
                        "Didn't receive the email?",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("• Check your spam/junk folder"),
                  Text("• Make sure your email is correct"),
                  Text("• Click 'Resend' to get a new email"),
                  Text("• Wait a few minutes for delivery"),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
