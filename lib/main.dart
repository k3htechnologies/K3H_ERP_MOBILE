import 'dart:convert';

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/services/notification_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
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

  SchedulerBinding.instance.addPostFrameCallback((_) {
    print("FIRST FRAME RENDERED");
  });

  print("STEP 1 - before Firebase");

  await Firebase.initializeApp();

  print("STEP 2 - after Firebase");

  // INITIAL SETUP
  await initialSetup();

  print("STEP 3 - after initialSetup");

  // LOCK ORIENTATION
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // RUN APP
  runApp(const MyApp());
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

Future initialSetup() async {
  // LOCAL STORAGE
  await LocalStorageManager().init();
  // DEPENDENCY INJECTION
  initDependencies();
  HttpOverrides.global = MyHttpOverrides();

  final notificationService = NotificationService();
  await notificationService
      .setupFlutterNotifications(); // The local notifications setup
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

  // ROUTING
  GoRouter.optionURLReflectsImperativeAPIs = true;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("MyApp build called");
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
