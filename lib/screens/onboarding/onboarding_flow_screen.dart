import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_screen_1.dart';
import 'onboarding_screen_2.dart';
import 'onboarding_screen_3.dart';
import 'onboarding_screen_4.dart';
import 'onboarding_screen_5.dart';
import 'onboarding_screen_6.dart';
import 'onboarding_screen_7.dart';
import 'onboarding_screen_8.dart';
import 'onboarding_step_header.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key, required this.onCompleted});

  final Future<void> Function() onCompleted;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  static const int _totalSteps = 18;

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
        _OnboardingPlaceholderScreen(
          currentStep: 9,
          totalSteps: _totalSteps,
          isSubmitting: _isCompleting,
          onContinue: _completeFlow,
          onSkip: _completeFlow,
        ),
      ],
    );
  }

  Future<void> _goToNextStep() async {
    if (_currentPage >= 8) {
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

class _OnboardingPlaceholderScreen extends StatelessWidget {
  const _OnboardingPlaceholderScreen({
    required this.currentStep,
    required this.totalSteps,
    required this.isSubmitting,
    required this.onContinue,
    required this.onSkip,
  });

  final int currentStep;
  final int totalSteps;
  final bool isSubmitting;
  final Future<void> Function() onContinue;
  final Future<void> Function() onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              OnboardingTopBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                onSkip: isSubmitting ? null : _handleSkip,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text(
                          'Screen 9 placeholder',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2E2520),
                            fontSize: 34,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Screen 8 now routes correctly into this temporary ninth step, so the onboarding flow stays intact while the remaining pages are designed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B6057),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[Color(0xFFFF8C42), Color(0xFFFF5F8F)],
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x332E2520),
                          blurRadius: 22,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isSubmitting ? null : _handleContinue,
                        borderRadius: BorderRadius.circular(999),
                        child: Center(
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    HapticFeedback.lightImpact();
    onContinue();
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    onSkip();
  }
}
