library lh.core.engines.helmscript.language_bundle;

import 'package:affogato_core/affogato_core.dart';
import 'package:affogato_editor/battery_themes/affogato_classic/theme_bundle.dart';
import 'package:flutter/material.dart';

part './tokeniser.dart';
part './parser.dart';
part './interpreter.dart';
part './syntax_highlighter.dart';

final LanguageBundle helmscriptLB = LanguageBundle(
  tokeniser: HSTokeniser(),
  parser: HSParser(),
  interpreter: HSInterpreter(),
);

final ThemeBundle<HelmscriptRenderToken, HelmscriptSyntaxHighlighter>
    helmscriptTB = ThemeBundle(synaxHighlighter: HelmscriptSyntaxHighlighter());
