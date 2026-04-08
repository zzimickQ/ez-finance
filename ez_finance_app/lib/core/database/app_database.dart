import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables/profiles_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/users_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users, Profiles, SyncQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'ez_finance_db_v1');
  }

  Future<List<User>> getAllUsers() => select(users).get();

  Stream<List<User>> watchAllUsers() => select(users).watch();

  Future<User?> getUserById(String id) =>
      (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<User?> getUserByEmail(String email) =>
      (select(users)..where((u) => u.email.equals(email))).getSingleOrNull();

  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<bool> updateUser(User user) => update(users).replace(user);

  Future<int> deleteUser(String id) =>
      (delete(users)..where((u) => u.id.equals(id))).go();

  Future<List<Profile>> getAllProfiles() => select(profiles).get();

  Stream<List<Profile>> watchAllProfiles() {
    return (select(profiles)..where((p) => p.isDeleted.equals(false))).watch();
  }

  Future<Profile?> getProfileByUserId(String userId) =>
      (select(profiles)..where((p) => p.id.equals(userId))).getSingleOrNull();

  Stream<Profile?> watchProfileByUserId(String userId) =>
      (select(profiles)
            ..where((p) => p.id.equals(userId) & p.isDeleted.equals(false)))
          .watchSingleOrNull();

  Future<Profile?> insertProfile(ProfilesCompanion profile) =>
      into(profiles).insertReturning(profile);

  Future<bool> updateProfile(Profile profile) =>
      update(profiles).replace(profile);

  Future<int> softDeleteProfile(String id) =>
      (update(profiles)..where((p) => p.id.equals(id))).write(
        const ProfilesCompanion(isDeleted: Value(true)),
      );

  Future<List<SyncQueueData>> getAllSyncQueueItems() => select(syncQueue).get();

  Future<List<SyncQueueData>> getPendingSyncQueueItems() =>
      (select(syncQueue)..orderBy([(t) => OrderingTerm.asc(t.priority)])).get();

  Stream<List<SyncQueueData>> watchPendingSyncQueueItems() => (select(
    syncQueue,
  )..orderBy([(t) => OrderingTerm.asc(t.priority)])).watch();

  Future<int> insertSyncQueueItem(SyncQueueCompanion item) =>
      into(syncQueue).insert(item);

  Future<int> deleteSyncQueueItem(int id) =>
      (delete(syncQueue)..where((s) => s.id.equals(id))).go();

  Future<bool> updateSyncQueueItem(SyncQueueData item) =>
      update(syncQueue).replace(item);

  Future<void> clearAllData() async {
    await delete(syncQueue).go();
    await delete(profiles).go();
    await delete(users).go();
  }
}
