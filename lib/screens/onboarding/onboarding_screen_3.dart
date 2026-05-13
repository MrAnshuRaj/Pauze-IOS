import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_screen_2.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen3 extends StatefulWidget {
  const OnboardingScreen3({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen3> createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final AnimationController _indicatorController;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotScale;
  late final Animation<double> _lineOneFade;
  late final Animation<Offset> _lineOneSlide;
  late final Animation<double> _lineTwoFade;
  late final Animation<Offset> _lineTwoSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _mascotFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.06, 0.30, curve: Curves.easeOut),
    );
    _mascotScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.06, 0.34, curve: Curves.easeOutBack),
      ),
    );
    _lineOneFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.30, 0.58, curve: Curves.easeOut),
    );
    _lineOneSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.30, 0.58, curve: Curves.easeOutCubic),
          ),
        );
    _lineTwoFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.46, 0.74, curve: Curves.easeOut),
    );
    _lineTwoSlide =
        Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.46, 0.74, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.62, 0.96, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.62, 0.96, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    final double serifSize = width < 360 ? 18 : 20;
    final double lineTwoSize = width < 360 ? 18 : 20;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              OnboardingTopBar(
                currentStep: 3,
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
                                  offset: Offset(0, wave * -5),
                                  child: Transform.scale(
                                    scale: 1.0 + (((wave + 1) / 2) * 0.02),
                                    child: child,
                                  ),
                                );
                              },
                              child: const PauMascot(state: 'okay', size: 160),
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        FadeTransition(
                          opacity: _lineOneFade,
                          child: SlideTransition(
                            position: _lineOneSlide,
                            child: Text(
                              'Then... we start scrolling.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF5C5148),
                                fontSize: serifSize,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeTransition(
                          opacity: _lineTwoFade,
                          child: SlideTransition(
                            position: _lineTwoSlide,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: const Color(0xFF2E2520),
                                  fontSize: lineTwoSize,
                                  height: 1.25,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: const <InlineSpan>[
                                  TextSpan(text: 'Just a '),
                                  TextSpan(
                                    text: 'few',
                                    style: TextStyle(
                                      color: Color(0xFFFF6B9D),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(text: ' reels.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _indicatorController,
                builder: (BuildContext context, Widget? child) {
                  final double progress = _indicatorController.value;
                  final double wave = math.sin(progress * math.pi * 2);
                  final double easedOpacity = (0.55 + (wave * 0.25))
                      .clamp(0.30, 0.80)
                      .toDouble();
                  final Color color = Color.lerp(
                    const Color(0xFF9A948F),
                    const Color(0xFFFF6B9D),
                    (wave + 1) / 2 * 0.35,
                  )!;

                  return Transform.translate(
                    offset: Offset(0, wave * 4),
                    child: Opacity(
                      opacity: easedOpacity,
                      child: Text(
                        '\u2195',
                        style: TextStyle(
                          color: color,
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          shadows: <Shadow>[
                            Shadow(
                              color: color.withValues(alpha: 0.20),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 26),
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
    );
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
