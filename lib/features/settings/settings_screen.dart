import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/category.dart';
import '../../data/providers/finance_providers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
      ),
      body: const SettingsPanel(),
    );
  }
}

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({
    super.key,
    this.showTitle = true,
  });

  final bool showTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetControllerProvider);
    final budget = ref.watch(monthlyBudgetProvider);
    final categories = ref.watch(categoriesProvider);
    final categoryState = ref.watch(categoryControllerProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        if (showTitle) ...[
          const Text(
            'Ajustes',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _SettingsSection(
          title: 'Presupuesto mensual',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                icon: Icons.savings_outlined,
                title: 'Monto base mensual',
                subtitle: budget.isConfigured
                    ? CurrencyFormatter.format(budget.limit)
                    : 'Sin presupuesto definido',
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: budgetState.isProcessing
                      ? null
                      : () => showDialog<void>(
                            context: context,
                            builder: (_) => const _BudgetDialog(),
                          ),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(
                    budget.isConfigured
                        ? 'Editar presupuesto'
                        : 'Definir presupuesto',
                  ),
                ),
              ),
              if (budgetState.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _InlineMessage(
                  message: budgetState.errorMessage!,
                  color: AppColors.expense,
                ),
              ],
            ],
          ),
        ),
        _SettingsSection(
          title: 'Categorias',
          child: categoryState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryGroup(
                      title: 'Gastos',
                      categories: categories
                          .where((category) => category.type?.name == 'expense')
                          .toList(growable: false),
                    ),
                    _CategoryGroup(
                      title: 'Ingresos',
                      categories: categories
                          .where((category) => category.type?.name == 'income')
                          .toList(growable: false),
                    ),
                    _CategoryGroup(
                      title: 'General',
                      categories: categories
                          .where((category) => category.type == null)
                          .toList(growable: false),
                    ),
                    if (categoryState.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _InlineMessage(
                        message: categoryState.errorMessage!,
                        color: AppColors.expense,
                      ),
                    ],
                  ],
                ),
        ),
        _SettingsSection(
          title: 'Limpiar datos',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Borra movimientos, presupuesto y categorias configuradas. '
                'Las categorias base se restauran automaticamente.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const _ClearDataDialog(),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Limpiar datos de la app'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.expense,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetDialog extends ConsumerStatefulWidget {
  const _BudgetDialog();

  @override
  ConsumerState<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends ConsumerState<_BudgetDialog> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final budget = ref.read(monthlyBudgetProvider);
    _controller = TextEditingController(
      text: budget.limit > 0 ? budget.limit.toStringAsFixed(2) : '',
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
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    try {
      await ref.read(budgetControllerProvider.notifier).saveBudget(value);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      messenger.showSnackBar(
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
      messenger.showSnackBar(
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

class _ClearDataDialog extends ConsumerStatefulWidget {
  const _ClearDataDialog();

  @override
  ConsumerState<_ClearDataDialog> createState() => _ClearDataDialogState();
}

class _ClearDataDialogState extends ConsumerState<_ClearDataDialog> {
  late final TextEditingController _controller;
  bool _isClearing = false;

  bool get _canClear => _controller.text.trim().toUpperCase() == 'BORRAR';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_refresh);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  Future<void> _clearData() async {
    if (!_canClear || _isClearing) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isClearing = true);

    try {
      await ref.read(appMaintenanceProvider).clearAppData();
      await ref.read(financeControllerProvider.notifier).load();
      await ref.read(categoryControllerProvider.notifier).load();
      await ref.read(budgetControllerProvider.notifier).load();
      ref.read(historyFilterProvider.notifier).state =
          const HistoryFilterState();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Datos limpiados.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isClearing = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudieron limpiar los datos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Limpiar datos'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esta accion borrara movimientos, presupuesto y categorias '
            'configuradas. Escribe BORRAR para confirmar.',
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            enabled: !_isClearing,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Confirmacion',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isClearing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _canClear && !_isClearing ? _clearData : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.expense,
          ),
          child: Text(_isClearing ? 'Limpiando...' : 'Limpiar'),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.10),
          foregroundColor: AppColors.primary,
          child: Icon(icon),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({
    required this.title,
    required this.categories,
  });

  final String title;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final category in categories) _CategoryTile(category: category),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: category.color.withOpacity(0.12),
        foregroundColor: category.color,
        child: Icon(category.icon),
      ),
      title: Text(category.name),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    required this.color,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
