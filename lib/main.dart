import 'dart:convert';

import 'dart:io';

import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/services/app_call_tracker_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/theme/theme.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:workmanager/workmanager.dart';

// NAVIGATOR KEY
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

const String _nightlyCallLogTaskName = 'nightlyCallLogSync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _nightlyCallLogTaskName) return Future.value(true);

    WidgetsFlutterBinding.ensureInitialized();
    await LocalStorageManager().init();
    initDependencies();

    // Only sync after 21:00 and once per calendar day.
    final now = DateTime.now();
    if (now.hour < 21) return Future.value(true);

    final lastSyncRaw = LocalStorageManager().getString(
      StorageKey.appInitiatedCallLogsLastSyncDate,
    );
    DateTime? lastSync;
    if (lastSyncRaw != null && lastSyncRaw.isNotEmpty) {
      lastSync = DateTime.tryParse(lastSyncRaw);
    }
    if (lastSync != null &&
        lastSync.year == now.year &&
        lastSync.month == now.month &&
        lastSync.day == now.day) {
      // Already synced today.
      return Future.value(true);
    }

    final tracker = serviceLocator<AppCallTrackerService>();
    final allLogs = tracker.getAppInitiatedCallLogs();
    final todayLogs =
        allLogs.where((log) {
          final d = log.endedAt;
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();

    if (todayLogs.isNotEmpty) {
      final payload =
          todayLogs
              .map(
                (log) => {
                  "MobileNumber": log.phoneNumber,
                  "CallDate": _formatCallDateForApi(log.startedAt),
                  "Duration": _formatDurationForApi(log.durationSeconds),
                  "Status": "",
                },
              )
              .toList();
      final callLogJSON = jsonEncode(payload);
      final projectId = getProject().projectId;
      final wrapper = {"ProjectId": projectId, "CallLogJSON": callLogJSON};
      final client = BaseClient();
      await client.postRequestWithAuthentication("CallLog/AddCallLog", wrapper);
    }

    await LocalStorageManager().setString(
      StorageKey.appInitiatedCallLogsLastSyncDate,
      now.toIso8601String(),
    );

    return Future.value(true);
  });
}

String _formatDurationForApi(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(h)}:${two(m)}:${two(s)}';
}

String _formatCallDateForApi(DateTime dt) {
  return DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(dt);
}

Future<void> main() async {
  // INITIAL SETUP
  await initialSetup();

  // BACKGROUND WORKER (Android only)
  if (Platform.isAndroid) {
    await Workmanager().initialize(
      callbackDispatcher,
      // ignore: deprecated_member_use
      isInDebugMode: kDebugMode,
    );
    await Workmanager().registerPeriodicTask(
      _nightlyCallLogTaskName,
      _nightlyCallLogTaskName,
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
  // LOCK ORIENTATION
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // RUN APP
  runApp(const MyApp());
}

Future initialSetup() async {
  WidgetsFlutterBinding.ensureInitialized();
  // REMOVE '#' FROM THE PATH
  setPathUrlStrategy();
  // LOCAL STORAGE
  await LocalStorageManager().init();
  // DEPENDENCY INJECTION
  initDependencies();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        themeMode: ThemeMode.system,
        //  ROUTING
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
        routeInformationProvider: goRouter.routeInformationProvider,
      ),
    );
  }
}
