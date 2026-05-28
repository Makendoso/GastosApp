import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/financial_summary.dart';
import '../../../data/models/monthly_budget.dart';
import '../../../data/models/movement.dart';
import 'summary_card.dart';

class SummaryCardsRow extends StatelessWidget {
  const SummaryCardsRow({
    required this.summary,
    required this.budget,
    required this.movements,
    super.key,
  });

  final FinancialSummary summary;
  final MonthlyBudget budget;
  final List<Movement> movements;

  @override
  Widget build(BuildContext context) {
    final budgetProgress =
        budget.isConfigured ? summary.monthExpenses / budget.limit : 0.0;
    final todayExpense = _todayExpense(movements);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.48,
      children: [
        SummaryCard(
          title: 'Ingresos',
          value: summary.income,
          color: AppColors.income,
          icon: Icons.arrow_upward,
          backgroundColor: const Color(0xFFEFFDF4),
          indicatorColor: const Color(0xFFDCFCE7),
          caption: 'Este mes',
        ),
        SummaryCard(
          title: 'Gastos',
          value: summary.expenses,
          color: AppColors.expense,
          icon: Icons.arrow_downward,
          backgroundColor: const Color(0xFFFFF1F6),
          indicatorColor: const Color(0xFFFFB3C2),
          caption: 'Este mes',
        ),
        SummaryCard(
          title: 'Presupuesto',
          value: budgetProgress.clamp(0.0, 9.99),
          color: AppColors.info,
          icon: Icons.pie_chart_outline,
          backgroundColor: const Color(0xFFEFF6FF),
          indicatorColor: const Color(0xFFDBEAFE),
          caption: budget.isConfigured ? 'Usado' : 'Sin limite',
          isPercent: true,
        ),
        SummaryCard(
          title: 'Hoy',
          value: todayExpense,
          color: AppColors.warning,
          icon: Icons.today_outlined,
          backgroundColor: const Color(0xFFFFFBEB),
          indicatorColor: const Color(0xFFFEF3C7),
          caption: 'Gasto del dia',
        ),
      ],
    );
  }

  double _todayExpense(List<Movement> movements) {
    final now = DateTime.now();

    return movements
        .where(
          (movement) =>
              movement.isExpense &&
              movement.date.year == now.year &&
              movement.date.month == now.month &&
              movement.date.day == now.day,
        )
        .fold<double>(0, (total, movement) => total + movement.amount.abs());
  }
}
