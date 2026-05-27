import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.backgroundColor,
    required this.indicatorColor,
    super.key,
  });

  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final Color backgroundColor;
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 162),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Este mes',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 31),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
