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
