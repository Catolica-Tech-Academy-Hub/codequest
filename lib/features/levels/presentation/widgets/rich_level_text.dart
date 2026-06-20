import 'package:flutter/material.dart';

class RichLevelText extends StatelessWidget {
  const RichLevelText(
    this.source, {
    super.key,
    this.style,
    this.textAlign,
  });

  final String source;
  final TextStyle? style;
  final TextAlign? textAlign;

  static const Set<String> _blockTags = <String>{'pre'};
  static const Set<String> _knownTags = <String>{'code', 'b', 'i', 'pre'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = (style ?? theme.textTheme.bodyLarge) ?? const TextStyle();
    final nodes = _parse(source);

    if (!_containsBlock(nodes)) {
      return Text.rich(
        _renderInline(nodes, theme, baseStyle),
        textAlign: textAlign,
      );
    }

    final widgets = _renderMixed(nodes, theme, baseStyle);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  // ---------- Parser ----------

  List<_Node> _parse(String input) {
    final tokens = _tokenize(input);
    var index = 0;

    List<_Node> parseUntil(String? closing) {
      final nodes = <_Node>[];
      while (index < tokens.length) {
        final token = tokens[index];
        if (token is _CloseToken) {
          if (closing != null && token.name == closing) {
            return nodes;
          }
          nodes.add(_TextNode('</${token.name}>'));
          index++;
          continue;
        }
        if (token is _OpenToken) {
          index++;
          final children = parseUntil(token.name);
          if (index < tokens.length) {
            final maybeClose = tokens[index];
            if (maybeClose is _CloseToken && maybeClose.name == token.name) {
              index++;
            }
          }
          nodes.add(_TagNode(token.name, children));
          continue;
        }
        if (token is _TextToken) {
          nodes.add(_TextNode(token.text));
          index++;
        }
      }
      return nodes;
    }

    return parseUntil(null);
  }

  List<_Token> _tokenize(String input) {
    final tokens = <_Token>[];
    final pattern = RegExp(r'</?([a-zA-Z]+)>');
    var cursor = 0;
    for (final match in pattern.allMatches(input)) {
      if (match.start > cursor) {
        tokens.add(_TextToken(input.substring(cursor, match.start)));
      }
      final name = match.group(1)!;
      if (!_knownTags.contains(name)) {
        tokens.add(_TextToken(match.group(0)!));
      } else if (match.group(0)!.startsWith('</')) {
        tokens.add(_CloseToken(name));
      } else {
        tokens.add(_OpenToken(name));
      }
      cursor = match.end;
    }
    if (cursor < input.length) {
      tokens.add(_TextToken(input.substring(cursor)));
    }
    return tokens;
  }

  bool _containsBlock(List<_Node> nodes) {
    for (final node in nodes) {
      if (node is _TagNode) {
        if (_blockTags.contains(node.tag)) return true;
        if (_containsBlock(node.children)) return true;
      }
    }
    return false;
  }

  // ---------- Renderers ----------

  InlineSpan _renderInline(List<_Node> nodes, ThemeData theme, TextStyle base) {
    return TextSpan(style: base, children: _renderSpans(nodes, theme, base));
  }

  List<InlineSpan> _renderSpans(List<_Node> nodes, ThemeData theme, TextStyle base) {
    final spans = <InlineSpan>[];
    for (final node in nodes) {
      if (node is _TextNode) {
        spans.add(TextSpan(text: node.text));
      } else if (node is _TagNode) {
        spans.add(_renderInlineTag(node, theme, base));
      }
    }
    return spans;
  }

  // TODO: Cada case poderia virar seu próprio Widged/Textspan para para melhorar a legibilidade desse arquivo
  InlineSpan _renderInlineTag(_TagNode node, ThemeData theme, TextStyle base) {
    switch (node.tag) {
      case 'code':
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text.rich(
              TextSpan(
                children: _renderSpans(
                  node.children,
                  theme,
                  base.copyWith(fontFamily: 'monospace'),
                ),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontFamilyFallback: const <String>['Courier'],
                  color: theme.colorScheme.onSurface,
                  fontSize: (base.fontSize ?? 16) * 0.92,
                  height: 1.2,
                ),
              ),
            ),
          ),
        );
      case 'b':
        return TextSpan(
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: _renderSpans(node.children, theme, base),
        );
      case 'i':
        return TextSpan(
          style: const TextStyle(fontStyle: FontStyle.italic),
          children: _renderSpans(node.children, theme, base),
        );
      case 'pre':
        // <pre> isolada inline (sem ser usada como bloco) degrada para texto monospace.
        return TextSpan(
          style: const TextStyle(fontFamily: 'monospace'),
          children: _renderSpans(node.children, theme, base),
        );
      default:
        return TextSpan(children: _renderSpans(node.children, theme, base));
    }
  }

  List<Widget> _renderMixed(List<_Node> nodes, ThemeData theme, TextStyle base) {
    final widgets = <Widget>[];
    final buffer = <_Node>[];

    void flushInline() {
      if (buffer.isEmpty) return;
      widgets.add(
        Text.rich(_renderInline(buffer, theme, base), textAlign: textAlign),
      );
      buffer.clear();
    }

    for (final node in nodes) {
      if (node is _TagNode && _blockTags.contains(node.tag)) {
        flushInline();
        widgets.add(_renderBlock(node, theme, base));
      } else {
        buffer.add(node);
      }
    }
    flushInline();
    return widgets;
  }

  Widget _renderBlock(_TagNode node, ThemeData theme, TextStyle base) {
    final code = _extractCodeContent(node);
    final fontSize = (base.fontSize ?? 16) * 0.92;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text.rich(
          TextSpan(
            children: _renderSpans(
              code,
              theme,
              base.copyWith(fontFamily: 'monospace'),
            ),
            style: TextStyle(
              fontFamily: 'monospace',
              fontFamilyFallback: const <String>['Courier'],
              color: theme.colorScheme.onSurface,
              fontSize: fontSize,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  /// `<pre><code>...</code></pre>` é um caso comum: desempacota o `<code>`
  /// para evitar dupla estilização.
  List<_Node> _extractCodeContent(_TagNode preNode) {
    if (preNode.children.length == 1) {
      final only = preNode.children.single;
      if (only is _TagNode && only.tag == 'code') {
        return only.children;
      }
    }
    return preNode.children;
  }
}

// ---------- AST & tokens ----------

sealed class _Node {
  const _Node();
}

class _TextNode extends _Node {
  const _TextNode(this.text);
  final String text;
}

class _TagNode extends _Node {
  const _TagNode(this.tag, this.children);
  final String tag;
  final List<_Node> children;
}

sealed class _Token {
  const _Token();
}

class _TextToken extends _Token {
  const _TextToken(this.text);
  final String text;
}

class _OpenToken extends _Token {
  const _OpenToken(this.name);
  final String name;
}

class _CloseToken extends _Token {
  const _CloseToken(this.name);
  final String name;
}
