import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Нормализация слова для подсветки: регистр, ё→е, без пунктуации.
String normalizeAddressToken(String value) {
  final lower = value.toLowerCase().replaceAll('ё', 'е');
  return lower.replaceAll(RegExp(r'[^0-9a-zа-я]+'), '');
}

/// Разбить [title] на сегменты (text, highlighted) по токенам [query].
/// Как в Яндексе — подсвечивается только введённая часть слова:
/// токен-префикс слова подсвечивает ровно столько символов, сколько в нём
/// («дуб» → «Дуб»ровская, «ул» → «ул»ица, «14» → «14»к1);
/// если слово — префикс токена («ул.» против «улица»), слово целиком.
List<(String, bool)> addressTitleSegments(String title, String query) {
  if (title.isEmpty) return const [];
  final qTokens = query
      .split(RegExp(r'[^0-9a-zA-Zа-яА-ЯёЁ-]+'))
      .map(normalizeAddressToken)
      .where((t) => t.isNotEmpty)
      .toSet();
  if (qTokens.isEmpty) return [(title, false)];

  final segments = <(String, bool)>[];
  void push(String text, bool hit) {
    if (text.isEmpty) return;
    if (segments.isNotEmpty && segments.last.$2 == hit) {
      segments[segments.length - 1] = (segments.last.$1 + text, hit);
    } else {
      segments.add((text, hit));
    }
  }

  // Подслова — без дефиса и прочей пунктуации (они не подсвечиваются).
  final wordRe = RegExp(r'[0-9a-zA-Zа-яА-ЯёЁ]+');
  var last = 0;
  for (final m in wordRe.allMatches(title)) {
    if (m.start > last) {
      push(title.substring(last, m.start), false);
    }
    final word = m.group(0)!;
    final norm = normalizeAddressToken(word);
    var hitLen = 0;
    if (norm.isNotEmpty) {
      for (final q in qTokens) {
        if (norm.startsWith(q)) {
          if (q.length > hitLen) hitLen = q.length;
        } else if (q.startsWith(norm)) {
          hitLen = word.length;
          break;
        }
      }
    }
    if (hitLen >= word.length) {
      push(word, true);
    } else if (hitLen > 0) {
      push(word.substring(0, hitLen), true);
      push(word.substring(hitLen), false);
    } else {
      push(word, false);
    }
    last = m.end;
  }
  if (last < title.length) {
    push(title.substring(last), false);
  }
  return segments;
}

/// Строка подсказки адреса — общая для точек A и B.
/// [query] подсвечивает совпавшие слова цветом tertiary.
class AddressSuggestTile extends StatelessWidget {
  const AddressSuggestTile({
    super.key,
    required this.title,
    this.subtitle,
    this.query = '',
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String query;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final titleStyle = theme.bodyMedium.override(
      font: GoogleFonts.inter(
        fontWeight: theme.bodyMedium.fontWeight,
        fontStyle: theme.bodyMedium.fontStyle,
      ),
      fontSize: 16.0,
      letterSpacing: 0.0,
      fontWeight: theme.bodyMedium.fontWeight,
      fontStyle: theme.bodyMedium.fontStyle,
    );
    final subtitleStyle = theme.bodyMedium.override(
      font: GoogleFonts.inter(
        fontWeight: theme.bodyMedium.fontWeight,
        fontStyle: theme.bodyMedium.fontStyle,
      ),
      color: theme.secondaryText,
      fontSize: 14.0,
      letterSpacing: 0.0,
      fontWeight: theme.bodyMedium.fontWeight,
      fontStyle: theme.bodyMedium.fontStyle,
    );

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 14.0, 24.0, 14.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                  child: leading,
                ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: titleStyle,
                        children: [
                          for (final seg in addressTitleSegments(title, query))
                            TextSpan(
                              text: seg.$1,
                              style: seg.$2
                                  ? titleStyle.copyWith(color: theme.tertiary)
                                  : null,
                            ),
                        ],
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 6.0, 0.0, 0.0),
                        child: Text(subtitle!, style: subtitleStyle),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
