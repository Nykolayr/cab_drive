import 'package:cab_drive/core/extensions/double_extension.dart';
import 'package:cab_drive/login/login/presentation/pages/auth_page.dart';
import 'package:cab_drive/login/login/presentation/pages/code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/status.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import 'bloc/bloc.dart';

class LoginWidget extends StatelessWidget {
  const LoginWidget({super.key});


  static String routeName = 'LOGIN';
  static String routePath = '/login';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return AuthBloc();
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(0.0.getAdaptiveWidth(context)),
                  child: BlocConsumer<AuthBloc, AuthState>(
                    builder: (context, state) => Column(
                      children: [
                        Container(
                            width: double.infinity,
                            height: 80.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(18.0),
                                bottomRight: Radius.circular(18.0),
                                topLeft: Radius.circular(0.0),
                                topRight: Radius.circular(0.0),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.getAdaptiveWidth(context), vertical: 16.getAdaptiveHeight(context)),
                              child: Text(
                                'Авторизация',
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
                                  fontSize: 30.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle:
                                  FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                  lineHeight: 1.25,
                                ),
                              ),
                            ),),
                        SizedBox(
                          height: 8,
                        ),
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    color: Colors.white),
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 8.0, 16.0, 0.0),
                                child: Column(children: [

                                  Stack(
                                    children: [
                                      state.mapOrNull(
                                        auth: (_) => AuthorizationPage(),
                                      ) ??
                                          CodePage(
                                            isDialog: false,
                                          ),
                                      if (state.status is LoadingStatus)
                                        Container(
                                          height: MediaQuery.sizeOf(context).height,
                                          color: Colors.white12,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                    ],
                                  )
                                ]))),

                      ],
                    ),
                    listener: (BuildContext context, AuthState state) {
                      final error = state.status is FailedStatus
                          ? (state.status as FailedStatus).exception
                          : null;

                      if (error != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(error)));
                      }
                    },
                  ),
                ),
              )),
        ));
  }
}
