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
  bool isProcessing = false;

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
    _timer?.cancel();
    _routeTimer?.cancel();
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

      if (result != null) {
        currentAttendanceId = result['AttendanceId'];
        currentUniquekey = result['Uniquekey'];
      }
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

  @override
  Widget build(BuildContext context) {
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

          /// DISABLE FOREVER
          isSwipeDisabledNotifier.value = true;

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
              if (state.isLoading!) {
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

  Widget _buildWordayOverviewWidget(
    DashboardState state,
    BuildContext context,
  ) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Workday Overview",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.50),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: AppColor.primary.withValues(alpha: 0.13),
                        ),
                        child: Center(
                          child: Text(
                            dateFormatterDDMMYYYYDAY(
                              DateTime.now(),
                              isDayNotRequired: true,
                            ),
                            style: AppTextStyle.ts12M(color: AppColor.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 0.3,
                  color: AppColor.black.withValues(alpha: 0.50),
                ),
                Container(
                  margin: EdgeInsets.only(top: 32),
                  alignment: Alignment.center,
                  child: ValueListenableBuilder<Duration>(
                    valueListenable: workedDuration,
                    builder: (context, duration, _) {
                      return RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: formatDuration(duration),
                              style: AppTextStyle.ts24SB().copyWith(
                                fontFamily: "semibold",
                                fontSize: 34,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text: "/\n9:00:00",
                              style: AppTextStyle.ts12M().copyWith(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ValueListenableBuilder2<bool, bool>(
                  first: isPunchedInNotifier,
                  second: isSwipeDisabledNotifier,
                  builder: (context, isPunchedIn, isSwipeDisabled, _) {
                    final isCurrentlyPunchedIn =
                        isPunchedInNotifier.value &&
                        !isDayCompletedNotifier.value;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final sliderWidth = constraints.maxWidth;
                        final thumbWidth = 52.0;

                        maxWidth = sliderWidth - thumbWidth;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final targetPosition =
                              isCurrentlyPunchedIn ? maxWidth : 0.0;

                          if (dragPositionNotifier.value != targetPosition) {
                            dragPositionNotifier.value = targetPosition;
                          }
                        });
                        return StatefulBuilder(
                          builder: (context, setInnerState) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 24.0,
                              ),
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color:
                                    isSwipeDisabled
                                        ? AppColor.lightGrey
                                        : AppColor.primary.withValues(
                                          alpha: 0.12,
                                        ),
                              ),
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Text(
                                        isCurrentlyPunchedIn
                                            ? "Swipe to Punch Out"
                                            : "Swipe to Punch In",
                                        key: ValueKey(isCurrentlyPunchedIn),
                                        style: AppTextStyle.ts12B(
                                          color:
                                              isSwipeDisabled
                                                  ? AppColor.grey
                                                  : null,
                                        ),
                                      ),
                                    ),
                                  ),

                                  ValueListenableBuilder<double>(
                                    valueListenable: dragPositionNotifier,
                                    builder: (context, dragPosition, _) {
                                      return AnimatedPositioned(
                                        duration: const Duration(
                                          milliseconds: 120,
                                        ),
                                        curve: Curves.easeOut,
                                        left: dragPosition,
                                        top: 2,
                                        bottom: 2,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,

                                          onHorizontalDragUpdate:
                                              isSwipeDisabled
                                                  ? null
                                                  : (details) {
                                                    if (isProcessing) return;

                                                    final updated =
                                                        dragPositionNotifier
                                                            .value +
                                                        details.delta.dx;

                                                    dragPositionNotifier
                                                        .value = updated.clamp(
                                                      0.0,
                                                      maxWidth,
                                                    );
                                                  },

                                          onHorizontalDragEnd:
                                              isSwipeDisabled
                                                  ? null
                                                  : (details) async {
                                                    if (isProcessing) return;

                                                    final velocity =
                                                        details
                                                            .primaryVelocity ??
                                                        0;

                                                    final current =
                                                        dragPositionNotifier
                                                            .value;

                                                    final shouldComplete =
                                                        current >
                                                            maxWidth * 0.55 ||
                                                        velocity > 700;

                                                    // PUNCH IN
                                                    if (!isCurrentlyPunchedIn &&
                                                        shouldComplete &&
                                                        !isDayCompletedNotifier
                                                            .value &&
                                                        currentAttendanceId ==
                                                            null) {
                                                      final hasPermission =
                                                          await _ensureLocationPermission(
                                                            context,
                                                          );

                                                      if (!hasPermission) {
                                                        dragPositionNotifier
                                                            .value = 0;
                                                        return;
                                                      }

                                                      isProcessing = true;

                                                      dragPositionNotifier
                                                          .value = maxWidth;

                                                      await Future.delayed(
                                                        const Duration(
                                                          milliseconds: 150,
                                                        ),
                                                      );

                                                      /// COMMENTING THIS IF THE NEWER VERSION WILL NOT WORK THIS IS THE STABLE CODE

                                                      // isPunchedInNotifier
                                                      //     .value = true;

                                                      // if (context.mounted) {
                                                      //   await punchIn(context);
                                                      // }

                                                      // _startTimerFrom(
                                                      //   DateTime.now(),
                                                      // );
                                                      final success =
                                                          await punchIn(
                                                            context,
                                                          );

                                                      if (success) {
                                                        isPunchedInNotifier
                                                            .value = true;
                                                        _startTimerFrom(
                                                          DateTime.now(),
                                                        );
                                                        dragPositionNotifier
                                                            .value = maxWidth;
                                                        HapticFeedback.mediumImpact();
                                                      } else {
                                                        isPunchedInNotifier
                                                            .value = false;
                                                        dragPositionNotifier
                                                            .value = 0;
                                                      }

                                                      HapticFeedback.mediumImpact();

                                                      isProcessing = false;
                                                    }
                                                    // PUNCH OUT
                                                    else if (isCurrentlyPunchedIn) {
                                                      final shouldPunchOut =
                                                          current <
                                                              maxWidth * 0.45 ||
                                                          velocity < -700;

                                                      if (shouldPunchOut) {
                                                        if (!canPunchOut()) {
                                                          showErrorMessage(
                                                            context,
                                                            "Punch Out Not Allowed",
                                                            "Minimum working duration is 1 hour.",
                                                          );

                                                          dragPositionNotifier
                                                              .value = maxWidth;
                                                          return;
                                                        }

                                                        isProcessing = true;

                                                        dragPositionNotifier
                                                            .value = 0;

                                                        await Future.delayed(
                                                          const Duration(
                                                            milliseconds: 150,
                                                          ),
                                                        );

                                                        if (context.mounted) {
                                                          await punchOut(
                                                            context,
                                                          );
                                                        }
                                                        isSwipeDisabledNotifier
                                                            .value = true;
                                                        isDayCompletedNotifier
                                                            .value = true;
                                                        isPunchedInNotifier
                                                            .value = false;
                                                        await initialise();
                                                        HapticFeedback.mediumImpact();

                                                        isProcessing = false;
                                                      } else {
                                                        dragPositionNotifier
                                                            .value = maxWidth;
                                                      }
                                                    }
                                                    // RESET
                                                    else {
                                                      dragPositionNotifier
                                                              .value =
                                                          isCurrentlyPunchedIn
                                                              ? maxWidth
                                                              : 0;
                                                    }
                                                  },

                                          child: Container(
                                            width: thumbWidth,
                                            decoration: BoxDecoration(
                                              color:
                                                  isSwipeDisabled
                                                      ? AppColor.grey50
                                                      : AppColor.primary,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                  color: AppColor.black
                                                      .withValues(alpha: 0.15),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              isCurrentlyPunchedIn
                                                  ? Icons.arrow_back_ios_new
                                                  : Icons
                                                      .arrow_forward_ios_sharp,
                                              color: AppColor.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                _buildDashboardPunchInPunchOutWidget(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardPunchInPunchOutWidget(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final bool hasLocation =
            state.data != null &&
            state.data!.startLatitude != 0 &&
            state.data!.startLongitude != 0 &&
            state.data!.endLatitude != 0 &&
            state.data!.endLongitude != 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Punch In : ',
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  TextSpan(
                    text:
                        (state.data != null && state.data?.punchIn != null)
                            ? DateFormat('hh:mm a').format(state.data!.punchIn!)
                            : "--",
                    style: AppTextStyle.ts14M(color: AppColor.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '',
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  TextSpan(
                    text:
                        (state.data != null &&
                                state.data!.punchInAddress.isNotEmpty)
                            ? state.data!.punchInAddress
                            : "--",
                    style: AppTextStyle.ts14M(color: AppColor.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Punch Out : ',
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  TextSpan(
                    text:
                        (state.data != null && state.data?.punchOut != null)
                            ? DateFormat(
                              'hh:mm a',
                            ).format(state.data!.punchOut!)
                            : "--",
                    style: AppTextStyle.ts14M(color: AppColor.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '',
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  TextSpan(
                    text:
                        (state.data != null &&
                                state.data!.punchOutAddress.isNotEmpty)
                            ? state.data!.punchOutAddress
                            : "--",
                    style: AppTextStyle.ts14M(color: AppColor.black),
                  ),
                ],
              ),
            ),
            if (hasLocation) ...[
              verticalSpacing(height: 5),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => MapScreen(
                            startLatitude: state.data!.startLatitude,
                            startLongitude: state.data!.startLongitude,
                            endLatitude: state.data!.endLatitude,
                            endLongitude: state.data!.endLongitude,
                            polyline: state.data!.polyline,
                            distance: state.data!.distance.toDouble(),
                            attendanceDataModel: state.data!,
                          ),
                    ),
                  );
                },
                child: Text(
                  "View Location",
                  style: AppTextStyle.ts12M().copyWith(
                    color: AppColor.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColor.primary,
                  ),
                ),
              ),
            ],
          ],
        );
      },
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
