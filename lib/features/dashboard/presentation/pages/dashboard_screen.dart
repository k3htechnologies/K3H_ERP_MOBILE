// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/widgets/attendance_summary.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/widgets/events_and_more.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/widgets/holidays_summary.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/widgets/leave_balance_summary.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/widgets/quick_actions.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/widgets/reporting_manager.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/widgets/team_attendance_summary.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/widgets/working_hours_summary.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/widget/pending_approval_card.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/pages/route_map_screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

part 'widgets/work_overview.dart';

class DashboardScreen extends StatefulWidget {
  final AttendanceModel? data;
  const DashboardScreen({super.key, this.data});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late DashboardCubit _dashboardCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorization;

  final ValueNotifier<double> dragPositionNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> isPunchedInNotifier = ValueNotifier(false);

  late DateTime punchInTime;
  DateTime? punchOutTime;

  final ValueNotifier<Duration> workedDuration = ValueNotifier(Duration.zero);

  Timer? _timer;
  int? currentAttendanceId;
  String? currentUniquekey;

  final LocalStorageManager storage = LocalStorageManager();

  UserModel? currentUser;

  /// true while punch in / punch out runs -> blocks all taps and back button
  final ValueNotifier<bool> isProcessingNotifier = ValueNotifier(false);

  final ValueNotifier<bool> isDayCompletedNotifier = ValueNotifier(false);
  Timer? _routeTimer;
  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;

  double dragPosition = 0.0;

  bool isAnimating = false;
  final ValueNotifier<bool> isSwipeDisabledNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _routeAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.dashboardScreen]!;
    _dashboardCubit = context.read<DashboardCubit>();
    initialise();
    final userJson = storage.getString(StorageKey.currentUser);
    if (userJson != null) {
      currentUser = UserModel.fromJson(jsonDecode(userJson));
    }
    _routeTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadSavedRoute();
    });
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  Future<void> initialise() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start;

    await _dashboardCubit.getAttendanceList(context, 1, start, end, 0);
    if (context.mounted) {
      await _dashboardCubit.getDashboardList(context);
    }
  }

  @override
  void dispose() {
    isPunchedInNotifier.dispose();
    dragPositionNotifier.dispose();
    workedDuration.dispose();
    isProcessingNotifier.dispose();
    isDayCompletedNotifier.dispose();
    _timer?.cancel();
    _routeTimer?.cancel();
    positionStream?.cancel();
    _swipeController.dispose();
    isSwipeDisabledNotifier.dispose();
    super.dispose();
  }

  void _startTimerFrom(DateTime start) {
    _timer?.cancel();

    punchInTime = start;

    workedDuration.value = DateTime.now().difference(punchInTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = DateTime.now().difference(punchInTime);
      workedDuration.value = diff.isNegative ? Duration.zero : diff;
    });
  }

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  Future<String?> _getAddressFromGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      return "${place.name}, ${place.street}, ${place.locality}, "
          "${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      return null;
    }
  }

  Future<bool> _ensureLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (context.mounted) {
        showErrorMessage(
          context,
          "Location Disabled",
          "Please turn on Location (GPS)",
        );
      }

      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        showErrorMessage(
          context,
          "Permission Required",
          "Enable location permission from settings",
        );
      }
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  double maxWidth = 0.0;

  bool isDraggingRight = true;

  StreamSubscription<Position>? positionStream;
  List<LatLng> routePoints = [];
  LatLng? startLatLng;
  LatLng? lastPoint;
  double totalDistance = 0.0;

  Future<bool> punchIn(BuildContext context) async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      if (pos.isMocked) {
        if (context.mounted) {
          showErrorMessage(
            context,
            "Mock Location Detected",
            "Please disable Fake GPS / Mock Location before punching in.",
          );
        }
        return false;
      }

      final address = await _getAddressFromGPS();

      if (address == null) {
        showErrorMessage(context, "Error", "Unable to fetch location");
        return false;
      }

      await storage.setString(
        "route_points",
        jsonEncode([
          {"lat": pos.latitude, "lng": pos.longitude},
        ]),
      );
      //  START FOREGROUND TRACKING
      _startLocationTracking();
      startLatLng = LatLng(pos.latitude, pos.longitude);
      routePoints.clear();
      routePoints.add(startLatLng!);
      lastPoint = startLatLng;
      totalDistance = 0.0;
      final int attendanceIdToSend = currentAttendanceId ?? 0;

      final result = await _dashboardCubit.addAttendance(
        context,
        attendanceId: attendanceIdToSend,
        punchAddress: address,
        startLatitude: pos.latitude,
        startLongitude: pos.longitude,
        endLatitude: 0,
        endLongitude: 0,
        polyline: "",
        distance: 0,
      );

      if (result == null) {
        if (context.mounted) {
          showErrorMessage(context, "ERROR", "NO INTERNET CONNECTION");
        }
        return false;
      }

      currentAttendanceId = result.attendanceId;
      currentUniquekey = result.uniquekey;

      await storage.setString(
        "route_points",
        jsonEncode([
          {"lat": pos.latitude, "lng": pos.longitude},
        ]),
      );
      startLatLng = LatLng(pos.latitude, pos.longitude);
      routePoints.clear();
      routePoints.add(startLatLng!);
      lastPoint = startLatLng;
      totalDistance = 0.0;
      _startLocationTracking();

      return true;
    } catch (e) {
      debugPrint("Punch In GPS Error: $e");
      return false;
    }
  }

  Future<void> punchOut(BuildContext context) async {
    final address = await _getAddressFromGPS();

    await positionStream?.cancel();

    final currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    final endPoint = LatLng(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    routePoints.add(endPoint);

    final finalDistance =
        routePoints.length > 1 ? _calculateDistance(routePoints) : 0.0;

    final finalPolyline =
        routePoints.length > 1 ? PolylineEncoder.encode(routePoints) : "";

    final data = _dashboardCubit.state.data;
    if (data == null) {
      debugPrint("Attendance data null");
      return;
    }

    double startLat;
    double startLng;

    if (startLatLng != null) {
      startLat = startLatLng!.latitude;
      startLng = startLatLng!.longitude;
    } else if (routePoints.isNotEmpty) {
      startLat = routePoints.first.latitude;
      startLng = routePoints.first.longitude;
    } else {
      startLat = currentPosition.latitude;
      startLng = currentPosition.longitude;
    }

    if (context.mounted) {
      await _dashboardCubit.updateAttendance(
        context,
        attendanceId: data.attendanceId,
        uniquekey: data.uniquekey,
        punchAddress: address!,
        startLatitude: startLat,
        startLongitude: startLng,
        endLatitude: endPoint.latitude,
        endLongitude: endPoint.longitude,
        polyline: finalPolyline,
        distance: finalDistance,
      );
    }

    workedDuration.value = DateTime.now().difference(punchInTime);
    await loadSavedRoute();
    _timer?.cancel();
  }

  bool canPunchOut() {
    final workedTime = DateTime.now().difference(punchInTime);
    return workedTime >= const Duration(hours: 1);
  }

  double _calculateDistance(List<LatLng> points) {
    double total = 0;

    for (int i = 0; i < points.length - 1; i++) {
      total += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }

    return total / 1000; // KM
  }

  void _startLocationTracking() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("Location permission denied");
      return;
    }

    await positionStream?.cancel();

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) async {
      if (position.isMocked) {
        debugPrint("Mock location detected");
        return;
      }
      if (position.accuracy > 30) return;

      final currentPoint = LatLng(position.latitude, position.longitude);

      if (lastPoint == null) {
        lastPoint = currentPoint;
        routePoints.add(currentPoint);
        return;
      }

      final segmentDistance = Geolocator.distanceBetween(
        lastPoint!.latitude,
        lastPoint!.longitude,
        currentPoint.latitude,
        currentPoint.longitude,
      );
      if (segmentDistance < 10) return;

      final speedKmph = position.speed * 3.6;

      if (speedKmph > 140) return;

      routePoints.add(currentPoint);

      totalDistance += segmentDistance;

      lastPoint = currentPoint;
    }, onError: (e) {});
  }

  Future<void> loadSavedRoute() async {
    final data = storage.getString("route_points");

    if (data != null && data.isNotEmpty) {
      final List decoded = jsonDecode(data);

      final newPoints = decoded.map((e) => LatLng(e["lat"], e["lng"])).toList();

      if (!mounted) return;

      setState(() {
        routePoints = newPoints;

        if (routePoints.isNotEmpty) {
          startLatLng = routePoints.first;
          lastPoint = routePoints.last;
        }
      });
    }
  }

  void animateSlider(double target) {
    isAnimating = true;

    _swipeAnimation = Tween<double>(begin: dragPosition, end: target).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOutCubic),
    )..addListener(() {
      setState(() {
        dragPosition = _swipeAnimation.value;
      });
    });

    _swipeController.forward(from: 0).whenComplete(() {
      isAnimating = false;
    });
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isProcessingNotifier,
      builder: (context, processing, child) {
        return PopScope(
          canPop: !processing, // blocks Android back button
          child: AbsorbPointer(
            absorbing: processing, // blocks all taps and swipes
            child: child,
          ),
        );
      },
      child: _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    return BlocListener<DashboardCubit, DashboardState>(
      listener: (context, state) {
        final today = DateTime.now();

        final todayRecords =
            state.dashboardModelList
                .where(
                  (e) =>
                      e.punchIn != null &&
                      e.punchIn!.year == today.year &&
                      e.punchIn!.month == today.month &&
                      e.punchIn!.day == today.day,
                )
                .toList();

        if (todayRecords.isEmpty) return;

        final record = todayRecords.first;

        currentAttendanceId = record.attendanceId;
        currentUniquekey = record.uniquekey;
        if (record.punchOut == null) {
          isPunchedInNotifier.value = true;
          isDayCompletedNotifier.value = false;
          isSwipeDisabledNotifier.value = false;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            dragPositionNotifier.value = maxWidth;
          });

          if (_timer == null) {
            _startTimerFrom(record.punchIn!);
          }
        } else {
          _timer?.cancel();

          isPunchedInNotifier.value = false;

          /// COMPLETELY LOCK SLIDER
          isSwipeDisabledNotifier.value = true;

          isDayCompletedNotifier.value = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            dragPositionNotifier.value = 0;
          });

          workedDuration.value = record.punchOut!.difference(record.punchIn!);
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          initialise();
        },
        child: Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Dashboard",
            isMenuButton: true,
            authorization: _routeAuthorization,
            showNotification: true,
          ),
          body: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              // keep the screen (and slider) mounted while punching,
              // otherwise the cubit loader replaces the whole page
              if (state.isLoading! && !isProcessingNotifier.value) {
                return Center(child: loader());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome ${currentUser?.fullName ?? ""}!",
                      style: AppTextStyle.ts16SB(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                    verticalSpacing(),
                    // PUNCH IN - PUNCH OUT WIDGET
                    _buildWordayOverviewWidget(state, context),
                    verticalSpacing(height: 16),
                    // PENDING APPROVAL WIDGET
                    pendingApprovalWidget(),
                    verticalSpacing(height: 16),
                    //  QUICK ACTIONS WIDGET
                    buildQuickActionsWidget(context),
                    verticalSpacing(height: 16),
                    // ATTENDANCE SUMMARY WIGET
                    buildAttendanceSummaryWidget(context),
                    verticalSpacing(height: 16),
                    // WORKING HOUR SUMMARY WIGET
                    buildWorkingHourSummaryWidget(context),
                    verticalSpacing(height: 16),
                    // TEAM ATTENDANCE WIDGET
                    buildTeamAttendanceSummaryWidget(context),
                    verticalSpacing(height: 16),
                    buildLeaveBalanceSummaryWidget(context),
                    verticalSpacing(height: 16),
                    // HOLIDAY WIDGET
                    buildHolidaySummaryWidget(context),
                    verticalSpacing(height: 16),
                    // EVENTS WIDGET (BIRTHDAY'S AND EVENTS)
                    buildEventsAndMoreWidget(context),
                    verticalSpacing(height: 16),
                    // REPORTING MANAGER WIDGET
                    buildReportingManagerWidget(context),
                    verticalSpacing(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueNotifier<A> first;
  final ValueNotifier<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return builder(context, a, b, null);
          },
        );
      },
    );
  }
}
