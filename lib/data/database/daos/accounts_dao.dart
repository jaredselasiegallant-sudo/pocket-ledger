import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/data/database/tables/accounts_table.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  /// Insert a new account
  Future<int> insertAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }

  /// Get all active accounts
  Future<List<Account>> getActiveAccounts() {
    return (select(accounts)
          ..where((a) => a.isActive.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.name)]))
        .get();
  }

  /// Watch all active accounts
  Stream<List<Account>> watchActiveAccounts() {
    return (select(accounts)
          ..where((a) => a.isActive.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.name)]))
        .watch();
  }

  /// Get account by ID
  Future<Account?> getAccountById(int id) {
    return (select(accounts)..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get account by name
  Future<Account?> getAccountByName(String name) {
    return (select(accounts)
          ..where((a) => a.name.equals(name) & a.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Update account balance
  Future<int> updateBalance(int accountId, double newBalance) {
    return (update(accounts)..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion(
        balance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update an account
  Future<bool> updateAccount(AccountsCompanion account) {
    return update(accounts).replace(account);
  }

  /// Deactivate an account
  Future<int> deactivateAccount(int id) {
    return (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get total balance across all accounts that include in total
  Future<double> getTotalBalance() async {
    final query = selectOnly(accounts).join([])
      ..where(accounts.isActive.equals(true) &
          accounts.includeInTotal.equals(true))
      ..addColumns([accounts.balance.sum()]);

    final result = await query.get();
    return result.first.read(accounts.balance.sum()) ?? 0;
  }

  /// Seed default accounts for Ghana
  Future<void> seedDefaultAccounts() async {
    final defaults = [
      ('MTN MoMo', 'mobile_money', 'MTN MoMo', 0.0),
      ('Telecel Cash', 'mobile_money', 'Telecel Cash', 0.0),
      ('AT Money', 'mobile_money', 'AT Money', 0.0),
      ('GCB Bank', 'bank', 'GCB', 0.0),
      ('Cash Wallet', 'cash', null, 0.0),
    ];

    final uuid = const Uuid();
    for (final (name, type, provider, balance) in defaults) {
      await into(accounts).insert(
        AccountsCompanion.insert(
          uuid: uuid.v4(),
          name: name,
          type: type,
          provider: Value(provider),
          balance: Value(balance),
        ),
      );
    }
  }
}
