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
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return BlocProvider(
      create: (BuildContext context) => AuthBloc(),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          resizeToAvoidBottomInset: true,
          // Снизу — глобальный SafeArea в main.dart; сверху — статус-бар.
          body: Padding(
            padding: EdgeInsets.only(top: topInset),
            child: BlocConsumer<AuthBloc, AuthState>(
              listenWhen: (prev, next) =>
                  next.status is FailedStatus && prev.status is! FailedStatus,
              listener: (BuildContext context, AuthState state) {
                final raw = (state.status as FailedStatus).exception;
                final error = raw?.toString() ?? '';
                if (error.isEmpty) return;

                final messenger = ScaffoldMessenger.of(context);
                messenger.clearSnackBars();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(error),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  ),
                );
              },
              builder: (context, state) => Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18.0),
                        bottomRight: Radius.circular(18.0),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.getAdaptiveWidth(context),
                        vertical: 16.getAdaptiveHeight(context),
                      ),
                      child: Text(
                        'Авторизация',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 30.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                              lineHeight: 1.25,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                16.0,
                                8.0,
                                16.0,
                                16.0 + MediaQuery.viewInsetsOf(context).bottom,
                              ),
                              child: state.mapOrNull(
                                    auth: (_) => const AuthorizationPage(),
                                  ) ??
                                  const CodePage(isDialog: false),
                            ),
                          ),
                          if (state.status is LoadingStatus)
                            const Positioned.fill(
                              child: ColoredBox(
                                color: Colors.white54,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
