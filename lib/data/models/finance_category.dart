import 'package:flutter/material.dart';

class FinanceCategory {
  const FinanceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;

  static const defaults = <FinanceCategory>[
    FinanceCategory(
      id: 'comida',
      name: 'Comida',
      icon: Icons.fastfood,
      color: Color(0xFFF97316),
    ),
    FinanceCategory(
      id: 'transporte',
      name: 'Transporte',
      icon: Icons.directions_bus,
      color: Color(0xFF2563EB),
    ),
    FinanceCategory(
      id: 'casa',
      name: 'Casa',
      icon: Icons.home,
      color: Color(0xFF34B56B),
    ),
    FinanceCategory(
      id: 'salud',
      name: 'Salud',
      icon: Icons.health_and_safety,
      color: Color(0xFFEF4444),
    ),
    FinanceCategory(
      id: 'entretenimiento',
      name: 'Entretenimiento',
      icon: Icons.sports_esports,
      color: Color(0xFF7C3AED),
    ),
    FinanceCategory(
      id: 'educacion',
      name: 'Educacion',
      icon: Icons.school,
      color: Color(0xFF0EA5E9),
    ),
    FinanceCategory(
      id: 'otros',
      name: 'Otros',
      icon: Icons.receipt_long,
      color: Color(0xFF64748B),
    ),
  ];
}
