import 'package:drift/drift.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/data/database/tables/transactions_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  /// Insert a new transaction
  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  /// Get all transactions (non-deleted), newest first
  Future<List<Transaction>> getAllTransactions({int limit = 100, int offset = 0}) {
    return (select(transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Watch all transactions (reactive stream)
  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  /// Get transactions by type (credit/debit/transfer)
  Future<List<Transaction>> getTransactionsByType(String type) {
    return (select(transactions)
          ..where((t) => t.type.equals(type) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(String category) {
    return (select(transactions)
          ..where((t) =>
              t.category.equals(category) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Get transactions within a date range
  Future<List<Transaction>> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return (select(transactions)
          ..where((t) =>
              t.transactionDate.isBetweenValues(start, end) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Get total income (credits) for a period
  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    final result = await (selectOnly(transactions)
          ..where(transactions.type.equals('credit') &
              transactions.isDeleted.equals(false) &
              transactions.transactionDate.isBetweenValues(start, end))
          ..addColumns([transactions.amount.sum()]))
        .get();

    return result.fold<double>(0, (sum, row) {
      final amount = row.read(transactions.amount.sum());
      return sum + (amount ?? 0).toDouble();
    });
  }

  /// Get total expenses (debits) for a period
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    final result = await (selectOnly(transactions)
          ..where(transactions.type.equals('debit') &
              transactions.isDeleted.equals(false) &
              transactions.transactionDate.isBetweenValues(start, end))
          ..addColumns([transactions.amount.sum()]))
        .get();

    return result.fold<double>(0, (sum, row) {
      final amount = row.read(transactions.amount.sum());
      return sum + (amount ?? 0).toDouble();
    });
  }

  /// Get spending by category for a period
  Future<List<MapEntry<String, double>>> getSpendingByCategory(
      DateTime start, DateTime end) async {
    final query = selectOnly(transactions)
      ..where(transactions.type.equals('debit') &
          transactions.isDeleted.equals(false) &
          transactions.transactionDate.isBetweenValues(start, end))
      ..groupBy([transactions.category])
      ..addColumns([transactions.amount.sum()]);

    final result = await query.get();
    return result.map((row) {
      final category = row.read(transactions.category) ?? 'Other';
      final total = (row.read(transactions.amount.sum()) ?? 0).toDouble();
      return MapEntry(category, total);
    }).toList();
  }

  /// Update a transaction
  Future<bool> updateTransaction(TransactionsCompanion transaction) {
    return update(transactions).replace(transaction);
  }

  /// Soft delete a transaction
  Future<int> softDeleteTransaction(int id) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get the most recent transactions (for auto-capture dedup check)
  Future<Transaction?> getMostRecentTransaction() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }
}
