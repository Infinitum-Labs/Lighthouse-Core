part of lh.core.engines.helmscript.language_bundle;

class HSTokeniser extends Tokeniser {
  final List<Token> tokens = [];
  late Cursor cursor;
  CursorLocation? offset;

  @override
  List<Token> tokenise(
    String source, {
    List<Token> precedingTokens = const [],
    List<Token> succeedingTokens = const [],
  }) {
    tokens.clear();
    cursor = Cursor(source);

    if (precedingTokens.isNotEmpty) {
      offset = precedingTokens.last.end;
    }

    tokenisingLoop();
    offset = null;
    return tokens;
  }

  void tokenisingLoop() {
    do {
      tokens.add(
        switch (cursor.current) {
          "." => Token(
              tokenType: const TokenType.dot(),
              lexeme: const TokenType.dot().value,
              start: cursor.location() + offset,
              end: cursor.location() + offset),
          ";" => Token(
              tokenType: const TokenType.semicolon(),
              lexeme: const TokenType.semicolon().value,
              start: cursor.location() + offset,
              end: cursor.location() + offset),
          ":" => Token(
              tokenType: const TokenType.colon(),
              lexeme: const TokenType.colon().value,
              start: cursor.location() + offset,
              end: cursor.location() + offset),
          "-" => Token(
              tokenType: const TokenType.minus(),
              lexeme: const TokenType.semicolon().value,
              start: cursor.location() + offset,
              end: cursor.location() + offset),
          '"' => tokeniseString(),
          "'" => tokeniseString(),
/*           '"' => Token(
              tokenType: const TokenType.doubleQuote(),
              lexeme: const TokenType.doubleQuote().value,
              start: cursor.location() + offset,
              end: cursor.location() + offset),
          "'" => Token(
              tokenType: const TokenType.singleQUote(),
              lexeme: const TokenType.singleQUote().value,
              start: cursor.location() + offset,
              end: cursor.location() + offset), */
          ' ' => Token(
              tokenType: const TokenType.space(),
              lexeme: const TokenType.space().value,
              start: cursor.location() + offset,
              end: cursor.location() + offset),
          '\n' => Token(
              tokenType: const TokenType.newline(),
              lexeme: const TokenType.newline().value,
              start: cursor.location(),
              end: cursor.location()),
          '/' => Token(
              tokenType: const TokenType.slash(),
              lexeme: const TokenType.slash().value,
              start: cursor.location(),
              end: cursor.location()),
          String() => Token(
              tokenType: const TokenType.identifier(),
              lexeme: cursor.current,
              start: cursor.location() + offset,
              end: cursor.location() + offset),
        },
      );
    } while (!cursor.advance().isEOF);

    tokens.add(Token(
      tokenType: const TokenType.eof(),
      lexeme: const TokenType.eof().value,
      start: cursor.location(),
      end: cursor.location(),
    ));
  }

  Token tokeniseString() {
    final CursorLocation start = cursor.location();
    final String opening = cursor.current;
    cursor.advance();
    final List<String> contents = [];
    while (cursor.current != opening && !cursor.reachedEOF) {
      contents.add(cursor.current);
      cursor.advance();
    }
    if (cursor.reachedEOF) {
      throw HSTokenException(
        message: 'Unexpected end of string, closing ($opening) not found',
        location: cursor.location(),
      );
    } else {
      final Token t = Token(
        tokenType: const TokenType.string(),
        lexeme: contents.join(),
        start: start,
        end: cursor.location(),
      );
      cursor.skip();

      return t;
    }
  }
}

class HSTokenException implements Exception {
  final String message;
  final CursorLocation location;

  const HSTokenException({
    required this.message,
    required this.location,
  });
}
