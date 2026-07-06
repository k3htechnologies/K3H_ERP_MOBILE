import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/data/model/performance_report_closing.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/data/model/performance_report_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/presentation/cubit/performance_cubit.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewPerformanceScreen extends StatefulWidget {
  final PerformanceReportSourcingModel? sourcing;
  final PerformanceReportClosingModel? closing;
  const ViewPerformanceScreen({super.key, this.sourcing, this.closing});

  @override
  State<ViewPerformanceScreen> createState() => _ViewPerformanceScreenState();
}

class _ViewPerformanceScreenState extends State<ViewPerformanceScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late PerformanceCubit _performanceCubit;

  @override
  void initState() {
    super.initState();
    _performanceCubit = context.read<PerformanceCubit>();
    _tabController = TabController(
      length: widget.sourcing != null ? 4 : 2,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _performanceCubit.onTabChangedViewScreen(_tabController.index, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Performance",
        authorization: AuthorizationModel(),
      ),
      body:
          widget.sourcing != null
              ? _buildSourcingView(widget.sourcing!)
              : widget.closing != null
              ? _buildClosingView(widget.closing!)
              : const Center(child: Text("No Data")),
    );
  }

  // BUILD SOURCING VIEW
  Widget _buildSourcingView(PerformanceReportSourcingModel sourcing) {
    return BlocBuilder<PerformanceCubit, PerformanceState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: showSiteSelectedWidget(),
            ),
            ChipStyleTabBar(
              controller: _tabController,
              tabs: ["Walkins", "Bookings", "Meetings", "CPs"],
            ),
            verticalSpacing(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildWalkInsSection(sourcing),
                  _buildBookingsSection(sourcing),
                  _buildMeetingSection(sourcing),
                  _buildCPSection(sourcing),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // BUILD CLOSING VIEW
  Widget _buildClosingView(PerformanceReportClosingModel closing) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: showSiteSelectedWidget(),
        ),
        ChipStyleTabBar(
          controller: _tabController,
          tabs: ["Walkins", "Bookings"],
        ),
        verticalSpacing(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildWalkInsClosingSection(closing),
              _buildBookingsClosingSection(closing),
            ],
          ),
        ),
      ],
    );
  }

  // BUILD WALK INS SOURCING SECTION
  Widget _buildWalkInsSection(PerformanceReportSourcingModel sourcing) {
    return Column(
      children: [
        _buildCard(
          "Walkins By CP",
          sourcing.walkinsByCp,
          sourcing.actualWalkinsByCp,
          sourcing.performanceWalkinsByCp,
        ),
        _buildCard(
          "Fresh Visits",
          sourcing.freshVisits,
          sourcing.actualFreshVisits,
          sourcing.performanceFreshVisits,
        ),
        _buildCard(
          "Revisits",
          sourcing.revisits,
          sourcing.actualRevisits,
          sourcing.performanceRevisits,
        ),
      ],
    );
  }

  /// ---------------------------------- SOURCING TABS ----------------------------------------

  // BUILD BOOKINGS SOURCING SECTION
  Widget _buildBookingsSection(PerformanceReportSourcingModel sourcing) {
    return ListView(
      children: [
        _buildCard(
          "Bookings",
          sourcing.bookings,
          sourcing.actualBookings,
          sourcing.performanceBookings,
        ),
      ],
    );
  }

  // BUILD BOOKINGS SOURCING SECTION
  Widget _buildMeetingSection(PerformanceReportSourcingModel sourcing) {
    return ListView(
      children: [
        _buildCard(
          "Total Meetings",
          sourcing.totalMeetings,
          sourcing.actualTotalMeetings,
          sourcing.performanceTotalMeetings,
        ),
        _buildCard(
          "Total OBM",
          sourcing.totalObm,
          sourcing.actualTotalObm,
          sourcing.performanceTotalObm,
        ),
        _buildCard(
          "OBM Fresh Visits",
          sourcing.totalObmFreshVisits,
          sourcing.actualTotalObmFreshVisits,
          sourcing.performanceTotalObmFreshVisits,
        ),
        _buildCard(
          "OBM Revisits",
          sourcing.totalObmRevisits,
          sourcing.actualTotalObmRevisits,
          sourcing.performanceTotalObmRevisits,
        ),
        _buildCard(
          "Total IBM",
          sourcing.totalIbm,
          sourcing.actualTotalIbm,
          sourcing.performanceTotalIbm,
        ),
      ],
    );
  }

  // BUILD CPs SOURCING SECTION
  Widget _buildCPSection(PerformanceReportSourcingModel sourcing) {
    return ListView(
      children: [
        _buildCard(
          "Unique CPs",
          sourcing.uniqueCPs,
          sourcing.actualUniqueCPs,
          sourcing.performanceUniqueCPs,
        ),
        _buildCard(
          "Active CPs",
          sourcing.activeCp,
          sourcing.actualActiveCp,
          sourcing.performanceActiveCp,
        ),
        _buildCard(
          "New CP",
          sourcing.newCp,
          sourcing.actualNewCp,
          sourcing.performanceNewCp,
        ),
      ],
    );
  }

  // ---------------------------------- CLOSING TABS ----------------------------------------

  // BUILD WALK INS CLOSING SECTION
  Widget _buildWalkInsClosingSection(PerformanceReportClosingModel closing) {
    return ListView(
      children: [
        _buildCard(
          "Walkins By CP",
          closing.walkinsByCp,
          closing.actualWalkinsByCp,
          closing.performanceWalkinsByCp,
        ),
        _buildCard(
          "Walkins Direct",
          closing.walkinsDirect,
          closing.actualWalkinsDirect,
          closing.performanceWalkinsDirect,
        ),
        _buildCard(
          "Fresh Visits",
          closing.freshVisits,
          closing.actualFreshVisits,
          closing.performanceFreshVisits,
        ),
        _buildCard(
          "Revisits",
          closing.revisits,
          closing.actualRevisits,
          closing.performanceRevisits,
        ),
      ],
    );
  }

  // BUILD BOOKINGS CLOSING SECTION
  Widget _buildBookingsClosingSection(PerformanceReportClosingModel closing) {
    return ListView(
      children: [
        _buildCard(
          "Booking By CP",
          closing.bookingByCp,
          closing.actualBookingByCp,
          closing.performanceBookingByCp,
        ),
        _buildCard(
          "Booking Direct",
          closing.bookingDirect,
          closing.actualBookingDirect,
          closing.performanceBookingDirect,
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------------------------

  // HELPER CARD WIDGET
  Widget _buildCard(String title, int target, int actual, double performance) {
    return Container(
      decoration: commonCardDecoration(),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14SB()),
          verticalSpacing(height: 2),
          buildRowTitleValue(title: "Target", value: target.toString()),
          buildRowTitleValue(title: "Actual", value: actual.toString()),
          buildRowTitleValue(title: "Performance", value: "$performance%"),
        ],
      ),
    );
  }
}
