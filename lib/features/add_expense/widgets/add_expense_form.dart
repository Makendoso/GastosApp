import 'package:flutter/material.dart';

import '../../../core/formatters/date_formatter.dart';
import '../../../data/models/category.dart';
import '../../../data/models/movement.dart';
import 'category_dropdown.dart';
import 'date_picker_tile.dart';
import 'expense_text_field.dart';
import 'save_expense_button.dart';

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({
    required this.categories,
    required this.onSave,
    this.initialMovement,
    super.key,
  });

  final List<Category> categories;
  final Future<void> Function(Movement movement) onSave;
  final Movement? initialMovement;

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  late bool _isExpense;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final movement = widget.initialMovement;
    _titleController = TextEditingController(text: movement?.title);
    _amountController = TextEditingController(
      text: movement?.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: movement?.note);
    _isExpense = movement?.isExpense ?? true;
    final initialCategory = movement?.category;
    final categoryNames = _expenseCategories.map((category) => category.name);
    _selectedCategory = initialCategory == null ||
            initialCategory.trim().isEmpty ||
            !categoryNames.contains(initialCategory)
        ? _expenseCategories.first.name
        : initialCategory;
    _selectedDate = movement?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() => _selectedDate = pickedDate);
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isExpense && _selectedCategory.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoria')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final movement = Movement(
      id: widget.initialMovement?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.replaceAll(',', '.')).abs(),
      type: _isExpense ? MovementType.expense : MovementType.income,
      category: _isExpense ? _selectedCategory : 'Ingreso',
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    try {
      movement.validate();
      await widget.onSave(movement);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento guardado')),
    );
    Navigator.pop(context);
  }

  List<Category> get _expenseCategories {
    final categories = [
      for (final category in widget.categories)
        if (category.supports(MovementType.expense)) category,
    ];

    if (categories.isEmpty) {
      return Category.defaults;
    }

    final initialCategory = widget.initialMovement?.category;
    final hasInitialCategory = initialCategory != null &&
        categories.any((category) => category.name == initialCategory);

    if (initialCategory == null ||
        initialCategory.trim().isEmpty ||
        hasInitialCategory ||
        widget.initialMovement?.type != MovementType.expense) {
      return categories;
    }

    return [
      ...categories,
      Category(
        id: 'legacy-${initialCategory.toLowerCase().replaceAll(' ', '-')}',
        name: initialCategory,
        icon: widget.initialMovement?.icon ?? Icons.receipt_long,
        color: const Color(0xFF64748B),
        type: MovementType.expense,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        children: [
          MovementTypeSelector(
            isExpense: _isExpense,
            onChanged: (value) => setState(() => _isExpense = value),
          ),
          const SizedBox(height: 32),
          ExpenseTextField(
            controller: _titleController,
            label: 'Titulo',
            hintText: _isExpense ? 'Ej. Comida' : 'Ej. Sueldo',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Escribe un titulo';
              }

              return null;
            },
          ),
          const SizedBox(height: 28),
          ExpenseTextField(
            controller: _amountController,
            label: 'Monto',
            prefixText: r'$',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final amount = double.tryParse(
                (value ?? '').replaceAll(',', '.'),
              );

              if (amount == null || amount <= 0) {
                return 'Ingresa un monto valido';
              }

              return null;
            },
          ),
          if (_isExpense) ...[
            const SizedBox(height: 28),
            CategoryDropdown(
              categories: _expenseCategories,
              value: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
          ],
          const SizedBox(height: 28),
          DatePickerTile(
            dateText: DateFormatter.short(_selectedDate),
            onTap: _pickDate,
          ),
          const SizedBox(height: 28),
          ExpenseTextField(
            controller: _noteController,
            label: 'Nota (opcional)',
            hintText: 'Ej. Almuerzo con amigos',
          ),
          const SizedBox(height: 38),
          SaveExpenseButton(
            onPressed: _isSaving ? null : _saveExpense,
            label: _isSaving ? 'Guardando...' : 'Guardar',
          ),
        ],
      ),
    );
  }
}

class MovementTypeSelector extends StatelessWidget {
  const MovementTypeSelector({
    required this.isExpense,
    required this.onChanged,
    super.key,
  });

  final bool isExpense;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF7),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MovementTypeOption(
              label: 'Gasto',
              icon: Icons.arrow_downward,
              color: const Color(0xFFFF3B64),
              isSelected: isExpense,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _MovementTypeOption(
              label: 'Ingreso',
              icon: Icons.arrow_upward,
              color: const Color(0xFF34B56B),
              isSelected: !isExpense,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementTypeOption extends StatelessWidget {
  const _MovementTypeOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(36),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 1 : 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
