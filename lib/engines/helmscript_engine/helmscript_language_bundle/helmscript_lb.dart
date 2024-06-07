library lh.core.engines.helmscript.language_bundle;

import 'package:affogato_core/affogato_core.dart';

part './tokeniser.dart';
part './parser.dart';
part './interpreter.dart';

final LanguageBundle helmscriptLB = LanguageBundle(
  tokeniser: HSTokeniser(),
  parser: HSParser(),
  interpreter: HSInterpreter(),
);

void main(List<String> args) {
  try {
    final List<Token> tokens = helmscriptLB.tokeniser
        .tokenise("root.a.b 'and hello' 'there' s:1t; tru:dart; -V");
    // print([for (final tok in tokens) tok.toPrettyString()].join('\n'));
    for (final cnode
        in ((helmscriptLB.parser.parse(tokens).nodes).cast<HSCommandNode>())) {
      cnode.toPrettyString();
    }
  } on HSParseException catch (e, st) {
    print(e.message);
    print(e.current.toPrettyString());
    print(st);
  }
}
