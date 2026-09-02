
import 'package:cab_drive/core/extensions/double_extension.dart';
import 'package:cab_drive/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../../auth/firebase_auth/auth_util.dart';
import '../../../../flutter_flow/flutter_flow_theme.dart';
import '../../../load/load_widget.dart';
import '../bloc/bloc.dart';
import '../widgets/send_code_widget.dart';

class CodePage extends StatelessWidget {
  final bool isDialog;
  const CodePage({super.key, required this.isDialog});

  @override
  Widget build(BuildContext context) {


    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bloc  = context.read<AuthBloc>();
          return state.mapOrNull(
            code:(_) => SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 16.getAdaptiveHeight(context),),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 16.0, 0.0),
                    child: Text(
                      'Введите последние 4 цифры номера',
                      style: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontStyle:
                          FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontStyle,
                        ),
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                        FlutterFlowTheme.of(context)
                            .bodyMedium
                            .fontStyle,
                        lineHeight: 1.25,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.getAdaptiveHeight(context),),


                  SizedBox(
                    width: 300.getAdaptiveWidth(context),
                    child: Pinput(
                      length: 4,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      onCompleted: (str) {
                        bloc.add(AuthEvent.confirmCode(onSuccess: (_user) async {
                          try {


                            final user = await authManager.signInWithEmail(
                              context,
                              _user.email!,
                              _user.password!,
                            );

                            if (user == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Не удалось войти. Проверьте код или попробуйте позже',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            bloc.add(AuthEvent.sendFcmToken());

                            context.goNamedAuth(
                                LoadWidget.routeName, context.mounted);
                          } catch(_) {
                            rethrow;
                          }
                        }));
                      },
                      controller: _.controller,
                      cursor: Container(
                        width: 2,
                        height: 25,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(1)),
                          color: Colors.transparent,
                        ),
                      ),
                      separatorBuilder: (index) => Container(
                        width: 3.getAdaptiveWidth(context),
                      ),

                      followingPinTheme: PinTheme(
                        width: 80.getAdaptiveHeight(context),
                        height: 100.getAdaptiveHeight(context),
                        decoration: BoxDecoration(

                            color: Colors.white,
                            border: Border(bottom: BorderSide(width: 2.getAdaptiveHeight(context), color:Colors.black38,) )),
                        textStyle: GoogleFonts.inter(fontSize: 60),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 80.getAdaptiveHeight(context),
                        height: 100.getAdaptiveHeight(context),
                        decoration: BoxDecoration(

                            color: Colors.white,
                            border: Border(bottom: BorderSide(width: 2.getAdaptiveHeight(context), color:Colors.black38,) )),
                        textStyle: GoogleFonts.inter(fontSize: 60),
                      ),
                      defaultPinTheme: PinTheme(
                        width: 80.getAdaptiveHeight(context),
                        height: 100.getAdaptiveHeight(context),
                        decoration: BoxDecoration(

                            color: Colors.white,
                            border: Border(bottom: BorderSide(width: 2.getAdaptiveHeight(context), color:Colors.blue,) )),
                        textStyle: GoogleFonts.inter(fontSize: 60),
                      ),
                    ),
                  ),

                  SizedBox(height: 60.getAdaptiveHeight(context),),
                  SendCodeWidget(() {
                    context.read<AuthBloc>().add(const AuthEvent.resendCode());
                  },),
                ],
              ),
            ),
          ) ?? Container();
        },
    );
  }
}
