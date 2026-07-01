import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
            '__transition_info__': TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 0),
            ),
          },
        );

        return;
      } else {
        if (valueOrDefault<bool>(currentUserDocument?.loginComplete, false)) {
          if (valueOrDefault<bool>(currentUserDocument?.isDriver, false)) {
            context.goNamed(
              MainDriverWidget.routeName,
              extra: <String, dynamic>{
                '__transition_info__': TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );

            FFAppState().driver = true;
            FFAppState().update(() {});

            final order = currentUserDocument?.currentOrder;
            if (order?.orderDocRef != null && order?.pointB != null) {
              unawaited(
                actions.toggleRouteTracking(
                  'AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
                  true,
                  order!.orderDocRef!,
                  order.pointB!,
                ).catchError((_) {}),
              );
            }
            return;
          } else {
            context.goNamed(
              MainUserWidget.routeName,
              extra: <String, dynamic>{
                '__transition_info__': TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );

            FFAppState().driver = false;
            FFAppState().update(() {});
            return;
          }
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
              '__transition_info__': TransitionInfo(
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
