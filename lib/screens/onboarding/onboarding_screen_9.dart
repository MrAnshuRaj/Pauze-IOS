import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_screen_2.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen9 extends StatefulWidget {
  const OnboardingScreen9({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen9> createState() => _OnboardingScreen9State();
}

class _OnboardingScreen9State extends State<OnboardingScreen9>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _wobbleController;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotScale;
  late final Animation<double> _mascotRotation;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _supportingFade;
  late final Animation<Offset> _supportingSlide;
  late final Animation<double> _pillFade;
  late final Animation<Offset> _pillSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _mascotFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.04, 0.28, curve: Curves.easeOut),
    );
    _mascotScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.04, 0.32, curve: Curves.easeOutBack),
      ),
    );
    _mascotRotation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: -3 * math.pi / 180),
            weight: 1,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: -3 * math.pi / 180,
              end: 3 * math.pi / 180,
            ),
            weight: 1,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: 3 * math.pi / 180,
              end: -3 * math.pi / 180,
            ),
            weight: 1,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: -3 * math.pi / 180, end: 0.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
        );
    _headlineFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.28, 0.52, curve: Curves.easeOut),
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.28, 0.52, curve: Curves.easeOutCubic),
          ),
        );
    _supportingFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.42, 0.68, curve: Curves.easeOut),
    );
    _supportingSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.42, 0.68, curve: Curves.easeOutCubic),
          ),
        );
    _pillFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.58, 0.82, curve: Curves.easeOut),
    );
    _pillSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.58, 0.82, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.70, 0.98, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.70, 0.98, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    final bool compact = width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              OnboardingTopBar(
                currentStep: 9,
                totalSteps: 18,
                onSkip: _handleSkip,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: compact ? 28 : 40,
                        bottom: compact ? 20 : 28,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                FadeTransition(
                                  opacity: _mascotFade,
                                  child: ScaleTransition(
                                    scale: _mascotScale,
                                    child: AnimatedBuilder(
                                      animation: _mascotRotation,
                                      builder:
                                          (
                                            BuildContext context,
                                            Widget? child,
                                          ) {
                                            return Transform.rotate(
                                              angle: _mascotRotation.value,
                                              alignment: Alignment.bottomCenter,
                                              child: child,
                                            );
                                          },
                                      child: PauMascot(
                                        state: 'okay',
                                        size: compact ? 132 : 144,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 28 : 36),
                                FadeTransition(
                                  opacity: _headlineFade,
                                  child: SlideTransition(
                                    position: _headlineSlide,
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: const Color(0xFF2E2520),
                                          fontSize: compact ? 28 : 33,
                                          height: 1.10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.9,
                                        ),
                                        children: const <InlineSpan>[
                                          TextSpan(text: 'It\'s '),
                                          TextSpan(
                                            text: 'not just you',
                                            style: TextStyle(
                                              color: Color(0xFFFF8C42),
                                            ),
                                          ),
                                          TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 18 : 24),
                                FadeTransition(
                                  opacity: _supportingFade,
                                  child: SlideTransition(
                                    position: _supportingSlide,
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: const Color(0xFF5C5148),
                                          fontSize: compact ? 17 : 18.5,
                                          height: 1.65,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: 'serif',
                                        ),
                                        children: const <InlineSpan>[
                                          TextSpan(text: 'These apps are '),
                                          TextSpan(
                                            text: 'designed',
                                            style: TextStyle(
                                              color: Color(0xFFFF6B9D),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' to keep you\nscrolling.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 24 : 34),
                                FadeTransition(
                                  opacity: _pillFade,
                                  child: SlideTransition(
                                    position: _pillSlide,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: 0.96,
                                        end: 1.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
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
                                          horizontal: 18,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFF8C42,
                                          ).withValues(alpha: 0.10),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFFFF8C42,
                                            ).withValues(alpha: 0.30),
                                          ),
                                        ),
                                        child: Text(
                                          'Infinite scroll \u2022 Auto-play \u2022 Notifications',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF5C5148),
                                            fontSize: compact ? 13 : 14,
                                            height: 1.4,
                                            fontWeight: FontWeight.w500,
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
                    );
                  },
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
            width: double.infinity,
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
