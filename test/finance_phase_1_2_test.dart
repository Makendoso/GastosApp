import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/data/models/movement.dart';
import 'package:mi_app/data/repositories/local_finance_repository.dart';
import 'package:mi_app/data/services/finance_calculator.dart';
import 'package:mi_app/data/services/finance_data_source.dart';

void main() {
  group('Movement', () {
    test('creates a valid movement', () {
      final movement = _movement(
        id: '1',
        title: 'Sueldo',
        amount: 1000,
        type: MovementType.income,
      );

      expect(() => movement.validate(), returnsNormally);
      expect(movement.signedAmount, 1000);
    });

    test('rejects zero and negative amounts', () {
      final zero = _movement(id: '1', amount: 0);
      final negative = _movement(id: '2', amount: -10);

      expect(zero.validate, throwsA(isA<MovementValidationException>()));
      expect(negative.validate, throwsA(isA<MovementValidationException>()));
    });
  });

  group('FinanceCalculator', () {
    final calculator = FinanceCalculator(
      now: () => DateTime(2026, 5, 27),
    );

    test('calculates balance, monthly income and monthly expenses', () {
      final summary = calculator.summary([
        _movement(
          id: 'income-current',
          amount: 5000,
          type: MovementType.income,
          date: DateTime(2026, 5, 1),
        ),
        _movement(
          id: 'expense-current',
          amount: 120,
          type: MovementType.expense,
          category: 'Comida',
          date: DateTime(2026, 5, 2),
        ),
        _movement(
          id: 'expense-previous',
          amount: 80,
          type: MovementType.expense,
          category: 'Transporte',
          date: DateTime(2026, 4, 30),
        ),
      ]);

      expect(summary.balance, 4800);
      expect(summary.monthIncome, 5000);
      expect(summary.monthExpenses, 120);
      expect(summary.expenseByCategory, {'Comida': 120});
    });
  });

  group('LocalFinanceRepository', () {
    test('edits a movement by id', () async {
      final dataSource = _MemoryFinanceDataSource();
      final repository = LocalFinanceRepository(dataSource);
      final original = _movement(id: 'same-id', title: 'Comida', amount: 120);
      final edited = original.copyWith(title: 'Cena', amount: 180);

      await repository.createMovement(original);
      await repository.updateMovement(edited);

      final movements = await repository.getMovements();
      expect(movements, hasLength(1));
      expect(movements.single.id, 'same-id');
      expect(movements.single.title, 'Cena');
      expect(movements.single.amount, 180);
    });

    test('deletes a movement by id', () async {
      final dataSource = _MemoryFinanceDataSource();
      final repository = LocalFinanceRepository(dataSource);

      await repository.createMovement(_movement(id: 'keep', title: 'Sueldo'));
      await repository.createMovement(_movement(id: 'delete', title: 'Cafe'));
      await repository.deleteMovement('delete');

      final movements = await repository.getMovements();
      expect(movements.map((movement) => movement.id), ['keep']);
    });
  });
}

Movement _movement({
  required String id,
  String title = 'Movimiento',
  double amount = 100,
  MovementType type = MovementType.expense,
  String category = 'Comida',
  DateTime? date,
}) {
  return Movement(
    id: id,
    title: title,
    amount: amount,
    type: type,
    category: category,
    date: date ?? DateTime(2026, 5, 27),
  );
}

class _MemoryFinanceDataSource implements FinanceDataSource {
  final _movements = <String, Movement>{};

  @override
  Future<List<Movement>> getMovements() async {
    return _movements.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> saveMovement(Movement movement) async {
    _movements[movement.id] = movement;
  }

  @override
  Future<void> deleteMovement(String id) async {
    _movements.remove(id);
  }
}
