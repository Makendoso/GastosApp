import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/formatters/currency_formatter.dart';
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
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late Category _selectedCategory;
  late DateTime _selectedDate;
  late bool _isExpense;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final movement = widget.initialMovement;
    final categories = _availableCategories;
    final initialCategory = movement?.category;

    _amountController = TextEditingController(
      text: movement?.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(
      text: _initialNoteFrom(movement),
    );
    _isExpense = movement?.isExpense ?? true;
    _selectedCategory = categories.firstWhere(
      (category) => category.name == initialCategory,
      orElse: () => categories.first,
    );
    _selectedDate = movement?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<Category> get _availableCategories {
    final expenseCategories = widget.categories
        .where((category) => category.supports(MovementType.expense))
        .toList(growable: false);

    return expenseCategories.isEmpty ? Category.defaults : expenseCategories;
  }

  String? _initialNoteFrom(Movement? movement) {
    if (movement == null) {
      return null;
    }

    final note = movement.note?.trim();
    if (note != null && note.isNotEmpty) {
      return note;
    }

    if (movement.title != movement.category && movement.title != 'Ingreso') {
      return movement.title;
    }

    return null;
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

  Future<void> _saveMovement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = _parseAmount(_amountController.text);
    if (amount == null) {
      return;
    }

    final note = _noteController.text.trim();
    final categoryName = _isExpense ? _selectedCategory.name : 'Ingreso';
    final movement = Movement(
      id: widget.initialMovement?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: note.isEmpty ? categoryName : note,
      amount: amount.abs(),
      type: _isExpense ? MovementType.expense : MovementType.income,
      category: categoryName,
      date: _selectedDate,
      note: note.isEmpty ? null : note,
    );

    try {
      movement.validate();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      return;
    }

    final shouldSave = await _confirmSave(movement);
    if (!shouldSave || !mounted) {
      return;
    }

    setState(() => _isSaving = true);

    try {
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

    final movementLabel = _isExpense ? 'Gasto' : 'Ingreso';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$movementLabel guardado')),
    );
    Navigator.pop(context);
  }

  Future<bool> _confirmSave(Movement movement) async {
    final movementLabel = movement.isExpense ? 'gasto' : 'ingreso';
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Guardar $movementLabel'),
          content: Text(
            'Se registrara ${CurrencyFormatter.format(movement.amount)} en '
            '${movement.category}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  double? _parseAmount(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String? _validateAmount(String? value) {
    final cleanValue = (value ?? '').trim();
    if (cleanValue.isEmpty) {
      return 'Ingresa un monto';
    }

    final amount = _parseAmount(cleanValue);
    if (amount == null) {
      return 'Monto inválido';
    }

    if (amount <= 0) {
      return 'El monto debe ser mayor a 0';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        children: [
          _AmountField(
            controller: _amountController,
            validator: _validateAmount,
          ),
          const SizedBox(height: 24),
          MovementTypeSelector(
            isExpense: _isExpense,
            onChanged: (value) => setState(() => _isExpense = value),
          ),
          if (_isExpense) ...[
            const SizedBox(height: 28),
            CategorySelector(
              categories: _availableCategories,
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
            hintText: _isExpense ? 'Ej. Almuerzo' : 'Ej. Pago quincenal',
          ),
          const SizedBox(height: 38),
          SaveExpenseButton(
            onPressed: _isSaving ? null : _saveMovement,
            label: _isSaving ? 'Guardando...' : 'Guardar',
          ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.validator,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Monto'),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
          ],
          validator: validator,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 42,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: r'$ ',
            prefixStyle: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
            hintStyle: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 22,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            enabledBorder: _border(),
            focusedBorder: _border(color: const Color(0xFF34B56B), width: 2),
            errorBorder: _border(color: const Color(0xFFFF3B64), width: 2),
            focusedErrorBorder:
                _border(color: const Color(0xFFFF3B64), width: 2),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({
    Color color = const Color(0xFFDDE2E8),
    double width = 1.5,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
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
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF7),
        borderRadius: BorderRadius.circular(34),
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
      borderRadius: BorderRadius.circular(34),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 1 : 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
