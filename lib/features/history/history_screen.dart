import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/finance_providers.dart';
import 'widgets/movement_history_list.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeControllerProvider);
    final movements = ref.watch(movementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        centerTitle: true,
      ),
      body: financeState.isLoading && movements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : financeState.errorMessage != null && movements.isEmpty
              ? _HistoryMessage(message: financeState.errorMessage!)
              : MovementHistoryList(
                  movements: movements,
                  isProcessing: financeState.isProcessing,
                  onDelete: (id) {
                    return ref
                        .read(financeControllerProvider.notifier)
                        .deleteMovement(id);
                  },
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
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
