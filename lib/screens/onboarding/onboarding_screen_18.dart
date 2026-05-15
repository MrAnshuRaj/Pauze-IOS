import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_step_header.dart';

class OnboardingScreen18 extends StatefulWidget {
  const OnboardingScreen18({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen18> createState() => _OnboardingScreen18State();
}

class _OnboardingScreen18State extends State<OnboardingScreen18>
    with TickerProviderStateMixin {
  static const List<OnboardingFeature> _features = <OnboardingFeature>[
    OnboardingFeature('\u{1F4CA}', 'Track every scroll & app open'),
    OnboardingFeature('\u23F0', 'Smart interruptions at key moments'),
    OnboardingFeature('\u{1F9D8}', 'Guided breathing breaks'),
    OnboardingFeature('\u{1F4F1}', 'App open warnings'),
    OnboardingFeature('\u{1F4C8}', 'Weekly analytics & insights'),
    OnboardingFeature('\u{1F3AF}', 'Custom limits & goals'),
  ];

  late final AnimationController _entryController;
  late final AnimationController _ctaGlowController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..forward();
    _ctaGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _headerFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.04, 0.26, curve: Curves.easeOut),
    );
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.04, 0.26, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.18, 0.40, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, -0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.18, 0.40, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.56, 0.88, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.56, 0.88, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _ctaGlowController.dispose();
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
                currentStep: 18,
                totalSteps: 18,
                onSkip: _handleSkip,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: compact ? 18 : 26,
                        bottom: compact ? 18 : 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FadeTransition(
                              opacity: _headerFade,
                              child: SlideTransition(
                                position: _headerSlide,
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: const Color(0xFF2E2520),
                                      fontSize: compact ? 28 : 33,
                                      height: 1.14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.9,
                                    ),
                                    children: const <InlineSpan>[
                                      TextSpan(text: 'Build a '),
                                      TextSpan(
                                        text: 'healthier',
                                        style: TextStyle(
                                          color: Color(0xFFFF8C42),
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '\nrelationship\nwith your screen.',
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 12 : 16),
                            FadeTransition(
                              opacity: _subtitleFade,
                              child: SlideTransition(
                                position: _subtitleSlide,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: const Color(0xFF5C5148),
                                      fontSize: compact ? 17 : 18,
                                      height: 1.55,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'serif',
                                    ),
                                    children: const <InlineSpan>[
                                      TextSpan(text: 'Try Pauze '),
                                      TextSpan(
                                        text: 'today',
                                        style: TextStyle(
                                          color: Color(0xFFFF6B9D),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 24 : 30),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 340),
                              child: Column(
                                children: List<Widget>.generate(
                                  _features.length,
                                  (int index) {
                                    final OnboardingFeature feature =
                                        _features[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index == _features.length - 1
                                            ? 0
                                            : 12,
                                      ),
                                      child: _AnimatedFeatureRow(
                                        feature: feature,
                                        animation: _entryController,
                                        index: index,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
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
                    child: _FinalCtaButton(
                      animation: _ctaGlowController,
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

class _AnimatedFeatureRow extends StatelessWidget {
  const _AnimatedFeatureRow({
    required this.feature,
    required this.animation,
    required this.index,
  });

  final OnboardingFeature feature;
  final Animation<double> animation;
  final int index;

  @override
  Widget build(BuildContext context) {
    final double start = (0.24 + (index * 0.05)).clamp(0.0, 1.0);
    final double end = (start + 0.22).clamp(0.0, 1.0);
    final Animation<double> fade = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final Animation<Offset> slide =
        Tween<Offset>(begin: const Offset(-0.08, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE5EC).withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFB6C1).withValues(alpha: 0.30),
            ),
          ),
          child: Row(
            children: <Widget>[
              Text(
                feature.icon,
                style: const TextStyle(fontSize: 22, height: 1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  feature.text,
                  style: const TextStyle(
                    color: Color(0xFF2E2520),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalCtaButton extends StatefulWidget {
  const _FinalCtaButton({required this.animation, required this.onPressed});

  final Animation<double> animation;
  final VoidCallback onPressed;

  @override
  State<_FinalCtaButton> createState() => _FinalCtaButtonState();
}

class _FinalCtaButtonState extends State<_FinalCtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Color(0xFFFF8C42), Color(0xFFFF6B9D)],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x332E2520),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                AnimatedBuilder(
                  animation: widget.animation,
                  builder: (BuildContext context, Widget? child) {
                    final double wave = math.sin(
                      widget.animation.value * math.pi * 2,
                    );
                    final double scale = 1.0 + (((wave + 1) / 2) * 0.35);
                    final double opacity = 0.12 + (((wave + 1) / 2) * 0.10);

                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.7,
                        colors: <Color>[Color(0xAAFFFFFF), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Start Pauze',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingFeature {
  const OnboardingFeature(this.icon, this.text);

  final String icon;
  final String text;
}
