import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/data/database/daos/budgets_dao.dart';

/// Repository for budget data operations
class BudgetRepository {
  final BudgetsDao _dao;
  final _uuid = const Uuid();

  BudgetRepository(AppDatabase db) : _dao = BudgetsDao(db);

  /// Create a new budget
  Future<int> createBudget({
    required String name,
    required String category,
    required double limitAmount,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _dao.insertBudget(
      BudgetsCompanion.insert(
        uuid: _uuid.v4(),
        name: name,
        category: category,
        limitAmount: limitAmount,
        period: Value(period),
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  /// Get all active budgets
  Future<List<Budget>> getActive() {
    return _dao.getActiveBudgets();
  }

  /// Watch all active budgets
  Stream<List<Budget>> watchActive() {
    return _dao.watchActiveBudgets();
  }

  /// Get budget by category
  Future<Budget?> getByCategory(String category) {
    return _dao.getBudgetByCategory(category);
  }

  /// Update spent amount when a transaction is recorded
  Future<void> recordSpending(String category, double amount) async {
    final budget = await _dao.getBudgetByCategory(category);
    if (budget != null) {
      final newSpent = budget.spentAmount + amount;
      await _dao.updateSpentAmount(budget.id, newSpent);
    }
  }

  /// Update a budget
  Future<bool> updateBudget(BudgetsCompanion budget) {
    return _dao.updateBudget(budget);
  }

  /// Deactivate a budget
  Future<int> deactivate(int id) {
    return _dao.deactivateBudget(id);
  }

  /// Get total monthly budget
  Future<double> getTotalMonthlyBudget() {
    return _dao.getTotalMonthlyBudget();
  }

  /// Get total spent this month
  Future<double> getTotalSpentThisMonth() {
    return _dao.getTotalSpentThisMonth();
  }

  /// Get budget utilization percentage
  Future<double> getBudgetUtilization(int budgetId) async {
    final budgets = await _dao.getActiveBudgets();
    final budget = budgets.where((b) => b.id == budgetId).firstOrNull;
    if (budget == null || budget.limitAmount == 0) return 0;
    return (budget.spentAmount / budget.limitAmount).clamp(0.0, 1.0);
  }
}
