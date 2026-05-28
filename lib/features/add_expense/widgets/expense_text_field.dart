import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseTextField extends StatelessWidget {
  const ExpenseTextField({
    required this.controller,
    required this.label,
    this.icon,
    this.prefixText,
    this.hintText,
    this.keyboardType,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? prefixText;
  final String? hintText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: icon == null ? null : Icon(icon),
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: _border(),
              focusedBorder: _border(color: AppColors.primary),
              errorBorder: _border(color: AppColors.expense),
              focusedErrorBorder: _border(color: AppColors.expense),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({Color color = AppColors.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
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
        color: AppColors.text,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
