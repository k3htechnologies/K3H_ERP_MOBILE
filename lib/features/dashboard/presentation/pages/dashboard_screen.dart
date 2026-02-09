// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/dashboard.model.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/widget/project_selector_overlay.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final DashboardModel? data;
  const DashboardScreen({super.key, this.data});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // PROJECT MASTER REPOSITORY
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  // CUBIT
  late DashboardCubit _dashboardCubit;

  final ValueNotifier<List<ProjectModel>> _projectListNotifier = ValueNotifier(
    [],
  );

  final ValueNotifier<bool> _showOverlayNotifier = ValueNotifier(false);

  ProjectModel? _selectedProject;

  late DateTime punchInTime;
  DateTime? punchOutTime;

  final ValueNotifier<Duration> workedDuration = ValueNotifier(Duration.zero);

  Timer? _timer;
  int? currentAttendanceId;
  @override
  void initState() {
    super.initState();
    _dashboardCubit = context.read<DashboardCubit>();
    _loadProjects();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      _dashboardCubit.getAttendanceList(context, 1, start, end, 0);
    });
  }

  @override
  void dispose() {
    _showOverlayNotifier.dispose();
    _timer?.cancel();
    workedDuration.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    await _fetchProjects(1);
    final projects = _projectListNotifier.value;
    ProjectModel? storedProject;
    final storedJson = LocalStorageManager().getString(
      StorageKey.selectedProject,
    );
    if (storedJson != null && storedJson.isNotEmpty) {
      storedProject = ProjectModel.fromJson(jsonDecode(storedJson));
    }
    if (storedProject != null &&
        projects.any((p) => p.projectId == storedProject!.projectId)) {
      _selectedProject = storedProject;
    } else if (projects.isNotEmpty) {
      _selectedProject = projects.first;
      LocalStorageManager().setString(
        StorageKey.selectedProject,
        jsonEncode(_selectedProject!.toJson()),
      );
    }
  }

  // FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    final userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? '',
    );
    final user = UserModel.fromJson(userJson);

    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 100,
      queryParams: {
        'EmployeeId': user.employeeId.toString(),
        if (value != null && value.isNotEmpty) 'ProjectName': value,
      },
    );

    return result.fold(
      (failure) {
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        final List<ProjectModel> projects =
            (response['data'] as List<ProjectModel>);
        if (pageNumber == 1) {
          _projectListNotifier.value = projects;
        } else {
          _projectListNotifier.value = [
            ..._projectListNotifier.value,
            ...projects,
          ];
        }
        final List<Map<String, dynamic>> itemList =
            projects
                .map(
                  (project) => {
                    'zAttributesId': project.projectId,
                    'DisplayName': project.projectName,
                  },
                )
                .toList();
        return {
          "itemList": itemList,
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  void _startTimerFrom(DateTime start, DateTime? end) {
    _timer?.cancel();

    punchInTime = start;
    punchOutTime = end;

    // ✅ SET INITIAL VALUE FIRST
    final initialEnd = punchOutTime ?? DateTime.now();
    workedDuration.value = initialEnd.difference(punchInTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final effectiveEnd = punchOutTime ?? DateTime.now();
      workedDuration.value = effectiveEnd.difference(punchInTime);
    });
  }

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  void handleAddUpdateAttendance() {
    if (widget.data == null) {
      _dashboardCubit.addAttendance(
        context,
        attendanceId: 0,
        uniquekey: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        punchAddress: widget.data!.punchInAddress,
      );
    } else {
      _dashboardCubit.updateAttendance(
        context,
        attendanceId: widget.data!.attendanceId,
        uniquekey: widget.data!.uniquekey,
        punchAddress: widget.data!.punchOutAddress,
      );
    }
  }

  Future<String> _getAddressFromGPS() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied");
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
  }

  double dragPosition = 0.0;
  double maxWidth = 0.0;

  bool isPunchedIn = false;
  bool isDraggingRight = true; // direction tracker

  void _handleDragEnd() async {
    if (!isPunchedIn && dragPosition > maxWidth * 0.75) {
      // PUNCH IN
      final address = await _getAddressFromGPS();

      await _dashboardCubit.addAttendance(
        context,
        attendanceId: 0,
        uniquekey: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        punchAddress: address,
      );

      // start timer NOW
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      await _dashboardCubit.getAttendanceList(context, 1, start, end, 0);
      isPunchedIn = true;
      dragPosition = maxWidth;
    } else if (isPunchedIn && dragPosition < maxWidth * 0.25) {
      // PUNCH OUT
      final address = await _getAddressFromGPS();

      await _dashboardCubit.updateAttendance(
        context,
        attendanceId: currentAttendanceId!,
        uniquekey: context.read<DashboardCubit>().state.data!.uniquekey,
        punchAddress: address,
      );

      // stop timer
      _timer?.cancel();
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      await _dashboardCubit.getAttendanceList(context, 1, start, end, 0);
      isPunchedIn = false;
      dragPosition = 0;
    } else {
      dragPosition = isPunchedIn ? maxWidth : 0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardCubit, DashboardState>(
      listener: (context, state) {
        final item = state.data;
        if (item == null) return;

        currentAttendanceId = item.attendanceId;

        // If punched in and not punched out → start live timer from API time
        if (item.punchIn != null && item.punchOut == null) {
          isPunchedIn = true;
          dragPosition = maxWidth;
          _startTimerFrom(item.punchIn, null);
        }
        // If punched out → show fixed duration
        else if (item.punchIn != null && item.punchOut != null) {
          isPunchedIn = false;
          dragPosition = 0;
          _timer?.cancel();
          workedDuration.value = item.punchOut.difference(item.punchIn);
        }
        // No punch at all
        else {
          isPunchedIn = false;
          dragPosition = 0;
          _timer?.cancel();
          workedDuration.value = Duration.zero;
        }
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading!) {
            return Center(child: loader());
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  mobileScreenGlobalScaffoldKey.currentState?.openDrawer();
                },
              ),
              title: const Text("Dashboard"),
              actions: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        DialogHelper.showProcessingOverlay(context);
                      },
                      icon: SvgPicture.asset(
                        AppAssets.dashboardNotificationIcon,
                        height: 32,
                        width: 32,
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder<List<ProjectModel>>(
                  valueListenable: _projectListNotifier,
                  builder: (context, projects, _) {
                    if (projects.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      onPressed: () {
                        _showOverlayNotifier.value = true;
                      },
                      icon: SvgPicture.asset(
                        AppAssets.projectIcon,
                        height: 32,
                        width: 32,
                      ),
                    );
                  },
                ),
              ],
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
                          "Welcome ${state.data?.fullName ?? "s,df"} !",
                          style: AppTextStyle.ts16SB(
                            color: AppColor.black.withValues(alpha: 0.50),
                          ),
                        ),
                        verticalSpacing(),
                        _buildWordayOverviewWidget(state, context),
                        verticalSpacing(),
                        _buildScheduledTaskWidget(context),
                        verticalSpacing(),
                        _buildQuickActionsWidget(context),
                        verticalSpacing(),
                        _buildAttendanceSummaryWidget(context),
                        verticalSpacing(),
                        _buildWorkingHourSummaryWidget(context),
                        verticalSpacing(),
                        _buildTeamAttendanceSummaryWidget(context),
                        verticalSpacing(),
                        _buildLeaveBalanceSummaryWidget(context),
                        verticalSpacing(),
                        _buildHolidaySummaryWidget(context),
                        verticalSpacing(),
                        _buildEventsAndMoreWidget(context),
                      ],
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showOverlayNotifier,
                  builder: (context, showOverlay, _) {
                    if (!showOverlay) return const SizedBox.shrink();
                    return ProjectSelectorOverlay(
                      projects: _projectListNotifier.value,
                      selectedProjectId: _selectedProject?.projectId,
                      onSelect: _onProjectSelected,
                      onClose: () {
                        _showOverlayNotifier.value = false;
                      },
                    );
                  },
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
            LayoutBuilder(
              builder: (context, constraints) {
                maxWidth = constraints.maxWidth - 42;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 24.0),
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
                            setState(() {
                              dragPosition += details.delta.dx;
                              dragPosition = dragPosition.clamp(0, maxWidth);
                            });
                          },
                          onHorizontalDragEnd: (_) => _handleDragEnd(),
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
            ),
            if (state.dashboardModelList.isNotEmpty)
              _buildDashboardPunchInPunchOutWidget(state.data!, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardPunchInPunchOutWidget(
    DashboardModel data,
    BuildContext context,
  ) {
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
                    data.punchIn != null
                        ? DateFormat('hh:mm a').format(data.punchIn)
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
                text: data.punchInAddress,
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
                    data.punchOut != null
                        ? DateFormat('hh:mm a').format(data.punchOut)
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
                text: data.punchOutAddress,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildQuickActionsWidget(BuildContext context) {
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
                  "Quick Actions",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 26.0,
            children: [
              QuickActionTile(
                icon: AppAssets.applyLeaveIcon,
                title: "Apply Leave",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.raiseTaskIcon,
                title: "Raise Task",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.applyAdvanceIcon,
                title: "Apply Advance",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.regularizeIcon,
                title: "Regularize",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.requestAssetIcon,
                title: "Request Asset",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.payslipIcon,
                title: "Payslip",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummaryWidget(BuildContext context) {
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 13,
            crossAxisSpacing: 16,
            childAspectRatio: 1.95,
            children: const [
              AttendanceStatCard(
                title: "Present Days",
                value: "22",
                subtitle: "This Month",
                bgColor: Color(0xFFEFFAF3),
                borderColor: Color(0xFFB7E4C7),
                valueColor: Color(0xFF2E7D32),
              ),
              AttendanceStatCard(
                title: "Avg Login Time",
                value: "9:12 am",
                bgColor: Color(0xFFFFF6ED),
                borderColor: Color(0xFFFFD8B5),
                valueColor: Color(0xFFE65100),
              ),
              AttendanceStatCard(
                title: "WFH Days",
                value: "03",
                subtitle: "This Month",
                bgColor: Color(0xFFEFF5FF),
                borderColor: Color(0xFFCFE0FF),
                valueColor: Color(0xFF1565C0),
              ),
              AttendanceStatCard(
                title: "Shift Pattern",
                value: "9 am - 6 pm",
                bgColor: Color(0xFFF4F0FF),
                borderColor: Color(0xFFD9CCFF),
                valueColor: Color(0xFF6A1B9A),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHourSummaryWidget(BuildContext context) {
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
                  "Working Hour Summary",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              summaryOverallWidget(title: "This Week", subTitle: "42h"),
              summaryOverallWidget(
                title: "Overtime",
                subTitle: "8h",
                color: AppColor.yellow,
              ),
              summaryOverallWidget(title: "Avg Daily", subTitle: "8.2h"),
            ],
          ),
          const SizedBox(height: 30),
          _buildDayWiseProgress(),
        ],
      ),
    );
  }

  Widget _buildTeamAttendanceSummaryWidget(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [AttendanceRadialChart(present: 8, absent: 3, leave: 1)],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalanceSummaryWidget(BuildContext context) {
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
                  "Leave Balance",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _leaveRow(title: "Total Leaves", value: "24"),
          _leaveRow(title: "Used Leaves", value: "20"),
          _leaveRow(title: "Pending Leaves", value: "04"),
          const SizedBox(height: 20),
          Text(
            "Upcoming Approved",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          _buildUpcomingAttendanceWidget(
            title: "Casual Leave",
            value: "",
            subtitle: "Feb 14-16, 2024 (3 days)",
            bgColor: Color(0xFFEFFAF3),
            borderColor: Color(0xFFB7E4C7),
          ),
        ],
      ),
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
    return Container(
      height: 300.0,
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
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              shrinkWrap: true,
              itemBuilder: (context, int index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: AppColor.lightPurple.withValues(alpha: 0.50),
                    border: Border.all(width: 1, color: AppColor.lightPurple),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Labour’s Day", style: AppTextStyle.ts14M()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Feb 22 , Monday",
                            style: AppTextStyle.ts12R(
                              color: AppColor.black.withValues(alpha: 0.50),
                            ),
                          ),
                          Text(
                            "In 26 days",
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
          ),
        ],
      ),
    );
  }

  Widget _buildEventsAndMoreWidget(BuildContext context) {
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
          ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, int index) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColor.white,
                  backgroundImage: AssetImage(AppAssets.sampleCompanyImage),
                ),
                title: Text("data"),
              );
            },
          ),
        ],
      ),
    );
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
    return Column(
      children: const [
        DayWorkProgress(
          day: "Monday",
          worked: Duration(hours: 8, minutes: 53),
          target: Duration(hours: 9),
        ),
        DayWorkProgress(
          day: "Tuesday",
          worked: Duration(hours: 9, minutes: 10),
          target: Duration(hours: 9),
        ),
        DayWorkProgress(
          day: "Wednesday",
          worked: Duration(hours: 6, minutes: 10),
          target: Duration(hours: 9),
        ),
        DayWorkProgress(
          day: "Thursday",
          worked: Duration(hours: 9, minutes: 10),
          target: Duration(hours: 9),
        ),
        DayWorkProgress(
          day: "Friday",
          worked: Duration(hours: 9, minutes: 10),
          target: Duration(hours: 9),
        ),
      ],
    );
  }

  void _onProjectSelected(ProjectModel project) {
    _selectedProject = project;
    LocalStorageManager().setString(
      StorageKey.selectedProject,
      jsonEncode(project.toJson()),
    );
    showSuccessMessage(
      context,
      subTitle: "Project Selected ${project.projectName}",
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
  final String value;
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

  @override
  Widget build(BuildContext context) {
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
              Text(value, style: AppTextStyle.ts16SB(color: valueColor)),
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
    final progress = (worked.inSeconds / target.inSeconds).clamp(0.0, 1.0);

    String format(Duration d) =>
        "${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:00";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(day, style: AppTextStyle.ts14M()),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Grey track
                Container(
                  height: 22,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.lightGreyBackground,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                // Blue progress
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

class AttendanceRadialChart extends StatelessWidget {
  final int present;
  final int absent;
  final int leave;

  const AttendanceRadialChart({
    super.key,
    required this.present,
    required this.absent,
    required this.leave,
  });

  int get total => present + absent + leave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 110,
              width: 110,
              child: CustomPaint(
                painter: RadialPainter(
                  present: present,
                  absent: absent,
                  leave: leave,
                ),
                child: Center(
                  child: Text("$total", style: AppTextStyle.ts16SB()),
                ),
              ),
            ),
            const SizedBox(width: 30),
            // Legend
            SizedBox(
              height: 110, // SAME as chart
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: _legend(AppColor.primary, present, "Present"),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _legend(AppColor.blue, absent, "Absent"),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: _legend(AppColor.grey50, leave, "On Leave"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        verticalSpacing(height: 20.0),
        Text(
          "$total Total Employee",
          style: AppTextStyle.ts12SB(
            color: AppColor.black.withValues(alpha: 0.50),
          ),
        ),
      ],
    );
  }

  Widget _legend(Color color, int value, String text) {
    return Row(
      children: [
        Container(
          height: 14,
          width: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(width: 10),
        Text(value.toString().padLeft(2, '0'), style: AppTextStyle.ts16SB()),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyle.ts16M(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class RadialPainter extends CustomPainter {
  final int present;
  final int absent;
  final int leave;

  RadialPainter({
    required this.present,
    required this.absent,
    required this.leave,
  });

  final double stroke = 20;
  final double gapDegrees = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final total = present + absent + leave;

    final center = size.center(Offset.zero);
    final radius = size.width / 2.2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;

    // Total degrees available after gaps
    final usable = 360 - (gapDegrees * 3);

    final presentSweep = (present / total) * usable;
    final absentSweep = (absent / total) * usable;
    final leaveSweep = (leave / total) * usable;

    // ⭐ KEY: center PRESENT arc at top
    double start = -90 - (presentSweep / 2);

    void draw(Color color, double sweep) {
      paint.color = color;
      canvas.drawArc(rect, _deg(start), _deg(sweep), false, paint);
      start += sweep + gapDegrees;
    }

    draw(AppColor.primary, presentSweep); // Present
    draw(AppColor.blue, absentSweep); // Absent
    draw(AppColor.grey50, leaveSweep); // Leave
  }

  double _deg(double d) => d * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
