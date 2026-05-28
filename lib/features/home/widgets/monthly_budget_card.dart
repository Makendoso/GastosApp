import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/financial_summary.dart';
import '../../../data/models/monthly_budget.dart';
import '../../../data/providers/finance_providers.dart';

class MonthlyBudgetCard extends ConsumerWidget {
  const MonthlyBudgetCard({
    required this.budget,
    required this.summary,
    super.key,
  });

  final MonthlyBudget budget;
  final FinancialSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spent = summary.monthExpenses;
    final limit = budget.limit;
    final hasBudget = budget.isConfigured;
    final progress = hasBudget ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final remaining = hasBudget ? limit - spent : 0.0;
    final status = _statusFor(progress, hasBudget, remaining);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(status.icon, color: status.color),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Presupuesto mensual',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18,
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
              TextButton(
                onPressed: () => _showBudgetDialog(context, ref, budget),
                child: Text(hasBudget ? 'Editar' : 'Crear'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (!hasBudget) ...[
            const _EmptyBudgetState(),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showBudgetDialog(context, ref, budget),
                icon: const Icon(Icons.add),
                label: const Text('Definir presupuesto'),
              ),
            ),
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
            const SizedBox(height: AppSpacing.md),
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

  Future<void> _showBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    MonthlyBudget budget,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (_) => _BudgetDialog(
        budget: budget,
        messenger: messenger,
      ),
    );
  }
}

class _BudgetDialog extends ConsumerStatefulWidget {
  const _BudgetDialog({
    required this.budget,
    required this.messenger,
  });

  final MonthlyBudget budget;
  final ScaffoldMessengerState messenger;

  @override
  ConsumerState<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends ConsumerState<_BudgetDialog> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text:
          widget.budget.limit > 0 ? widget.budget.limit.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final value = double.tryParse(_controller.text.trim()) ?? 0;
    setState(() => _isSaving = true);

    try {
      await ref.read(budgetControllerProvider.notifier).saveBudget(value);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      widget.messenger.showSnackBar(
        SnackBar(
          content: Text(
            value <= 0
                ? 'Presupuesto desactivado.'
                : 'Presupuesto actualizado.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      final error = ref.read(budgetControllerProvider).errorMessage;
      widget.messenger.showSnackBar(
        SnackBar(
          content: Text(error ?? 'No se pudo guardar el presupuesto.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Presupuesto mensual'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        enabled: !_isSaving,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        decoration: const InputDecoration(
          labelText: 'Limite del mes',
          prefixText: '\$ ',
          helperText: 'Usa 0 para dejarlo sin presupuesto.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Guardando...' : 'Guardar'),
        ),
      ],
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
