import 'dart:convert';

import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/services/notification_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/firebase_options.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // // LOCK ORIENTATION
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // RUN APP
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  await LocalStorageManager().init();

  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    ),
  ).listen((position) async {
    final storage = LocalStorageManager();

    List points = jsonDecode(storage.getString("route_points") ?? "[]");

    points.add({"lat": position.latitude, "lng": position.longitude});

    await storage.setString("route_points", jsonEncode(points));
  });
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
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// Future initialSetup() async {
//   print("STEP A");

//   await LocalStorageManager().init();
//   print("STEP B");

//   initDependencies();
//   print("STEP C");

//   final notificationService = NotificationService();
//   await notificationService.setupFlutterNotifications();
//   print("STEP D");

//   await notificationService.initNotifications();
//   print("STEP E");
// }
Future initialSetup() async {
  // LOCAL STORAGE
  await LocalStorageManager().init();
  // DEPENDENCY INJECTION
  initDependencies();
  HttpOverrides.global = MyHttpOverrides();

  Future.microtask(() async {
    await NotificationService().setupFlutterNotifications();
    await NotificationService().initNotifications();
  });
  final info = await PackageInfo.fromPlatform();
  final currentVersion = info.version;

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
  // LOCATION PERMISSION
  // handleLocationPermission();

  // requestPhonePermission();
  SchedulerBinding.instance.addPostFrameCallback((_) {});
  // ROUTING
  GoRouter.optionURLReflectsImperativeAPIs = true;
}

Future<void> requestLocationPermission() async {
  var status = await Permission.location.request();

  if (status.isGranted) {
    await Permission.locationAlways.request();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await initialSetup(); // ✅ now safe
      setState(() => isReady = true);
    } catch (e, s) {
      print("INIT ERROR: $e");
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ SHOW LOADER FIRST
    if (!isReady) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    print("the app started");
    return MultiBlocProvider(
      providers: [
        // LOGIN CUBIT
        BlocProvider(create: (context) => LoginCubit()),
      ],
      child: MaterialApp.router(
        title: "K3H ERP",
        debugShowCheckedModeBanner: false,
        // THEME
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        //  ROUTING
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
        routeInformationProvider: goRouter.routeInformationProvider,
      ),
    );
  }
}
