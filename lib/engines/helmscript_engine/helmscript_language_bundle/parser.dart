part of lh.core.engines.helmscript.language_bundle;

class HSParser extends Parser {
  late TokenCursor cursor;

  @override
  AST parse(List<Token> tokens) {
    cursor = TokenCursor(tokens);
    AST ast = AST(nodes: []);

    while (!cursor.reachedEOF) {
      final HSCommandRootNode rootNode = parseCommand();
      final HSCommandNode commandNode = HSCommandNode(root: rootNode);
      if (!cursor.reachedEOF) cursor.advance();
      while (cursor.current.tokenType == const TokenType.string()) {
        commandNode.posArgNodes.add(
            HSPosArgNode(cursor.current.lexeme)..tokens.add(cursor.current));
        cursor.advance();
        if (cursor.current.tokenType == const TokenType.space()) {
          cursor.advance();
        }
      }
      while (!cursor.reachedEOF) {
        while (cursor.current.tokenType == const TokenType.identifier()) {
          commandNode.namedArgNodes.add(parseNamedArg());
          cursor.advance();
          if (cursor.current.tokenType == const TokenType.space()) {
            cursor.advance();
          }
        }
        while (cursor.current.tokenType == const TokenType.minus()) {
          commandNode.flagNodes.add(parseFlag());
          cursor.advance();
          if (cursor.current.tokenType == const TokenType.space()) {
            cursor.advance();
          }
        }
      }

      ast.nodes.add(
        commandNode..tokens.addAll(rootNode.tokens),
      );
    }

    return ast;
  }

  HSCommandRootNode parseCommand() {
    if (cursor.current.tokenType == const TokenType.identifier()) {
      return parseRoot();
    } else {
      throw HSParseException(
          current: cursor.current,
          message:
              "Identifier for root node expected, '${cursor.current.tokenType.value}' given instead.");
    }
  }

  HSCommandRootNode parseRoot() {
    final node = HSCommandRootNode();
    final List<Token> currentChunk = [];
    while (cursor.current.tokenType != const TokenType.space() &&
        !cursor.reachedEOF) {
      switch (cursor.current.tokenType) {
        case const TokenType.identifier():
          currentChunk.add(cursor.current);
          break;
        case const TokenType.dot():
          if (currentChunk.isEmpty) {
            throw HSParseException(
                message:
                    "Identifier for subcommand after '.': ${cursor.current.lexeme} given instead",
                current: cursor.current);
          } else {
            node.commandChunks.add(currentChunk.map((e) => e.lexeme).join(''));
            currentChunk.clear();
            break;
          }

        default:
          throw HSParseException(
            message:
                "Only identifiers and dots are allowed in command root, ${cursor.current.tokenType.value} was given instead.",
            current: cursor.current,
          );
      }
      node.tokens.add(cursor.current);
      cursor.advance();
    }
    if (cursor.current.tokenType == const TokenType.eof() ||
        cursor.current.tokenType == const TokenType.space()) {
      node.commandChunks.add(currentChunk.map((e) => e.lexeme).join(''));
      currentChunk.clear();
    } else {
      throw HSParseException(
        message:
            "Unexpected token ${cursor.current.lexeme}: space or EOF expected",
        current: cursor.current,
      );
    }
    return node;
  }

  HSNamedArgNode parseNamedArg() {
    final List<Token> nodeTokens = [];
    final List<String> name = [];
    while (cursor.current.tokenType == const TokenType.identifier() &&
        !cursor.reachedEOF) {
      name.add(cursor.current.lexeme);
      nodeTokens.add(cursor.current);
      cursor.advance();
    }
    // End of param name

    if (cursor.reachedEOF) {
      throw HSParseException(
        message:
            "Unexpected end of input: ':' expected to end parameter name and begin argument value",
        current: cursor.current,
      );
    } else {
      // Start of arg val
      if (cursor.current.tokenType == const TokenType.colon()) {
        cursor.advance();
        final List<String> argVal = [];
        while (cursor.current.tokenType != const TokenType.semicolon() &&
            !cursor.reachedEOF) {
          argVal.add(cursor.current.lexeme);
          nodeTokens.add(cursor.current);
          cursor.advance();
        }

        if (cursor.reachedEOF) {
          // reached EOF before semicolon
          throw HSParseException(
            message:
                "Unexpected end of input: ';' expected to end argument value",
            current: cursor.current,
          );
        } else {
          cursor.advance();
          return HSNamedArgNode(argName: name.join(), argValue: argVal.join());
        }
      } else {
        // Some illegal character instead of ':'
        throw HSParseException(
            message:
                "Illegal character '${cursor.current.lexeme}': only alphanumeric characters allowed as parameter names, and ':' to mark end of parameter name.",
            current: cursor.current);
      }
    }
  }

  HSFlagNode parseFlag() {
    final List<Token> nodeTokens = [];
    final List<String> flagName = [];
    int minusCounter = 0;
    while (cursor.current.tokenType == const TokenType.minus()) {
      nodeTokens.add(cursor.current);
      minusCounter += 1;
      cursor.advance();
    }
    if (minusCounter > 2) {
      throw HSParseException(
          message:
              "Too many '-' preceding the flag, use only 1 for local flag and 2 for global flags: $minusCounter were given",
          current: cursor.current);
    }

    while (cursor.current.tokenType == const TokenType.identifier() &&
        !cursor.reachedEOF) {
      flagName.add(cursor.current.lexeme);
      nodeTokens.add(cursor.current);
      cursor.advance();
    }
    if (cursor.current.tokenType == const TokenType.space() ||
        cursor.reachedEOF) {
      return HSFlagNode(
          flagName: flagName.join(), globalFlag: minusCounter == 2);
    } else {
      throw HSParseException(
          message:
              "Illegal character '${cursor.current.lexeme}': only alphanumeric characters allowed as flag names, and space or EOF to mark end of flag name.",
          current: cursor.current);
    }
  }
}

class HSCommandNode extends ASTNode {
  final HSCommandRootNode root;
  final List<HSPosArgNode> posArgNodes = [];
  final List<HSNamedArgNode> namedArgNodes = [];
  final List<HSFlagNode> flagNodes = [];
  final List<HSCommentNode> commentNodes = [];
  HSCommandNode({
    required this.root,
  }) : super('HSCommandNode', scopes: ['hs.cmd']);

  @override
  String toPrettyString([int indent = 1]) => [
        "NEW COMMAND",
        "|- ROOT: ${root.commandChunks}",
        "|- POSARGS: ${posArgNodes.map((e) => e.value).toList()}",
        "|- NAMEDARGS: ${namedArgNodes.map((e) => "${e.argName} >> ${e.argValue}").join(' | ')}",
        "|- FLAGS: ${flagNodes.map((e) => "${e.flagName} (${e.globalFlag ? 'G' : 'L'})").join(' | ')}",
        "|- COMMENTS: $commentNodes",
        '\n',
      ].join('\n');
}

class HSCommandRootNode extends ASTNode {
  final List<String> commandChunks = [];
  HSCommandRootNode() : super('HSCommandRootNode', scopes: ['hs.root']);
}

class HSCommentNode extends ASTNode {
  HSCommentNode() : super('HSCommentNode', scopes: ['hs.comment']);
}

class HSPosArgNode extends ASTNode {
  final String value;
  HSPosArgNode(this.value) : super('HSPosArgNode', scopes: ['hs.posarg']);
}

class HSNamedArgNode extends ASTNode {
  final String argName;
  final String argValue;
  HSNamedArgNode({
    required this.argName,
    required this.argValue,
  }) : super('HSNamedArgNode', scopes: ['hs.namedarg']);
}

class HSFlagNode extends ASTNode {
  final String flagName;
  final bool globalFlag;
  HSFlagNode({
    required this.flagName,
    required this.globalFlag,
  }) : super('HSCommanHSFlagNodeRootNode', scopes: ['hs.flag']);
}

class HSParseException implements Exception {
  final String message;
  final Token current;

  const HSParseException({
    required this.message,
    required this.current,
  });
}
