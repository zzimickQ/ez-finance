import 'package:drift/drift.dart';
import 'users_table.dart';

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
