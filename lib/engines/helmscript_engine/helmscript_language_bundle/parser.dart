part of lh.core.engines.helmscript.language_bundle;

class HSParser extends Parser {
  ParseResult result = ParseResult();
  late TokenCursor cursor;

  @override
  ParseResult parse(List<Token> tokens) {
    result = ParseResult();
    cursor = TokenCursor(tokens);

    while (!cursor.reachedEOF) {
      final HSCommandNode commandNode = HSCommandNode();
      final HSCommandRootNode rootNode = parseRoot();
      commandNode.root = rootNode;
      result.ast.nodes.add(commandNode);
      if (!cursor.reachedEOF && cursor.current.lexeme.isWhitespace) {
        cursor.skip(result);
      }
      while (cursor.current.tokenType == const TokenType.string()) {
        commandNode.posArgNodes.add(
            HSPosArgNode(cursor.current.literal as String)
              ..tokens.add(cursor.current));
        cursor.advance();
        if (cursor.current.tokenType == const TokenType.space()) {
          cursor.skip(result);
        }
      }
      while (!cursor.reachedEOF) {
        while (cursor.current.tokenType == const TokenType.identifier()) {
          commandNode.namedArgNodes.add(parseNamedArg());
          if (cursor.current.tokenType == const TokenType.space()) {
            cursor.skip(result);
          }
        }
        while (cursor.current.tokenType == const TokenType.minus()) {
          commandNode.flagNodes.add(parseFlag());
          cursor.skip(result);
          if (cursor.current.tokenType == const TokenType.space()) {
            cursor.skip(result);
          }
        }
        while (cursor.current.lexeme.isWhitespace) {
          cursor.skip(result);
        }
        break;
      }
    }
/*     print("AST (${result.ast.terminalNodes.length})");
    print([for (final tn in result.ast.terminalNodes) tn.toPrettyString()]
        .join('\n'));
    print("===================");
    print(result.ast.reconstructSource());
    print("==================="); */

    return result;
  }

  HSCommandRootNode parseRoot() {
    if (cursor.current.tokenType != const TokenType.identifier()) {
      throw HSParseException(
          current: cursor.current,
          message:
              "Identifier for root node expected, '${cursor.current.tokenType.value}' given instead.");
    }
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
    while (!cursor.reachedEOF &&
        cursor.current.tokenType == const TokenType.identifier()) {
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
        nodeTokens.add(cursor.current);
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
          nodeTokens.add(cursor.current);
          cursor.advance();
          return HSNamedArgNode(argName: name.join(), argValue: argVal.join())
            ..tokens.addAll(nodeTokens);
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
          flagName: flagName.join(), globalFlag: minusCounter == 2)
        ..tokens.addAll(nodeTokens);
    } else {
      throw HSParseException(
          message:
              "Illegal character '${cursor.current.lexeme}': only alphanumeric characters allowed as flag names, and space or EOF to mark end of flag name.",
          current: cursor.current);
    }
  }
}

class HSCommandNode extends NonTerminalASTNode {
  late final HSCommandRootNode root;
  final List<HSPosArgNode> posArgNodes = [];
  final List<HSNamedArgNode> namedArgNodes = [];
  final List<HSFlagNode> flagNodes = [];
  final List<HSCommentNode> commentNodes = [];
  HSCommandNode() : super('HSCommandNode');

  @override
  CursorLocation get start => root.start;
  @override
  CursorLocation get end {
    final List<TerminalASTNode> tnodes = [];
    if (posArgNodes.isNotEmpty) tnodes.add(posArgNodes.last);
    if (namedArgNodes.isNotEmpty) tnodes.add(namedArgNodes.last);
    if (flagNodes.isNotEmpty) tnodes.add(flagNodes.last);
    if (commentNodes.isNotEmpty) tnodes.add(commentNodes.last);
    TerminalASTNode prev = tnodes[0];
    CursorLocation maxEnd = prev.end;
    for (final TerminalASTNode tnode in tnodes) {
      if (tnode.end > prev.end) {
        maxEnd = tnode.end;
      }
      prev = tnode;
    }
    return maxEnd;
  }

  @override
  List<TerminalASTNode> findAllTerminals() => [
        root,
        ...posArgNodes,
        ...namedArgNodes,
        ...flagNodes,
        ...commentNodes,
      ];

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

class HSCommandRootNode extends TerminalASTNode {
  final List<String> commandChunks = [];
  HSCommandRootNode() : super('HSCommandRootNode', scopes: ['hs.root']);
}

class HSCommentNode extends TerminalASTNode {
  HSCommentNode() : super('HSCommentNode', scopes: ['hs.comment']);
}

class HSPosArgNode extends TerminalASTNode {
  final String value;
  HSPosArgNode(this.value) : super('HSPosArgNode', scopes: ['hs.posarg']);
}

class HSNamedArgNode extends TerminalASTNode {
  final String argName;
  final String argValue;
  HSNamedArgNode({
    required this.argName,
    required this.argValue,
  }) : super('HSNamedArgNode', scopes: ['hs.namedarg']);
}

class HSFlagNode extends TerminalASTNode {
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

  @override
  String toString() => "$message\n${current.toPrettyString().padLeft(4, ' ')}";
}
