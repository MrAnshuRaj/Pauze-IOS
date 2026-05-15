import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../screens/onboarding/onboarding_screen_2.dart';
import '../data/brain_stats_provider.dart';

class BrainHealthCalendar extends StatelessWidget {
  const BrainHealthCalendar({
    super.key,
    required this.month,
    required this.monthStats,
    required this.selectedDate,
    required this.onDaySelected,
  });

  final DateTime month;
  final Map<DateTime, DailyBrainStats> monthStats;
  final DateTime? selectedDate;
  final ValueChanged<DailyBrainStats> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final DateTime firstDay = DateTime(month.year, month.month);
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final int leadingEmptyDays = firstDay.weekday % 7;
    final List<Widget> dayCells = <Widget>[];

    for (int index = 0; index < leadingEmptyDays; index++) {
      dayCells.add(const SizedBox(height: 42));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(month.year, month.month, day);
      final DailyBrainStats stats =
          monthStats[date] ??
          DailyBrainStats(
            date: date,
            brainLoad: 0,
            timeSpent: Duration.zero,
            pickups: 0,
            notifications: 0,
            appStats: const <String, AppBrainStats>{},
            brainState: date.isAfter(normalizeDate(DateTime.now()))
                ? BrainState.future
                : BrainState.empty,
          );

      dayCells.add(
        _CalendarDayCell(
          stats: stats,
          isSelected: selectedDate != null && isSameDate(selectedDate!, date),
          onTap: stats.brainState == BrainState.future
              ? null
              : () async {
                  await HapticFeedback.selectionClick();
                  onDaySelected(stats);
                },
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFE6E0)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F25120B),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                _WeekdayHeader(label: 'S'),
                _WeekdayHeader(label: 'M'),
                _WeekdayHeader(label: 'T'),
                _WeekdayHeader(label: 'W'),
                _WeekdayHeader(label: 'T'),
                _WeekdayHeader(label: 'F'),
                _WeekdayHeader(label: 'S'),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 6,
              childAspectRatio: 0.95,
              children: dayCells,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFA89893),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.stats,
    required this.isSelected,
    required this.onTap,
  });

  final DailyBrainStats stats;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool interactive = onTap != null;
    final bool showIcon = stats.brainState != BrainState.future;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? const Color(0x1FFFA1B8) : Colors.transparent,
          ),
          child: Center(
            child: showIcon
                ? Opacity(
                    opacity: interactive ? 1 : 0.72,
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: PauMascot(
                        state: pauStateName(stats.brainState),
                        size: 26,
                      ),
                    ),
                  )
                : Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: <Color>[Color(0xFFFFD1C1), Color(0xFFF7B6A1)],
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(color: Color(0x24FFBFA9), blurRadius: 8),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
