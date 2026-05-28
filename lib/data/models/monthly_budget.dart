class MonthlyBudget {
  const MonthlyBudget({
    required this.monthKey,
    required this.limit,
  });

  final String monthKey;
  final double limit;

  bool get isConfigured => limit > 0;

  static String keyFor(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  factory MonthlyBudget.empty([DateTime? date]) {
    return MonthlyBudget(
      monthKey: keyFor(date ?? DateTime.now()),
      limit: 0,
    );
  }

  MonthlyBudget copyWith({
    String? monthKey,
    double? limit,
  }) {
    return MonthlyBudget(
      monthKey: monthKey ?? this.monthKey,
      limit: limit ?? this.limit,
    );
  }
}
