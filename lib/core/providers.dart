import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/data/repositories/transaction_repository.dart';
import 'package:pocket_ledger/data/repositories/account_repository.dart';
import 'package:pocket_ledger/data/repositories/budget_repository.dart';

// ─── Database Singleton ───
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ─── Repositories ───
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(databaseProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(databaseProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(databaseProvider));
});

// ─── Transaction Streams ───
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

// ─── Account Data ───
final activeAccountsProvider = FutureProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).getActive();
});

final totalBalanceProvider = FutureProvider<double>((ref) {
  return ref.watch(accountRepositoryProvider).getTotalBalance();
});

// ─── Budget Data ───
final activeBudgetsProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchActive();
});

final totalBudgetProvider = FutureProvider<double>((ref) {
  return ref.watch(budgetRepositoryProvider).getTotalMonthlyBudget();
});

final totalSpentProvider = FutureProvider<double>((ref) {
  return ref.watch(budgetRepositoryProvider).getTotalSpentThisMonth();
});

// ─── Summary Data (current month) ───
final currentMonthSummaryProvider = FutureProvider<MonthSummary>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final txRepo = ref.watch(transactionRepositoryProvider);
  final income = await txRepo.getTotalIncome(start, end);
  final expenses = await txRepo.getTotalExpenses(start, end);
  final transactions = await txRepo.getByDateRange(start, end);

  return MonthSummary(
    income: income,
    expenses: expenses,
    balance: income - expenses,
    transactions: transactions,
  );
});

// ─── Category Spending for current month ───
final categorySpendingProvider = FutureProvider<List<MapEntry<String, double>>>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return ref.watch(transactionRepositoryProvider).getSpendingByCategory(start, end);
});

class MonthSummary {
  final double income;
  final double expenses;
  final double balance;
  final List<Transaction> transactions;

  const MonthSummary({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.transactions,
  });
}
