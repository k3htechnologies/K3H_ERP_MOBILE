import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/cubit/payroll_report_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PayrollReportScreen extends StatefulWidget {
  const PayrollReportScreen({super.key});

  @override
  State<PayrollReportScreen> createState() => _PayrollReportScreenState();
}

class _PayrollReportScreenState extends State<PayrollReportScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late PayrollReportCubit _payrollReportCubit;

  // TEXT CONTROLLER
  late TextEditingController _searchC;

  // SELECTED DATE
  late ValueNotifier<DateTime> _selectedDateNotifier;

  // ATTENDANCE PAGINATION
  late ScrollController _attendanceScrollController;
  Timer? _attendanceDebounce;

  //COMPOFF PAGINATION
  late ScrollController _regularizationScrollerController;
  Timer? _regurizationDebounce;

  //COMPOFF PAGINATION
  late ScrollController _compOffScrollerController;
  Timer? _compOffDebounce;

  // LEAVE PAGINATION
  late ScrollController _leaveScrollController;
  Timer? _leaveDebounce;

  // OUTDOOR PAGINATION
  late ScrollController _outdoorScrollController;
  Timer? _outdoorDebounce;

  // RESIGNATION PAGINATION
  late ScrollController _resignationScrollController;
  Timer? _resignationDebounce;

  @override
  void initState() {
    super.initState();
    _payrollReportCubit = context.read<PayrollReportCubit>();
    _searchC = TextEditingController();
    _selectedDateNotifier = ValueNotifier(DateTime.now());
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
    _attendanceScrollController = ScrollController();
    _regularizationScrollerController = ScrollController();
    _compOffScrollerController = ScrollController();
    _leaveScrollController = ScrollController();
    _outdoorScrollController = ScrollController();
    _resignationScrollController = ScrollController();
    _setupAttendancePagination();
    _setupRegularizationPagination();
    _setupCompOffPagination();
    _setupLeavePagination();
    _setupOutdoorPagination();
    _setupResignationPagination();
    _selectedDateNotifier.addListener(_onSelectedDateChanged);
    _loadDataForTab(_tabController.index);
  }

  @override
  void dispose() {
    _selectedDateNotifier.removeListener(_onSelectedDateChanged);
    _tabController.dispose();
    _searchC.dispose();
    _selectedDateNotifier.dispose();
    _attendanceDebounce?.cancel();
    _leaveDebounce?.cancel();
    _outdoorDebounce?.cancel();
    _resignationDebounce?.cancel();
    _attendanceScrollController.dispose();
    _leaveScrollController.dispose();
    _outdoorScrollController.dispose();
    _resignationScrollController.dispose();
    super.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final index = _tabController.index;
      _payrollReportCubit.onTabChanged(index, context);
      _loadDataForTab(index);
    }
  }

  // FORWARD ARROW CLICKED
  void _onForwardArrowClicked() {
    _selectedDateNotifier.value = _selectedDateNotifier.value.add(
      const Duration(days: 1),
    );
  }

  // BACK ARROW CLICKED
  void _onBackArrowClicked() {
    _selectedDateNotifier.value = _selectedDateNotifier.value.subtract(
      const Duration(days: 1),
    );
  }

  // WHEN SELECTED DATE CHANGES, REFETCH CURRENT TAB DATA
  void _onSelectedDateChanged() {
    final date = _selectedDateNotifier.value;
    switch (_tabController.index) {
      case 0:
        _payrollReportCubit.getAttendanceList(
          context,
          1,
          startDate: date,
          endDate: date,
        );
        break;
      case 1:
        _payrollReportCubit.getAttendanceRegularizationList(
          context,
          1,
          startDate: date,
          endDate: date,
        );
      case 2:
        _payrollReportCubit.getCompOffList(
          context,
          1,
          startDate: date,
          endDate: date,
        );

      case 3:
        _payrollReportCubit.getLeaveList(
          context: context,
          pageNumber: 1,
          startDate: date,
          endDate: date,
        );
        break;
      case 4:
        _payrollReportCubit.getOutdoorList(
          context,
          1,
          startDate: date,
          endDate: date,
        );
        break;
      case 5:
        _payrollReportCubit.getResignationList(
          context,
          1,
          startDate: date,
          endDate: date,
        );
        break;
      default:
        break;
    }
  }

  // LOAD DATA BASED ON CURRENT TAB
  void _loadDataForTab(int index) {
    final date = _selectedDateNotifier.value;
    switch (index) {
      case 0: // Attendance
        if (_payrollReportCubit.state.attendanceList.isEmpty) {
          _payrollReportCubit.getAttendanceList(
            context,
            1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      case 1: // Regularize
        if (_payrollReportCubit.state.regularizationList.isEmpty) {
          _payrollReportCubit.getAttendanceRegularizationList(
            context,
            1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      case 2: //Comp Off
        if (_payrollReportCubit.state.compOffList.isEmpty) {
          _payrollReportCubit.getCompOffList(
            context,
            1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      case 3: // Leave
        if (_payrollReportCubit.state.leaveList.isEmpty) {
          _payrollReportCubit.getLeaveList(
            context: context,
            pageNumber: 1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      case 4: // Outdoor
        if (_payrollReportCubit.state.outdoorList.isEmpty) {
          _payrollReportCubit.getOutdoorList(
            context,
            1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      case 5: // Resignation
        if (_payrollReportCubit.state.resignationList.isEmpty) {
          _payrollReportCubit.getResignationList(
            context,
            1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      default:
        break;
    }
  }

  // <---- ATTENDANCE PAGINATION ---->
  void _setupAttendancePagination() {
    _attendanceScrollController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_attendanceScrollController.position.pixels >=
              _attendanceScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.attendanceList.length < state.totalNumberOfRecordAttendance) {
        if (_attendanceDebounce?.isActive ?? false) {
          _attendanceDebounce?.cancel();
        }
        final date = _selectedDateNotifier.value;
        _attendanceDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getAttendanceList(
            context,
            state.currentPageAttendance + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  // <---- REGULARIZATION PAGINATION ---->
  void _setupRegularizationPagination() {
    _regularizationScrollerController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_regularizationScrollerController.position.pixels >=
              _regularizationScrollerController.position.maxScrollExtent -
                  100 &&
          !(state.isLoading ?? false) &&
          state.regularizationList.length <
              state.totalNumberOfRecordRegurization) {
        if (_regurizationDebounce?.isActive ?? false) {
          _regurizationDebounce?.cancel();
        }
        final date = _selectedDateNotifier.value;
        _regurizationDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getAttendanceRegularizationList(
            context,
            state.currentPageRegurization + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  // <---- COMPOFF PAGINATION ---->
  void _setupCompOffPagination() {
    _compOffScrollerController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_compOffScrollerController.position.pixels >=
              _compOffScrollerController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.compOffList.length < state.totalNumberOfRecordCompOff) {
        if (_compOffDebounce?.isActive ?? false) _compOffDebounce?.cancel();
        final date = _selectedDateNotifier.value;
        _compOffDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getCompOffList(
            context,
            state.currentPageCompOff + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  // <---- LEAVE PAGINATION ---->
  void _setupLeavePagination() {
    _leaveScrollController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_leaveScrollController.position.pixels >=
              _leaveScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.leaveList.length < state.totalNumberOfRecordLeave) {
        if (_leaveDebounce?.isActive ?? false) _leaveDebounce?.cancel();
        final date = _selectedDateNotifier.value;
        _leaveDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getLeaveList(
            context: context,
            pageNumber: state.currentPageLeave + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  // <---- OUTDOOR PAGINATION ---->
  void _setupOutdoorPagination() {
    _outdoorScrollController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_outdoorScrollController.position.pixels >=
              _outdoorScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.outdoorList.length < state.totalNumberOfRecordOutdoor) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_outdoorDebounce?.isActive ?? false) _outdoorDebounce?.cancel();
        final date = _selectedDateNotifier.value;
        _outdoorDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getOutdoorList(
            context,
            state.currentPageOutdoor + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  // <---- RESIGNATION PAGINATION ---->
  void _setupResignationPagination() {
    _resignationScrollController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_resignationScrollController.position.pixels >=
              _resignationScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.resignationList.length < state.totalNumberOfRecordResignation) {
        if (_resignationDebounce?.isActive ?? false) {
          _resignationDebounce?.cancel();
        }
        final date = _selectedDateNotifier.value;
        _resignationDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getResignationList(
            context,
            state.currentPageResignation + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Report",
        authorization: AuthorizationModel(),
        isMenuButton: true,
      ),
      body: Column(
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
                  tabs: const [
                    Tab(text: 'Attendance'),
                    Tab(text: 'Regularize'),
                    Tab(text: 'Comp-Off'),
                    Tab(text: 'Leave'),
                    Tab(text: 'Outdoor'),
                    Tab(text: 'Resignation'),
                  ],
                ),
              ),
            ),
          ),
          verticalSpacing(),
          BlocBuilder<PayrollReportCubit, PayrollReportState>(
            builder: (context, state) {
              if (state.currentTabIndex == 0) {
                return SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchWidget(
                  onSubmit: (value) {},
                  textController: _searchC,
                ),
              );
            },
          ),
          verticalSpacing(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _onBackArrowClicked();
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: AppColor.black.withValues(alpha: .5),
                  ),
                ),
                horizontalSpacing(width: 20),
                ValueListenableBuilder<DateTime>(
                  valueListenable: _selectedDateNotifier,
                  builder: (context, date, _) {
                    return Text(
                      formatDateTimeAsDDMMMYYYY(date),
                      style: AppTextStyle.ts14M(),
                    );
                  },
                ),
                horizontalSpacing(width: 20),
                InkWell(
                  onTap: () {
                    _onForwardArrowClicked();
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: AppColor.black.withValues(alpha: .5),
                  ),
                ),
              ],
            ),
          ),
          verticalSpacing(height: 15),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildAttendanceSection(),
                buildRegularizeSection(),
                buildCompOffSection(),
                buildLeaveSection(),
                buildOutdoorSection(),
                buildResignationSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUILD ATTENDANCE SECTION
  Widget buildAttendanceSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.attendanceList.isEmpty) {
          return Center(child: loader());
        }

        if (state.attendanceList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _attendanceScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.attendanceList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.attendanceList.length) {
              return state.attendanceList.length <
                      state.totalNumberOfRecordAttendance
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final attendance = state.attendanceList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attendance.fullName,
                              style: AppTextStyle.ts16SB(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Attendance Date: ",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  formatDateTimeAsDDMMMYYYY(
                                    attendance.attendanceDate,
                                  ),
                                  style: AppTextStyle.ts12R(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _statusButton(attendance.attendanceStatus),
                    ],
                  ),
                  verticalSpacing(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Punch In",
                        value:
                            attendance.punchIn != null
                                ? DateFormat(
                                  'hh:mm a',
                                ).format(attendance.punchIn!)
                                : "-",
                      ),
                      buildColumnTitleValue(
                        title: "Punch In Address",
                        value:
                            attendance.punchInAddress.isEmpty
                                ? "-"
                                : attendance.punchInAddress,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Punch Out",
                        value:
                            attendance.punchOut != null
                                ? DateFormat(
                                  'hh:mm a',
                                ).format(attendance.punchOut!)
                                : "-",
                      ),
                      buildColumnTitleValue(
                        title: "Punch Out Address",
                        value:
                            attendance.punchOutAddress.isEmpty
                                ? "-"
                                : attendance.punchOutAddress,
                      ),
                    ],
                  ),
                  buildRowTitleValue(
                    title: "Working Hours",
                    value: attendance.workingHours,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD REGULARIZE SECTION
  Widget buildRegularizeSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.regularizationList.isEmpty) {
          return Center(child: loader());
        }

        if (state.regularizationList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _regularizationScrollerController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.regularizationList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.regularizationList.length) {
              return state.regularizationList.length <
                      state.totalNumberOfRecordRegurization
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final attendanceRegularize = state.regularizationList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Employee Name",
                            style: AppTextStyle.ts16M(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Designation",
                            style: AppTextStyle.ts14M(color: AppColor.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      _statusButton(''),
                    ],
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Punch In",
                    value:
                        attendanceRegularize.punchIn != null
                            ? DateFormat(
                              'hh:mm a',
                            ).format(attendanceRegularize.punchIn!)
                            : "-",
                  ),
                  buildRowTitleValue(
                    title: "Punch Out",
                    value:
                        attendanceRegularize.punchOut != null
                            ? DateFormat(
                              'hh:mm a',
                            ).format(attendanceRegularize.punchOut!)
                            : "-",
                  ),
                  buildRowTitleValue(
                    title: "Date",
                    value: formatDateTimeAsDDMMMYYYY(
                      attendanceRegularize.attendanceDate,
                    ),
                  ),
                  buildRowTitleValue(
                    title: "Reason",
                    value: attendanceRegularize.reason,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD COMP-OFF SECTION
  Widget buildCompOffSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.compOffList.isEmpty) {
          return Center(child: loader());
        }

        if (state.compOffList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _compOffScrollerController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.compOffList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.compOffList.length) {
              return state.compOffList.length < state.totalNumberOfRecordCompOff
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final compOff = state.compOffList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: NetworkImageWidget(
                            imageUrl:
                                "https://plus.unsplash.com/premium_photo-1667358091118-29e916ddbcc5?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fGh1c2t5fGVufDB8fDB8fHww",
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(55),
                          ),
                          title: Text('Employee Name'),
                          subtitle: Text(
                            "Designation",
                            style: AppTextStyle.ts14M(color: AppColor.grey),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      _statusButton(''),
                    ],
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "CompOff Date",
                    value: formatDateTimeAsDDMMMYYYY(compOff.compOffDate),
                  ),
                  buildRowTitleValue(
                    title: "Working Date",
                    value: formatDateTimeAsDDMMMYYYY(compOff.workingDate),
                  ),
                  buildRowTitleValue(title: "Reason", value: compOff.reason),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD LEAVE SECTION
  Widget buildLeaveSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.leaveList.isEmpty) {
          return Center(child: loader());
        }

        if (state.leaveList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _leaveScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.leaveList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.leaveList.length) {
              return state.leaveList.length < state.totalNumberOfRecordLeave
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final leave = state.leaveList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leave.createdBy,
                    style: AppTextStyle.ts16M(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Leave Type",
                    value: leave.leaveType,
                  ),
                  buildRowTitleValue(
                    title: "Start Date",
                    value: formatDateTimeAsDDMMMYYYY(leave.startDate),
                  ),
                  buildRowTitleValue(
                    title: "End Date",
                    value: formatDateTimeAsDDMMMYYYY(leave.endDate),
                  ),
                  buildRowTitleValue(
                    title: "No Of Days",
                    value: leave.noOfDays.toString(),
                  ),
                  buildRowTitleValue(title: "Reason", value: leave.reason),
                  buildRowTitleValue(
                    title: "Leave Status",
                    value: leave.leaveStatus,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD OUTDOOR SECTION
  Widget buildOutdoorSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.outdoorList.isEmpty) {
          return Center(child: loader());
        }

        if (state.outdoorList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _outdoorScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.outdoorList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.outdoorList.length) {
              return state.outdoorList.length < state.totalNumberOfRecordOutdoor
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final outdoor = state.outdoorList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outdoor.createdBy,
                    style: AppTextStyle.ts16M(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Date",
                    value: formatDateTimeAsDDMMMYYYY(outdoor.outDoorDate),
                  ),
                  buildRowTitleValue(
                    title: "Time",
                    value: DateFormat('hh:mm a').format(outdoor.outDoorTime),
                  ),
                  buildRowTitleValue(
                    title: "Company",
                    value: outdoor.companyName,
                  ),
                  buildRowTitleValue(
                    title: "Department",
                    value: outdoor.departmentName,
                  ),
                  buildRowTitleValue(
                    title: "Accompanied By",
                    value: outdoor.accompaniedByName,
                  ),
                  buildRowTitleValue(title: "Purpose", value: outdoor.purpose),
                  if (outdoor.conclusion.isNotEmpty)
                    buildRowTitleValue(
                      title: "Conclusion",
                      value: outdoor.conclusion,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD RESIGNATION SECTION
  Widget buildResignationSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.resignationList.isEmpty) {
          return Center(child: loader());
        }

        if (state.resignationList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _resignationScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.resignationList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.resignationList.length) {
              return state.resignationList.length <
                      state.totalNumberOfRecordResignation
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final resignation = state.resignationList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          resignation.employeeName,
                          style: AppTextStyle.ts16M(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusButton(resignation.approvalStatus),
                    ],
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Resignation Date",
                    value: formatDateTimeAsDDMMMYYYY(
                      resignation.resignationDate,
                    ),
                  ),
                  buildRowTitleValue(
                    title: "Expected Relieving Date",
                    value: formatDateTimeAsDDMMMYYYY(
                      resignation.expectedRelievingDate,
                    ),
                  ),
                  buildRowTitleValue(
                    title: "Reason Of Leaving",
                    value: resignation.reasonOfLeaving,
                  ),
                  buildRowTitleValue(
                    title: "Offer In Hand",
                    value: resignation.isAnyOfferInHand ? "Yes" : "No",
                  ),
                  buildRowTitleValue(
                    title: "Offer Amount",
                    value: resignation.offerAmount.toString(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // HELPER WIDGET FOR STATE
  Widget _statusButton(String status) {
    String status;
    status = '';

    late String buttonText;
    late Color bgColor;
    late Color textColor;

    switch (status) {
      default:
        buttonText = "Pending";
        bgColor = AppColor.darkBlue;
        textColor = AppColor.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(buttonText, style: AppTextStyle.ts14M(color: textColor)),
    );
  }
}
