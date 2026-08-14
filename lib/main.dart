// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/cubit/no_internet_connection_cubit.dart';
import 'package:k3h_erp_app/core/cubit/no_internet_connection_state.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/features/register/presentation/cubit/register_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/theme/theme.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/no_internet_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/scheduler.dart';

// NAVIGATOR KEY
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

StreamSubscription<Position>? positionStreamSubscription;
String currentVersion = "";
void main() async {
  // INITIAL SETUP
  await initialSetup();
  // RUN APP
  runApp(MyApp());
}

Future<void> requestPhonePermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      debugPrint("Phone permission granted");
    } else {
      debugPrint("Phone permission denied");
    }
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

Future initialSetup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // LOCAL STORAGE
  await LocalStorageManager().init();
  // DEPENDENCY INJECTION
  initDependencies();
  HttpOverrides.global = MyHttpOverrides();
  SchedulerBinding.instance.addPostFrameCallback((_) {});
  // LOCK ORIENTATION
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final info = await PackageInfo.fromPlatform();
  currentVersion = info.version;
  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      foregroundServiceNotificationId: 888,
      initialNotificationTitle: 'K3H ERP',
      initialNotificationContent: 'Location tracking is active',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  final storage = LocalStorageManager();
  final storedVersion = storage.getString(StorageKey.appVersion);
  if (storedVersion != currentVersion) {
    await storage.setString(StorageKey.appVersion, currentVersion);
  }
  // MENU LIST
  var decodedMenuData = LocalStorageManager().getString(StorageKey.menu);
  if (decodedMenuData != null) {
    List<ModuleModel> moduleData = List<ModuleModel>.from(
      jsonDecode(decodedMenuData).map((e) => ModuleModel.fromJson(e)),
    );
    await updateRouteAuthorization(moduleData);
  }
  // ROUTING
  GoRouter.optionURLReflectsImperativeAPIs = true;
}

Future<bool> checkLocationPermission() async {
  var permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return false;
  }

  return true;
}

Future<void> startLocationTracking() async {
  final hasPermission = await checkLocationPermission();

  if (!hasPermission) {
    debugPrint("Location permission denied");
    return;
  }

  final service = FlutterBackgroundService();

  if (!await service.isRunning()) {
    await service.startService();
  }
}

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'sync') {}
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await LocalStorageManager().init();

  // if (service is AndroidServiceInstance) {
  //   service.setForegroundNotificationInfo(
  //     title: "K3H ERP",
  //     content: "Location tracking is active",
  //   );
  // }

  service.on('stop').listen((event) async {
    await positionStreamSubscription?.cancel();
    positionStreamSubscription = null;

    service.stopSelf();
  });

  try {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      log("Location permission not granted");
      service.stopSelf();
      return;
    }

    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen(
      (Position position) async {
        try {
          final storage = LocalStorageManager();

          final String savedData = storage.getString("route_points") ?? "[]";

          final List<dynamic> points = jsonDecode(savedData);

          points.add({
            "lat": position.latitude,
            "lng": position.longitude,
            "timestamp": DateTime.now().toIso8601String(),
          });

          await storage.setString("route_points", jsonEncode(points));

          log(
            "Background location: "
            "${position.latitude}, ${position.longitude}",
          );
        } catch (e) {
          log("Storage error: $e");
        }
      },
      onError: (error) {
        log("Location stream error: $error");
      },
    );
  } catch (e) {
    log("Background service error: $e");
    service.stopSelf();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InternetCubit>(create: (_) => InternetCubit()),
        BlocProvider<LoginCubit>(create: (_) => LoginCubit()),
        BlocProvider<RegisterCubit>(create: (_) => RegisterCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: "K3H ERP",
            debugShowCheckedModeBanner: false,
            // THEME
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            // LOCALIZATION (required by flutter_quill's toolbar)
            localizationsDelegates: const [
              FlutterQuillLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            supportedLocales: const [Locale('en')],

            builder: (context, child) {
              return BlocBuilder<InternetCubit, InternetState>(
                builder: (context, state) {
                  if (state is InternetDisconnected) {
                    return const NoInternetScreen();
                  }

                  if (state is InternetInitial) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return child ?? const SizedBox.shrink();
                },
              );
            },

            // ROUTING
            routeInformationParser: goRouter.routeInformationParser,
            routerDelegate: goRouter.routerDelegate,
            routeInformationProvider: goRouter.routeInformationProvider,
          );
        },
      ),
    );
  }
}
