import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/cubit/visitor_management_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/pages/widgets/overview_widget.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class GatePassWiseDistributionScreen extends StatefulWidget {
  final String title;
  final GatePassFilter filter;
  const GatePassWiseDistributionScreen({
    super.key,
    required this.title,
    this.filter = GatePassFilter.all,
  });

  @override
  State<GatePassWiseDistributionScreen> createState() =>
      _GatePassWiseDistributionScreenState();
}

class _GatePassWiseDistributionScreenState
    extends State<GatePassWiseDistributionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: widget.title,
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: _buildUnitList())],
        ),
      ),
    );
  }

  Widget _buildUnitList() {
    return BlocBuilder<
      VisitorManagementDashboardCubit,
      VisitorManagementDashboardState
    >(
      builder: (context, state) {
        final dashboard =
            state.gatePassDashboardList.isNotEmpty
                ? state.gatePassDashboardList.first
                : null;
        final allVisitors = dashboard?.table1 ?? [];
        final visitors =
            allVisitors.where((v) => widget.filter.matches(v.status)).toList();

        if ((state.isLoading ?? false) && visitors.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (visitors.isEmpty) {
          return Center(child: noDataWidget(message: "No units found"));
        }

        return ListView.builder(
          itemCount: visitors.length,
          itemBuilder: (context, index) {
            final visitor = visitors[index];

            return Container(
              decoration: commonCardDecoration(),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  buildRowTitleValue(
                    title: "Visitor Name",
                    value: visitor.visitorName,
                  ),
                  buildRowTitleValue(
                    title: "Mobile Number",
                    value: visitor.contact,
                  ),
                  buildRowTitleValue(
                    title: "Appointment With",
                    value: visitor.appointmentWith,
                  ),
                  buildRowTitleValue(
                    title: "Purpose",
                    value: visitor.purpose,
                    customValueWidget: visitorManagementStatusWidget(
                      visitor.purpose,
                    ),
                  ),
                  buildRowTitleValue(
                    title: "Check-In Time",
                    value: formatTime(visitor.checkInTime),
                  ),
                  buildRowTitleValue(
                    title: "Check-Out Time",
                    value: formatTime(visitor.checkOutTime),
                  ),
                  buildRowTitleValue(
                    title: "Status",
                    value: visitor.status,
                    customValueWidget: gatePassStatusWidget(visitor.status),
                  ),
                  buildRowTitleValue(
                    title: "Remark",
                    value: visitor.remark.isEmpty ? "-" : visitor.remark,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
