import 'dart:convert';
import 'dart:developer';

import 'dart:io';
import 'dart:ui';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/features/register/presentation/cubit/register_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/theme/theme.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/scheduler.dart';

// NAVIGATOR KEY
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
String currentVersion = "";

void main() async {
  // INITIAL SETUP
  await initialSetup();
  // RUN APP
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(), // Wrap your app
    ),
  );
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
  if (Platform.isAndroid) {
    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
      ),
      iosConfiguration: IosConfiguration(),
    );
  }
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

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'sync') {}
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  try {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      log("Location permission not granted");
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(
      (position) async {
        try {
          final storage = LocalStorageManager();

          List points = jsonDecode(storage.getString("route_points") ?? "[]");

          points.add({"lat": position.latitude, "lng": position.longitude});

          await storage.setString("route_points", jsonEncode(points));
        } catch (e) {
          log("Storage error: $e");
        }
      },
      onError: (error) {
        log("Location stream error: $error");
      },
    );
  } catch (e) {
    log("onStart error: $e");
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
        // LOGIN CUBIT
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => RegisterCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: "K3H ERP",
            debugShowCheckedModeBanner: false,

            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            // THEME
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,

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
