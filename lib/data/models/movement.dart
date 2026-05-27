import 'package:flutter/material.dart';

enum MovementType {
  income,
  expense,
}

class MovementValidationException implements Exception {
  const MovementValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Movement {
  const Movement({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  final String id;
  final String title;
  final double amount;
  final MovementType type;
  final String category;
  final DateTime date;
  final String? note;

  bool get isExpense => type == MovementType.expense;

  double get signedAmount => isExpense ? -amount.abs() : amount.abs();

  void validate() {
    if (id.trim().isEmpty) {
      throw const MovementValidationException(
          'El id del movimiento es invalido');
    }

    if (title.trim().isEmpty) {
      throw const MovementValidationException('El titulo no puede estar vacio');
    }

    if (amount <= 0) {
      throw const MovementValidationException('El monto debe ser mayor que 0');
    }

    if (category.trim().isEmpty) {
      throw const MovementValidationException(
        'La categoria no puede estar vacia',
      );
    }

    if (date.year < 1900 || date.year > 2200) {
      throw const MovementValidationException('La fecha no es valida');
    }
  }

  IconData get icon {
    return switch (category.toLowerCase()) {
      'sueldo' || 'ingreso' || 'ingresos' => Icons.account_balance_wallet,
      'comida' => Icons.fastfood,
      'transporte' || 'uber' => Icons.directions_bus,
      'casa' || 'servicios' => Icons.home,
      'salud' => Icons.health_and_safety,
      'entretenimiento' => Icons.sports_esports,
      'educacion' || 'educación' => Icons.school,
      'supermercado' => Icons.shopping_bag,
      _ => Icons.receipt_long,
    };
  }

  Movement copyWith({
    String? id,
    String? title,
    double? amount,
    MovementType? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Movement(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  factory Movement.fromJson(Map<dynamic, dynamic> json) {
    final typeName = json['type'] as String? ?? 'expense';

    return Movement(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: MovementType.values.firstWhere(
        (type) => type.name == typeName,
        orElse: () => MovementType.expense,
      ),
      category: json['category'] as String? ?? 'Otros',
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount.abs(),
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      if (note != null && note!.trim().isNotEmpty) 'note': note,
    };
  }
}
