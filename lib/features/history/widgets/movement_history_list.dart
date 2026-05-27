import 'package:flutter/material.dart';

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

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: movements.length,
      separatorBuilder: (_, __) => const Divider(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final movement = movements[index];

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
              showDate: true,
            ),
          ),
        );
      },
    );
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
