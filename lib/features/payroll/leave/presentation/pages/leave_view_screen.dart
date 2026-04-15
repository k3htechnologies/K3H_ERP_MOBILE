import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/leave/model/leave.model.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/cubit/leave_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class LeaveViewScreen extends StatefulWidget {
  final LeaveModel leaveModel;
  const LeaveViewScreen({super.key, required this.leaveModel});

  @override
  State<LeaveViewScreen> createState() => _LeaveViewScreenState();
}

class _LeaveViewScreenState extends State<LeaveViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late LeaveCubit _leaveCubit;

  @override
  void initState() {
    super.initState();
    _leaveCubit = context.read<LeaveCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _leaveCubit.onTabChangedViewScreen(_tabController.index, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Leave",
        authorization: AuthorizationModel(),
      ),
      body: Column(
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
                  tabs: const [Tab(text: 'Overview'), Tab(text: 'Document')],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildOverView(), _buildDocument()],
            ),
          ),
        ],
      ),
    );
  }

  // OVERVIEW
  Widget _buildOverView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Leave Details", style: AppTextStyle.ts16SB()),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Leave Type",
                      value: widget.leaveModel.leaveType,
                    ),
                    buildColumnTitleValue(
                      title: "Leave Code",
                      value: widget.leaveModel.leaveTypeCode,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Start Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.leaveModel.startDate,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "End Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.leaveModel.endDate,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Start Day Duration",
                      value: widget.leaveModel.startDateLeaveDuration,
                    ),
                    buildColumnTitleValue(
                      title: "End Day Duration",
                      value: widget.leaveModel.endDateLeaveDuration,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "No. Of Days",
                      value: widget.leaveModel.noOfDays.toString(),
                    ),
                    Expanded(child: SizedBox()),
                  ],
                ),
                Text("Reason", style: AppTextStyle.ts14M(color: AppColor.grey)),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.leaveModel.reason,
                        style: AppTextStyle.ts14M(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actionCardWidget(
            createdBy: widget.leaveModel.createdBy,
            createdDate: widget.leaveModel.createdDate,
            modifiedBy: widget.leaveModel.modifiedBy,
            modifiedDate: widget.leaveModel.modifiedDate,
          ),
        ],
      ),
    );
  }

  // DOCUMENT
  Widget _buildDocument() {
    return SingleChildScrollView(
      child: Container(
        decoration: commonCardDecoration(),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () {
            if (widget.leaveModel.leaveDocumentUrl.isNotEmpty) {
              showFilePreviewDialog(
                context,
                widget.leaveModel.leaveDocumentUrl.split(","),
              );
            } else {
              showErrorMessage(context, "Image Error", "No Document Found");
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Leave Document", style: AppTextStyle.ts16M()),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color:
                      widget.leaveModel.leaveDocumentUrl.isNotEmpty
                          ? AppColor.lightBlue
                          : AppColor.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.remove_red_eye,
                  size: 16,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
