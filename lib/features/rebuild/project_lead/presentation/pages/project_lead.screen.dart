import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/cubit/project_lead_cubit.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/pages/land/land.screen.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/pages/redevelopment/redevelopment.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProjectLeadScreen extends StatefulWidget {
  const ProjectLeadScreen({super.key});

  @override
  State<ProjectLeadScreen> createState() => _ProjectLeadScreenState();
}

class _ProjectLeadScreenState extends State<ProjectLeadScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late ProjectLeadCubit _projectLeadCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _redevlopmentSearchC, _landSearchC;

  // TAB CONTROLLER
  late TabController _tabController;
  late List<String> _tabs;
  @override
  void initState() {
    _projectLeadCubit = context.read<ProjectLeadCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.projectLead] ??
        AuthorizationModel();
    _redevlopmentSearchC = TextEditingController();
    _tabs = ["Redevlopment", "Land"];
    _landSearchC = TextEditingController();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _projectLeadCubit.getRedevelopmentList(context, 1);
    super.initState();
  }

  @override
  void dispose() {
    _redevlopmentSearchC.dispose();
    _landSearchC.dispose();
    super.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      onTabChanged(context, _tabController.index);
    }
  }

  void onTabChanged(BuildContext context, int index) {
    if (index == 0) {
      _projectLeadCubit.getRedevelopmentList(context, 1);
    } else if (index == 1) {
      _projectLeadCubit.getLandList(context, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Project Lead",
        authorization: _routeAuthorizationModel,
        isMenuButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChipStyleTabBar(
            controller: _tabController,
            tabs: ["Redevlopment", "Land"],
          ),
          BlocBuilder<ProjectLeadCubit, ProjectLeadState>(
            builder: (context, state) {
              if (state.isLoading ?? true) {
                return Center(child: loader());
              }
              return Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [redevelopmentWidget(context), landWidget(context)],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget redevelopmentWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchbar(isRedevelopment: true),
          verticalSpacing(),
          Expanded(child: RedevelopmentScreen()),
        ],
      ),
    );
  }

  Widget landWidget(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchbar(isRedevelopment: false),
          verticalSpacing(),
          LandScreen(),
        ],
      ),
    );
  }

  Widget _buildSearchbar({required bool isRedevelopment}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SearchWidget(
            onSubmit: (value) {
              if (isRedevelopment) {
              } else {}
            },
            textController:
                isRedevelopment ? _redevlopmentSearchC : _landSearchC,
            hintText:
                isRedevelopment
                    ? "Search By Building Name"
                    : "Search By Land owner Name",
            isFilterOn: true,
            onFilterTap: () {},
          ),
        ),
        horizontalSpacing(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomButton(
              text: "Add",
              onPressed: () {
                if (isRedevelopment) {
                  goRouter.pushNamed(AppRoutes.addRedevelopment);
                } else {
                  goRouter.pushNamed(AppRoutes.addLand);
                }
              },
            ),
            horizontalSpacing(),
            CustomExportButton(
              onExport: (value) {
                if (isRedevelopment) {
                  _projectLeadCubit.exportRedevelopmentExcelPdf(context, value);
                } else {}
              },
            ),
          ],
        ),
      ],
    );
  }
}
