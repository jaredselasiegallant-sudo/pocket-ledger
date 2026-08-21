import 'package:drift/drift.dart';

/// Transaction table for storing all financial transactions
/// Default currency is GHS (Ghana Cedi)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get type => text()(); // credit, debit, transfer
  TextColumn get category => text().withDefault(const Constant('Other'))();
  TextColumn get vendor => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get provider => text().nullable()(); // MTN MoMo, GCB, etc.
  TextColumn get account => text().nullable()();
  BoolColumn get isAutoCaptured => boolean().withDefault(const Constant(false))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringFrequency => text().nullable()(); // daily, weekly, monthly
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
