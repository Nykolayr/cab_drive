import 'dart:async';
import 'dart:io' show Platform;

import 'package:cab_drive/core/utils/shared_prefs.dart';
import 'package:cab_drive/customer/create_map_page/data/datasources/orders_remote_data_source.dart';
import 'package:cab_drive/customer/create_map_page/domain/repositories/orders_repository.dart';
import 'package:cab_drive/customer/create_map_page/domain/usecases/get_etas.dart';
import 'package:cab_drive/customer/create_map_page/domain/usecases/get_prices.dart';
import 'package:cab_drive/customer/create_map_page/presentation/bloc/orders_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '/core/config/app_env.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'auth/firebase_auth/auth_util.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'backend/api_requests/payments_api_config.dart';
import 'backend/firebase/firebase_config.dart';
import 'backend/push_notifications/fb_messages.dart';
import 'backend/push_notifications/push_notifications_util.dart';
import 'customer/create_map_page/data/repositories/orders_repository_impl.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && Platform.isAndroid) {
    AndroidYandexMap.useAndroidViewSurface = true;
  }
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await AppEnv.load();
  await initFirebase();

  // Register background message handler BEFORE any other Firebase calls
  // This handler will be called when app is in background or terminated
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  SharedPrefs.sharedPreferences = await SharedPreferences.getInstance();
  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();
  // Fire-and-forget: серверные тайминги подъедут асинхронно
  unawaited(appState.loadServerSettings());

  // Initialize notification channels at startup for background notifications
  await initializeNotificationChannels();

  // iOS: Enable foreground notification display
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Handle foreground messages (both notification and data-only)
  FirebaseMessaging.onMessage.listen((message) {
    final title = message.data['title'] ?? message.notification?.title ?? 'no title';
    print('[FCM.foreground] Received message: $title');
    print('[FCM.foreground] Data: ${message.data}');
    showFlutterNotificationFromFirebase(message);
  });



  await initializeFirebaseRemoteConfig();

  // Платёжный base URL с сервера (смена домена без обновления стора)
  await PaymentsApiConfig.load();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = ThemeMode.system;
  double _textScaleFactor = 1.0;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((_) {});
  final fcmTokenSub = fcmTokenUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = cabDriveFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();
    fcmTokenSub.cancel();
    super.dispose();
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  void setTextScaleFactor(double updatedFactor) {
    if (updatedFactor < FlutterFlowTheme.minTextScaleFactor ||
        updatedFactor > FlutterFlowTheme.maxTextScaleFactor) {
      return;
    }
    safeSetState(() {
      _textScaleFactor = updatedFactor;
    });
  }

  void incrementTextScaleFactor(double incrementValue) {
    final updatedFactor = _textScaleFactor + incrementValue;
    if (updatedFactor < FlutterFlowTheme.minTextScaleFactor ||
        updatedFactor > FlutterFlowTheme.maxTextScaleFactor) {
      return;
    }
    safeSetState(() {
      _textScaleFactor = updatedFactor;
    });
  }

  final OrdersRepository _ordersRepository =
      OrdersRepositoryImpl(remoteDataSource: OrdersRemoteDataSource());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Cab Drive',
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('ru'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler:
              _textScaleFactor == FlutterFlowTheme.defaultTextScaleFactor
                  ? MediaQuery.of(context).textScaler.clamp(
                        minScaleFactor: FlutterFlowTheme.minTextScaleFactor,
                        maxScaleFactor: FlutterFlowTheme.maxTextScaleFactor,
                      )
                  : TextScaler.linear(_textScaleFactor).clamp(
                      minScaleFactor: FlutterFlowTheme.minTextScaleFactor,
                      maxScaleFactor: FlutterFlowTheme.maxTextScaleFactor,
                    ),
        ),
        // Глобально: контент над системной панелью жестов/навигации.
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => OrdersBloc(
                  getEtasUseCase: GetEtasUseCase(_ordersRepository),
                  getPricesUseCase: GetPricesUseCase(_ordersRepository),
                ),
              ),
            ],
            child: BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) => child!,
            ),
          ),
        ),
      ),
    );
  }
}
