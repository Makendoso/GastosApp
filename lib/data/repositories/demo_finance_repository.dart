import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/finance_category.dart';
import '../models/financial_summary.dart';
import '../models/movement.dart';

abstract final class DemoFinanceRepository {
  static const summary = FinancialSummary(
    balance: 5200,
    monthIncome: 8200,
    monthExpenses: 3000,
    expenseByCategory: {'Comida': 1200, 'Transporte': 600, 'Otros': 1200},
    message: 'Tus finanzas estan saludables',
  );

  static final movements = <Movement>[
    Movement(
      id: 'demo-1',
      title: 'Sueldo',
      amount: 5000,
      type: MovementType.income,
      category: 'Ingreso',
      date: DateTime(2026, 5, 25),
    ),
    Movement(
      id: 'demo-2',
      title: 'Comida',
      amount: 120,
      type: MovementType.expense,
      category: 'Comida',
      date: DateTime(2026, 5, 24),
    ),
    Movement(
      id: 'demo-3',
      title: 'Uber',
      amount: 80,
      type: MovementType.expense,
      category: 'Transporte',
      date: DateTime(2026, 5, 24),
    ),
    Movement(
      id: 'demo-4',
      title: 'Supermercado',
      amount: 250,
      type: MovementType.expense,
      category: 'Comida',
      date: DateTime(2026, 5, 23),
    ),
    Movement(
      id: 'demo-5',
      title: 'Netflix',
      amount: 200,
      type: MovementType.expense,
      category: 'Entretenimiento',
      date: DateTime(2026, 5, 9),
    ),
  ];

  static const categories = <FinanceCategory>[
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
      id: 'entretenimiento',
      name: 'Entretenimiento',
      icon: Icons.sports_esports,
      color: Color(0xFF7C3AED),
    ),
    FinanceCategory(
      id: 'servicios',
      name: 'Servicios',
      icon: Icons.receipt_long,
      color: AppColors.primary,
    ),
  ];
}
