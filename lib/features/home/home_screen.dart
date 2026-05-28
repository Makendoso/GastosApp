import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/providers/finance_providers.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import 'widgets/balance_card.dart';
import 'widgets/home_header.dart';
import 'widgets/monthly_budget_card.dart';
import 'widgets/recent_movements_section.dart';
import 'widgets/summary_cards_row.dart';
import 'widgets/weekly_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeControllerProvider);
    final summary = ref.watch(financialSummaryProvider);
    final movements = ref.watch(movementsProvider);
    final budgetState = ref.watch(budgetControllerProvider);
    final budget = ref.watch(monthlyBudgetProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: () {},
          icon: const Icon(Icons.menu, size: 28),
        ),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, size: 26),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 0),
      body: financeState.isLoading && movements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : financeState.errorMessage != null && movements.isEmpty
              ? _HomeMessage(
                  message: financeState.errorMessage!,
                  icon: Icons.error_outline,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    const HomeHeader(userName: 'Andres'),
                    const SizedBox(height: AppSpacing.md),
                    if (financeState.errorMessage != null) ...[
                      _InlineError(message: financeState.errorMessage!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    BalanceCard(summary: summary),
                    const SizedBox(height: AppSpacing.md),
                    SummaryCardsRow(
                      summary: summary,
                      budget: budget,
                      movements: movements,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (budgetState.errorMessage != null) ...[
                      _InlineError(message: budgetState.errorMessage!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    MonthlyBudgetCard(
                      budget: budget,
                      summary: summary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    WeeklyChart(movements: movements),
                    const SizedBox(height: AppSpacing.md),
                    RecentMovementsSection(
                      movements: financeState.recentMovements,
                    ),
                  ],
                ),
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
    required this.message,
    required this.icon,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6B7280), size: 38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

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
