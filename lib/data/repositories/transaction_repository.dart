import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/data/database/daos/transactions_dao.dart';
import 'package:pocket_ledger/features/auto_capture/data/ghana_transaction_parser.dart';

/// Repository for transaction data operations
/// Bridges the DAO layer with feature-level business logic
class TransactionRepository {
  final TransactionsDao _dao;
  final _uuid = const Uuid();

  TransactionRepository(AppDatabase db) : _dao = TransactionsDao(db);

  /// Add a manually created transaction
  Future<int> addTransaction({
    required String title,
    String? description,
    required double amount,
    required String type,
    required String category,
    String? vendor,
    String? reference,
    String? provider,
    String? account,
    DateTime? transactionDate,
  }) async {
    final now = DateTime.now();
    return _dao.insertTransaction(
      TransactionsCompanion.insert(
        uuid: _uuid.v4(),
        title: title,
        description: description != null ? Value(description) : const Value.absent(),
        amount: amount,
        type: type,
        category: Value(category),
        vendor: vendor != null ? Value(vendor) : const Value.absent(),
        reference: reference != null ? Value(reference) : const Value.absent(),
        provider: provider != null ? Value(provider) : const Value.absent(),
        account: account != null ? Value(account) : const Value.absent(),
        transactionDate: transactionDate ?? now,
      ),
    );
  }

  /// Add a transaction captured from notification/SMS
  Future<int?> addAutoCapturedTransaction(ParsedTransaction parsed) async {
    // Check for duplicate based on amount + reference + timestamp proximity
    final recent = await _dao.getMostRecentTransaction();
    if (recent != null) {
      final timeDiff = DateTime.now().difference(recent.createdAt).inSeconds;
      if (recent.amount == parsed.amount &&
          recent.reference == parsed.reference &&
          timeDiff < 30) {
        return null; // Duplicate — skip
      }
    }

    final title = _generateTitle(parsed);

    return _dao.insertTransaction(
      TransactionsCompanion.insert(
        uuid: _uuid.v4(),
        title: title,
        amount: parsed.amount,
        type: parsed.type.name,
        category: Value(_autoCategory(parsed)),
        vendor: parsed.sender != null ? Value(parsed.sender!) : const Value.absent(),
        reference: parsed.reference != null ? Value(parsed.reference!) : const Value.absent(),
        provider: Value(parsed.provider),
        isAutoCaptured: const Value(true),
        transactionDate: parsed.timestamp,
      ),
    );
  }

  /// Get all transactions
  Future<List<Transaction>> getAll({int limit = 100, int offset = 0}) {
    return _dao.getAllTransactions(limit: limit, offset: offset);
  }

  /// Watch all transactions (reactive)
  Stream<List<Transaction>> watchAll() {
    return _dao.watchAllTransactions();
  }

  /// Get transactions by type
  Future<List<Transaction>> getByType(String type) {
    return _dao.getTransactionsByType(type);
  }

  /// Get transactions by category
  Future<List<Transaction>> getByCategory(String category) {
    return _dao.getTransactionsByCategory(category);
  }

  /// Get transactions in date range
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) {
    return _dao.getTransactionsByDateRange(start, end);
  }

  /// Get total income for period
  Future<double> getTotalIncome(DateTime start, DateTime end) {
    return _dao.getTotalIncome(start, end);
  }

  /// Get total expenses for period
  Future<double> getTotalExpenses(DateTime start, DateTime end) {
    return _dao.getTotalExpenses(start, end);
  }

  /// Get spending breakdown by category
  Future<List<MapEntry<String, double>>> getSpendingByCategory(
      DateTime start, DateTime end) {
    return _dao.getSpendingByCategory(start, end);
  }

  /// Delete a transaction (soft)
  Future<int> delete(int id) {
    return _dao.softDeleteTransaction(id);
  }

  /// Update an existing transaction
  Future<bool> updateTransaction({
    required int id,
    required String title,
    required double amount,
    required String type,
    required String category,
    String? vendor,
    String? account,
    String? description,
    DateTime? transactionDate,
  }) async {
    return _dao.updateTransaction(
      TransactionsCompanion(
        id: Value(id),
        title: Value(title),
        amount: Value(amount),
        type: Value(type),
        category: Value(category),
        vendor: vendor != null ? Value(vendor) : const Value.absent(),
        account: account != null ? Value(account) : const Value.absent(),
        description: description != null ? Value(description) : const Value.absent(),
        transactionDate: Value(transactionDate ?? DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  String _generateTitle(ParsedTransaction parsed) {
    if (parsed.type == TransactionType.credit) {
      return 'Received from ${parsed.sender ?? parsed.provider}';
    } else if (parsed.type == TransactionType.debit) {
      return parsed.recipient != null
          ? 'Paid to ${parsed.recipient}'
          : 'Payment via ${parsed.provider}';
    } else if (parsed.type == TransactionType.transfer) {
      return 'Transfer via ${parsed.provider}';
    }
    return 'Transaction via ${parsed.provider}';
  }

  String _autoCategory(ParsedTransaction parsed) {
    final text = parsed.rawText.toLowerCase();

    if (text.contains('airtime') || text.contains('data') || text.contains('bundle')) {
      return 'Communication';
    }
    if (text.contains('electricity') || text.contains('water') || text.contains('utility')) {
      return 'Utilities';
    }
    if (text.contains('salary') || text.contains('wages')) {
      return 'Salary';
    }
    if (text.contains('airline') || text.contains('hotel') || text.contains('uber') || text.contains('taxi') || text.contains('bolt')) {
      return 'Transport';
    }
    if (text.contains('school') || text.contains('tuition') || text.contains('university')) {
      return 'Education';
    }
    if (text.contains('hospital') || text.contains('pharmacy') || text.contains('clinic')) {
      return 'Health';
    }
    if (parsed.isCredit) {
      return 'Income';
    }
    return 'Other';
  }
}
