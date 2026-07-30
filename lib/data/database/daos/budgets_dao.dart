import 'package:drift/drift.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/data/database/tables/budgets_table.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetsDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  /// Insert a new budget
  Future<int> insertBudget(BudgetsCompanion budget) {
    return into(budgets).insert(budget);
  }

  /// Get all active budgets
  Future<List<Budget>> getActiveBudgets() {
    return (select(budgets)
          ..where((b) => b.isActive.equals(true))
          ..orderBy([(b) => OrderingTerm.asc(b.category)]))
        .get();
  }

  /// Watch all active budgets
  Stream<List<Budget>> watchActiveBudgets() {
    return (select(budgets)
          ..where((b) => b.isActive.equals(true))
          ..orderBy([(b) => OrderingTerm.asc(b.category)]))
        .watch();
  }

  /// Get budget by category
  Future<Budget?> getBudgetByCategory(String category) {
    return (select(budgets)
          ..where((b) =>
              b.category.equals(category) & b.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Update budget spent amount
  Future<int> updateSpentAmount(int budgetId, double newSpentAmount) {
    return (update(budgets)..where((b) => b.id.equals(budgetId))).write(
      BudgetsCompanion(
        spentAmount: Value(newSpentAmount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update a budget
  Future<bool> updateBudget(BudgetsCompanion budget) {
    return update(budgets).replace(budget);
  }

  /// Deactivate a budget
  Future<int> deactivateBudget(int id) {
    return (update(budgets)..where((b) => b.id.equals(id))).write(
      BudgetsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get total budget for the current month
  Future<double> getTotalMonthlyBudget() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final query = selectOnly(budgets).join([])
      ..where(budgets.isActive.equals(true) &
          budgets.startDate.isBetweenValues(startOfMonth, endOfMonth))
      ..addColumns([budgets.limitAmount.sum()]);

    final result = await query.get();
    return result.first.read(budgets.limitAmount.sum()) ?? 0;
  }

  /// Get total spent this month across all budgets
  Future<double> getTotalSpentThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final query = selectOnly(budgets).join([])
      ..where(budgets.isActive.equals(true) &
          budgets.startDate.isBetweenValues(startOfMonth, endOfMonth))
      ..addColumns([budgets.spentAmount.sum()]);

    final result = await query.get();
    return result.first.read(budgets.spentAmount.sum()) ?? 0;
  }
}
