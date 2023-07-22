part of core.auth;

typedef JwtString = String;

enum JWTAlgo {
  hs256,
}

/// A schema for a JWTObject. Extend this base class to create new versions.
abstract class JWTObject {}

class JWTObjectV1 implements JSONObject {
  final JWTAlgo jwtAlgo;
  final String typ = 'jwt';

  /// User ID
  final String sub;
  final DateTime iat;
  final DateTime exp;
  final Set<Permission> permissions;

  const JWTObjectV1({
    required this.jwtAlgo,
    required this.sub,
    required this.iat,
    required this.exp,
    required this.permissions,
  });

  JSON get headerJson => {
        'jwtAlgo': jwtAlgo.name,
        'typ': typ,
      };

  JSON get payloadJson => {
        'sub': sub,
        'iat': iat.secondsSinceEpoch,
        'exp': exp.secondsSinceEpoch,
        'perms': permissions,
      };

  /// Not fully implemented yet (need to pick an algorithm)
  String get signature {
    return HttpUtils.encodeToBase64Url(jsonEncode(headerJson)) +
        HttpUtils.encodeToBase64Url(jsonEncode(payloadJson)) +
        secret;
  }

  JwtString get jwtString {
    return "${HttpUtils.encodeToBase64Url(jsonEncode(headerJson))}.${HttpUtils.encodeToBase64Url(jsonEncode(payloadJson))}.$signature";
  }

  /// Not actually used, just for debugging
  @override
  Map toJson() {
    return {
      'header': headerJson,
      'payload': payloadJson,
      'signature': signature,
    };
  }
}
