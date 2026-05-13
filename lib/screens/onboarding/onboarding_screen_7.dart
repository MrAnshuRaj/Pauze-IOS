import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/analytics_service.dart';
import 'onboarding_screen_2.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen7 extends StatefulWidget {
  const OnboardingScreen7({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen7> createState() => _OnboardingScreen7State();
}

class _OnboardingScreen7State extends State<OnboardingScreen7>
    with TickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();

  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotScale;
  late final Animation<double> _lineOneFade;
  late final Animation<Offset> _lineOneSlide;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _pillFade;
  late final Animation<Offset> _pillSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  int _yearlyDays = 46;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _mascotFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.06, 0.28, curve: Curves.easeOut),
    );
    _mascotScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.06, 0.32, curve: Curves.easeOutBack),
      ),
    );
    _lineOneFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.24, 0.52, curve: Curves.easeOut),
    );
    _lineOneSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.24, 0.52, curve: Curves.easeOutCubic),
          ),
        );
    _headlineFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.38, 0.68, curve: Curves.easeOut),
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.38, 0.68, curve: Curves.easeOutCubic),
          ),
        );
    _pillFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.58, 0.84, curve: Curves.easeOut),
    );
    _pillSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.58, 0.84, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.66, 0.96, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.66, 0.96, curve: Curves.easeOutCubic),
          ),
        );

    _loadYearlyImpact();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0x1AE8A0B5), Color(0xFFFFF9F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 12),
                OnboardingTopBar(
                  currentStep: 7,
                  totalSteps: 18,
                  onSkip: _handleSkip,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FadeTransition(
                            opacity: _mascotFade,
                            child: ScaleTransition(
                              scale: _mascotScale,
                              child: AnimatedBuilder(
                                animation: _floatController,
                                builder: (BuildContext context, Widget? child) {
                                  final double wave = math.sin(
                                    _floatController.value * math.pi * 2,
                                  );
                                  return Transform.translate(
                                    offset: Offset(0, wave * -4.5),
                                    child: child,
                                  );
                                },
                                child: const PauMascot(
                                  state: 'drained',
                                  size: 140,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 34),
                          FadeTransition(
                            opacity: _lineOneFade,
                            child: SlideTransition(
                              position: _lineOneSlide,
                              child: Text(
                                'At this pace...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF5C5148),
                                  fontSize: width < 360 ? 19 : 21,
                                  height: 1.45,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _headlineFade,
                            child: SlideTransition(
                              position: _headlineSlide,
                              child: Column(
                                children: <Widget>[
                                  Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                        color: const Color(0xFF2E2520),
                                        fontSize: width < 360 ? 22 : 24,
                                        height: 1.20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.8,
                                      ),
                                      children: const <InlineSpan>[
                                        TextSpan(text: 'That\'s '),
                                        TextSpan(
                                          text: 'months of your\nlife',
                                          style: TextStyle(
                                            color: Color(0xFFFF6B9D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'every year.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF2E2520),
                                      fontSize: width < 360 ? 22 : 24,
                                      height: 1.20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeTransition(
                            opacity: _pillFade,
                            child: SlideTransition(
                              position: _pillSlide,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.96, end: 1.0),
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutBack,
                                builder:
                                    (
                                      BuildContext context,
                                      double scale,
                                      Widget? child,
                                    ) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: child,
                                      );
                                    },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFF6B9D,
                                    ).withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFFF6B9D,
                                      ).withValues(alpha: 0.30),
                                    ),
                                  ),
                                  child: Text(
                                    '~$_yearlyDays days per year',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B9D),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
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
                ),
                FadeTransition(
                  opacity: _buttonFade,
                  child: SlideTransition(
                    position: _buttonSlide,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: math.max(mediaQuery.padding.bottom, 12),
                      ),
                      child: _GradientPillButton(
                        label: 'Continue',
                        onPressed: _handleNext,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadYearlyImpact() async {
    final double dailyHours = await _analyticsService
        .loadOnboardingDailyScrollHours();
    final int yearlyDays = _calculateYearlyDays(dailyHours);
    if (!mounted) {
      return;
    }
    setState(() {
      _yearlyDays = yearlyDays;
    });
  }

  int _calculateYearlyDays(double dailyHours) {
    return ((dailyHours * 365) / 24).round();
  }

  void _handleNext() {
    HapticFeedback.lightImpact();
    widget.onNext();
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    widget.onSkip();
  }
}

class _GradientPillButton extends StatefulWidget {
  const _GradientPillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_GradientPillButton> createState() => _GradientPillButtonState();
}

class _GradientPillButtonState extends State<_GradientPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            height: 58,
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
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
