import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/category.dart';
import '../../../data/models/financial_summary.dart';
import 'category_expense_chart.dart';
import 'category_expense_list.dart';

class CategoryBreakdownSection extends StatelessWidget {
  const CategoryBreakdownSection({
    required this.summary,
    required this.categories,
    super.key,
  });

  final FinancialSummary summary;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final expenseByCategory = summary.expenseByCategory;

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
          const Row(
            children: [
              Icon(Icons.donut_small_outlined, color: AppColors.expense),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Gastos por categoria',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (expenseByCategory.isEmpty)
            const _EmptyStatsState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;

                if (isCompact) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 210,
                        child: CategoryExpenseChart(
                          categories: categories,
                          expenseByCategory: expenseByCategory,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CategoryExpenseList(
                        categories: categories,
                        expenseByCategory: expenseByCategory,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 8,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CategoryExpenseChart(
                          categories: categories,
                          expenseByCategory: expenseByCategory,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 9,
                      child: CategoryExpenseList(
                        categories: categories,
                        expenseByCategory: expenseByCategory,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EmptyStatsState extends StatelessWidget {
  const _EmptyStatsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.bar_chart_outlined, color: AppColors.textMuted, size: 34),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Sin estadisticas todavia',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Registra gastos para ver el desglose por categoria.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
