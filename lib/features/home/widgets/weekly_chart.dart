import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/movement.dart';
import 'home_section_title.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    required this.movements,
    super.key,
  });

  final List<Movement> movements;

  @override
  Widget build(BuildContext context) {
    final days = _weeklyExpenses(movements);
    final maxExpense = days.fold<double>(
      0,
      (max, day) => day.amount > max ? day.amount : max,
    );
    final total = days.fold<double>(0, (sum, day) => sum + day.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: 'Semana'),
        const SizedBox(height: AppSpacing.xs),
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Gastos semanales',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(total),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 112,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in days) ...[
                      Expanded(
                        child: _DayBar(
                          day: day,
                          maxExpense: maxExpense,
                        ),
                      ),
                      if (day != days.last) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_WeeklyExpense> _weeklyExpenses(List<Movement> movements) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = today.subtract(Duration(days: today.weekday - 1));
    final totals = List<double>.filled(7, 0);

    for (final movement in movements) {
      if (!movement.isExpense) {
        continue;
      }

      final date = DateTime(
        movement.date.year,
        movement.date.month,
        movement.date.day,
      );
      final index = date.difference(firstDay).inDays;

      if (index >= 0 && index < totals.length) {
        totals[index] += movement.amount.abs();
      }
    }

    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return [
      for (var index = 0; index < totals.length; index++)
        _WeeklyExpense(label: labels[index], amount: totals[index]),
    ];
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.maxExpense,
  });

  final _WeeklyExpense day;
  final double maxExpense;

  @override
  Widget build(BuildContext context) {
    final ratio = maxExpense == 0 ? 0.0 : (day.amount / maxExpense);
    final height = 18 + (70 * ratio);
    final hasExpense = day.amount > 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: hasExpense
                    ? AppColors.expense.withOpacity(0.82)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day.label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WeeklyExpense {
  const _WeeklyExpense({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;
}
