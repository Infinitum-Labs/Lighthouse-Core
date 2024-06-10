part of lh.core.engines.helmscript.language_bundle;

class HelmscriptSyntaxHighlighter
    extends SyntaxHighlighter<HelmscriptRenderToken> {
  @override
  List<HelmscriptRenderToken> createRenderTokens(ParseResult result) {
    final List<HelmscriptRenderToken> renderTokens = [];
    // print("RENDERTOKENS");
    for (final node in result.ast.terminalNodes) {
      // print(node.toPrettyString());
      if (node.scopes.contains('hs.root')) {
        renderTokens.add(CommandRootRenderToken(node));
      } else if (node.scopes.contains('hs.posarg')) {
        renderTokens.add(PosArgRenderToken(node));
      } else if (node.scopes.contains('hs.namedarg')) {
        renderTokens.add(NamedArgRenderToken(node));
      } else if (node.scopes.contains('hs.flag')) {
        renderTokens.add(FlagRenderToken(node));
      } else if (node.scopes.contains('hs.comment')) {
        renderTokens.add(CommentRenderToken(node));
      } else {
        renderTokens.add(DefaultRenderToken(node));
      }
    }
    // print("===================");

    return renderTokens;
  }
}

abstract class HelmscriptRenderToken extends AffogatoRenderToken {
  HelmscriptRenderToken(super.node);
}

class CommandRootRenderToken extends HelmscriptRenderToken {
  CommandRootRenderToken(super.node);

  @override
  render(TextStyle defaultStyle) => defaultStyle.copyWith(
        color: Colors.amber,
      );
}

class PosArgRenderToken extends HelmscriptRenderToken {
  PosArgRenderToken(super.node);

  @override
  render(TextStyle defaultStyle) => defaultStyle.copyWith(
        color: Colors.deepOrange,
      );
}

class NamedArgRenderToken extends HelmscriptRenderToken {
  NamedArgRenderToken(super.node);

  @override
  render(TextStyle defaultStyle) => defaultStyle.copyWith(
        color: Colors.purple,
      );
}

class FlagRenderToken extends HelmscriptRenderToken {
  FlagRenderToken(super.node);

  @override
  render(TextStyle defaultStyle) => defaultStyle.copyWith(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      );
}

class CommentRenderToken extends HelmscriptRenderToken {
  CommentRenderToken(super.node);

  @override
  render(TextStyle defaultStyle) => defaultStyle.copyWith(
        color: Colors.green,
      );
}

class DefaultRenderToken extends HelmscriptRenderToken {
  DefaultRenderToken(super.node);

  @override
  render(TextStyle defaultStyle) => defaultStyle.copyWith(
        color: Colors.white,
      );
}
