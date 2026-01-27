import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/cubit/leave_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class LeaveViewScreen extends StatefulWidget {
  final LeaveTypeModel leaveTypeModel;
  const LeaveViewScreen({super.key, required this.leaveTypeModel});

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
      _leaveCubit.onTabChanged(_tabController.index, context);
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
                    buildColumnTitleValue(title: "Leave Type", value: "hahaha"),
                    buildColumnTitleValue(title: "Leave Code", value: "hahaha"),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(title: "Start Date", value: "hahaha"),
                    buildColumnTitleValue(title: "End Date", value: "hahaha"),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Start Date Duration",
                      value: "hahaha",
                    ),
                    buildColumnTitleValue(
                      title: "End Date Duration",
                      value: "hahaha",
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "No. Of Days",
                      value: "hahaha",
                    ),
                    Expanded(child: SizedBox()),
                  ],
                ),
                Text("Remark", style: AppTextStyle.ts14M(color: AppColor.grey)),
                Row(children: [Flexible(child: Text("haha"))]),
              ],
            ),
          ),
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
                      title: "Approved By",
                      value: "hahaha",
                    ),
                    buildColumnTitleValue(
                      title: "Approved Date",
                      value: "hahaha",
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(title: "Created By", value: "hahaha"),
                    buildColumnTitleValue(
                      title: "Created Date",
                      value: "hahaha",
                    ),
                  ],
                ),
              ],
            ),
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
        child: Row(
          children: [
            Text("Leave Document", style: AppTextStyle.ts16M()),
            Spacer(),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColor.lightBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.remove_red_eye, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
