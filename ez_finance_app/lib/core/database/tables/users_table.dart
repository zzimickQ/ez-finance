import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()();
  TextColumn get name => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
