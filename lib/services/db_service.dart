part of core.services;

class DBService extends LHService {
  const DBService({
    required super.accessKey,
  });

  Future<Workbench> getWorkbench({
    required String userName,
  }) async {
    requirePermissions({
      const Permission(permId: PermissionId.db_read),
      const Permission(permId: PermissionId.db_access_workbenches),
    });
    final QuerySnapshot snapshot = await DB.db
        .collection('workbenches')
        .where('userName', isEqualTo: userName)
        .get();
    final QueryDocumentSnapshot docRef = snapshot.docs.first;
    //return DB.loadNative<Workbench>(docRef.data() as JSON);
    throw "whut";
  }
}
