import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_screen_2.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen10 extends StatefulWidget {
  const OnboardingScreen10({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen10> createState() => _OnboardingScreen10State();
}

class _OnboardingScreen10State extends State<OnboardingScreen10>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _glowController;
  late final AnimationController _floatController;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotScale;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _supportingFade;
  late final Animation<Offset> _supportingSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _mascotFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.06, 0.28, curve: Curves.easeOut),
    );
    _mascotScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.06, 0.34, curve: ElasticOutCurve(0.90)),
      ),
    );
    _headlineFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.26, 0.54, curve: Curves.easeOut),
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.26, 0.54, curve: Curves.easeOutCubic),
          ),
        );
    _supportingFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.42, 0.70, curve: Curves.easeOut),
    );
    _supportingSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.42, 0.70, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.66, 0.96, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.66, 0.96, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowController.dispose();
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
            colors: <Color>[Color(0x4DFFE5EC), Color(0xFFF7F3EE)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 12),
                OnboardingTopBar(
                  currentStep: 10,
                  totalSteps: 18,
                  onSkip: _handleSkip,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: compact ? 26 : 38,
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
                                            _glowController,
                                            _floatController,
                                          ],
                                        ),
                                        builder:
                                            (
                                              BuildContext context,
                                              Widget? child,
                                            ) {
                                              final double glowWave = math.sin(
                                                _glowController.value *
                                                    math.pi *
                                                    2,
                                              );
                                              final double glowScale =
                                                  1.1 +
                                                  ((glowWave + 1) / 2) * 0.2;
                                              final double glowOpacity =
                                                  0.20 +
                                                  ((glowWave + 1) / 2) * 0.20;

                                              final double floatWave = math.sin(
                                                _floatController.value *
                                                    math.pi *
                                                    2,
                                              );
                                              final double floatOffset =
                                                  floatWave * -5;
                                              final double breatheScale =
                                                  1.0 +
                                                  (((floatWave + 1) / 2) *
                                                      0.025);

                                              return Transform.translate(
                                                offset: Offset(0, floatOffset),
                                                child: Transform.scale(
                                                  scale: breatheScale,
                                                  child: SizedBox(
                                                    width: compact ? 220 : 240,
                                                    height: compact ? 190 : 210,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        Opacity(
                                                          opacity: glowOpacity,
                                                          child: Transform.scale(
                                                            scale: glowScale,
                                                            child:
                                                                const _GlowAura(),
                                                          ),
                                                        ),
                                                        child!,
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                        child: PauMascot(
                                          state: 'healing',
                                          size: compact ? 148 : 158,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 30 : 40),
                                  FadeTransition(
                                    opacity: _headlineFade,
                                    child: SlideTransition(
                                      position: _headlineSlide,
                                      child: Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            color: const Color(0xFF2E2520),
                                            fontSize: compact ? 28 : 33,
                                            height: 1.18,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -1.0,
                                          ),
                                          children: const <InlineSpan>[
                                            TextSpan(
                                              text: 'Pauze helps you take\n',
                                            ),
                                            TextSpan(
                                              text: 'control',
                                              style: TextStyle(
                                                color: Color(0xFFFF8C42),
                                              ),
                                            ),
                                            TextSpan(text: ' back.'),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 20 : 26),
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
                                            height: 1.55,
                                            fontStyle: FontStyle.italic,
                                            fontFamily: 'serif',
                                          ),
                                          children: const <InlineSpan>[
                                            TextSpan(
                                              text: 'You decide',
                                              style: TextStyle(
                                                color: Color(0xFFFF6B9D),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            TextSpan(text: ' when to stop.'),
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

class _GlowAura extends StatelessWidget {
  const _GlowAura();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 190,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            Color(0x2EFF8C42),
            Color(0x1FFF6B9D),
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
