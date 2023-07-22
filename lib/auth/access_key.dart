part of core.auth;

/// An [AccessKey] is issued by a trusted source, and follows a JWT model
/// where the payload is part of the signature.
/// See Figma brainstorm for full details.
class AccessKey {
  final JWTObjectV1 _jwtObject;

  AccessKey.fromString({required JWTObjectV1 jwtObject})
      : _jwtObject = jwtObject;

  Set<Permission> get permissions => _jwtObject.permissions;

  bool get isAuthentic => true;
  bool get isValid => true;
}
