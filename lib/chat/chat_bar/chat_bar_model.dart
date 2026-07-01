import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'chat_bar_widget.dart' show ChatBarWidget;
import 'package:flutter/material.dart';

class ChatBarModel extends FlutterFlowModel<ChatBarWidget> {
  ///  Local state fields for this component.

  List<FFUploadedFile> images = [];
  void addToImages(FFUploadedFile item) => images.add(item);
  void removeFromImages(FFUploadedFile item) => images.remove(item);
  void removeAtIndexFromImages(int index) => images.removeAt(index);
  void insertAtIndexInImages(int index, FFUploadedFile item) =>
      images.insert(index, item);
  void updateImagesAtIndex(int index, Function(FFUploadedFile) updateFn) =>
      images[index] = updateFn(images[index]);

  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataH1g2 = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataH1g2 = [];

  // State field(s) for Text widget.
  FocusNode? textFocusNode;
  TextEditingController? textTextController;
  String? Function(BuildContext, String?)? textTextControllerValidator;
  bool isDataUploading_uploadDataLms = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataLms = [];
  List<String> uploadedFileUrls_uploadDataLms = [];

  // Stores action output result for [Backend Call - Create Document] action in IconButton widget.
  MessagesRecord? newmess2;
  // Stores action output result for [Backend Call - Create Document] action in IconButton widget.
  MessagesRecord? newmess;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFocusNode?.dispose();
    textTextController?.dispose();
  }
}
