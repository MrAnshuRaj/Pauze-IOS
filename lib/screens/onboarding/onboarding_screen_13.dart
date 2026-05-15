import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_screen_2.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen13 extends StatefulWidget {
  const OnboardingScreen13({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen13> createState() => _OnboardingScreen13State();
}

class _OnboardingScreen13State extends State<OnboardingScreen13>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _breatheController;
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

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    )..repeat();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
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
    _lineOneFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.28, 0.52, curve: Curves.easeOut),
    );
    _lineOneSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.28, 0.52, curve: Curves.easeOutCubic),
          ),
        );
    _headlineFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.40, 0.68, curve: Curves.easeOut),
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.40, 0.68, curve: Curves.easeOutCubic),
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
    _breatheController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    final bool compact = width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0x33FFE5D9), Color(0xFFEDE7DE)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 12),
                OnboardingTopBar(
                  currentStep: 13,
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
                                        animation: Listenable.merge(
                                          <Listenable>[
                                            _breatheController,
                                            _floatController,
                                          ],
                                        ),
                                        builder:
                                            (
                                              BuildContext context,
                                              Widget? child,
                                            ) {
                                              final double breatheProgress =
                                                  _breatheController.value;
                                              final double eased = Curves
                                                  .easeInOut
                                                  .transform(
                                                    breatheProgress < 0.29
                                                        ? breatheProgress / 0.29
                                                        : 1 -
                                                              ((breatheProgress -
                                                                      0.29) /
                                                                  0.71),
                                                  );
                                              final double circleScale =
                                                  0.85 + (eased * 0.30);
                                              final double floatWave = math.sin(
                                                _floatController.value *
                                                    math.pi *
                                                    2,
                                              );
                                              final double floatOffset =
                                                  floatWave * -4.0;
                                              final double pauScale =
                                                  1.0 +
                                                  (((floatWave + 1) / 2) *
                                                      0.02);

                                              return SizedBox(
                                                width: compact ? 250 : 290,
                                                height: compact ? 220 : 250,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    Transform.scale(
                                                      scale: circleScale,
                                                      child:
                                                          const _BreathingAura(),
                                                    ),
                                                    Transform.translate(
                                                      offset: Offset(
                                                        0,
                                                        floatOffset,
                                                      ),
                                                      child: Transform.scale(
                                                        scale: pauScale,
                                                        child: child,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                        child: PauMascot(
                                          state: 'healing',
                                          size: compact ? 132 : 142,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 18 : 24),
                                  FadeTransition(
                                    opacity: _lineOneFade,
                                    child: SlideTransition(
                                      position: _lineOneSlide,
                                      child: Text(
                                        'When it goes too far...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF5C5148),
                                          fontSize: compact ? 18 : 19.5,
                                          height: 1.55,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 14 : 18),
                                  FadeTransition(
                                    opacity: _headlineFade,
                                    child: SlideTransition(
                                      position: _headlineSlide,
                                      child: Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            color: const Color(0xFF2E2520),
                                            fontSize: compact ? 26 : 31,
                                            height: 1.18,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.9,
                                          ),
                                          children: const <InlineSpan>[
                                            TextSpan(text: 'we help you '),
                                            TextSpan(
                                              text: 'reset',
                                              style: TextStyle(
                                                color: Color(0xFFFF6B9D),
                                              ),
                                            ),
                                            TextSpan(text: '.'),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 24 : 30),
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
                                            horizontal: 20,
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
                                            '2-minute breathing break @ 200 scrolls',
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

class _BreathingAura extends StatelessWidget {
  const _BreathingAura();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            const Color(0xFFFF8C42).withValues(alpha: 0.20),
            const Color(0xFFFF6B9D).withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ),
      ),
    );
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
