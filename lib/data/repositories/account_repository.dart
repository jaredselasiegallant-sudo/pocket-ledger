import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/data/database/daos/accounts_dao.dart';

/// Repository for account/wallet data operations
class AccountRepository {
  final AccountsDao _dao;
  final _uuid = const Uuid();

  AccountRepository(AppDatabase db) : _dao = AccountsDao(db);

  /// Add a new account
  Future<int> addAccount({
    required String name,
    required String type,
    String? provider,
    double initialBalance = 0,
    String? accountNumber,
  }) async {
    return _dao.insertAccount(
      AccountsCompanion.insert(
        uuid: _uuid.v4(),
        name: name,
        type: type,
        provider: provider != null ? Value(provider) : const Value.absent(),
        balance: Value(initialBalance),
        accountNumber: accountNumber != null ? Value(accountNumber) : const Value.absent(),
      ),
    );
  }

  /// Get all active accounts
  Future<List<Account>> getActive() {
    return _dao.getActiveAccounts();
  }

  /// Watch all active accounts
  Stream<List<Account>> watchActive() {
    return _dao.watchActiveAccounts();
  }

  /// Get account by ID
  Future<Account?> getById(int id) {
    return _dao.getAccountById(id);
  }

  /// Update account balance
  Future<int> updateBalance(int accountId, double newBalance) {
    return _dao.updateBalance(accountId, newBalance);
  }

  /// Credit an account (income)
  Future<void> creditAccount(int accountId, double amount) async {
    final account = await _dao.getAccountById(accountId);
    if (account != null) {
      await _dao.updateBalance(accountId, account.balance + amount);
    }
  }

  /// Debit an account (expense)
  Future<void> debitAccount(int accountId, double amount) async {
    final account = await _dao.getAccountById(accountId);
    if (account != null) {
      await _dao.updateBalance(accountId, account.balance - amount);
    }
  }

  /// Get total balance across all accounts
  Future<double> getTotalBalance() {
    return _dao.getTotalBalance();
  }

  /// Seed default Ghana accounts
  Future<void> seedDefaults() {
    return _dao.seedDefaultAccounts();
  }

  /// Deactivate an account
  Future<int> deactivate(int id) {
    return _dao.deactivateAccount(id);
  }
}
