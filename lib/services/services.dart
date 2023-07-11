library core.services;

import '../engines/engines.dart';

part 'auth_service.dart';
part 'beaconsearch_service.dart';
part 'context_service.dart';
part 'keybine_service.dart';
part 'prototype_service.dart';
part 'wiz_service.dart';

/// An [AccessKey] is issued by a trusted source, and follows a JWT model
/// where the payload is part of the signature.
/// The app loads its [AccessKey]s via asset files that are excluded from Git tracking
/// and only provided to deployment platforms.
class AccessKey {
  final String jwtString;

  AccessKey({
    required this.jwtString,
  });
}

class Permission {}

abstract class LHService<K extends AccessKey> {
  final K accessKey;
  late final bool authenticated;

  LHService({
    required this.accessKey,
  }) {
    authenticated = authenticateKey(accessKey);
  }

  bool authenticateKey(K accessKey);
  void ensureAuthenticated() {
    if (!authenticated) throw Exception("Not authenticated");
  }
}
