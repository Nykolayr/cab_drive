import 'package:cab_drive/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../../flutter_flow/flutter_flow_theme.dart';

class CustomDialog extends StatelessWidget {
  final String text;
  const CustomDialog({super.key, required this.text});

   show(BuildContext context) => showDialog(context: context, builder: (_) => CustomDialog(text: text));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Material(

          color: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, style:  FlutterFlowTheme
                    .of(context)
                    .titleSmall
                    .override(
                  fontFamily: 'SF',
                  color: Colors.black,

                  fontSize: 15.0,
                  letterSpacing: 0.0,
                  fontWeight:
                  FontWeight.w500,
                ), textAlign: TextAlign.center,),
                SizedBox(height: 30,),
                CustomButton(text: 'Ясно', onTap: () {
                  Navigator.pop(context);
                },)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
