import 'package:flutter/material.dart';

class SaveExpenseButton extends StatelessWidget {
  const SaveExpenseButton({
    required this.onPressed,
    this.label = 'Guardar movimiento',
    super.key,
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2FB86A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
