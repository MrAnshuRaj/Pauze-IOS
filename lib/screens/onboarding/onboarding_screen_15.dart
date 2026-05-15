import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_step_header.dart';

class OnboardingScreen15 extends StatefulWidget {
  const OnboardingScreen15({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen15> createState() => _OnboardingScreen15State();
}

class _OnboardingScreen15State extends State<OnboardingScreen15>
    with TickerProviderStateMixin {
  static const List<WeeklyDemoData> _demoData = <WeeklyDemoData>[
    WeeklyDemoData('Mon', 80),
    WeeklyDemoData('Tue', 120),
    WeeklyDemoData('Wed', 100),
    WeeklyDemoData('Thu', 60),
    WeeklyDemoData('Fri', 140),
    WeeklyDemoData('Sat', 90),
    WeeklyDemoData('Sun', 70),
  ];

  late final AnimationController _entryController;
  late final Animation<double> _cardFade;
  late final Animation<double> _cardScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    )..forward();

    _cardFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.04, 0.28, curve: Curves.easeOut),
    );
    _cardScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.04, 0.32, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.42, 0.72, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.42, 0.72, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.68, 0.98, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.68, 0.98, curve: Curves.easeOutCubic),
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
                currentStep: 15,
                totalSteps: 18,
                onSkip: _handleSkip,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: compact ? 26 : 40,
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
                                    child: _WeeklyAnalyticsCard(
                                      compact: compact,
                                      animation: _entryController,
                                      data: _demoData,
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 38 : 46),
                                FadeTransition(
                                  opacity: _textFade,
                                  child: SlideTransition(
                                    position: _textSlide,
                                    child: Column(
                                      children: <Widget>[
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              color: const Color(0xFF2E2520),
                                              fontSize: compact ? 25 : 30,
                                              height: 1.18,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.9,
                                            ),
                                            children: const <InlineSpan>[
                                              TextSpan(text: 'See your '),
                                              TextSpan(
                                                text: 'progress',
                                                style: TextStyle(
                                                  color: Color(0xFFFF8C42),
                                                ),
                                              ),
                                              TextSpan(text: '.'),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: compact ? 6 : 8),
                                        Text(
                                          'Track your habits.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF2E2520),
                                            fontSize: compact ? 22 : 25,
                                            height: 1.2,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.7,
                                          ),
                                        ),
                                        SizedBox(height: compact ? 10 : 12),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: const Color(0xFF5C5148),
                                              fontSize: compact ? 18 : 19,
                                              height: 1.55,
                                              fontStyle: FontStyle.italic,
                                              fontFamily: 'serif',
                                            ),
                                            children: const <InlineSpan>[
                                              TextSpan(text: 'Take '),
                                              TextSpan(
                                                text: 'control',
                                                style: TextStyle(
                                                  color: Color(0xFFFF6B9D),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              TextSpan(text: ' back.'),
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

  void _handleNext() {
    HapticFeedback.lightImpact();
    widget.onNext();
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    widget.onSkip();
  }
}

class _WeeklyAnalyticsCard extends StatelessWidget {
  const _WeeklyAnalyticsCard({
    required this.compact,
    required this.animation,
    required this.data,
  });

  final bool compact;
  final Animation<double> animation;
  final List<WeeklyDemoData> data;

  @override
  Widget build(BuildContext context) {
    final double maxValue = data
        .map((WeeklyDemoData item) => item.value)
        .reduce(math.max);

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
        border: Border.all(color: const Color(0xFFFFE5EC), width: 1.5),
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
          Row(
            children: const <Widget>[
              Expanded(
                child: _AnalyticsSummary(
                  label: 'Weekly Scrolls',
                  value: '660',
                  valueColor: Color(0xFFFF6B9D),
                  alignment: CrossAxisAlignment.start,
                ),
              ),
              Expanded(
                child: _AnalyticsSummary(
                  label: 'Avg per day',
                  value: '94',
                  valueColor: Color(0xFFFF8C42),
                  alignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 20 : 24),
          SizedBox(
            height: compact ? 122 : 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(data.length, (int index) {
                final WeeklyDemoData item = data[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == data.length - 1 ? 0 : 7,
                    ),
                    child: _DemoBar(
                      item: item,
                      maxValue: maxValue,
                      compact: compact,
                      animation: animation,
                      index: index,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsSummary extends StatelessWidget {
  const _AnalyticsSummary({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.alignment,
  });

  final String label;
  final String value;
  final Color valueColor;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 22,
            height: 1.0,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _DemoBar extends StatelessWidget {
  const _DemoBar({
    required this.item,
    required this.maxValue,
    required this.compact,
    required this.animation,
    required this.index,
  });

  final WeeklyDemoData item;
  final double maxValue;
  final bool compact;
  final Animation<double> animation;
  final int index;

  @override
  Widget build(BuildContext context) {
    final double start = (0.14 + (index * 0.08)).clamp(0.0, 1.0);
    final double end = (start + 0.28).clamp(0.0, 1.0);
    final Animation<double> grow = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );
    final double maxHeight = compact ? 86 : 96;
    final double targetHeight = (item.value / maxValue) * maxHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: maxHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: grow,
              builder: (BuildContext context, Widget? child) {
                final double height = targetHeight * grow.value;
                return Container(
                  width: double.infinity,
                  height: height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFFFF8C42), Color(0xFFFF6B9D)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.day,
          style: const TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 10,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class WeeklyDemoData {
  const WeeklyDemoData(this.day, this.value);

  final String day;
  final double value;
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
