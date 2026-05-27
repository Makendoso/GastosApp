class FinancialSummary {
  const FinancialSummary({
    required this.balance,
    required this.monthIncome,
    required this.monthExpenses,
    required this.expenseByCategory,
    required this.message,
  });

  final double balance;
  final double monthIncome;
  final double monthExpenses;
  final Map<String, double> expenseByCategory;
  final String message;

  double get income => monthIncome;
  double get expenses => monthExpenses;
}
