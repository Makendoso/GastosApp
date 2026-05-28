import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/providers/finance_providers.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import 'widgets/category_breakdown_section.dart';
import 'widgets/expense_evolution_card.dart';
import 'widgets/period_selector.dart';
import 'widgets/statistics_header.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeControllerProvider);
    final summary = ref.watch(financialSummaryProvider);
    final movements = ref.watch(movementsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 2),
      body: financeState.isLoading && movements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 34, 18, 20),
              children: [
                const StatisticsHeader(),
                const SizedBox(height: AppSpacing.lg),
                if (financeState.errorMessage != null) ...[
                  _StatisticsMessage(message: financeState.errorMessage!),
                  const SizedBox(height: AppSpacing.lg),
                ],
                const PeriodSelector(),
                const SizedBox(height: AppSpacing.lg),
                CategoryBreakdownSection(
                  summary: summary,
                  categories: categories,
                ),
                const SizedBox(height: AppSpacing.lg),
                const ExpenseEvolutionCard(),
              ],
            ),
    );
  }
}

class _StatisticsMessage extends StatelessWidget {
  const _StatisticsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.expense.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.expense.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.expense,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
