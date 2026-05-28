import 'package:flutter/material.dart';

import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/movement.dart';
import '../../add_expense/add_expense_screen.dart';
import '../../shared/widgets/movement_tile.dart';

class MovementHistoryList extends StatelessWidget {
  const MovementHistoryList({
    required this.movements,
    required this.onDelete,
    this.isProcessing = false,
    super.key,
  });

  final List<Movement> movements;
  final Future<void> Function(String id) onDelete;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    if (movements.isEmpty) {
      return const Center(
        child: Text(
          'Aun no hay movimientos',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final items = _groupMovements(movements);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, AppSpacing.md),
      itemCount: items.length,
      separatorBuilder: (_, index) {
        return items[index].isHeader || items[index + 1].isHeader
            ? const SizedBox(height: 2)
            : const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.date != null) {
          return _DateHeader(date: item.date!);
        }

        final movement = item.movement!;

        return Dismissible(
          key: ValueKey(movement.id),
          direction: isProcessing
              ? DismissDirection.none
              : DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) async {
            try {
              await onDelete(movement.id);
            } catch (error) {
              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.toString())),
              );
              return;
            }

            if (!context.mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Movimiento eliminado')),
            );
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B64),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: SizedBox(
            width: double.infinity,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => AddExpenseScreen(movement: movement),
                  ),
                );
              },
              child: MovementTile(
                movement,
                showDate: false,
                fullWidth: true,
              ),
            ),
          ),
        );
      },
    );
  }

  List<_HistoryItem> _groupMovements(List<Movement> movements) {
    final items = <_HistoryItem>[];
    DateTime? currentDate;

    for (final movement in movements) {
      final movementDate = DateTime(
        movement.date.year,
        movement.date.month,
        movement.date.day,
      );

      if (currentDate == null || currentDate != movementDate) {
        currentDate = movementDate;
        items.add(_HistoryItem.header(movementDate));
      }

      items.add(_HistoryItem.movement(movement));
    }

    return items;
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar movimiento'),
          content: const Text('Esta accion no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 2),
      child: Text(
        _labelFor(date),
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _labelFor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Hoy';
    }

    if (target == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    }

    return DateFormatter.short(date);
  }
}

class _HistoryItem {
  const _HistoryItem._({
    this.date,
    this.movement,
  });

  factory _HistoryItem.header(DateTime date) {
    return _HistoryItem._(date: date);
  }

  factory _HistoryItem.movement(Movement movement) {
    return _HistoryItem._(movement: movement);
  }

  final DateTime? date;
  final Movement? movement;

  bool get isHeader => date != null;
}
