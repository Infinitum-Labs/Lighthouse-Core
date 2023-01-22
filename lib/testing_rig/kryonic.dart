library kryonic;

import 'dart:async';

enum StatusCode {
  err("ERR "),
  warn("WARN"),
  log("LOG ");

  const StatusCode(this.code);
  final String code;

  @override
  String toString() => code;
}

class KRConsole {
  static final List<KRLog> logs = [];
  static final StreamController<KRLog> streamController =
      StreamController<KRLog>();
  static final Stream<KRLog> output =
      streamController.stream.asBroadcastStream();
  static void write(KRLog log) {
    logs.add(log);
    streamController.add(log);
  }

  static void deinit() {
    streamController.close();
  }
}

class KRLog {
  final String message;
  final dynamic payload;
  final StatusCode statusCode;

  KRLog({
    required this.statusCode,
    required this.message,
    this.payload,
  });

  KRLog.log({
    required this.message,
    this.statusCode = StatusCode.log,
    this.payload,
  });

  KRLog.warn({
    required this.message,
    this.statusCode = StatusCode.warn,
    this.payload,
  });

  KRLog.err({
    required this.message,
    this.statusCode = StatusCode.err,
    this.payload,
  });

  String generateTimestamp() {
    final DateTime now = DateTime.now();
    return "${now.minute}:${now.second}:${now.millisecond}";
  }

  String toLogString() {
    return "[${generateTimestamp()}] $statusCode | $message\n${' ' * 38}$payload";
  }
}
