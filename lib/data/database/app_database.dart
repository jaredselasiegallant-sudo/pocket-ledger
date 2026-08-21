import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:pocket_ledger/data/database/tables/transactions_table.dart';
import 'package:pocket_ledger/data/database/tables/budgets_table.dart';
import 'package:pocket_ledger/data/database/tables/accounts_table.dart';
import 'package:pocket_ledger/data/database/daos/transactions_dao.dart';
import 'package:pocket_ledger/data/database/daos/budgets_dao.dart';
import 'package:pocket_ledger/data/database/daos/accounts_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Transactions, Budgets, Accounts, Categories],
  daos: [TransactionsDao, BudgetsDao, AccountsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
      },
    );
  }

  Future<void> _seedDefaultCategories() async {
    final defaultCategories = [
      ('Food & Dining', 'restaurant', '#FF6D00'),
      ('Transport', 'directions_car', '#2962FF'),
      ('Utilities', 'bolt', '#00BFA5'),
      ('Health', 'local_hospital', '#D50000'),
      ('Education', 'school', '#AA00FF'),
      ('Entertainment', 'movie', '#FF1744'),
      ('Shopping', 'shopping_bag', '#E91E63'),
      ('Savings', 'savings', '#00C853'),
      ('Investment', 'trending_up', '#6200EA'),
      ('Salary', 'work', '#00B0FF'),
      ('Business', 'business', '#FFD600'),
      ('Gifts', 'card_giftcard', '#FF4081'),
      ('Rent', 'home', '#795548'),
      ('Communication', 'phone', '#00BCD4'),
      ('Other', 'category', '#9E9E9E'),
    ];

    for (int i = 0; i < defaultCategories.length; i++) {
      final (name, icon, color) = defaultCategories[i];
      await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          icon: Value(icon),
          color: Value(color),
          isDefault: const Value(true),
          sortOrder: Value(i),
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pocket_ledger', 'pocket_ledger.db'));
    return NativeDatabase.createInBackground(file);
  });
}
