import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      backgroundColor: Colors.white,
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 2),
      body: financeState.isLoading && movements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(22, 42, 22, 24),
              children: [
                const StatisticsHeader(),
                const SizedBox(height: AppSpacing.xl),
                if (financeState.errorMessage != null) ...[
                  _StatisticsMessage(message: financeState.errorMessage!),
                  const SizedBox(height: AppSpacing.xl),
                ],
                const PeriodSelector(),
                const SizedBox(height: AppSpacing.xl),
                CategoryBreakdownSection(
                  summary: summary,
                  categories: categories,
                ),
                const SizedBox(height: AppSpacing.xl),
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
        color: const Color(0xFFFFF1F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          style: const TextStyle(
            color: Color(0xFFFF3B64),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
