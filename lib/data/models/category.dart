import 'package:flutter/material.dart';

import 'movement.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final MovementType? type;

  String get nombre => name;
  IconData get icono => icon;

  bool supports(MovementType movementType) {
    return type == null || type == movementType;
  }

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    MovementType? type,
    bool clearType = false,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: clearType ? null : type ?? this.type,
    );
  }

  static const defaults = <Category>[
    Category(
      id: 'comida',
      name: 'Comida',
      icon: Icons.fastfood,
      color: Color(0xFFF97316),
      type: MovementType.expense,
    ),
    Category(
      id: 'transporte',
      name: 'Transporte',
      icon: Icons.directions_bus,
      color: Color(0xFF2563EB),
      type: MovementType.expense,
    ),
    Category(
      id: 'casa',
      name: 'Casa',
      icon: Icons.home,
      color: Color(0xFF34B56B),
      type: MovementType.expense,
    ),
    Category(
      id: 'salud',
      name: 'Salud',
      icon: Icons.health_and_safety,
      color: Color(0xFFEF4444),
      type: MovementType.expense,
    ),
    Category(
      id: 'entretenimiento',
      name: 'Entretenimiento',
      icon: Icons.sports_esports,
      color: Color(0xFF7C3AED),
      type: MovementType.expense,
    ),
    Category(
      id: 'educacion',
      name: 'Educacion',
      icon: Icons.school,
      color: Color(0xFF0EA5E9),
      type: MovementType.expense,
    ),
    Category(
      id: 'otros',
      name: 'Otros',
      icon: Icons.receipt_long,
      color: Color(0xFF64748B),
      type: null,
    ),
  ];
}
