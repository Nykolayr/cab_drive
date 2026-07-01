import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import '/pages/bottom/chips_card/chips_card_widget.dart';
import 'detaliy_sozdanie_widget.dart' show DetaliySozdanieWidget;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class DetaliySozdanieModel extends FlutterFlowModel<DetaliySozdanieWidget> {
  ///  Local state fields for this page.

  int? supply;

  List<FFUploadedFile> images = [];
  void addToImages(FFUploadedFile item) => images.add(item);
  void removeFromImages(FFUploadedFile item) => images.remove(item);
  void removeAtIndexFromImages(int index) => images.removeAt(index);
  void insertAtIndexInImages(int index, FFUploadedFile item) =>
      images.insert(index, item);
  void updateImagesAtIndex(int index, Function(FFUploadedFile) updateFn) =>
      images[index] = updateFn(images[index]);

  String select = 'Оплата картой';

  ///  State fields for stateful widgets in this page.

  // Model for app_bar component.
  late AppBarModel appBarModel;
  // State field(s) for entrance_A widget.
  FocusNode? entranceAFocusNode;
  TextEditingController? entranceATextController;
  late MaskTextInputFormatter entranceAMask;
  String? Function(BuildContext, String?)? entranceATextControllerValidator;
  // State field(s) for flat_A widget.
  FocusNode? flatAFocusNode;
  TextEditingController? flatATextController;
  String? Function(BuildContext, String?)? flatATextControllerValidator;
  // State field(s) for Floor_A widget.
  FocusNode? floorAFocusNode;
  TextEditingController? floorATextController;
  late MaskTextInputFormatter floorAMask;
  String? Function(BuildContext, String?)? floorATextControllerValidator;
  // State field(s) for Intercom_A widget.
  FocusNode? intercomAFocusNode;
  TextEditingController? intercomATextController;
  String? Function(BuildContext, String?)? intercomATextControllerValidator;
  // State field(s) for comment_A widget.
  FocusNode? commentAFocusNode;
  TextEditingController? commentATextController;
  String? Function(BuildContext, String?)? commentATextControllerValidator;
  // State field(s) for entrance_B widget.
  FocusNode? entranceBFocusNode;
  TextEditingController? entranceBTextController;
  String? Function(BuildContext, String?)? entranceBTextControllerValidator;
  // State field(s) for flat_B widget.
  FocusNode? flatBFocusNode;
  TextEditingController? flatBTextController;
  String? Function(BuildContext, String?)? flatBTextControllerValidator;
  // State field(s) for Floor_B widget.
  FocusNode? floorBFocusNode;
  TextEditingController? floorBTextController;
  String? Function(BuildContext, String?)? floorBTextControllerValidator;
  // State field(s) for Intercom_B widget.
  FocusNode? intercomBFocusNode;
  TextEditingController? intercomBTextController;
  String? Function(BuildContext, String?)? intercomBTextControllerValidator;
  // State field(s) for comment_B widget.
  FocusNode? commentBFocusNode;
  TextEditingController? commentBTextController;
  String? Function(BuildContext, String?)? commentBTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for description widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionTextController;
  String? Function(BuildContext, String?)? descriptionTextControllerValidator;
  bool isDataUploading_uploadDataH1g3 = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataH1g3 = [];

  // Model for chips_card component.
  late ChipsCardModel chipsCardModel1;
  // Model for chips_card component.
  late ChipsCardModel chipsCardModel2;

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
    chipsCardModel1 = createModel(context, () => ChipsCardModel());
    chipsCardModel2 = createModel(context, () => ChipsCardModel());
  }

  @override
  void dispose() {
    appBarModel.dispose();
    entranceAFocusNode?.dispose();
    entranceATextController?.dispose();

    flatAFocusNode?.dispose();
    flatATextController?.dispose();

    floorAFocusNode?.dispose();
    floorATextController?.dispose();

    intercomAFocusNode?.dispose();
    intercomATextController?.dispose();

    commentAFocusNode?.dispose();
    commentATextController?.dispose();

    entranceBFocusNode?.dispose();
    entranceBTextController?.dispose();

    flatBFocusNode?.dispose();
    flatBTextController?.dispose();

    floorBFocusNode?.dispose();
    floorBTextController?.dispose();

    intercomBFocusNode?.dispose();
    intercomBTextController?.dispose();

    commentBFocusNode?.dispose();
    commentBTextController?.dispose();

    descriptionFocusNode?.dispose();
    descriptionTextController?.dispose();

    chipsCardModel1.dispose();
    chipsCardModel2.dispose();
  }
}
