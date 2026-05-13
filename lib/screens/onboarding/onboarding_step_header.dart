import 'package:flutter/material.dart';

class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    super.key,
    required this.currentStep,
    required this.onSkip,
    this.totalSteps = 18,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8D837A),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('Skip'),
            ),
            const Spacer(),
            Text(
              '$currentStep/$totalSteps',
              style: const TextStyle(
                color: Color(0xFF7A7068),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        OnboardingProgressBar(currentStep: currentStep, totalSteps: totalSteps),
      ],
    );
  }
}

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 18,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final int safeTotalSteps = totalSteps <= 0 ? 18 : totalSteps;
    final int safeCurrentStep = currentStep.clamp(1, safeTotalSteps);

    return SizedBox(
      height: 3,
      child: Row(
        children: List<Widget>.generate(safeTotalSteps, (int index) {
          final bool active = index < safeCurrentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == safeTotalSteps - 1 ? 0 : 4,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 3,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFFDED8D3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({
    super.key,
    required this.currentStep,
    required this.onSkip,
    this.totalSteps = 18,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return OnboardingTopBar(
      currentStep: currentStep,
      totalSteps: totalSteps,
      onSkip: onSkip,
    );
  }
}
