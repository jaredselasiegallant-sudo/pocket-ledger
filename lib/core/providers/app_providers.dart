import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/data/repositories/transaction_repository.dart';
import 'package:pocket_ledger/data/repositories/budget_repository.dart';
import 'package:pocket_ledger/data/repositories/account_repository.dart';

/// Singleton database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Transaction repository provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(databaseProvider));
});

/// Budget repository provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(databaseProvider));
});

/// Account repository provider
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(databaseProvider));
});

/// Reactive stream of all transactions
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

/// Total balance across all accounts
final totalBalanceProvider = FutureProvider<double>((ref) async {
  final accountRepo = ref.watch(accountRepositoryProvider);
  final balance = await accountRepo.getTotalBalance();
  ref.watch(_transactionRefreshProvider);
  return balance;
});

/// Trigger to refresh balance/summary when transactions change
final _transactionRefreshProvider = StreamProvider<int>((ref) async* {
  final txnRepo = ref.watch(transactionRepositoryProvider);
  await for (final _ in txnRepo.watchAll()) {
    yield DateTime.now().millisecondsSinceEpoch;
  }
});

/// Monthly income for current month
final monthlyIncomeProvider = FutureProvider<double>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  ref.watch(_transactionRefreshProvider);
  return ref.watch(transactionRepositoryProvider).getTotalIncome(start, end);
});

/// Monthly expenses for current month
final monthlyExpensesProvider = FutureProvider<double>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  ref.watch(_transactionRefreshProvider);
  return ref.watch(transactionRepositoryProvider).getTotalExpenses(start, end);
});

/// Active budgets stream
final activeBudgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchActive();
});

/// Active accounts stream
final activeAccountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchActive();
});

/// Spending by category for current month
final monthlySpendingByCategoryProvider =
    FutureProvider<List<MapEntry<String, double>>>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  ref.watch(_transactionRefreshProvider);
  return ref
      .watch(transactionRepositoryProvider)
      .getSpendingByCategory(start, end);
});

/// Date range helper providers
DateTimeRange getCurrentMonthRange() {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month, 1),
    end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
  );
}

DateTimeRange getCurrentWeekRange() {
  final now = DateTime.now();
  final weekday = now.weekday;
  return DateTimeRange(
    start: now.subtract(Duration(days: weekday - 1)),
    end: now,
  );
}

DateTimeRange getCurrentYearRange() {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, 1, 1),
    end: DateTime(now.year, 12, 31, 23, 59, 59),
  );
}

DateTimeRange getTodayRange() {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month, now.day),
    end: DateTime(now.year, now.month, now.day, 23, 59, 59),
  );
}
