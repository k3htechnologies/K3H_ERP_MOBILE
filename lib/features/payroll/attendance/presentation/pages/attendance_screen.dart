import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/features/payroll/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late AttendanceCubit _attendanceCubit;

  // DATE STATE (ValueNotifiers instead of setState)
  late final ValueNotifier<DateTime> _selectedDate; // for weekly / monthly
  late final ValueNotifier<DateTime> _visibleMonth; // for monthly view

  // WEEKLY EXPANSION STATE
  late final ValueNotifier<int> _expandedWeekIndex;

  @override
  void initState() {
    super.initState();
    _attendanceCubit = context.read<AttendanceCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _selectedDate = ValueNotifier<DateTime>(DateTime.now());
    _visibleMonth = ValueNotifier<DateTime>(
      DateTime(_selectedDate.value.year, _selectedDate.value.month, 1),
    );
    _expandedWeekIndex = ValueNotifier<int>(-1);

    // INITIAL LOAD - weekly data by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeeklyData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedDate.dispose();
    _visibleMonth.dispose();
    _expandedWeekIndex.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _attendanceCubit.onTabChanged(_tabController.index, context);
      if (_tabController.index == 0) {
        _loadWeeklyData();
      } else {
        _loadMonthlyData();
      }
    }
  }

  // LOAD WEEKLY DATA (Mon-Sun around selected date)
  void _loadWeeklyData() {
    final DateTime weekStart = _selectedDate.value.subtract(
      Duration(days: _selectedDate.value.weekday - 1),
    );
    final DateTime weekEnd = weekStart.add(const Duration(days: 6));
    _attendanceCubit.getDepartmentList(context, 1, weekStart, weekEnd);
  }

  // LOAD MONTHLY DATA (first..last day of visible month)
  void _loadMonthlyData() {
    final DateTime start = DateTime(
      _visibleMonth.value.year,
      _visibleMonth.value.month,
      1,
    );
    final DateTime end = DateTime(
      _visibleMonth.value.year,
      _visibleMonth.value.month + 1,
      0,
      23,
      59,
    );
    _attendanceCubit.getDepartmentList(context, 1, start, end);
  }

  void _goToPreviousWeek() {
    _selectedDate.value = _selectedDate.value.subtract(const Duration(days: 7));
    _expandedWeekIndex.value = -1;
    _loadWeeklyData();
  }

  void _goToNextWeek() {
    _selectedDate.value = _selectedDate.value.add(const Duration(days: 7));
    _expandedWeekIndex.value = -1;
    _loadWeeklyData();
  }

  void _goToPreviousMonth() {
    _visibleMonth.value = DateTime(
      _visibleMonth.value.year,
      _visibleMonth.value.month - 1,
      1,
    );
    _loadMonthlyData();
  }

  void _goToNextMonth() {
    _visibleMonth.value = DateTime(
      _visibleMonth.value.year,
      _visibleMonth.value.month + 1,
      1,
    );
    _loadMonthlyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Attendance",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColor.primary,
                    unselectedLabelColor: AppColor.grey,
                    indicator: BoxDecoration(
                      color: AppColor.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.ts14M(),
                    unselectedLabelStyle: AppTextStyle.ts14M(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.zero,
                    tabs: const [Tab(text: 'Weekly'), Tab(text: 'Monthly')],
                  ),
                ),
              ),
            ),
            verticalSpacing(height: 16),
            Expanded(
              child: ValueListenableBuilder<DateTime>(
                valueListenable: _selectedDate,
                builder: (context, selectedDate, _) {
                  return ValueListenableBuilder<DateTime>(
                    valueListenable: _visibleMonth,
                    builder: (context, visibleMonth, __) {
                      return ValueListenableBuilder<int>(
                        valueListenable: _expandedWeekIndex,
                        builder: (context, expandedIndex, ___) {
                          return BlocBuilder<AttendanceCubit, AttendanceState>(
                            builder: (context, state) {
                              if ((state.isLoading ?? true) &&
                                  state.attendanceList.isEmpty) {
                                return Center(child: loader());
                              }
                              if (state.currentTabIndex == 0) {
                                if (state.attendanceList.isEmpty) {
                                  return Center(child: noDataWidget());
                                }
                                return _buildWeeklyContent(
                                  state,
                                  selectedDate,
                                  expandedIndex,
                                );
                              }
                              // For monthly view, always show calendar; it will simply
                              // render without colored statuses if there's no data.
                              return _buildMonthlyContent(
                                state,
                                selectedDate,
                                visibleMonth,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WEEKLY CONTENT
  Widget _buildWeeklyContent(
    AttendanceState state,
    DateTime selectedDate,
    int expandedIndex,
  ) {
    // Compute week start based on selectedDate
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final days = List<DateTime>.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week header with arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _goToPreviousWeek,
                child: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(days.length, (index) {
                    final date = days[index];
                    return Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('E').format(date).toUpperCase(),
                            style: AppTextStyle.ts12M(color: AppColor.grey),
                          ),
                          verticalSpacing(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColor.grey30),
                            ),
                            child: Text(
                              DateFormat('d').format(date),
                              style: AppTextStyle.ts12M(color: AppColor.black),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              GestureDetector(
                onTap: _goToNextWeek,
                child: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ],
          ),
          verticalSpacing(height: 16),
          Expanded(
            child: ListView.builder(
              // One card per record; we align them to the *last* N days
              // in the visible week. So if the API returns only 27–31
              // for a 26–31 range, cards appear only from 27–31.
              itemCount: state.attendanceList.length,
              itemBuilder: (context, index) {
                final totalDays = days.length;
                final totalRecords = state.attendanceList.length;
                final startOffset =
                    totalRecords < totalDays ? totalDays - totalRecords : 0;

                final currentDate = days[startOffset + index];
                final item = state.attendanceList[index];

                final dayLabel = DateFormat('d MMMM').format(currentDate);
                final statusConfig = _statusConfig(item.attendanceStatus);
                final bool isExpandedDay = index == expandedIndex;

                return GestureDetector(
                  onTap: () {
                    _expandedWeekIndex.value = isExpandedDay ? -1 : index;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.only(
                      left: 0,
                      right: 12,
                      top: 8,
                      bottom: 8,
                    ),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              // Colored status strip flush with card edge
                              Container(
                                width: 3,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: statusConfig.borderColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(2),
                                    bottomLeft: Radius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dayLabel,
                                        style: AppTextStyle.ts14M(),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusConfig.backgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: statusConfig.borderColor,
                                          ),
                                        ),
                                        child: Text(
                                          statusConfig.label,
                                          style: AppTextStyle.ts12M(
                                            color: statusConfig.textColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isExpandedDay
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColor.grey,
                              ),
                            ],
                          ),
                        ),
                        ClipRect(
                          child: AnimatedAlign(
                            alignment: Alignment.topCenter,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            heightFactor: isExpandedDay ? 1 : 0,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                    "Punch In",
                                    item.punchIn != null
                                        ? DateFormat(
                                          'hh:mm a',
                                        ).format(item.punchIn!)
                                        : "--",
                                  ),
                                  if (item.punchInAddress.isNotEmpty)
                                    _buildDetailRow(
                                      "Punch In Address",
                                      item.punchInAddress,
                                    ),
                                  _buildDetailRow(
                                    "Punch Out",
                                    item.punchOut != null
                                        ? DateFormat(
                                          'hh:mm a',
                                        ).format(item.punchOut!)
                                        : "--",
                                  ),
                                  if (item.punchOutAddress.isNotEmpty)
                                    _buildDetailRow(
                                      "Punch Out Address",
                                      item.punchOutAddress,
                                    ),
                                  if (item.workingHours.isNotEmpty)
                                    _buildDetailRow(
                                      "Working Hours",
                                      item.workingHours,
                                    ),
                                  verticalSpacing(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // MONTHLY CONTENT
  Widget _buildMonthlyContent(
    AttendanceState state,
    DateTime selectedDate,
    DateTime visibleMonth,
  ) {
    print("Selected Date: $selectedDate");
    final firstDayOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday -> 0
    final totalGridItems = startWeekday + daysInMonth;
    final rows = (totalGridItems / 7).ceil();
    final paddedItemCount = rows * 7;
    String? punchInTime;
    String? punchOutTime;
    // Helper to get attendance by day-of-month index (backend is expected
    // to return records in order from start to end date).
    AttendanceModel? attendanceForDay(DateTime date) {
      final dayIndex = date.day - 1;
      if (dayIndex < 0 || dayIndex >= state.attendanceList.length) {
        return null;
      }
      return state.attendanceList[dayIndex];
    }

    final AttendanceModel? selectedAttendance =
        selectedDate.month == visibleMonth.month &&
                selectedDate.year == visibleMonth.year
            ? attendanceForDay(selectedDate)
            : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _goToPreviousMonth,
                child: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              Text(
                DateFormat('MMMM').format(visibleMonth),
                style: AppTextStyle.ts16SB(),
              ),
              GestureDetector(
                onTap: _goToNextMonth,
                child: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: AppTextStyle.ts12M(color: AppColor.grey),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          verticalSpacing(),
          SizedBox(
            height: 280,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: paddedItemCount,
              itemBuilder: (context, index) {
                DateTime? currentDate;
                bool isOutOfMonth = false;

                if (index < startWeekday) {
                  isOutOfMonth = true;
                } else if (index >= startWeekday + daysInMonth) {
                  isOutOfMonth = true;
                } else {
                  final day = index - startWeekday + 1;
                  currentDate = DateTime(
                    visibleMonth.year,
                    visibleMonth.month,
                    day,
                  );
                }

                if (currentDate == null) {
                  return const SizedBox.shrink();
                }

                // Normalize today to date-only for comparisons
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final bool isFutureDate = currentDate.isAfter(today);
                final bool isTodayDate =
                    currentDate.year == today.year &&
                    currentDate.month == today.month &&
                    currentDate.day == today.day;

                // For future dates, show plain text only (no decoration/status)
                if (isFutureDate) {
                  return Center(
                    child: Text(
                      DateFormat('dd').format(currentDate),
                      style: AppTextStyle.ts12M(color: AppColor.grey),
                    ),
                  );
                }

                final attendance = attendanceForDay(currentDate);
                final statusConfig =
                    attendance != null
                        ? _statusConfig(attendance.attendanceStatus)
                        : null;

                final bool isCheckoutMissing =
                    attendance != null &&
                    attendance.attendanceStatus.toLowerCase() ==
                        "checkout missing";
                final bool isAbsent =
                    attendance != null &&
                    attendance.attendanceStatus.toLowerCase() == "absent";

                return GestureDetector(
                  onTap: () {
                    if (isCheckoutMissing ||
                        isAbsent && selectedAttendance != null) {
                      _selectedDate.value = currentDate!;
                      DialogHelper.showCustomBottomSheet(
                        context,
                        "Regularize",
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10,
                          ),
                          child: Column(
                            children: [
                              CustomTextField(
                                title: "Date",
                                readOnly: true,
                                textController: TextEditingController(
                                  text: formatDateTimeAsDDMMMYYYY(
                                    attendance.attendanceDate,
                                  ),
                                ),
                              ),

                              CustomTimePicker(
                                title: 'Punch In Time',
                                initialTime:
                                    (selectedAttendance != null &&
                                            selectedAttendance.punchIn != null)
                                        ? TimeOfDay(
                                          hour:
                                              selectedAttendance.punchIn!.hour,
                                          minute:
                                              selectedAttendance
                                                  .punchIn!
                                                  .minute,
                                        )
                                        : null,
                                setValue: (value) {
                                  punchInTime = formatTimeOfDayHHmm(value);
                                },
                              ),
                              CustomTimePicker(
                                title: 'Punch Out Time',
                                initialTime:
                                    attendance.punchOut != null
                                        ? TimeOfDay(
                                          hour: attendance.punchOut!.hour,
                                          minute: attendance.punchOut!.minute,
                                        )
                                        : null,
                                setValue: (value) {
                                  punchOutTime = formatTimeOfDayHHmm(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      _selectedDate.value = currentDate!;
                    }
                  },
                  child: Builder(
                    builder: (context) {
                      // Plain style for checkout missing
                      if (isCheckoutMissing) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColor.error.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColor.error, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              DateFormat('dd').format(currentDate!),
                              style: AppTextStyle.ts12M(color: AppColor.error),
                            ),
                          ),
                        );
                      }

                      if (isAbsent) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColor.grey.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColor.grey, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              DateFormat('dd').format(currentDate!),
                              style: AppTextStyle.ts12M(color: AppColor.grey),
                            ),
                          ),
                        );
                      }

                      // Highlight current date similar to blue filled circle
                      if (isTodayDate) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            DateFormat('dd').format(currentDate!),
                            style: AppTextStyle.ts12M(color: AppColor.white),
                          ),
                        );
                      }

                      // Status-based box with top bar (for non-checkout statuses)
                      if (statusConfig != null) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColor.grey30,
                              width: .5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: statusConfig.borderColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              verticalSpacing(),
                              Text(
                                DateFormat('dd').format(currentDate!),
                                style: AppTextStyle.ts12M(
                                  color:
                                      isOutOfMonth
                                          ? AppColor.grey30
                                          : AppColor.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // No attendance: plain text only
                      return Center(
                        child: Text(
                          DateFormat('dd').format(currentDate!),
                          style: AppTextStyle.ts12M(
                            color:
                                isOutOfMonth ? AppColor.grey30 : AppColor.black,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (selectedAttendance != null) ...[
            verticalSpacing(height: 6),
            Container(
              decoration: commonCardDecoration(),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // Use the calendar-selected date for header label so
                        // we are not affected by any default/incorrect
                        // AttendanceDate coming from API (e.g. 1 January 1970).
                        DateFormat('d MMMM').format(selectedDate),
                        style: AppTextStyle.ts14M(),
                      ),
                      Builder(
                        builder: (context) {
                          final config = _statusConfig(
                            selectedAttendance.attendanceStatus,
                          );
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: config.backgroundColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: config.borderColor),
                            ),
                            child: Text(
                              config.label,
                              style: AppTextStyle.ts12M(
                                color: config.textColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  verticalSpacing(height: 6),
                  _buildDetailRow(
                    "Punch In",
                    selectedAttendance.punchIn != null
                        ? DateFormat(
                          'hh:mm a',
                        ).format(selectedAttendance.punchIn!)
                        : "--",
                  ),
                  if (selectedAttendance.punchInAddress.isNotEmpty)
                    _buildDetailRow(
                      "Punch In Address",
                      selectedAttendance.punchInAddress,
                    ),

                  _buildDetailRow(
                    "Punch Out",
                    selectedAttendance.punchOut != null
                        ? DateFormat(
                          'hh:mm a',
                        ).format(selectedAttendance.punchOut!)
                        : "--",
                  ),
                  if (selectedAttendance.punchOutAddress.isNotEmpty)
                    _buildDetailRow(
                      "Punch Out Address",
                      selectedAttendance.punchOutAddress,
                    ),
                  if (selectedAttendance.workingHours.isNotEmpty)
                    _buildDetailRow(
                      "Working Hours",
                      selectedAttendance.workingHours,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$title :",
              style: AppTextStyle.ts12R(color: AppColor.grey),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyle.ts12R())),
        ],
      ),
    );
  }

  // STATUS COLOR CONFIG
  _AttendanceStatusConfig _statusConfig(String status) {
    switch (status.toLowerCase()) {
      case "present":
        return _AttendanceStatusConfig(
          label: "Present",
          textColor: AppColor.green,
          backgroundColor: AppColor.lightGreen,
          borderColor: AppColor.green,
        );
      case "early leave":
        return _AttendanceStatusConfig(
          label: "Early Leave",
          textColor: AppColor.warning,
          backgroundColor: AppColor.lightYellow,
          borderColor: AppColor.warning,
        );
      case "checkout missing":
        return _AttendanceStatusConfig(
          label: "Checkout Missing",
          textColor: AppColor.error,
          backgroundColor: AppColor.lightRed,
          borderColor: AppColor.error,
        );
      case "leave":
        return _AttendanceStatusConfig(
          label: "Leave",
          textColor: AppColor.red,
          backgroundColor: AppColor.lightRed,
          borderColor: AppColor.red,
        );
      case "week off":
        return _AttendanceStatusConfig(
          label: "Week Off",
          textColor: AppColor.blue,
          backgroundColor: AppColor.lightBlue2,
          borderColor: AppColor.blue,
        );
      case "late in":
        return _AttendanceStatusConfig(
          label: "Late In",
          textColor: AppColor.orange,
          backgroundColor: AppColor.orange.withValues(alpha: .2),
          borderColor: AppColor.orange,
        );
      case "compoff":
        return _AttendanceStatusConfig(
          label: "Comp Off",
          textColor: AppColor.purple,
          backgroundColor: AppColor.purple20,
          borderColor: AppColor.purple,
        );
      case "absent":
      default:
        return _AttendanceStatusConfig(
          label: "Absent",
          textColor: AppColor.grey,
          backgroundColor: AppColor.lightGreyBackground,
          borderColor: AppColor.grey30,
        );
    }
  }
}

class _AttendanceStatusConfig {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  _AttendanceStatusConfig({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
