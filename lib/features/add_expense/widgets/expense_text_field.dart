import 'package:flutter/material.dart';

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
        const SizedBox(height: 14),
        SizedBox(
          height: 72,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: icon == null ? null : Icon(icon),
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              enabledBorder: _border(),
              focusedBorder: _border(color: const Color(0xFF34B56B)),
              errorBorder: _border(color: const Color(0xFFFF3B64)),
              focusedErrorBorder: _border(color: const Color(0xFFFF3B64)),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({Color color = const Color(0xFFDDE2E8)}) {
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
        color: Color(0xFF111827),
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
