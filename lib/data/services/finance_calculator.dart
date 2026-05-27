import '../models/financial_summary.dart';
import '../models/movement.dart';

class FinanceCalculator {
  const FinanceCalculator({
    DateTime Function()? now,
  }) : _now = now;

  final DateTime Function()? _now;

  FinancialSummary summary(List<Movement> movements) {
    final currentDate = (_now ?? DateTime.now)();
    final currentMonthMovements = movements.where((movement) {
      return movement.date.year == currentDate.year &&
          movement.date.month == currentDate.month;
    });

    var balance = 0.0;
    var monthIncome = 0.0;
    var monthExpenses = 0.0;
    final expenseByCategory = <String, double>{};

    for (final movement in movements) {
      balance += movement.signedAmount;
    }

    for (final movement in currentMonthMovements) {
      if (movement.isExpense) {
        final amount = movement.amount.abs();
        monthExpenses += amount;
        expenseByCategory.update(
          movement.category,
          (total) => total + amount,
          ifAbsent: () => amount,
        );
      } else {
        monthIncome += movement.amount.abs();
      }
    }

    return FinancialSummary(
      balance: balance,
      monthIncome: monthIncome,
      monthExpenses: monthExpenses,
      expenseByCategory: expenseByCategory,
      message: _messageFor(balance, monthIncome, monthExpenses),
    );
  }

  String _messageFor(
    double balance,
    double monthIncome,
    double monthExpenses,
  ) {
    if (balance <= 0) {
      return 'Revisa tus gastos de este mes';
    }

    if (monthIncome == 0 && monthExpenses == 0) {
      return 'Empieza registrando tus movimientos';
    }

    if (monthExpenses > monthIncome && monthIncome > 0) {
      return 'Tus gastos superan tus ingresos';
    }

    return 'Tus finanzas estan saludables';
  }
}
