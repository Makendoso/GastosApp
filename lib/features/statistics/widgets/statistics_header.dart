import 'package:flutter/material.dart';

class StatisticsHeader extends StatelessWidget {
  const StatisticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 44),
        Expanded(
          child: Text(
            'Estadisticas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF111827),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        IconButton(
          tooltip: 'Calendario',
          onPressed: () {},
          icon: const Icon(
            Icons.calendar_month_outlined,
            color: Color(0xFF111827),
            size: 30,
          ),
        ),
      ],
    );
  }
}
