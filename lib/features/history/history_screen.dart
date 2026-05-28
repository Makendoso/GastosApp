import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters/date_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/category.dart';
import '../../data/models/movement.dart';
import '../../data/providers/finance_providers.dart';
import 'widgets/movement_history_list.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(historyFilterProvider).query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financeState = ref.watch(financeControllerProvider);
    final movements = ref.watch(movementsProvider);
    final filteredMovements = ref.watch(filteredMovementsProvider);
    final filter = ref.watch(historyFilterProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Filtros',
            onPressed: () => _showFilterSheet(context, filter, categories),
            icon: Badge(
              isLabelVisible: filter.hasFilters,
              smallSize: 8,
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: financeState.isLoading && movements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : financeState.errorMessage != null && movements.isEmpty
              ? _HistoryMessage(message: financeState.errorMessage!)
              : Column(
                  children: [
                    _HistorySearchField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref.read(historyFilterProvider.notifier).state =
                            ref.read(historyFilterProvider).copyWith(
                                  query: value,
                                );
                      },
                      onClear: filter.query.trim().isEmpty
                          ? null
                          : () {
                              _searchController.clear();
                              ref.read(historyFilterProvider.notifier).state =
                                  ref.read(historyFilterProvider).copyWith(
                                        query: '',
                                      );
                            },
                    ),
                    Expanded(
                      child: filteredMovements.isEmpty
                          ? _HistoryEmptyState(
                              hasMovements: movements.isNotEmpty,
                              hasFilters: filter.hasFilters,
                              onClearFilters: filter.hasFilters
                                  ? () {
                                      _searchController.clear();
                                      ref
                                          .read(
                                            historyFilterProvider.notifier,
                                          )
                                          .state = const HistoryFilterState();
                                    }
                                  : null,
                            )
                          : MovementHistoryList(
                              movements: filteredMovements,
                              isProcessing: financeState.isProcessing,
                              onDelete: (id) {
                                return ref
                                    .read(financeControllerProvider.notifier)
                                    .deleteMovement(id);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _showFilterSheet(
    BuildContext context,
    HistoryFilterState filter,
    List<Category> categories,
  ) {
    var draft = filter;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _TypeFilter(
                      value: draft.type,
                      onChanged: (value) {
                        setSheetState(() {
                          draft = draft.copyWith(
                            type: value,
                            clearType: value == null,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: draft.categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        for (final category in categories)
                          DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                      ],
                      onChanged: (value) {
                        setSheetState(() {
                          draft = draft.copyWith(
                            categoryId: value,
                            clearCategory: value == null,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _DateFilterButton(
                            label: 'Desde',
                            date: draft.startDate,
                            onTap: () async {
                              final date = await _pickFilterDate(
                                context,
                                draft.startDate,
                              );
                              if (date == null) {
                                return;
                              }
                              setSheetState(() {
                                draft = draft.copyWith(startDate: date);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _DateFilterButton(
                            label: 'Hasta',
                            date: draft.endDate,
                            onTap: () async {
                              final date = await _pickFilterDate(
                                context,
                                draft.endDate,
                              );
                              if (date == null) {
                                return;
                              }
                              setSheetState(() {
                                draft = draft.copyWith(endDate: date);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              draft = HistoryFilterState(query: draft.query);
                            });
                          },
                          child: const Text('Limpiar'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            ref.read(historyFilterProvider.notifier).state =
                                draft;
                            Navigator.pop(context);
                          },
                          child: const Text('Aplicar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<DateTime?> _pickFilterDate(
    BuildContext context,
    DateTime? initialDate,
  ) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }
}

class _HistorySearchField extends StatelessWidget {
  const _HistorySearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar movimientos',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  tooltip: 'Limpiar busqueda',
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _TypeFilter extends StatelessWidget {
  const _TypeFilter({
    required this.value,
    required this.onChanged,
  });

  final MovementType? value;
  final ValueChanged<MovementType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        ChoiceChip(
          label: const Text('Todos'),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
        ChoiceChip(
          label: const Text('Gastos'),
          selected: value == MovementType.expense,
          onSelected: (_) => onChanged(MovementType.expense),
        ),
        ChoiceChip(
          label: const Text('Ingresos'),
          selected: value == MovementType.income,
          onSelected: (_) => onChanged(MovementType.income),
        ),
      ],
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.event),
      label: Text(date == null ? label : DateFormatter.short(date!)),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({
    required this.hasMovements,
    required this.hasFilters,
    required this.onClearFilters,
  });

  final bool hasMovements;
  final bool hasFilters;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final title = hasMovements && hasFilters
        ? 'No hay resultados'
        : 'Aun no hay movimientos';
    final message = hasMovements && hasFilters
        ? 'Prueba con otra busqueda o ajusta los filtros.'
        : 'Cuando registres ingresos o gastos apareceran aqui.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasMovements && hasFilters
                  ? Icons.manage_search
                  : Icons.receipt_long,
              color: AppColors.textMuted,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onClearFilters != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: onClearFilters,
                child: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
