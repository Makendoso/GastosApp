import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/movement.dart';
import '../../data/providers/finance_providers.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import 'widgets/add_expense_form.dart';

class AddExpenseScreen extends ConsumerWidget {
  const AddExpenseScreen({
    super.key,
    this.movement,
  });

  final Movement? movement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 64,
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.chevron_left, size: 34),
        ),
        title: const Text(
          'Movimiento',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 1),
      body: AddExpenseForm(
        initialMovement: movement,
        categories: categories,
        onSave: (movement) async {
          final controller = ref.read(financeControllerProvider.notifier);

          if (this.movement == null) {
            await controller.addMovement(movement);
          } else {
            await controller.updateMovement(movement);
          }
        },
      ),
    );
  }
}
