import 'package:delivery_partner/utils/theme.dart';
import 'package:flutter/material.dart';

class PasswordResetSuccessScreen extends StatefulWidget {
  final String email;

  const PasswordResetSuccessScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<PasswordResetSuccessScreen> createState() =>
      _PasswordResetSuccessScreenState();
}

class _PasswordResetSuccessScreenState
    extends State<PasswordResetSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Zenzio',
          style: TextStyle(
            color: AppTheme.primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Email icon with background
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.mail,
                              color: AppTheme.primaryRed, size: 70),
                          Positioned(
                            right: 35,
                            bottom: 35,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Password Reset Link Sent!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF9E9E9E),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'We have sent a password reset link to\n',
                          ),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '\nPlease check your inbox to reset your password.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'Go to Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTroubleshootingBox(),
                  const SizedBox(height: 80),
                  // Success message at bottom
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Password reset link sent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTroubleshootingBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF90CAF9).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 22),
              SizedBox(width: 10),
              Text(
                "Didn't receive the email?",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1976D2),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBulletPoint("Check your spam/junk folder"),
          const SizedBox(height: 4),
          _buildBulletPoint("Make sure your email is correct"),
          const SizedBox(height: 4),
          _buildBulletPoint("Wait a few minutes for delivery"),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFF1976D2),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF424242),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
