import '/flutter_flow/flutter_flow_util.dart';
import 'image_view_widget.dart' show ImageViewWidget;
import 'package:flutter/material.dart';

class ImageViewModel extends FlutterFlowModel<ImageViewWidget> {
  ///  Local state fields for this component.

  bool view = true;

  ///  State fields for stateful widgets in this component.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
