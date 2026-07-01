import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Аватар пользователя с заглушкой при 402/404 и пустом URL.
class UserAvatarImage extends StatelessWidget {
  const UserAvatarImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.iconSize,
  });

  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final double? iconSize;

  Widget _placeholder(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: width,
      height: height,
      color: theme.alternate,
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        color: theme.secondaryText,
        size: iconSize ?? (height * 0.42).clamp(18.0, 32.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = _placeholder(context);

    if (imageUrl.isEmpty) {
      return ClipRRect(borderRadius: borderRadius, child: placeholder);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
