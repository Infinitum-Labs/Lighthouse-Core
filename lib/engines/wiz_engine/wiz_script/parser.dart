part of core.engines.wiz_engine.wiz_script;

class WizScriptParser {
  final List<Token> tokens;
  int current = 0;

  WizScriptParser(this.tokens);

  WizCommand parse() {
    final List<String> cmdRoot = parseCmdRoot();
    final List<String> posArgs = parsePosArgs();
    final Map<String, Map> argsAndFlags = parseNamedArgs();
    final Map<String, String> namedArgs =
        argsAndFlags['namedArgs'] as Map<String, String>;
    final Map<String, Map<String, String>> flags =
        argsAndFlags['flags'] as Map<String, Map<String, String>>;

    return WizCommand(
      cmdRoot: cmdRoot,
      posArgs: posArgs,
      namedArgs: namedArgs,
      localFlags: flags['local']!,
      globalFlags: flags['global']!,
    );
  }

  List<String> parseCmdRoot() {
    final List<String> cmdRoots = [];

    do {
      cmdRoots.add(
          consume(TokenType.IDENTIFIER, "Identifier for command root expected")
              .lexeme);
    } while (match(TokenType.DOT));

    consume(TokenType.SPACE,
        "Space after command root expected before positional or named args");
    return cmdRoots;
  }

  List<String> parsePosArgs() {
    final List<String> posArgs = [];

    while (peek().tokenType == TokenType.STRING) {
      posArgs.add(
          consume(TokenType.STRING, "Positional argument expected").lexeme);
      consume(TokenType.SPACE,
          "Space after positional args expected, followed by more positional args or named args");
    }
    return posArgs;
  }

  Map<String, Map> parseNamedArgs() {
    final Map<String, String> namedArgs = {};
    final Map<String, Map<String, String>> flags = {
      'local': {},
      'global': {},
    };

    while (!atEnd) {
      final List<Object> args = [];
      final Token name;
      if (match(TokenType.MINUS)) {
        final String flagType;
        if (match(TokenType.MINUS)) {
          flagType = 'global';
        } else {
          flagType = 'local';
        }
        name = consume(TokenType.IDENTIFIER, "Parameter name expected");
        if (match(TokenType.COLON)) {
          while (!match(TokenType.SEMICOLON)) {
            args.add(consume(peek().tokenType, "Argument expected").lexeme);
          }
        }
        flags[flagType]![name.lexeme] = args.join('');
      } else {
        name = consume(TokenType.IDENTIFIER, "Parameter name expected");
        consume(TokenType.COLON,
            "Colon expected after parameter name, followed by argument");

        while (!match(TokenType.SEMICOLON)) {
          args.add(consume(peek().tokenType, "Argument expected").lexeme);
        }
        consume(TokenType.SPACE,
            "Space after named argument expected before next argument");
        namedArgs[name.lexeme] = args.join('');
      }
    }

    return {
      'namedArgs': namedArgs,
      'flags': flags,
    };
  }

  Token consume(TokenType type, String msg) {
    if (check(type)) return advance();
    throw "$msg [${peek().lexeme}]";
  }

  bool check(TokenType type) {
    if (atEnd) return false;
    return peek().tokenType == type;
  }

  Token advance() {
    if (!atEnd) current++;
    return previous();
  }

  bool match(TokenType type) {
    if (check(type)) {
      advance();
      return true;
    }
    return false;
  }

  bool get atEnd => peek().tokenType == TokenType.EOF;

  Token peek() {
    return tokens[current];
  }

  Token previous([int lookBehind = 1]) {
    return tokens[current - lookBehind];
  }
}

class WizCommand {
  final List<String> cmdRoot;
  final List<String> posArgs;
  final Map<String, String> namedArgs;
  final Map<String, String> localFlags;
  final Map<String, String> globalFlags;

  WizCommand({
    required this.cmdRoot,
    required this.posArgs,
    required this.namedArgs,
    required this.localFlags,
    required this.globalFlags,
  });

  Map get json => {
        'cmdRoot': cmdRoot,
        'posArgs': posArgs,
        'namedArgs': namedArgs,
        'localFlags': localFlags,
        'globalFlags': globalFlags,
      };
}
