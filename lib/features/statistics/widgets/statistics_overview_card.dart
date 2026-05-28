import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/providers/finance_providers.dart';

class StatisticsOverviewCard extends StatelessWidget {
  const StatisticsOverviewCard({
    required this.overview,
    super.key,
  });

  final StatisticsOverview overview;

  @override
  Widget build(BuildContext context) {
    final difference = overview.difference;
    final differenceColor = difference > 0
        ? AppColors.expense
        : difference < 0
            ? AppColors.income
            : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  overview.period.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final cards = [
                _MetricTile(
                  label: overview.period.currentLabel,
                  value: CurrencyFormatter.format(
                    overview.currentExpenses,
                  ),
                  icon: Icons.calendar_today_outlined,
                  color: AppColors.expense,
                ),
                _MetricTile(
                  label: overview.period.previousLabel,
                  value: CurrencyFormatter.format(
                    overview.previousExpenses,
                  ),
                  icon: Icons.history_outlined,
                  color: AppColors.info,
                ),
                _MetricTile(
                  label: 'Promedio diario',
                  value: CurrencyFormatter.format(overview.dailyAverage),
                  icon: Icons.today_outlined,
                  color: AppColors.warning,
                ),
                _MetricTile(
                  label: 'Categoria principal',
                  value: overview.topCategoryName ?? 'Sin gastos',
                  detail: overview.topCategoryName == null
                      ? null
                      : CurrencyFormatter.format(overview.topCategoryAmount),
                  icon: Icons.local_offer_outlined,
                  color: AppColors.primary,
                ),
              ];

              if (compact) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              }

              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final card in cards)
                    SizedBox(
                      width: (constraints.maxWidth - AppSpacing.sm) / 2,
                      child: card,
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _InsightBox(
            message: overview.insight,
            difference: difference,
            color: differenceColor,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.detail,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBox extends StatelessWidget {
  const _InsightBox({
    required this.message,
    required this.difference,
    required this.color,
  });

  final String message;
  final double difference;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$message ${_differenceText(difference)}',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _differenceText(double difference) {
    if (difference == 0) {
      return 'Diferencia: \$0.00.';
    }

    final direction = difference > 0 ? 'mas' : 'menos';
    return 'Diferencia: ${CurrencyFormatter.format(difference.abs())} $direction.';
  }
}
