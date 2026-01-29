import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/cubit/payroll_report_cubit.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/widgets/payroll_report_expandable_card.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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

  // OUTDOOR PAGINATION
  late ScrollController _outdoorScrollController;
  Timer? _outdoorDebounce;

  @override
  void initState() {
    super.initState();
    _payrollReportCubit = context.read<PayrollReportCubit>();
    _searchC = TextEditingController();
    _selectedDateNotifier = ValueNotifier(DateTime.now());
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
    _outdoorScrollController = ScrollController();
    _setupOutdoorPagination();
    _selectedDateNotifier.addListener(_onSelectedDateChanged);
    _loadDataForTab(_tabController.index);
  }

  @override
  void dispose() {
    _selectedDateNotifier.removeListener(_onSelectedDateChanged);
    _tabController.dispose();
    _searchC.dispose();
    _selectedDateNotifier.dispose();
    _outdoorDebounce?.cancel();
    _outdoorScrollController.dispose();
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
    _selectedDateNotifier.value =
        _selectedDateNotifier.value.add(const Duration(days: 1));
  }

  // BACK ARROW CLICKED
  void _onBackArrowClicked() {
    _selectedDateNotifier.value =
        _selectedDateNotifier.value.subtract(const Duration(days: 1));
  }

  // WHEN SELECTED DATE CHANGES, REFETCH CURRENT TAB DATA
  void _onSelectedDateChanged() {
    final date = _selectedDateNotifier.value;
    if (_tabController.index == 4) {
      _payrollReportCubit.getOutdoorList(
        context,
        1,
        startDate: date,
        endDate: date,
      );
    }
  }

  // LOAD DATA BASED ON CURRENT TAB
  void _loadDataForTab(int index) {
    final date = _selectedDateNotifier.value;
    switch (index) {
      // 0 - Attendance
      // 1 - Regularize
      // 2 - Comp-Off
      // 3 - Leave
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
      // 5 - Resignation
      default:
        break;
    }
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Report",
        authorization: AuthorizationModel(),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchWidget(onSubmit: (value) {}, textController: _searchC),
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
          )
        ],
      ),
    );
  }

  // BUILD ATTENDANCE SECTION
  Widget buildAttendanceSection() {
    return Container(
      color: AppColor.lightBlue,
      child: Center(child: Text("Attendance Section")),
    );
  }

  // BUILD REGULARIZE SECTION
  Widget buildRegularizeSection() {
    return Container(
      child: Center(child: Text("Regularize Section")),
    );
  }

  // BUILD COMP-OFF SECTION
  Widget buildCompOffSection() {
    return Container(
      child: Center(child: Text("Comp-Off Section")),
    );
  }

  // BUILD LEAVE SECTION
  Widget buildLeaveSection() {
    return Container(
      child: Center(child: Text("Leave Section")),
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
              return state.outdoorList.length <
                      state.totalNumberOfRecordOutdoor
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            final outdoor = state.outdoorList[index];

            return PayrollReportExpandableCard(
              title: outdoor.createdBy,
              subtitle: outdoor.departmentName,
              expandedContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  buildRowTitleValue(
                    title: "Purpose",
                    value: outdoor.purpose,
                  ),
                  if (outdoor.conclusion.isNotEmpty) ...[
                    buildRowTitleValue(
                      title: "Conclusion",
                      value: outdoor.conclusion,
                    ),
                  ],
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
    return Container(
      child: Center(child: Text("Resignation Section")),
    );
  }


}
