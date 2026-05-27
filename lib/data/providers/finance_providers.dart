import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/finance_category.dart';
import '../models/financial_summary.dart';
import '../models/movement.dart';
import '../repositories/finance_repository.dart';
import '../repositories/local_finance_repository.dart';
import '../services/local_finance_service.dart';

final localFinanceServiceProvider = Provider<LocalFinanceService>((ref) {
  throw UnimplementedError('LocalFinanceService must be overridden in main.');
});

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return LocalFinanceRepository(ref.watch(localFinanceServiceProvider));
});

final financeControllerProvider =
    StateNotifierProvider<FinanceController, FinanceState>((ref) {
  return FinanceController(ref.watch(financeRepositoryProvider));
});

final categoriesProvider = Provider<List<FinanceCategory>>((ref) {
  return FinanceCategory.defaults;
});

final movementsProvider = Provider<List<Movement>>((ref) {
  return ref.watch(financeControllerProvider).movements;
});

final financialSummaryProvider = Provider<FinancialSummary>((ref) {
  return ref.watch(financeControllerProvider).summary;
});

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

  List<Movement> get recentMovements => movements.take(4).toList();

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
