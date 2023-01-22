part of core.engines.wiz_engine.wiz_script;

class WizScriptTokeniser {
  final String source;
  final List<String> chars = [];
  final List<Token> tokens = [];
  int start = 0;
  int current = 0;

  WizScriptTokeniser(this.source) {
    chars.addAll(source.split(''));
  }

  void tokenise() {
    while (!atEnd) {
      start = current;
      scanToken();
    }

    tokens.add(
      Token(
        TokenType.EOF,
        '',
        start: 0,
      ),
    );
  }

  void scanToken() {
    String c = advance();
    switch (c) {
      case '(':
        addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        addToken(TokenType.RIGHT_BRACE);
        break;
      case ',':
        addToken(TokenType.COMMA);
        break;
      case '.':
        addToken(TokenType.DOT);
        break;
      case '-':
        addToken(TokenType.MINUS);
        break;
      case '+':
        addToken(TokenType.PLUS);
        break;
      case ':':
        addToken(TokenType.COLON);
        break;
      case ';':
        addToken(TokenType.SEMICOLON);
        break;
      case '*':
        addToken(TokenType.STAR);
        break;
      case '/':
        if (match('/')) {
          while (peek() != '\n' && !atEnd) {
            advance();
          }
        } else {
          addToken(TokenType.SLASH);
        }
        break;
      case ' ':
        addToken(TokenType.SPACE);
        break;
      case '\r':
      case '\t':
        // Ignore whitespace.
        break;
      case '\n':
      case '"':
      case "'":
        tokeniseString(c);
        break;
      default:
        if (c.isDigit) {
          tokeniseNumber();
        } else if (c.isAlpha) {
          tokeniseIdentifier();
        } else {
          "Tokeniser could not produce a token for: $c. It may be an illegal character in the given context.";
        }
        break;
    }
  }

  void addToken(TokenType tokenType, [Object? literal]) {
    tokens.add(
      Token(
        tokenType,
        source.substring(start, current),
        start: start,
        literal: literal,
      ),
    );
  }

  String advance() {
    return source.charAt(current++);
  }

  String peek([int lookaheadCount = 0]) {
    if (current + lookaheadCount >= source.length) return 'EOF';
    return source.charAt(current + lookaheadCount);
  }

  bool match(String expected) {
    if (atEnd) return false;
    if (source.charAt(current) != expected) return false;

    current++;
    return true;
  }

  void tokeniseString(String delimiter) {
    while (peek() != delimiter && !atEnd) {
      advance();
    }

    if (atEnd) {
      // unterminated string error
      "Unterminated string literal";
      return;
    }

    advance();

    String value = source.substring(start + 1, current - 1);
    addToken(TokenType.STRING, value);
  }

  void tokeniseNumber() {
    while (peek().isDigit) {
      advance();
    }

    if (peek() == '.' && peek(1).isDigit) {
      advance();
      while (peek().isDigit) {
        advance();
      }
    }

    addToken(
      TokenType.NUMBER,
      double.parse(
        source.substring(start, current),
      ),
    );
  }

  void tokeniseIdentifier() {
    while (peek().isAlphaNum) {
      advance();
    }
    addToken(TokenType.IDENTIFIER);
  }

  bool get atEnd => !(current < source.length);
}

enum TokenType {
  // SINGLE-CHARACTER TOKENS
  LEFT_PAREN,
  RIGHT_PAREN,
  LEFT_BRACK,
  RIGHT_BRACK,
  LEFT_BRACE,
  RIGHT_BRACE,
  COMMA,
  DOT,
  MINUS,
  PLUS,
  COLON,
  SEMICOLON,
  SLASH,
  STAR,
  SPACE,

  // ONE- or TWO-CHARACTER TOKENS
  BANG,

  // LITERALS
  IDENTIFIER,
  STRING,
  NUMBER,
  FALSE,
  TRUE,
  NULL,

  // EOF
  EOF,
}

enum EqualitySymbol { isEqual, isNotEqual }

enum ArithmeticSymbol { plus, minus, star, divide }

enum ComparativeSymbol {
  lessThan,
  greaterThan,
  lessThanEqual,
  greaterThanEqual
}

enum LogicalSymbol { or, and }

enum UnaryPrefixSymbol { bang, minus }

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
final Random _rnd = Random();

class Token {
  final String id = String.fromCharCodes(Iterable.generate(
      5, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  final TokenType tokenType;
  final String lexeme;
  final Object? literal;
  final int start;

  Token(this.tokenType, this.lexeme, {required this.start, this.literal});

  Object toNative() {
    if (tokenType == TokenType.STRING || tokenType == TokenType.IDENTIFIER) {
      return literal as String;
    } else if (tokenType == TokenType.NUMBER) {
      return literal as num;
    } else {
      throw "Could not format token type ${tokenType} to native object";
    }
  }

  Map get json => {
        'id': id,
        'tokenType': tokenType.name,
        'lexeme': lexeme,
        'literal': literal,
        'start': start,
      };
}

extension StringUtils on String {
  String indent(int indent, [String indentStr = '-']) =>
      "|" + (indentStr * indent) + this;
  String newline(String text) => this + "\n" + text;
  bool get isNewline => (this == '\n');
  bool get isEOF => (this == 'EOF');
  bool get isDigit => (<String>[
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9'
      ].contains(this));
  bool get isAlphaNum => (<String>[
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z',
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z',
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '_'
      ].contains(this));

  bool get isAlpha => (<String>[
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z',
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z',
        '_'
      ].contains(this));

  String charAt(int pos) => this[pos];
}
