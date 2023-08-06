library lhcore.engines.wh_engine.wh_script;

import '../../../../utils/utils.dart';
import '../wheelhouse_engine.dart';

class WHParser {
  final String source;
  final List<String> chars;

  WHParser({
    required this.source,
  }) : chars = source.split('');

  WheelhouseCommand parse() {
    final Map<String, dynamic> localFlags = {};
    final Map<String, dynamic> globalFlags = {};
    final List<String> posArgsList = [];
    final Map<String, dynamic> namedArgsMap = {};

    void parsePosArgs() {
      final List<String> argChars = [];
      while (!match('"')) {
        argChars.add(discardRecentToken());
      }
      posArgsList.add(argChars.join());
    }

    final String root = parseRoot();
    final String endpoint = parseEndpoint();
    if (!atEnd) {
      while (!atEnd && match('"')) {
        parsePosArgs();
        if (!atEnd) discardRecentToken();
      }
      while (!atEnd && (isAlpha(currentToken) || currentToken == '-')) {
        namedArgsMap.addAll(parseNamedArgs());
        if (!atEnd) discardRecentToken();
      }
    }
    namedArgsMap.removeWhere((String key, dynamic value) {
      final bool shouldRemove;
      if (key.startsWith('--')) {
        globalFlags.addAll({key: value});
        shouldRemove = true;
      } else if (key.startsWith('-')) {
        localFlags.addAll({key: value});
        shouldRemove = true;
      } else {
        shouldRemove = false;
      }
      return shouldRemove;
    });
    return WheelhouseCommand(
      root: root,
      endpoint: endpoint,
      positionalArgsList: posArgsList,
      namedArgsMap: namedArgsMap,
      localFlags: localFlags,
      globalFlags: globalFlags,
    );
  }

  String parseRoot() {
    final List<String> rootChars = [];
    while (!match('.')) {
      if (isAlpha(currentToken) || isNum(currentToken)) {
        rootChars.add(discardRecentToken());
      } else {
        throw "Invalid token '$currentToken' when parsing root";
      }
    }
    return rootChars.join();
  }

  String parseEndpoint() {
    final List<String> endpointChars = [];
    while (!atEnd && !match(' ')) {
      if (isAlpha(currentToken) || isNum(currentToken) || currentToken == '.') {
        endpointChars.add(discardRecentToken());
      } else {
        throw "Invalid token '$currentToken' when parsing endpoint";
      }
    }
    return endpointChars.join();
  }

  Map<String, dynamic> parseNamedArgs() {
    final Map<String, dynamic> argMap = {};
    final List<String> argNameChars = [];
    final List<String> argValChars = [];
    final bool isFlag = match('-');
    final int flagDashCount = isFlag && match('-') ? 2 : 1;

    while (!match(':')) {
      if (isAlpha(currentToken) || isNum(currentToken)) {
        argNameChars.add(discardRecentToken());
      } else if (isFlag && currentToken == ' ') {
        argNameChars.insert(0, '-');
        if (flagDashCount == 2) argNameChars.insert(0, '-');
        argMap["${argNameChars.join()}"] = argValChars.join();
        return argMap;
      } else {
        throw "Invalid token '$currentToken' when parsing arg name";
      }
    }
    while (!match(';')) {
      if (isFlag) {
        argMap["${'-' * flagDashCount}${argNameChars.join()}"] =
            argValChars.join();
      }
      match(' ');
      argValChars.add(discardRecentToken());
    }
    argMap[argNameChars.join()] = argValChars.join();
    return argMap;
  }

  String get currentToken => chars[0];

  bool match(String expectedToken) {
    if (currentToken == expectedToken) {
      discardRecentToken();
      return true;
    } else {
      return false;
    }
  }

  bool isAlpha(String x) => alphabets.contains(x.toLowerCase());
  bool isNum(String x) => double.tryParse(x) != null;

  void consume(String expectedToken, String msg) {
    if (atEnd) {
      throw msg;
    } else {
      if (chars[0] == expectedToken) {
        discardRecentToken();
      } else {
        throw msg;
      }
    }
  }

  bool get atEnd => chars.isEmpty;

  String discardRecentToken() => chars.removeAt(0);
}
