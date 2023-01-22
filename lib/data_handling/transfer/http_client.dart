part of core.data_handling.transfer;

enum RequestMethod {
  get("GET"),
  post("POST"),
  put("PUT"),
  delete("DELETE");

  final String value;
  const RequestMethod(this.value);
}

class JWTToken {
  final String signature;
  final JSON payload;
  final JSON raw;

  JWTToken({
    required this.signature,
    required this.payload,
    required this.raw,
  });

  String get sub => payload['sub'] as String;
}

class Request {
  final RequestMethod method;
  final String path;
  final JSON params;
  final dynamic payload;
  final bool injectJwt;

  const Request({
    required this.path,
    this.method = RequestMethod.get,
    this.params = const {},
    this.injectJwt = true,
    this.payload,
  });

  Future<HttpRequest> execute() {
    if (injectJwt) {
      params.addAll({
        'jwt': json.encode(HTTP.jwtToken?.payload),
      });
    }
    return HttpRequest.request(
      "https://${HTTP.authority}${HTTP.api}$path".attachParams(params),
      method: method.value,
      requestHeaders: injectJwt
          ? {
              'authorization': "Bearer ${HTTP.jwtToken?.signature ?? 'null'}",
            }
          : null,
    );
  }
}

class Response {
  final Map<String, dynamic> raw;
  final int statusCode;
  final String statusMsg;
  final List<JSON> payload;

  Response.fromJSON(this.raw)
      : statusCode = raw['status']['code'] as int,
        statusMsg = raw['status']['msg'] as String,
        payload = (raw['payload'] as List).cast<JSON>();

  bool get isOk => (statusCode >= 200) && (statusCode < 300);
}

class HTTP {
  static const String authority = "infinitumlabsinc.editorx.io";
  static const String api = "/lighthousecloud/_functions";
  static JWTToken? jwtToken;

  static Future<Response> getJwtToken(
    String emailAddress,
    String password,
  ) async {
    final HttpRequest req = await Request(
      path: '/jwtToken',
      params: {
        'emailAddress': emailAddress,
        'password': password,
      },
      injectJwt: false,
    ).execute();
    final Response res = Response.fromJSON(json.decode(req.responseText!));
    jwtToken = JWTToken(
      signature: res.payload.first['signature'] as String,
      payload: res.payload.first['payload'] as JSON,
      raw: res.payload.first,
    );
    print("incoming");
    print(res.payload.first);
    return res;
  }

  static Future<Response> getRefreshJwtToken() async {
    throw "done";
  }

  static Future<Response> getAllObjects() async {
    final HttpRequest req = await Request(
      path: '/getAllObjects',
      params: {
        'userId': jwtToken!.sub,
      },
    ).execute();

    final Response res = Response.fromJSON(json.decode(req.responseText!));
    KRConsole.write(
        KRLog.log(message: "pullAllObjects", payload: res.payload.first));
    return res;
  }

  //static Future<Response> getAll() async {}

  //static Future<Response> getSync() async {}
}

extension HttpUtils on String {
  String attachParams(JSON params, {bool injectJwt = true}) {
    final List<String> encodedQueryComponents = [];
    for (final String key in params.keys) {
      encodedQueryComponents.add(
        "$key=" + Uri.encodeQueryComponent(params[key] as String),
      );
    }
    if (HTTP.jwtToken != null) {
      encodedQueryComponents
          .add("auth=${Uri.encodeQueryComponent(HTTP.jwtToken!.signature)}");
    }
    print("outgoing");
    print(HTTP.jwtToken?.signature);
    return this + "?" + encodedQueryComponents.join('&');
  }

  String base64Encode() => utf8.fuse(base64).encode(this);
  String base64Decode() => utf8.fuse(base64).decode(this);
}

extension JwtUtils on HttpRequest {
  void injectJwt() {
    setRequestHeader(
        'authorization', HTTP.jwtToken?.signature.base64Encode() ?? 'NULL');
  }
}
