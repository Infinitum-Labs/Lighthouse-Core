part of core.auth;

class Permission implements JSONObject {
  final PermissionId permId;

  const Permission({
    required this.permId,
  });

  @override
  Map toJson() => {'permId': permId.name.split('_').join('.')};

  static PermissionId? permissionIdFromString(String src) {
    // do a switch-case
    return null;
  }

  @override
  String toString() => "Permission<${permId.name}>";
}

enum PermissionId {
  db_read,
  db_write,
  db_delete,
  db_access_workbenches,
  wh_execute,
}
