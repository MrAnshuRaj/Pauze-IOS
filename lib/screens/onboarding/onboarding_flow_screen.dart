import 'package:flutter/material.dart';

import 'onboarding_screen_1.dart';
import 'onboarding_screen_2.dart';
import 'onboarding_screen_3.dart';
import 'onboarding_screen_4.dart';
import 'onboarding_screen_5.dart';
import 'onboarding_screen_6.dart';
import 'onboarding_screen_7.dart';
import 'onboarding_screen_8.dart';
import 'onboarding_screen_9.dart';
import 'onboarding_screen_10.dart';
import 'onboarding_screen_11.dart';
import 'onboarding_screen_12.dart';
import 'onboarding_screen_13.dart';
import 'onboarding_screen_14.dart';
import 'onboarding_screen_15.dart';
import 'onboarding_screen_16.dart';
import 'onboarding_screen_17.dart';
import 'onboarding_screen_18.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key, required this.onCompleted});

  final Future<void> Function() onCompleted;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (int page) {
        setState(() => _currentPage = page);
      },
      children: <Widget>[
        OnboardingScreen1(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen2(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen3(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen4(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen5(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen6(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen7(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen8(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen9(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen10(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen11(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen12(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen13(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen14(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen15(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen16(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen17(
          onNext: () {
            _goToNextStep();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
        OnboardingScreen18(
          onNext: () {
            _completeFlow();
          },
          onSkip: () {
            _completeFlow();
          },
        ),
      ],
    );
  }

  Future<void> _goToNextStep() async {
    if (_currentPage >= 17) {
      await _completeFlow();
      return;
    }

    await _pageController.animateToPage(
      _currentPage + 1,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _completeFlow() async {
    if (_isCompleting) {
      return;
    }

    setState(() => _isCompleting = true);
    try {
      await widget.onCompleted();
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }
}
