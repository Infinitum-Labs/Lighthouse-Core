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
  final JSON signature;
  final JSON payload;
  final JSON raw;

  JWTToken(this.raw)
      : signature = raw['signature'] as JSON,
        payload = (raw['body'] as JSON)['payload'] as JSON;

  String get sub => payload['sub'] as String;
}

class HTTP {
  static const String authority = "infinitumlabsinc.editorx.io";
  static const String api = "/lighthousecloud/_functions";
  static late Client client;
  static JWTToken? jwtToken;

  static void init() {
    client = Client();
  }

  static void deinit() {
    client.close();
  }

  static Future<Response> send({
    required String path,
    JSON requestBody = const {},
    bool injectJwt = true,
  }) async {
    final Uri uri = Uri.https(HTTP.authority, HTTP.api + path);
    if (injectJwt) {
      requestBody.addAll({
        'jwt': jwtToken!.raw,
      });
    }
    final String body = jsonEncode(requestBody);
    return await client.post(uri, body: body);
  }

  static Future<Response> getJwtToken(
    String emailAddress,
    String password,
  ) async {
    final Response res = await HTTP.send(
      path: '/getJwtToken',
      requestBody: {
        'emailAddress': emailAddress,
        'password': password,
      },
      injectJwt: false,
    );
    if (res.isOk) {
      jwtToken = JWTToken(
        (res.jsonBody['payload']! as List).first,
      );
    }
    return res;
  }

  static Future<Response> getAllObjects() async {
    return await send(path: '/getAllObjects', requestBody: {
      'userId': jwtToken!.sub,
    });
  }
}

extension ResponseUtils on Response {
  bool get isOk => statusCode >= 200 && statusCode < 300;
  JSON get jsonBody => json.decode(body);
  List<JSON> get jsonPayload => jsonBody['payload'] as List<JSON>;
}
