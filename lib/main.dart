import 'package:flutter/material.dart';
import 'package:lighthouse_core/auth/auth.dart';
import 'package:lighthouse_core/db/db.dart';

import './dev_temp.dart';

/// Dev purposes only
final AccessKey superAccessKey = AccessKey.fromString(
  jwtObject: JWTObjectV1(
    jwtAlgo: JWTAlgo.hs256,
    sub: 'sub',
    iat: DateTime.now(),
    exp: DateTime.now(),
    permissions: const {
      Permission(permId: PermissionId.db_read),
      Permission(permId: PermissionId.db_write),
      Permission(permId: PermissionId.db_access_workbenches),
      Permission(permId: PermissionId.wh_execute),
    },
  ),
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.init();
  runApp(const App());
}
