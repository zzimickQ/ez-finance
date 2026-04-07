import 'package:drift/drift.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationId => text()();
  TextColumn get entityType => text()();
  IntColumn get entityId => integer()();
  TextColumn get operation => text()();
  TextColumn get data => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
}
