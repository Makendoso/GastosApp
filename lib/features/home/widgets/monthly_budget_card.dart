import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/financial_summary.dart';
import '../../../data/models/monthly_budget.dart';

class MonthlyBudgetCard extends StatelessWidget {
  const MonthlyBudgetCard({
    required this.budget,
    required this.summary,
    super.key,
  });

  final MonthlyBudget budget;
  final FinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    final spent = summary.monthExpenses;
    final limit = budget.limit;
    final hasBudget = budget.isConfigured;
    final progress = hasBudget ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final remaining = hasBudget ? limit - spent : 0.0;
    final status = _statusFor(progress, hasBudget, remaining);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(status.icon, color: status.color),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Presupuesto mensual',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Control de gastos del mes',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!hasBudget) ...[
            const _EmptyBudgetState(),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}% usado',
                    style: TextStyle(
                      color: status.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(limit),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(status.color),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _BudgetValue(
                    label: 'Gastado',
                    value: CurrencyFormatter.format(spent),
                  ),
                ),
                Expanded(
                  child: _BudgetValue(
                    label: remaining >= 0 ? 'Disponible' : 'Excedido',
                    value: CurrencyFormatter.format(remaining.abs()),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _BudgetStatusMessage(status: status),
          ],
        ],
      ),
    );
  }

  _BudgetStatus _statusFor(double progress, bool hasBudget, double remaining) {
    if (!hasBudget) {
      return const _BudgetStatus(
        color: AppColors.info,
        icon: Icons.savings_outlined,
        message: 'Define un limite para medir tu avance mensual.',
      );
    }

    if (remaining < 0) {
      return const _BudgetStatus(
        color: AppColors.expense,
        icon: Icons.warning_amber_rounded,
        message: 'Ya superaste tu presupuesto. Conviene revisar tus gastos.',
      );
    }

    if (progress >= 0.85) {
      return const _BudgetStatus(
        color: Color(0xFFF59E0B),
        icon: Icons.error_outline,
        message: 'Estas cerca del limite. Baja el ritmo de gasto.',
      );
    }

    return const _BudgetStatus(
      color: AppColors.info,
      icon: Icons.check_circle_outline,
      message: 'Vas dentro de tu presupuesto mensual.',
    );
  }
}

class _EmptyBudgetState extends StatelessWidget {
  const _EmptyBudgetState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withOpacity(0.14)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 22),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Aun no tienes un limite para este mes.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetValue extends StatelessWidget {
  const _BudgetValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BudgetStatusMessage extends StatelessWidget {
  const _BudgetStatusMessage({required this.status});

  final _BudgetStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: status.color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              status.message,
              style: TextStyle(
                color: status.color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetStatus {
  const _BudgetStatus({
    required this.color,
    required this.icon,
    required this.message,
  });

  final Color color;
  final IconData icon;
  final String message;
}
