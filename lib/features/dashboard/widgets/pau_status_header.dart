import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../screens/onboarding/onboarding_screen_2.dart';
import '../data/brain_stats_provider.dart';

class PauStatusHeader extends StatefulWidget {
  const PauStatusHeader({super.key, required this.stats});

  final DailyBrainStats stats;

  @override
  State<PauStatusHeader> createState() => _PauStatusHeaderState();
}

class _PauStatusHeaderState extends State<PauStatusHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String pauState = pauStateName(widget.stats.brainState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          brainStateHeadline(widget.stats.brainState),
          style: textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF4A342F),
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatHeadlineDate(widget.stats.date),
          style: textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF9E908A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (BuildContext context, Widget? child) {
              final double wave = math.sin(
                _floatController.value * math.pi * 2,
              );
              return Transform.translate(
                offset: Offset(0, wave * -8),
                child: child,
              );
            },
            child: SizedBox(
              width: 208,
              height: 176,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 164,
                    height: 164,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          _glowColorForState(
                            widget.stats.brainState,
                          ).withValues(alpha: 0.34),
                          const Color(0xFFFFFBF8).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  PauMascot(state: pauState, size: 132),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Color _glowColorForState(BrainState state) {
  switch (state) {
    case BrainState.zen:
      return const Color(0xFFF8D8D0);
    case BrainState.okay:
      return const Color(0xFFFFD8C5);
    case BrainState.drained:
      return const Color(0xFFFFC8D6);
    case BrainState.fried:
      return const Color(0xFFFFB3C8);
    case BrainState.brainrot:
      return const Color(0xFFFFA0B3);
    case BrainState.future:
    case BrainState.empty:
      return const Color(0xFFF7DED6);
  }
}
