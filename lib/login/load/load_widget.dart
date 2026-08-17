import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'load_model.dart';
export 'load_model.dart';

class LoadWidget extends StatefulWidget {
  const LoadWidget({super.key});

  static String routeName = 'LOAD';
  static String routePath = '/load';

  @override
  State<LoadWidget> createState() => _LoadWidgetState();
}

class _LoadWidgetState extends State<LoadWidget> {
  late LoadModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (valueOrDefault<bool>(currentUserDocument?.admin, false)) {
        context.goNamed(
          VerifAdminWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 0),
            ),
          },
        );

        return;
      } else {
        if (valueOrDefault<bool>(currentUserDocument?.loginComplete, false)) {
          final isRoleSelected = FFAppState().roleSelected;
          final isDriver = FFAppState().driver;
          debugPrint('[LoadWidget] Navigation: roleSelected=$isRoleSelected, driver=$isDriver');

          if (isRoleSelected) {
            // Role already selected - go directly to main screen
            if (isDriver) {
              debugPrint('[LoadWidget] → MainDriverWidget');
              context.goNamed(
                MainDriverWidget.routeName,
                extra: <String, dynamic>{
                  kTransitionInfoKey: TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );

              final order = currentUserDocument?.currentOrder;
              if (order?.orderDocRef != null && order?.pointB != null) {
                unawaited(
                  actions
                      .toggleRouteTracking(
                        '',
                        true,
                        order!.orderDocRef!,
                        order.pointB!,
                      )
                      .catchError((_) {}),
                );
              }
            } else {
              debugPrint('[LoadWidget] → MainUserWidget');
              context.goNamed(
                MainUserWidget.routeName,
                extra: <String, dynamic>{
                  kTransitionInfoKey: TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            }
          } else {
            // First time - show role selection
            debugPrint('[LoadWidget] → ViborWidget (first time)');
            context.goNamed(
              ViborWidget.routeName,
              extra: <String, dynamic>{
                kTransitionInfoKey: TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );
          }

          return;
        } else {
          context.goNamed(
            GeoWidget.routeName,
            queryParameters: {
              'home': serializeParam(
                2,
                ParamType.int,
              ),
            }.withoutNulls,
            extra: <String, dynamic>{
              kTransitionInfoKey: TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 0),
              ),
            },
          );

          return;
        }
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        body: Image.asset(
          'assets/images/wx1aj_.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
