import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/presentation/cubit/payroll_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PayrollDashboardScreen extends StatefulWidget {
  const PayrollDashboardScreen({super.key});

  @override
  State<PayrollDashboardScreen> createState() => _PayrollDashboardScreenState();
}

class _PayrollDashboardScreenState extends State<PayrollDashboardScreen> {
  // CUBIT
  late PayrollDashboardCubit _payrollDashboardCubit;

  // TEXT CONTROLLER
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _payrollDashboardCubit = context.read<PayrollDashboardCubit>();
    _payrollDashboardCubit.getPayrollDashboardList(context);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Payroll Dashboard",
        authorization: AuthorizationModel(),
        textController: _searchC,
        searchHintText: "Search by Employee Name",
        onSearchSubmit: (value) {},
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: BlocBuilder<PayrollDashboardCubit, PayrollDashboardState>(
          builder: (context, state) {
            return Column(
              children: [_overview(state), verticalSpacing(), _quickAction()],
            );
          },
        ),
      ),
    );
  }

  // OVERVIEW
  Widget _overview(PayrollDashboardState state) {
    final table0 = state.payrollDashboardModel?.table0;

    if (table0 == null || table0.isEmpty) {
      return const SizedBox();
    }

    final data = table0.first;

    return Column(
      spacing: 10,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _overviewCard(
                title: "On Leave Today",
                value: data.onLeave.toString(),
                icon: SvgPicture.asset(
                  AppAssets.payrollOnLeaveIcon,
                  height: 16,
                  width: 16,
                ),
                iconColor: AppColor.error,
                backgroundColor: AppColor.lightRed.withValues(alpha: .5),
              ),
            ),
            Expanded(
              child: _overviewCard(
                title: "Outdoor Today",
                value: data.outdoor.toString(),
                icon: SvgPicture.asset(
                  AppAssets.locationIcon,
                  height: 16,
                  width: 16,
                  colorFilter: ColorFilter.mode(
                    AppColor.yellow,
                    BlendMode.srcIn,
                  ),

                ),
                iconColor: AppColor.yellow,
                backgroundColor: AppColor.lightYellow.withValues(alpha: .5),
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _overviewCard(
                title: "Pending Approval",
                value: data.pendingApproval.toString(),
                icon: SvgPicture.asset(
                  AppAssets.calenderIcon,
                  height: 16,
                  width: 16,
                ),
                iconColor: AppColor.darkGreen,
                backgroundColor: AppColor.lightGreen.withValues(alpha: .5),
              ),
            ),
            Expanded(
              child: _overviewCard(
                title: "Attendance Alert",
                value: data.attendanceAlert.toString(),
                icon: SvgPicture.asset(
                  AppAssets.calenderIcon,
                  height: 16,
                  width: 16,
                ),
                iconColor: AppColor.purple,
                backgroundColor: AppColor.purple20.withValues(alpha: .08),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // OVERVIEW CARD
  Widget _overviewCard({
    required String title,
    required String value,
    required Widget icon,
    required Color iconColor,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: commonCardDecoration(),
      padding: const EdgeInsets.all(10),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: AppTextStyle.ts20SB()),
              CustomIconButton(
                onPressed: onTap ?? () {},
                icon: icon,
                backgroundColor: backgroundColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // QUICK ACTION
  Widget _quickAction() {
    return Container(
      decoration: commonCardDecoration(),
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Action", style: AppTextStyle.ts14M()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        AppAssets.calenderIcon,
                        height: 16,
                        width: 16,
                        colorFilter: ColorFilter.mode(
                          AppColor.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text("Apply Leave", style: AppTextStyle.ts12M()),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.watch_later_outlined,
                        size: 16,
                        color: AppColor.darkGreen,
                      ),
                      backgroundColor: AppColor.lightGreen.withValues(
                        alpha: .5,
                      ),
                    ),
                    Text("Request Comp-off", style: AppTextStyle.ts12M()),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add, size: 16, color: AppColor.primary),
                    ),
                    Text("Add Outdoor", style: AppTextStyle.ts12M()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
