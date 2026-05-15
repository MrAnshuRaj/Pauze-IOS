import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_step_header.dart';

class OnboardingScreen11 extends StatefulWidget {
  const OnboardingScreen11({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen11> createState() => _OnboardingScreen11State();
}

class _OnboardingScreen11State extends State<OnboardingScreen11>
    with TickerProviderStateMixin {
  final ValueNotifier<int> _scrollCount = ValueNotifier<int>(0);

  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _cardFade;
  late final Animation<double> _cardScale;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  Timer? _counterTimer;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _cardFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.06, 0.30, curve: Curves.easeOut),
    );
    _cardScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.06, 0.34, curve: Curves.easeOutBack),
      ),
    );
    _headlineFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.28, 0.56, curve: Curves.easeOut),
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.28, 0.56, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.42, 0.68, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.42, 0.68, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.64, 0.96, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.64, 0.96, curve: Curves.easeOutCubic),
          ),
        );

    _counterTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted) {
        return;
      }
      _scrollCount.value = (_scrollCount.value + 1) % 301;
    });
  }

  @override
  void dispose() {
    _counterTimer?.cancel();
    _scrollCount.dispose();
    _entryController.dispose();
    _pulseController.dispose();
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
                currentStep: 11,
                totalSteps: 18,
                onSkip: _handleSkip,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: compact ? 30 : 46,
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
                                  opacity: _cardFade,
                                  child: ScaleTransition(
                                    scale: _cardScale,
                                    child: AnimatedBuilder(
                                      animation: _pulseController,
                                      builder:
                                          (
                                            BuildContext context,
                                            Widget? child,
                                          ) {
                                            final double t =
                                                _pulseController.value;
                                            final double scale =
                                                0.98 + (t * 0.04);
                                            final double pinkBlur =
                                                32 + (t * 10);
                                            final double orangeBlur =
                                                24 + (t * 8);
                                            final double pinkOpacity =
                                                0.15 + (t * 0.08);
                                            final double orangeOpacity =
                                                0.10 + (t * 0.08);

                                            return Transform.scale(
                                              scale: scale,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                      color:
                                                          const Color(
                                                            0xFFFF6B9D,
                                                          ).withValues(
                                                            alpha: pinkOpacity,
                                                          ),
                                                      blurRadius: pinkBlur,
                                                      offset: const Offset(
                                                        0,
                                                        10,
                                                      ),
                                                    ),
                                                    BoxShadow(
                                                      color:
                                                          const Color(
                                                            0xFFFF8C42,
                                                          ).withValues(
                                                            alpha:
                                                                orangeOpacity,
                                                          ),
                                                      blurRadius: orangeBlur,
                                                      offset: const Offset(
                                                        0,
                                                        14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                      child: Container(
                                        width: compact ? 160 : 172,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: compact ? 24 : 28,
                                          vertical: compact ? 20 : 22,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: <Color>[
                                              Color(0xFFFFFFFF),
                                              Color(0xFFFFF5F7),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFFFE5EC),
                                            width: 1.6,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const Text(
                                              'Scroll Count',
                                              style: TextStyle(
                                                color: Color(0xFF8B8B8B),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            ValueListenableBuilder<int>(
                                              valueListenable: _scrollCount,
                                              builder:
                                                  (
                                                    BuildContext context,
                                                    int value,
                                                    Widget? child,
                                                  ) {
                                                    return Text(
                                                      '$value',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFFFF6B9D,
                                                        ),
                                                        fontSize: compact
                                                            ? 54
                                                            : 60,
                                                        height: 0.95,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        letterSpacing: -2.2,
                                                        fontFamily: 'monospace',
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 46 : 58),
                                FadeTransition(
                                  opacity: _headlineFade,
                                  child: SlideTransition(
                                    position: _headlineSlide,
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: const Color(0xFF2E2520),
                                          fontSize: compact ? 26 : 31,
                                          height: 1.18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.9,
                                        ),
                                        children: const <InlineSpan>[
                                          TextSpan(text: 'We track '),
                                          TextSpan(
                                            text: 'every scroll',
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
                                SizedBox(height: compact ? 14 : 18),
                                FadeTransition(
                                  opacity: _subtitleFade,
                                  child: SlideTransition(
                                    position: _subtitleSlide,
                                    child: Text(
                                      'So you can see the loop.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF5C5148),
                                        fontSize: compact ? 17 : 18.5,
                                        height: 1.55,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'serif',
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
