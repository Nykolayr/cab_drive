import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Закрывает только modal/popup (шторку). Никогда не снимает экран go_router.
bool safePopModal(
  BuildContext context, {
  String tag = 'Modal',
  Object? result,
}) {
  if (!context.mounted) {
    debugPrint('[$tag] SKIP pop — not mounted');
    return false;
  }
  final route = ModalRoute.of(context);
  final nav = Navigator.maybeOf(context);
  final isPopup = route is PopupRoute;
  final canPop = nav?.canPop() ?? false;
  debugPrint(
    '[$tag] close? isPopup=$isPopup canPop=$canPop route=${route.runtimeType}',
  );
  if (!isPopup || nav == null || !canPop) {
    debugPrint('[$tag] SKIP pop — keep main screen');
    return false;
  }
  nav.pop(result);
  debugPrint('[$tag] popped PopupRoute only');
  return true;
}

/// Pop для полного экрана (MapPicker), только если под ним есть маршрут.
bool safePopPage(
  BuildContext context, {
  String tag = 'Page',
  Object? result,
}) {
  if (!context.mounted) {
    debugPrint('[$tag] SKIP pop — not mounted');
    return false;
  }
  final nav = Navigator.maybeOf(context);
  final canPop = nav?.canPop() ?? false;
  debugPrint('[$tag] page pop? canPop=$canPop');
  if (nav == null || !canPop) {
    debugPrint('[$tag] SKIP pop — keep main screen');
    return false;
  }
  nav.pop(result);
  debugPrint('[$tag] popped page');
  return true;
}
