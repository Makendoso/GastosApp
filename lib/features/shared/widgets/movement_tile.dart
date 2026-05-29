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
    this.fullWidth = true,
    this.horizontalPadding = 0,
  });

  final Movement movement;
  final bool showDate;
  final bool fullWidth;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final amountColor =
        movement.isExpense ? AppColors.expense : AppColors.income;
    final iconColor = _iconColor(movement.category);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(movement.icon, color: iconColor, size: 25),
            ),
            const SizedBox(width: 14),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.isExpense ? movement.category : 'Ingreso',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 126),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${movement.isExpense ? '-' : '+'} '
                      '${CurrencyFormatter.format(movement.amount.abs())}',
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    showDate
                        ? DateFormatter.short(movement.date)
                        : DateFormatter.dayMonth(movement.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
