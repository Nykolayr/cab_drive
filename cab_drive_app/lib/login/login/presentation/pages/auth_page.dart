import 'package:cab_drive/core/extensions/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../flutter_flow/flutter_flow_theme.dart';
import '../../../../flutter_flow/flutter_flow_widgets.dart';
import '../../../../pages/menu/o_prilozhen/o_prilozhen_widget.dart';
import '../bloc/bloc.dart';
import '../widgets/phone_field.dart';
import 'package:flutter/gestures.dart';
class AuthorizationPage extends StatelessWidget {
  const AuthorizationPage({super.key});

  openRules (context) {
     showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor:
    Colors.transparent,
    context: context,
    builder: (context) {
      return WebViewAware(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus();
            FocusManager.instance
                .primaryFocus
                ?.unfocus();
          },
          child: Padding(
            padding: MediaQuery
                .viewInsetsOf(
                context),
            child:
            OPrilozhenWidget(),
          ),
        ),
      );
    },
    );
  }

  @override
  Widget build(BuildContext context) {


    return BlocBuilder<AuthBloc, AuthState>(

        builder: (context, state) {
          final bloc = context.read<AuthBloc>();
          return state.mapOrNull(
            auth: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                SizedBox(height: 16.getAdaptiveHeight(context),),

                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      0.0, 0.0, 16.0, 0.0),
                  child: Text(
                    'Введите номер телефона',
                    style: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                        FlutterFlowTheme.of(context)
                            .bodyMedium
                            .fontStyle,
                      ),
                      fontSize: 20.0,
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
                SizedBox(height: 10.getAdaptiveHeight(context),),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      0.0, 0.0, 16.0, 0.0),
                  child: Text(
                    'На этот номер поступит звонок',
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

                PhoneField(
                  controller: _.phone,
                ),

                SizedBox(
                  height: 40.getAdaptiveHeight(context),
                ),
                CustomButton(
                  text: ('Вход'),
                  onTap: () =>
                      bloc.add(AuthEvent.sendCode()),
                ),
                SizedBox(height: 10.getAdaptiveHeight(context),),
                Text.rich(TextSpan(
                  children: [
                    TextSpan(text:'Авторизируясь в приложении вы автоматически принимаете '),
                    TextSpan(text: 'Политику конфиденциальности', recognizer: TapGestureRecognizer()..onTap = () => openRules(context), style: FlutterFlowTheme.of(context)
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
                      fontWeight: FontWeight.w600,
                      fontStyle:
                      FlutterFlowTheme.of(context)
                          .bodyMedium
                          .fontStyle,
                      lineHeight: 1.25,
                    )),
                    TextSpan(text: ' и '),
                    TextSpan(text: 'Условия использования', recognizer: TapGestureRecognizer()..onTap = () => openRules(context), style: FlutterFlowTheme.of(context)
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
                      fontWeight: FontWeight.w600,
                      fontStyle:
                      FlutterFlowTheme.of(context)
                          .bodyMedium
                          .fontStyle,
                      lineHeight: 1.25,
                    ))
                  ],
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
                  )
                ))

              ],
            ),
          ) ??
              Container();
        });
  }
}
