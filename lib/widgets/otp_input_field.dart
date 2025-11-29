import 'package:delivery_partner/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final int length;

  const OtpInputField({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.length = 6,
  }) : super(key: key);

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) {
          return SizedBox(
            width: 50,
            height: 60,
            child: TextField(
              controller: _controllers[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lightGrey, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lightGrey, width: 2),
                ),
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  widget.controller.text = _controllers
                      .map((c) => c.text)
                      .join();
                  widget.onChanged(widget.controller.text);

                  if (index < widget.length - 1) {
                    FocusScope.of(context).nextFocus();
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}
