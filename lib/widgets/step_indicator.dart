import 'package:delivery_partner/utils/theme.dart';
import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber == currentStep;
          final isCompleted = stepNumber < currentStep;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive || isCompleted
                    ? AppTheme.primaryRed
                    : AppTheme.lightGrey,
              ),
            ),
          );
        },
      ),
    );
  }
}
