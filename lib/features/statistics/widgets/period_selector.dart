import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          _PeriodOption(label: 'Semana'),
          _PeriodOption(label: 'Mes', isSelected: true),
          _PeriodOption(label: 'Año'),
        ],
      ),
    );
  }
}

class _PeriodOption extends StatelessWidget {
  const _PeriodOption({
    required this.label,
    this.isSelected = false,
  });

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF19B86D) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF111827),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
