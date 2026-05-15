import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_step_header.dart';

class OnboardingScreen14 extends StatefulWidget {
  const OnboardingScreen14({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen14> createState() => _OnboardingScreen14State();
}

class _OnboardingScreen14State extends State<OnboardingScreen14>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardScale;
  late final Animation<double> _buttonsFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _cardFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.06, 0.30, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.06, 0.32, curve: Curves.easeOutCubic),
          ),
        );
    _cardScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.06, 0.34, curve: Curves.easeOutBack),
      ),
    );
    _buttonsFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.24, 0.52, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.38, 0.70, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.38, 0.70, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.66, 0.98, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.66, 0.98, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _entryController.dispose();
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
                currentStep: 14,
                totalSteps: 18,
                onSkip: _handleSkip,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: compact ? 30 : 44,
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
                                  child: SlideTransition(
                                    position: _cardSlide,
                                    child: ScaleTransition(
                                      scale: _cardScale,
                                      child: _AppChoiceDemoCard(
                                        compact: compact,
                                        buttonsFade: _buttonsFade,
                                        onPrimaryTap: _handleDemoTap,
                                        onSecondaryTap: _handleDemoTap,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 42 : 50),
                                FadeTransition(
                                  opacity: _textFade,
                                  child: SlideTransition(
                                    position: _textSlide,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Before opening apps...',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF5C5148),
                                            fontSize: compact ? 18 : 19.5,
                                            height: 1.55,
                                            fontStyle: FontStyle.italic,
                                            fontFamily: 'serif',
                                          ),
                                        ),
                                        SizedBox(height: compact ? 18 : 22),
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              color: const Color(0xFF2E2520),
                                              fontSize: compact ? 25 : 29,
                                              height: 1.18,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.8,
                                            ),
                                            children: const <InlineSpan>[
                                              TextSpan(text: 'you get a '),
                                              TextSpan(
                                                text: 'choice',
                                                style: TextStyle(
                                                  color: Color(0xFFFF8C42),
                                                ),
                                              ),
                                              TextSpan(text: '.'),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: compact ? 10 : 12),
                                        RichText(
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
                                              TextSpan(text: 'Enter '),
                                              TextSpan(
                                                text: 'consciously',
                                                style: TextStyle(
                                                  color: Color(0xFFFF6B9D),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              TextSpan(text: ' or walk away.'),
                                            ],
                                          ),
                                        ),
                                      ],
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

  void _handleDemoTap() {
    HapticFeedback.lightImpact();
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

class _AppChoiceDemoCard extends StatelessWidget {
  const _AppChoiceDemoCard({
    required this.compact,
    required this.buttonsFade,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final bool compact;
  final Animation<double> buttonsFade;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 20 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFFFFFF), Color(0xFFFFF5F7)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE5EC), width: 1.6),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14FF6B9D),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x122E2520),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            '\u{1F4F1}',
            style: TextStyle(fontSize: compact ? 42 : 46, height: 1),
          ),
          const SizedBox(height: 14),
          Text(
            'Opening Instagram...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF2E2520),
              fontSize: compact ? 17 : 18,
              height: 1.45,
              fontStyle: FontStyle.italic,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Do you really want to?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          FadeTransition(
            opacity: buttonsFade,
            child: Column(
              children: <Widget>[
                _DemoActionButton(
                  label: 'Yes, open it',
                  filled: true,
                  onPressed: onPrimaryTap,
                ),
                const SizedBox(height: 10),
                _DemoActionButton(
                  label: 'No, go back',
                  filled: false,
                  onPressed: onSecondaryTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoActionButton extends StatefulWidget {
  const _DemoActionButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  State<_DemoActionButton> createState() => _DemoActionButtonState();
}

class _DemoActionButtonState extends State<_DemoActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: widget.filled
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[Color(0xFFFF8C42), Color(0xFFFF6B9D)],
                    )
                  : null,
              color: widget.filled ? null : Colors.transparent,
              border: widget.filled
                  ? null
                  : Border.all(color: const Color(0x338B8B8B), width: 1.5),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: widget.filled ? Colors.white : const Color(0xFF8B8B8B),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
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
