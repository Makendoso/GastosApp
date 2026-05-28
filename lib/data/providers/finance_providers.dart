import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/financial_summary.dart';
import '../models/movement.dart';
import '../models/monthly_budget.dart';
import '../repositories/budget_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/finance_repository.dart';
import '../repositories/local_budget_repository.dart';
import '../repositories/local_category_repository.dart';
import '../repositories/local_finance_repository.dart';
import '../services/local_finance_service.dart';

final localFinanceServiceProvider = Provider<LocalFinanceService>((ref) {
  throw UnimplementedError('LocalFinanceService must be overridden in main.');
});

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return LocalFinanceRepository(ref.watch(localFinanceServiceProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return LocalCategoryRepository(ref.watch(localFinanceServiceProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return LocalBudgetRepository(ref.watch(localFinanceServiceProvider));
});

final budgetControllerProvider =
    StateNotifierProvider<BudgetController, BudgetState>((ref) {
  return BudgetController(ref.watch(budgetRepositoryProvider));
});

final monthlyBudgetProvider = Provider<MonthlyBudget>((ref) {
  return ref.watch(budgetControllerProvider).budget;
});

final financeControllerProvider =
    StateNotifierProvider<FinanceController, FinanceState>((ref) {
  return FinanceController(ref.watch(financeRepositoryProvider));
});

final categoryControllerProvider =
    StateNotifierProvider<CategoryController, CategoryState>((ref) {
  return CategoryController(ref.watch(categoryRepositoryProvider));
});

final categoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoryControllerProvider).categories;
});

final movementsProvider = Provider<List<Movement>>((ref) {
  return ref.watch(financeControllerProvider).movements;
});

final financialSummaryProvider = Provider<FinancialSummary>((ref) {
  return ref.watch(financeControllerProvider).summary;
});

final statisticsPeriodProvider = StateProvider<StatisticsPeriod>((ref) {
  return StatisticsPeriod.month;
});

final statisticsSummaryProvider = Provider<FinancialSummary>((ref) {
  final movements = ref.watch(movementsProvider);
  final range = _rangeFor(ref.watch(statisticsPeriodProvider), DateTime.now());
  final expenseByCategory = <String, double>{};
  var income = 0.0;
  var expenses = 0.0;

  for (final movement in movements) {
    if (!_isWithinRange(movement.date, range.currentStart, range.currentEnd)) {
      continue;
    }

    if (movement.isExpense) {
      final amount = movement.amount.abs();
      expenses += amount;
      expenseByCategory.update(
        movement.category,
        (total) => total + amount,
        ifAbsent: () => amount,
      );
    } else {
      income += movement.amount.abs();
    }
  }

  return FinancialSummary(
    balance: income - expenses,
    monthIncome: income,
    monthExpenses: expenses,
    expenseByCategory: expenseByCategory,
    message: '',
  );
});

final statisticsOverviewProvider = Provider<StatisticsOverview>((ref) {
  final movements = ref.watch(movementsProvider);
  final period = ref.watch(statisticsPeriodProvider);
  final summary = ref.watch(statisticsSummaryProvider);
  final now = DateTime.now();
  final range = _rangeFor(period, now);

  final previousExpenses = movements
      .where(
        (movement) =>
            movement.isExpense &&
            _isWithinRange(
              movement.date,
              range.previousStart,
              range.previousEnd,
            ),
      )
      .fold(0.0, (total, movement) => total + movement.amount.abs());

  final topCategoryEntry = summary.expenseByCategory.entries.isEmpty
      ? null
      : (summary.expenseByCategory.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .first;

  return StatisticsOverview(
    period: period,
    currentExpenses: summary.monthExpenses,
    previousExpenses: previousExpenses,
    dailyAverage: summary.monthExpenses / range.elapsedDays,
    topCategoryName: topCategoryEntry?.key,
    topCategoryAmount: topCategoryEntry?.value ?? 0,
    elapsedDays: range.elapsedDays,
  );
});

final expenseEvolutionProvider = Provider<List<ExpenseEvolutionPoint>>((ref) {
  final movements = ref.watch(movementsProvider);
  final period = ref.watch(statisticsPeriodProvider);
  return buildExpenseEvolutionPoints(
    movements: movements,
    period: period,
    now: DateTime.now(),
  );
});

List<ExpenseEvolutionPoint> buildExpenseEvolutionPoints({
  required List<Movement> movements,
  required StatisticsPeriod period,
  required DateTime now,
}) {
  final range = _rangeFor(period, now);
  final expensesByBucket = <int, double>{};

  for (final movement in movements) {
    if (!movement.isExpense ||
        !_isWithinRange(movement.date, range.currentStart, range.currentEnd)) {
      continue;
    }

    final bucket = _bucketFor(movement.date, period, range.currentStart);
    expensesByBucket.update(
      bucket,
      (total) => total + movement.amount.abs(),
      ifAbsent: () => movement.amount.abs(),
    );
  }

  return [
    for (var bucket = 1; bucket <= range.bucketCount; bucket++)
      ExpenseEvolutionPoint(
        x: bucket,
        label: _bucketLabel(bucket, period, range.currentStart),
        amount: expensesByBucket[bucket] ?? 0,
      ),
  ];
}

final historyFilterProvider = StateProvider<HistoryFilterState>((ref) {
  return const HistoryFilterState();
});

final filteredMovementsProvider = Provider<List<Movement>>((ref) {
  final movements = ref.watch(movementsProvider);
  final categories = ref.watch(categoriesProvider);
  final filter = ref.watch(historyFilterProvider);

  return movements.where((movement) {
    if (filter.type != null && movement.type != filter.type) {
      return false;
    }

    if (filter.categoryId != null) {
      final selectedCategory = categories.where(
        (category) => category.id == filter.categoryId,
      );
      if (selectedCategory.isEmpty ||
          movement.category != selectedCategory.first.name) {
        return false;
      }
    }

    final movementDate = _dateOnly(movement.date);
    final startDate =
        filter.startDate == null ? null : _dateOnly(filter.startDate!);
    final endDate = filter.endDate == null ? null : _dateOnly(filter.endDate!);

    if (startDate != null && movementDate.isBefore(startDate)) {
      return false;
    }

    if (endDate != null && movementDate.isAfter(endDate)) {
      return false;
    }

    final query = filter.query.trim().toLowerCase();
    if (query.isNotEmpty) {
      final searchableText = [
        movement.title,
        movement.category,
        movement.note ?? '',
      ].join(' ').toLowerCase();

      if (!searchableText.contains(query)) {
        return false;
      }
    }

    return true;
  }).toList(growable: false);
});

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

StatisticsPeriodRange _rangeFor(StatisticsPeriod period, DateTime now) {
  final today = _dateOnly(now);

  switch (period) {
    case StatisticsPeriod.week:
      final start = today.subtract(Duration(days: today.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return StatisticsPeriodRange(
        currentStart: start,
        currentEnd: end,
        previousStart: start.subtract(const Duration(days: 7)),
        previousEnd: end.subtract(const Duration(days: 7)),
        bucketCount: 7,
        elapsedDays: today.difference(start).inDays + 1,
      );
    case StatisticsPeriod.month:
      final start = DateTime(today.year, today.month);
      final end = DateTime(today.year, today.month + 1, 0);
      final previousStart = DateTime(today.year, today.month - 1);
      final previousEnd = DateTime(today.year, today.month, 0);
      return StatisticsPeriodRange(
        currentStart: start,
        currentEnd: end,
        previousStart: previousStart,
        previousEnd: previousEnd,
        bucketCount: today.day,
        elapsedDays: today.day,
      );
    case StatisticsPeriod.year:
      final start = DateTime(today.year);
      final end = DateTime(today.year, 12, 31);
      return StatisticsPeriodRange(
        currentStart: start,
        currentEnd: end,
        previousStart: DateTime(today.year - 1),
        previousEnd: DateTime(today.year - 1, 12, 31),
        bucketCount: today.month,
        elapsedDays: today.difference(start).inDays + 1,
      );
  }
}

bool _isWithinRange(DateTime date, DateTime start, DateTime end) {
  final dateOnly = _dateOnly(date);
  return !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
}

int _bucketFor(DateTime date, StatisticsPeriod period, DateTime start) {
  return switch (period) {
    StatisticsPeriod.week => _dateOnly(date).difference(start).inDays + 1,
    StatisticsPeriod.month => date.day,
    StatisticsPeriod.year => date.month,
  };
}

String _bucketLabel(int bucket, StatisticsPeriod period, DateTime start) {
  return switch (period) {
    StatisticsPeriod.week => const [
        'Lun',
        'Mar',
        'Mie',
        'Jue',
        'Vie',
        'Sab',
        'Dom',
      ][bucket - 1],
    StatisticsPeriod.month => bucket.toString(),
    StatisticsPeriod.year => const [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ][bucket - 1],
  };
}

enum StatisticsPeriod {
  week,
  month,
  year;

  String get label {
    return switch (this) {
      StatisticsPeriod.week => 'Semana',
      StatisticsPeriod.month => 'Mes',
      StatisticsPeriod.year => 'Año',
    };
  }

  String get title {
    return switch (this) {
      StatisticsPeriod.week => 'Resumen de la semana',
      StatisticsPeriod.month => 'Resumen del mes',
      StatisticsPeriod.year => 'Resumen del año',
    };
  }

  String get currentLabel {
    return switch (this) {
      StatisticsPeriod.week => 'Semana actual',
      StatisticsPeriod.month => 'Mes actual',
      StatisticsPeriod.year => 'Año actual',
    };
  }

  String get previousLabel {
    return switch (this) {
      StatisticsPeriod.week => 'Semana anterior',
      StatisticsPeriod.month => 'Mes anterior',
      StatisticsPeriod.year => 'Año anterior',
    };
  }

  String get emptyEvolutionTitle {
    return switch (this) {
      StatisticsPeriod.week => 'Sin gastos esta semana',
      StatisticsPeriod.month => 'Sin gastos este mes',
      StatisticsPeriod.year => 'Sin gastos este año',
    };
  }

  String get noCurrentExpensesInsight {
    return switch (this) {
      StatisticsPeriod.week =>
        'Aun no hay gastos esta semana. Registra movimientos para ver tendencias.',
      StatisticsPeriod.month =>
        'Aun no hay gastos este mes. Registra movimientos para ver tendencias.',
      StatisticsPeriod.year =>
        'Aun no hay gastos este año. Registra movimientos para ver tendencias.',
    };
  }

  String get noPreviousExpensesInsight {
    return switch (this) {
      StatisticsPeriod.week =>
        'Esta semana ya tiene gastos registrados; la siguiente semana podras comparar mejor.',
      StatisticsPeriod.month =>
        'Este mes ya tiene gastos registrados; el siguiente mes podras comparar mejor.',
      StatisticsPeriod.year =>
        'Este año ya tiene gastos registrados; el siguiente año podras comparar mejor.',
    };
  }

  String get higherInsight {
    return switch (this) {
      StatisticsPeriod.week =>
        'Tus gastos van por encima de la semana anterior. Conviene revisar los rubros principales.',
      StatisticsPeriod.month =>
        'Tus gastos van por encima del mes anterior. Conviene revisar los rubros principales.',
      StatisticsPeriod.year =>
        'Tus gastos van por encima del año anterior. Conviene revisar los rubros principales.',
    };
  }

  String get lowerInsight {
    return switch (this) {
      StatisticsPeriod.week =>
        'Vas gastando menos que la semana anterior. Buen avance para mantener el ritmo.',
      StatisticsPeriod.month =>
        'Vas gastando menos que el mes anterior. Buen avance para mantener el ritmo.',
      StatisticsPeriod.year =>
        'Vas gastando menos que el año anterior. Buen avance para mantener el ritmo.',
    };
  }

  String get equalInsight {
    return switch (this) {
      StatisticsPeriod.week =>
        'Tus gastos van iguales a la semana anterior. Mantente atento a los proximos dias.',
      StatisticsPeriod.month =>
        'Tus gastos van iguales al mes anterior. Mantente atento a los proximos dias.',
      StatisticsPeriod.year =>
        'Tus gastos van iguales al año anterior. Mantente atento a los proximos meses.',
    };
  }
}

class StatisticsPeriodRange {
  const StatisticsPeriodRange({
    required this.currentStart,
    required this.currentEnd,
    required this.previousStart,
    required this.previousEnd,
    required this.bucketCount,
    required this.elapsedDays,
  });

  final DateTime currentStart;
  final DateTime currentEnd;
  final DateTime previousStart;
  final DateTime previousEnd;
  final int bucketCount;
  final int elapsedDays;
}

class HistoryFilterState {
  const HistoryFilterState({
    this.query = '',
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
  });

  final String query;
  final MovementType? type;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get hasFilters =>
      query.trim().isNotEmpty ||
      type != null ||
      categoryId != null ||
      startDate != null ||
      endDate != null;

  HistoryFilterState copyWith({
    String? query,
    MovementType? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    bool clearType = false,
    bool clearCategory = false,
    bool clearDates = false,
  }) {
    return HistoryFilterState(
      query: query ?? this.query,
      type: clearType ? null : type ?? this.type,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      startDate: clearDates ? null : startDate ?? this.startDate,
      endDate: clearDates ? null : endDate ?? this.endDate,
    );
  }
}

class BudgetState {
  const BudgetState({
    required this.budget,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
  });

  final MonthlyBudget budget;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;

  BudgetState copyWith({
    MonthlyBudget? budget,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BudgetState(
      budget: budget ?? this.budget,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class FinanceState {
  const FinanceState({
    required this.movements,
    required this.summary,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
  });

  final List<Movement> movements;
  final FinancialSummary summary;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;

  List<Movement> get recentMovements => movements.take(5).toList();

  FinanceState copyWith({
    List<Movement>? movements,
    FinancialSummary? summary,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FinanceState(
      movements: movements ?? this.movements,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CategoryState {
  const CategoryState({
    required this.categories,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Category> categories;
  final bool isLoading;
  final String? errorMessage;

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class StatisticsOverview {
  const StatisticsOverview({
    required this.period,
    required this.currentExpenses,
    required this.previousExpenses,
    required this.dailyAverage,
    required this.topCategoryName,
    required this.topCategoryAmount,
    required this.elapsedDays,
  });

  final StatisticsPeriod period;
  final double currentExpenses;
  final double previousExpenses;
  final double dailyAverage;
  final String? topCategoryName;
  final double topCategoryAmount;
  final int elapsedDays;

  double get difference => currentExpenses - previousExpenses;

  bool get hasCurrentExpenses => currentExpenses > 0;

  bool get hasPreviousExpenses => previousExpenses > 0;

  String get insight {
    if (!hasCurrentExpenses) {
      return period.noCurrentExpensesInsight;
    }

    if (!hasPreviousExpenses) {
      return period.noPreviousExpensesInsight;
    }

    if (difference > 0) {
      return period.higherInsight;
    }

    if (difference < 0) {
      return period.lowerInsight;
    }

    return period.equalInsight;
  }
}

class ExpenseEvolutionPoint {
  const ExpenseEvolutionPoint({
    required this.x,
    required this.label,
    required this.amount,
  });

  final int x;
  final String label;
  final double amount;
}

class CategoryController extends StateNotifier<CategoryState> {
  CategoryController(this._repository)
      : super(
          const CategoryState(
            categories: Category.defaults,
            isLoading: true,
          ),
        ) {
    load();
  }

  final CategoryRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final categories = await _repository.getCategories();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        categories: Category.defaults,
        isLoading: false,
        errorMessage: 'No se pudieron cargar las categorias.',
      );
    }
  }

  Future<void> addCategory(Category category) async {
    await _runAction(() => _repository.createCategory(category));
  }

  Future<void> updateCategory(Category category) async {
    await _runAction(() => _repository.updateCategory(category));
  }

  Future<void> deleteCategory(String id) async {
    await _runAction(() => _repository.deleteCategory(id));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      await load();
    } catch (error) {
      state = state.copyWith(errorMessage: _messageFrom(error));
      rethrow;
    }
  }

  String _messageFrom(Object error) {
    if (error is MovementValidationException) {
      return error.message;
    }

    return 'No se pudo completar la operacion. Intenta de nuevo.';
  }
}

class BudgetController extends StateNotifier<BudgetState> {
  BudgetController(this._repository)
      : super(
          BudgetState(
            budget: MonthlyBudget.empty(),
            isLoading: true,
          ),
        ) {
    load();
  }

  final BudgetRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final budget = await _repository.getCurrentMonthBudget();
      state = state.copyWith(
        budget: budget,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo cargar el presupuesto.',
      );
    }
  }

  Future<void> saveBudget(double limit) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      await _repository.saveCurrentMonthBudget(limit);
      await load();
    } catch (error) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: _messageFrom(error),
      );
      rethrow;
    } finally {
      if (mounted) {
        state = state.copyWith(isProcessing: false);
      }
    }
  }

  String _messageFrom(Object error) {
    if (error is BudgetValidationException) {
      return error.message;
    }

    return 'No se pudo guardar el presupuesto. Intenta de nuevo.';
  }
}

class FinanceController extends StateNotifier<FinanceState> {
  FinanceController(this._repository)
      : super(
          FinanceState(
            movements: const [],
            summary: _repository.getSummary(const []),
            isLoading: true,
          ),
        ) {
    _load();
  }

  final FinanceRepository _repository;

  Future<void> addMovement(Movement movement) async {
    await _runAction(() => _repository.createMovement(movement));
  }

  Future<void> updateMovement(Movement movement) async {
    await _runAction(() => _repository.updateMovement(movement));
  }

  Future<void> deleteMovement(String id) async {
    await _runAction(() => _repository.deleteMovement(id));
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final movements = await _repository.getMovements();
      state = state.copyWith(
        movements: movements,
        summary: _repository.getSummary(movements),
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFrom(error),
      );
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      await action();
      await _load();
    } catch (error) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: _messageFrom(error),
      );
      rethrow;
    } finally {
      if (mounted) {
        state = state.copyWith(isProcessing: false);
      }
    }
  }

  String _messageFrom(Object error) {
    if (error is MovementValidationException) {
      return error.message;
    }

    return 'No se pudo completar la operacion. Intenta de nuevo.';
  }
}
