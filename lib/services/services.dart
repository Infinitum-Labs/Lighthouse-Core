library core.services;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lighthouse_core/auth/auth.dart';
import 'package:lighthouse_core/cli/wheelhouse_engine/wh_script/wh_script.dart';
import 'package:lighthouse_core/db/db.dart';
import 'package:lighthouse_core/engines/wheelhouse_engine/wheelhouse_engine.dart';
import 'package:lighthouse_core/utils/utils.dart';
import '../engines/engines.dart';

part './db_service.dart';
part 'auth_service.dart';
part 'beaconsearch_service.dart';
part 'context_service.dart';
part 'keybine_service.dart';
part 'prototype_service.dart';
part 'wheelhouse_service.dart';

abstract class LHService {
  final AccessKey accessKey;

  const LHService({
    required this.accessKey,
  });

  void requirePermissions(Set<Permission> perms) {
    if (accessKey.permissions.containsAll(perms)) {
      return;
      // ensure the JWT is not compromised
      if (accessKey.isAuthentic) {
        // ensure the JWT is not expired
        if (accessKey.isValid) {}
      } else {}
    } else {
      throw InsufficientPermsException(perms.difference(accessKey.permissions));
    }
  }
}
