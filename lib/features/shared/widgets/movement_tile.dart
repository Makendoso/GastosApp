import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movement.dart';

class MovementTile extends StatelessWidget {
  const MovementTile(
    this.movement, {
    super.key,
    this.showDate = false,
  });

  final Movement movement;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final amountColor =
        movement.isExpense ? AppColors.expense : AppColors.income;
    final iconColor = _iconColor(movement.title);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(movement.icon, color: Colors.white, size: 31),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  movement.isExpense ? 'Gasto' : 'Ingreso',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${movement.isExpense ? '-' : '+'} '
                '${CurrencyFormatter.format(movement.amount.abs())}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                showDate
                    ? DateFormatter.short(movement.date)
                    : DateFormatter.dayMonth(movement.date),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _iconColor(String title) {
    return switch (title.toLowerCase()) {
      'sueldo' => const Color(0xFF67D992),
      'comida' => const Color(0xFFFF8547),
      'uber' => const Color(0xFF8170D8),
      'supermercado' => const Color(0xFFFFC356),
      _ => const Color(0xFF34B56B),
    };
  }
}
