import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/dashboard/presentation/cubit/crm_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CrmDashboardScreen extends StatefulWidget {
  const CrmDashboardScreen({super.key});

  @override
  State<CrmDashboardScreen> createState() => _CrmDashboardScreenState();
}

class _CrmDashboardScreenState extends State<CrmDashboardScreen>
    with TickerProviderStateMixin {
  late CrmDashboardCubit _crmDashboardCubit;
  // TAB CONTROLLERS
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _crmDashboardCubit = context.read<CrmDashboardCubit>();
    _crmDashboardCubit.getCrmDashboardList(context, filterType: "TODAY");
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    String filterType = "TODAY";

    switch (_tabController.index) {
      case 0:
        filterType = "TODAY";
        break;

      case 1:
        filterType = "WEEKLY";
        break;

      case 2:
        filterType = "MONTHLY";
        break;

      case 3:
        filterType = "DATEWISE";
        break;

      case 4:
        filterType = "OVERALL";
        break;
    }

    _crmDashboardCubit.getCrmDashboardList(context, filterType: filterType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Crm Dashbaord",
        authorization: AuthorizationModel(),
        isMenuButton: true,
      ),
      body: BlocBuilder<CrmDashboardCubit, CrmDashboardState>(
        builder: (context, state) {
          if (state.isLoading ?? false) {
            return Center(child: loader());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChipStyleTabBar(
                isSecondaryStyle: false,
                controller: _tabController,
                tabs: ["Today", "Weekly", "Monthly", "Datewise", "Overall"],
              ),
              verticalSpacing(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _projectWiseCollectionWidget(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _projectWiseCollectionWidget(
    BuildContext context,
    CrmDashboardState state,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Collection %",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                  verticalSpacing(height: 6),
                  Text("data %", style: AppTextStyle.ts20SB()),
                ],
              ),
              horizontalSpacing(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: AppColor.lightBlue,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  "Last 3 days",
                  style: AppTextStyle.ts12R(color: AppColor.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
