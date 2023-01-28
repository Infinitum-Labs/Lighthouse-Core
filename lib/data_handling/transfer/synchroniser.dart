part of core.data_handling.transfer;

class Synchroniser {
  static late Timer syncTimer;
  static late Timer jwtRefreshTimer;
  static void init() {
    syncTimer =
        Timer.periodic(const Duration(seconds: 20), (_) => synchronise());
    jwtRefreshTimer =
        Timer.periodic(const Duration(minutes: 20), (_) => refreshToken());
  }

  static void deinit() {
    syncTimer.cancel();
    jwtRefreshTimer.cancel();
  }

  static Future<void> refreshToken() async {}

  static final List<int> creationIndexes = [];

  static Future<void> synchronise() async {
    /* // { 'users': ['id#1', 'id#2'] }
    final Map<String, List<String>> updates = {};
    final Map<String, List<JSON>> creations = {};
    LoopUtils.iterateOver<Table>(Storage.tables.values, (Table table) async {
      final List<int> indexes =
          await table.getIndexesWhere(TableQuery.dirtyIndexes(table));
      await LoopUtils.iterateOverAsync<int>(indexes, (int index) async {
        if (creationIndexes.contains(index)) {
          final JSON json = (await table.recordsToJSON([index])).first;
          if (creations.keys.contains(table.name)) {
            creations[table.name]!.add(json);
          } else {
            creations[table.name] = [json];
          }
        } else {
          if (updates.keys.contains(table.name)) {
            updates[table.name]!.add(table.objectId.getCell(index));
          } else {
            updates[table.name] = [table.objectId.getCell(index)];
          }
        }
      });

      final Response res = Response.fromJSON(
          {}); /*await DB.get(
        SyncRequest(
          creations: creations,
          updates: updates,
        ),
      );*/

      final JSON payload = res.payload.first;
      final List<JSON> dbCreations =
          (payload['creations'] as List).map((e) => e as JSON).toList();
      final List<ObjectId> dbDeletions =
          (payload['deletions'] as List).map((e) => e as ObjectId).toList();
      final List<JSON> dbUpdates =
          (payload['updates'] as List).map((e) => e as JSON).toList();
      // Send to DB
      // Receive from DB
      // Update creations and deletions isDirty
      // Send request
      // Receive objects
      // Update isDirty
    }); */
  }
}
