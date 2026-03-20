// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/user_dashboard.model.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/pages/route_map_screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  final AttendanceModel? data;
  const DashboardScreen({super.key, this.data});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // CUBIT
  late DashboardCubit _dashboardCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorization;

  final ValueNotifier<double> dragPositionNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> isPunchedInNotifier = ValueNotifier(false);

  late ProjectModel _selectedProject;

  late DateTime punchInTime;
  DateTime? punchOutTime;

  final ValueNotifier<Duration> workedDuration = ValueNotifier(Duration.zero);

  Timer? _timer;
  int? currentAttendanceId;
  String? currentUniquekey;

  final LocalStorageManager storage = LocalStorageManager();

  UserModel? currentUser;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _routeAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.dashboardScreen]!;
    _dashboardCubit = context.read<DashboardCubit>();

    _selectedProject = getProject();
    initialise();
    final userJson = storage.getString(StorageKey.currentUser);
    if (userJson != null) {
      currentUser = UserModel.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> initialise() async {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start;

    await _dashboardCubit.getAttendanceList(
      context,
      1,
      start,
      end,
      0,
      _selectedProject.projectId,
    );
    // });
    await _dashboardCubit.getDashboardList(context);
  }

  @override
  void dispose() {
    isPunchedInNotifier.dispose();
    dragPositionNotifier.dispose();
    workedDuration.dispose();
    _timer?.cancel();
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

  Future<String> _getAddressFromGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return "Location service disabled";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return "Location permission not granted";
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;

      return "${place.name}, ${place.street}, ${place.locality}, "
          "${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      return "Unable to fetch location";
    }
  }

  double maxWidth = 0.0;

  bool isDraggingRight = true;

  StreamSubscription<Position>? positionStream;
  List<LatLng> routePoints = [];
  LatLng? startLatLng;
  LatLng? lastPoint;
  double totalDistance = 0.0;

  Future<void> punchIn(BuildContext context) async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      final address = await _getAddressFromGPS();

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
    } catch (e) {
      debugPrint("Punch In GPS Error: $e");
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

    final finalDistance =
        routePoints.length > 1 ? _calculateDistance(routePoints) : 0.0;

    final finalPolyline =
        routePoints.length > 1 ? PolylineEncoder.encode(routePoints) : "";

    await _dashboardCubit.updateAttendance(
      context,
      attendanceId: _dashboardCubit.state.data!.attendanceId,
      uniquekey: _dashboardCubit.state.data!.uniquekey,
      punchAddress: address,
      startLatitude: startLatLng?.latitude ?? routePoints.first.latitude,
      startLongitude: startLatLng?.longitude ?? routePoints.first.longitude,
      endLatitude: endPoint.latitude,
      endLongitude: endPoint.longitude,
      polyline: finalPolyline,
      distance: finalDistance,
    );

    _timer?.cancel();

    isPunchedInNotifier.value = false;
    dragPositionNotifier.value = 0;
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
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final currentPoint = LatLng(position.latitude, position.longitude);
      if (routePoints.isEmpty) {
        if (startLatLng != null) {
          routePoints.add(startLatLng!);
          lastPoint = startLatLng;
          totalDistance = 0.0;
          return;
        }

        startLatLng = currentPoint;
        routePoints.add(currentPoint);
        lastPoint = currentPoint;
        return;
      }
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

      if (segmentDistance < 5) return;

      routePoints.add(currentPoint);
      totalDistance += segmentDistance;
      lastPoint = currentPoint;
    }, onError: (e) {});
  }

  Future<void> _openEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Hello', 'body': 'Hi'},
    );

    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  }

  void _openDialer(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
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
        // PUNCH OUT SESSION
        if (record.punchOut == null) {
          isPunchedInNotifier.value = true;
          dragPositionNotifier.value = maxWidth;
          _startTimerFrom(record.punchIn!);
          if (startLatLng == null &&
              record.startLatitude != 0 &&
              record.startLongitude != 0) {
            startLatLng = LatLng(record.startLatitude, record.startLongitude);
            if (routePoints.isEmpty) {
              routePoints.add(startLatLng!);
              lastPoint = startLatLng;
              totalDistance = 0.0;
            }
            if (positionStream == null) {
              _startLocationTracking();
            }
          }
        } else {
          _timer?.cancel();
          isPunchedInNotifier.value = false;
          dragPositionNotifier.value = 0;
          workedDuration.value = record.punchOut!.difference(record.punchIn!);
        }
        isPunchedInNotifier.value = record.punchOut == null;
        dragPositionNotifier.value = record.punchOut == null ? maxWidth : 0;
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading!) {
            return Center(child: loader());
          }
          return Scaffold(
            appBar: CustomAppBarWithBackButton(
              screenTitle: "Dashboard",
              isMenuButton: true,
              authorization: _routeAuthorization,
              onProjectChangeCallback: (value) {
                print(_selectedProject.projectId);
                _selectedProject = value;
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, now.day);
                final end = start;
                _dashboardCubit.getAttendanceList(
                  context,
                  1,
                  start,
                  end,
                  0,
                  _selectedProject.projectId,
                );
                _dashboardCubit.getDashboardList(context);
              },
              showNotification: true,
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: SingleChildScrollView(
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
                        verticalSpacing(),
                        //  SCHEDULED TASK WIDGET
                        _buildScheduledTaskWidget(context),
                        verticalSpacing(),
                        //  QUICK ACTIONS WIDGET
                        _buildQuickActionsWidget(context),
                        verticalSpacing(),
                        // ATTENDANCE SUMMARY WIGET
                        _buildAttendanceSummaryWidget(context),
                        verticalSpacing(),
                        // WORKING HOUR SUMMARY WIGET
                        _buildWorkingHourSummaryWidget(context),
                        verticalSpacing(),
                        // TEAM ATTENDANCE WIDGET
                        _buildTeamAttendanceSummaryWidget(context),
                        verticalSpacing(),
                        _buildLeaveBalanceSummaryWidget(context),
                        verticalSpacing(),
                        // HOLIDAY WIDGET
                        _buildHolidaySummaryWidget(context),
                        verticalSpacing(),
                        // EVENTS WIDGET (BIRTHDAY'S AND EVENTS)
                        _buildEventsAndMoreWidget(context),
                        verticalSpacing(),
                        // REPORTING MANAGER WIDGET
                        _buildReportingManagerWidget(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
                ValueListenableBuilder2<bool, double>(
                  first: isPunchedInNotifier,
                  second: dragPositionNotifier,
                  builder: (context, isPunchedIn, dragPosition, _) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        maxWidth = constraints.maxWidth - 42;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 24.0),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColor.primary.withValues(alpha: 0.16),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  isPunchedIn
                                      ? "Swipe to Punch Out"
                                      : "Swipe to Punch In",
                                  style: AppTextStyle.ts12M(),
                                ),
                              ),
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                left: dragPosition,
                                top: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    double newPos =
                                        dragPositionNotifier.value +
                                        details.delta.dx;
                                    dragPositionNotifier.value = newPos.clamp(
                                      0,
                                      maxWidth,
                                    );
                                  },

                                  onHorizontalDragEnd: (_) async {
                                    if (isProcessing) {
                                      return;
                                    }

                                    final currentPos =
                                        dragPositionNotifier.value;

                                    /// PUNCH IN
                                    if (!isPunchedInNotifier.value &&
                                        currentPos > maxWidth * 0.7) {
                                      isProcessing = true;

                                      dragPositionNotifier.value = maxWidth;
                                      isPunchedInNotifier.value = true;

                                      await punchIn(context); //  ONLY ONCE

                                      _startLocationTracking();
                                      _startTimerFrom(DateTime.now());

                                      isProcessing = false;
                                    }
                                    /// PUNCH OUT
                                    else if (isPunchedInNotifier.value &&
                                        currentPos < maxWidth * 0.3) {
                                      isProcessing = true;

                                      dragPositionNotifier.value = 0;
                                      isPunchedInNotifier.value = false;

                                      await punchOut(context);

                                      isProcessing = false;
                                    }
                                    /// RESET
                                    else {
                                      dragPositionNotifier.value =
                                          isPunchedInNotifier.value
                                              ? maxWidth
                                              : 0;
                                    }
                                  },
                                  child: Container(
                                    width: 42,
                                    decoration: BoxDecoration(
                                      color: AppColor.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isPunchedIn
                                          ? Icons.arrow_back_ios_new_outlined
                                          : Icons.arrow_forward_ios_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
          ],
        );
      },
    );
  }

  Widget _buildScheduledTaskWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Scheduled Task",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          ListView.builder(
            itemCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, int index) {
              return scheduledTaskCard();
            },
          ),
        ],
      ),
    );
  }

  Widget scheduledTaskCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.lightGreyBackground,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: AppColor.priorityHighColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "HR Dashboard Redesign",
                        style: AppTextStyle.ts16M(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Due: Today, 5:00 PM",
                        style: AppTextStyle.ts12R(
                          color: AppColor.black.withValues(alpha: 0.50),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.priorityHighColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "High",
                      style: AppTextStyle.ts12M(
                        color: AppColor.priorityHighColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BUILD QUICK ACTIONS WIDGET
  Widget _buildQuickActionsWidget(BuildContext context) {
    final actions = [
      _QuickActionItem(
        icon: SvgPicture.asset(AppAssets.applyLeaveIcon),
        text: "Apply Leave",
        backgroundColor: AppColor.lightBlue,
        onTap: () {
          goRouter.pushNamed(AppRoutes.applyLeave);
        },
      ),
      _QuickActionItem(
        icon: SvgPicture.asset(AppAssets.raiseTaskIcon),
        text: "Raise Task",
        backgroundColor: AppColor.purple20.withValues(alpha: .08),
        onTap: () {
          DialogHelper.showCustomDialogue(
            context,
            icon: CustomIconButton(
              onPressed: () {},
              icon: Icon(
                Icons.warning_amber_outlined,
                color: AppColor.yellow,
                size: 16,
              ),
              backgroundColor: AppColor.yellow.withValues(alpha: .2),
            ),
            title: "ALERT",
            childContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: AppColor.black.withValues(alpha: 0.50),
                  thickness: 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Text(
                    "This feature is currently under development and will be available soon.",
                    style: AppTextStyle.ts14SB(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      _QuickActionItem(
        icon: SvgPicture.asset(AppAssets.applyAdvanceIcon),
        text: "Apply Advance",
        backgroundColor: AppColor.lightYellow.withValues(alpha: .5),
        onTap: () {
          DialogHelper.showCustomDialogue(
            context,
            icon: CustomIconButton(
              onPressed: () {},
              icon: Icon(
                Icons.warning_amber_outlined,
                color: AppColor.yellow,
                size: 16,
              ),
              backgroundColor: AppColor.yellow.withValues(alpha: .2),
            ),
            title: "ALERT",
            childContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: AppColor.black.withValues(alpha: 0.50),
                  thickness: 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Text(
                    "This feature is currently under development and will be available soon.",
                    style: AppTextStyle.ts14SB(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      _QuickActionItem(
        icon: SvgPicture.asset(AppAssets.regularizeIcon),
        text: "Regularize",
        backgroundColor: AppColor.lightGreen.withValues(alpha: .5),
        onTap: () {
          goRouter.pushNamed(AppRoutes.attendance);
        },
      ),
      _QuickActionItem(
        icon: SvgPicture.asset(AppAssets.requestAssetIcon),
        text: "Request Asset",
        backgroundColor: AppColor.lightOrangenBg.withValues(alpha: .5),
        onTap: () {
          DialogHelper.showCustomDialogue(
            context,
            icon: CustomIconButton(
              onPressed: () {},
              icon: Icon(
                Icons.warning_amber_outlined,
                color: AppColor.yellow,
                size: 16,
              ),
              backgroundColor: AppColor.yellow.withValues(alpha: .2),
            ),
            title: "ALERT",
            childContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: AppColor.black.withValues(alpha: 0.50),
                  thickness: 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Text(
                    "This feature is currently under development and will be available soon.",
                    style: AppTextStyle.ts14SB(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      _QuickActionItem(
        icon: SvgPicture.asset(AppAssets.payslipIcon),
        text: "Payslip",
        backgroundColor: AppColor.red.withValues(alpha: .08),
        onTap: () {
          DialogHelper.showCustomDialogue(
            context,
            icon: CustomIconButton(
              onPressed: () {},
              icon: Icon(
                Icons.warning_amber_outlined,
                color: AppColor.yellow,
                size: 16,
              ),
              backgroundColor: AppColor.yellow.withValues(alpha: .2),
            ),
            title: "ALERT",
            childContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: AppColor.black.withValues(alpha: 0.50),
                  thickness: 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Text(
                    "This feature is currently under development and will be available soon.",
                    style: AppTextStyle.ts14SB(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.50),
            ),
          ),

          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final item = actions[index];

              return _quickActionCard(
                icon: item.icon,
                text: item.text,
                backgroundColor: item.backgroundColor,
                onTap: item.onTap,
              );
            },
          ),
        ],
      ),
    );
  }

  // QUICK ACTION CARD
  Widget _quickActionCard({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomIconButton(
          onPressed: onTap,
          icon: icon,
          backgroundColor: backgroundColor ?? AppColor.lightBlue,
        ),
        Text(text, style: AppTextStyle.ts12M(), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildAttendanceSummaryWidget(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final userData = state.userData;
        final table1 = userData?.table1.first;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Attendance Summary",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (table1 != null) ...[
                Column(
                  children: [
                    AttendanceStatCard(
                      title: "Present Days",
                      value: table1.presentDays,
                      subtitle: "This Month",
                      bgColor: Color(0xFFEFFAF3),
                      borderColor: Color(0xFFB7E4C7),
                      valueColor: Color(0xFF2E7D32),
                    ),
                    verticalSpacing(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AttendanceStatCard(
                            title: "Avg Login Time",
                            value: formatApiTimeToAmPm(table1.avgLoginTime),
                            bgColor: Color(0xFFFFF6ED),
                            borderColor: Color(0xFFFFD8B5),
                            valueColor: Color(0xFFE65100),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: AttendanceStatCard(
                            title: "Shift Pattern",
                            value:
                                "${dateFormatterHourOnly(table1.shiftStartTime)} - ${dateFormatterHourOnly(table1.shiftEndTime)}",
                            bgColor: Color(0xFFF4F0FF),
                            borderColor: Color(0xFFD9CCFF),
                            valueColor: Color(0xFF6A1B9A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Attendance Summary Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkingHourSummaryWidget(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final userData = state.userData;
        final table2 = userData?.table2;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Working Hour Summary",
                style: AppTextStyle.ts14M(
                  color: AppColor.black.withValues(alpha: 0.50),
                ),
              ),

              const SizedBox(height: 20),

              if (table2?.isNotEmpty == true) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    summaryOverallWidget(
                      title: "This Week",
                      subTitle: formatDecimalHours(table2!.first.thisWeekHours),
                    ),
                    summaryOverallWidget(
                      title: "Overtime",
                      subTitle: formatDecimalHours(table2.first.overtimeHours),
                      color: AppColor.yellow,
                    ),
                    summaryOverallWidget(
                      title: "Avg Daily",
                      subTitle: formatDecimalHours(table2.first.avgDailyHours),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildDayWiseProgress(),
              ] else ...[
                Center(
                  child: Text(
                    "No Working Hour Summary Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamAttendanceSummaryWidget(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }
        final userData = state.userData;

        final table3 = userData?.table3;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Team Attendance Summary",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              (table3 != null && table3.isNotEmpty)
                  ? CommonRadialChart(
                    items: [
                      RadialChartItem(
                        title: "Present",
                        value: 9,
                        color: AppColor.primary,
                      ),
                      RadialChartItem(
                        title: "Absent",
                        value: 2,
                        color: AppColor.blue,
                      ),
                      RadialChartItem(
                        title: "Leave",
                        value: 2,
                        color: AppColor.grey50,
                      ),
                    ],
                  )
                  : Center(
                    child: Text(
                      "No Team Attendance Summary",
                      style: AppTextStyle.ts12M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaveBalanceSummaryWidget(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final table4List = state.userData?.table4;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Leave Balance",
                style: AppTextStyle.ts14M(
                  color: AppColor.black.withValues(alpha: 0.50),
                ),
              ),
              const SizedBox(height: 20),

              if (table4List != null && table4List.isNotEmpty) ...[
                _leaveRow(
                  title: "Total Leaves",
                  value: "${table4List.first.totalLeaves}",
                ),
                _leaveRow(
                  title: "Used Leaves",
                  value: "${table4List.first.usedLeaves}",
                ),
                _leaveRow(
                  title: "Pending Leaves",
                  value: "${table4List.first.pendingLeaves}",
                ),

                const SizedBox(height: 20),

                Text(
                  "Upcoming Approved",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 10),

                _buildUpcomingAttendanceWidget(
                  title: table4List.first.leaveTypeName,
                  value: "",
                  subtitle: "Feb 14-16, 2024 (3 days)",
                  bgColor: Color(0xFFEFFAF3),
                  borderColor: Color(0xFFB7E4C7),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Leave Balance Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _leaveRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 6, child: Text(title, style: AppTextStyle.ts14M())),

          SizedBox(
            width: 24,
            child: Center(child: Text(":", style: AppTextStyle.ts14M())),
          ),

          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(value, style: AppTextStyle.ts16SB()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAttendanceWidget({
    String? title,
    String? value,
    String? subtitle,
    Color? bgColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title!, style: AppTextStyle.ts14M(color: AppColor.black)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value!,
                style: AppTextStyle.ts16SB(color: Color(0xFF2E7D32)),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle,
                  style: AppTextStyle.ts10R(color: AppColor.black),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHolidaySummaryWidget(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final userData = state.userData;

        final table6List = userData?.table6;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Holiday",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (table6List != null) ...[
                ListView.builder(
                  itemCount: table6List.length,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    final holiday = table6List[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: AppColor.lightPurple.withValues(alpha: 0.50),
                        border: Border.all(
                          width: 1,
                          color: AppColor.lightPurple,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            holiday.holidayName,
                            style: AppTextStyle.ts14M(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${formatDateToDayMonth(holiday.holidayDate)}, ${holiday.dayName}",
                                style: AppTextStyle.ts12R(
                                  color: AppColor.black.withValues(alpha: 0.50),
                                ),
                              ),
                              Text(
                                "In ${holiday.daysRemaining} days",
                                style: AppTextStyle.ts10M().copyWith(
                                  color: AppColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Holiday Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsAndMoreWidget(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final userData = state.userData;

        final table8List = userData?.table8;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Events & More",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                thickness: 0.3,
                color: AppColor.black.withValues(alpha: 0.50),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Upcoming Birthday",
                      style: AppTextStyle.ts14SB(color: AppColor.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (table8List != null) ...[
                ListView.builder(
                  itemCount: table8List.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    var upcomingBirthday = table8List[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: NetworkImageWidget(
                          borderRadius: BorderRadius.circular(100.0),
                          imageUrl:
                              'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            color: AppColor.white,
                            width: 45,
                            height: 45,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 20,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),

                      title: Text(
                        upcomingBirthday.fullName,
                        style: AppTextStyle.ts14M(),
                      ),
                      subtitle: Text(
                        upcomingBirthday.departmentName,
                        style: AppTextStyle.ts14R(
                          color: AppColor.black.withValues(alpha: 0.50),
                        ),
                      ),
                      trailing: Text(
                        formatDateTimeAsDDMMMYYYY(upcomingBirthday.dateOfBirth),
                        style: AppTextStyle.ts14R(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Divider(
                  thickness: 0.3,
                  color: AppColor.black.withValues(alpha: 0.50),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Upcoming Events",
                        style: AppTextStyle.ts14SB(color: AppColor.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "No Upcoming Events Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
                /*
                ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Diwali Celebration",
                        style: AppTextStyle.ts14M(),
                      ),
                      subtitle: Text(
                        "Andheri",
                        style: AppTextStyle.ts16R(
                          color: AppColor.black.withValues(alpha: 0.50),
                        ),
                      ),
                      trailing: Text(
                        formatDateTimeAsDDMMMYYYY(DateTime.now()),
                        style: AppTextStyle.ts14R(),
                      ),
                    );
                  },
                ),
             */
              ] else ...[
                Center(
                  child: Text(
                    "No Upcoming Events Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportingManagerWidget(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final userData = state.userData;

        final table10List = userData?.table10;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Reporting Manager",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_hasValidManager(table10List)) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: NetworkImageWidget(
                      borderRadius: BorderRadius.circular(100.0),
                      imageUrl:
                          'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: AppColor.white,
                        width: 45,
                        height: 45,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    table10List!.first.managerName,
                    style: AppTextStyle.ts14B(),
                  ),
                  subtitle: Text(
                    table10List.first.designationName,
                    style: AppTextStyle.ts14R(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  trailing: Text(
                    table10List.first.departmentName,
                    style: AppTextStyle.ts14R(),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    _openEmail(table10List.first.managerEmail);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              AppAssets.mailIcon,
                              height: 16.0,
                              width: 16.0,
                            ),
                            const SizedBox(width: 6.0),
                            Expanded(
                              child: Text(
                                table10List.first.managerEmail,
                                style: AppTextStyle.ts14M(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _openDialer(table10List.first.managerPhone);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              AppAssets.phoneIcon,
                              height: 16.0,
                              width: 16.0,
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              table10List.first.managerPhone,
                              style: AppTextStyle.ts14M(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Reporting Manager",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  bool _hasValidManager(List<Table10>? list) {
    if (list == null || list.isEmpty) return false;

    final m = list.first;

    return (m.managerName.trim().isNotEmpty) ||
        (m.managerEmail.trim().isNotEmpty) ||
        (m.managerPhone.trim().isNotEmpty);
  }

  Widget summaryOverallWidget({String? title, String? subTitle, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title!, style: AppTextStyle.ts14M()),
        Text(subTitle!, style: AppTextStyle.ts16SB(color: color)),
      ],
    );
  }

  Widget _buildDayWiseProgress() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final userData = state.userData;

        if (userData == null || userData.table3.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Daily Attendance Data")),
          );
        }

        final table3List = userData.table3;
        final table1 =
            userData.table1.isNotEmpty ? userData.table1.first : null;
        Duration targetDuration = const Duration(hours: 9);

        if (table1 != null &&
            table1.shiftStartTime.isNotEmpty &&
            table1.shiftEndTime.isNotEmpty &&
            table1.shiftStartTime != "{}" &&
            table1.shiftEndTime != "{}") {
          try {
            final startParts = table1.shiftStartTime.split(':');
            final endParts = table1.shiftEndTime.split(':');

            final startHour = int.tryParse(startParts[0]) ?? 0;
            final startMin =
                startParts.length > 1 ? int.tryParse(startParts[1]) ?? 0 : 0;

            final endHour = int.tryParse(endParts[0]) ?? 0;
            final endMin =
                endParts.length > 1 ? int.tryParse(endParts[1]) ?? 0 : 0;

            final now = DateTime.now();

            final startDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              startHour,
              startMin,
            );

            final endDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              endHour,
              endMin,
            );

            final diff = endDateTime.difference(startDateTime);

            if (!diff.isNegative && diff.inSeconds > 0) {
              targetDuration = diff;
            }
          } catch (_) {}
        }

        return Column(
          children:
              table3List.map((dayData) {
                final workedDuration = parseWorkingHoursToDuration(
                  dayData.workingHours,
                );

                return DayWorkProgress(
                  day: dayData.dayName,
                  worked: workedDuration,
                  target: targetDuration,
                );
              }).toList(),
        );
      },
    );
  }
}

class QuickActionTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, height: 24, width: 24),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.ts12M(color: AppColor.black),
          ),
        ],
      ),
    );
  }
}

class AttendanceStatCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final String? subtitle;
  final Color bgColor;
  final Color borderColor;
  final Color valueColor;

  const AttendanceStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.valueColor,
  });

  String _formatValue(dynamic val) {
    if (val == null) return "-";
    if (val is Map && val.isEmpty) return "-";
    if (val is double) {
      if (val == val.toInt()) {
        return val.toInt().toString();
      }
      return val.toStringAsFixed(2);
    }
    if (val is int) return val.toString();
    if (val is DateTime) {
      return "${val.hour.toString().padLeft(2, '0')}:${val.minute.toString().padLeft(2, '0')}";
    }
    if (val is String) {
      if (val.isEmpty || val == "{}") return "-";
      return val;
    }
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final formattedValue = _formatValue(value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyle.ts14SB(
              color: AppColor.black.withValues(alpha: 0.45),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  formattedValue,
                  style: AppTextStyle.ts16SB(color: valueColor),
                  maxLines: 2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    subtitle!,
                    style: AppTextStyle.ts10R(color: valueColor),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class DayWorkProgress extends StatelessWidget {
  final String day;
  final Duration worked;
  final Duration target;

  const DayWorkProgress({
    super.key,
    required this.day,
    required this.worked,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        target.inSeconds == 0
            ? 0.0
            : (worked.inSeconds / target.inSeconds).clamp(0.0, 1.0);

    String format(Duration d) {
      final hours = d.inHours;
      final minutes = d.inMinutes % 60;
      final seconds = d.inSeconds % 60;

      return "${hours.toString().padLeft(2, '0')}:"
          "${minutes.toString().padLeft(2, '0')}:"
          "${seconds.toString().padLeft(2, '0')}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(day, style: AppTextStyle.ts14M()),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 22,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.lightGreyBackground,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                Container(
                  height: 22,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF2563EB),
                        Color(0xFF1E40AF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          "${format(worked)} / ${format(target)} hrs",
          style: AppTextStyle.ts12R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 22),
      ],
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

// HELPER MODEL
class _QuickActionItem {
  final Widget icon;
  final String text;
  final Color backgroundColor;
  final VoidCallback onTap;
  _QuickActionItem({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.onTap,
  });
}
