import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class SendCodeWidget extends StatefulWidget {
  final VoidCallback? sendCode;
  const SendCodeWidget(this.sendCode, {Key? key}) : super(key: key);

  @override
  State<SendCodeWidget> createState() => _SendCodeWidgetState();
}

class _SendCodeWidgetState extends State<SendCodeWidget> {

  bool canSend = false;
  int pastSeconds = 60;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createTimer ();
  }

  void createTimer () {
    canSend = false;
    pastSeconds  = kDebugMode ? 1 :  60;
    Timer.periodic(Duration(seconds: 1), (timer) {
      pastSeconds--;
      setState(() {});
      if(pastSeconds <= 0) {
        canSend = true;
        timer.cancel();
      }


    });
  }


  String formatSeconds(int seconds) {
    if (seconds >= 11 && seconds <= 19) {  // Исключение для чисел от 11 до 19
      return ' секунд';
    } else {
      switch (seconds % 10) {
        case 1:
          return ' секунда';
        case 2:
        case 3:
        case 4:
          return ' секунды';
        default:
          return ' секунд';
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return TextButton(
     child: Text(!canSend ? 'Получить новый код через ${pastSeconds >= 60 ? '1:${60 - pastSeconds}' : '0:$pastSeconds'}' : 'Отправить код заново'), onPressed:!canSend ? () {} : () {

      widget.sendCode?.call();
      createTimer();
    }
    );
  }
}