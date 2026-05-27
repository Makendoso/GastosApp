import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/financial_summary.dart';
import 'summary_card.dart';

class SummaryCardsRow extends StatelessWidget {
  const SummaryCardsRow({
    required this.summary,
    super.key,
  });

  final FinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            title: 'Ingresos',
            amount: summary.income,
            color: AppColors.income,
            icon: Icons.arrow_upward,
            backgroundColor: const Color(0xFFEFF9FC),
            indicatorColor: const Color(0xFFA8E9BB),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: SummaryCard(
            title: 'Gastos',
            amount: summary.expenses,
            color: AppColors.expense,
            icon: Icons.arrow_downward,
            backgroundColor: const Color(0xFFFFF1F6),
            indicatorColor: const Color(0xFFFFB3C2),
          ),
        ),
      ],
    );
  }
}
