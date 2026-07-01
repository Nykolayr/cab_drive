import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'verif_user_widget.dart' show VerifUserWidget;
import 'package:flutter/material.dart';

class VerifUserModel extends FlutterFlowModel<VerifUserWidget> {
  ///  Local state fields for this page.

  FFUploadedFile? passport;

  List<FFUploadedFile> car = [];
  void addToCar(FFUploadedFile item) => car.add(item);
  void removeFromCar(FFUploadedFile item) => car.remove(item);
  void removeAtIndexFromCar(int index) => car.removeAt(index);
  void insertAtIndexInCar(int index, FFUploadedFile item) =>
      car.insert(index, item);
  void updateCarAtIndex(int index, Function(FFUploadedFile) updateFn) =>
      car[index] = updateFn(car[index]);

  FFUploadedFile? prava1;

  FFUploadedFile? tehps1;

  FFUploadedFile? selfi1;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for Name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  String? _nameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Пожалуйста, представьтесь';
    }

    if (val.length < 1) {
      return 'Имя должно быть от 1 до 32 символов';
    }
    if (val.length > 32) {
      return 'Имя должно быть от 1 до 32 символов';
    }
    if (!RegExp('^[А-Яа-яЁё]+(?: [А-Яа-яЁё]+)*\\s*\$').hasMatch(val)) {
      return 'Некорректное имя';
    }
    return null;
  }

  @override
  void initState(BuildContext context) {
    nameTextControllerValidator = _nameTextControllerValidator;
  }

  @override
  void dispose() {
    nameFocusNode?.dispose();
    nameTextController?.dispose();
  }
}
