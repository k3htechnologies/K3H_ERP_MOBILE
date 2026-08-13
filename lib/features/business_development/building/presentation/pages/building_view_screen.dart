import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building_document.model.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/pages/widgets/building_details_view.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/pages/widgets/building_document_view.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/pages/widgets/building_overview.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';

class BuildingViewScreen extends StatefulWidget {
  final BusinessDevelopmentBuildingModel building;

  const BuildingViewScreen({super.key, required this.building});

  @override
  State<BuildingViewScreen> createState() => _BuildingViewScreenState();
}

class _BuildingViewScreenState extends State<BuildingViewScreen>
    with SingleTickerProviderStateMixin {
  late BuildingCubit _buildingCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late TabController _tabController;
  late ProjectModel _project;

  final ValueNotifier<Set<int>> _expandedDocumentIds = ValueNotifier<Set<int>>(
    {},
  );
  final ValueNotifier<Map<int, List<BuildingDocumentModel>>> _childDocuments =
      ValueNotifier<Map<int, List<BuildingDocumentModel>>>({});
  final ValueNotifier<Map<int, bool>> _loadingChildDocuments =
      ValueNotifier<Map<int, bool>>({});

  late TextEditingController _newDocumentTitleController, _searchDocumentNameC;

  @override
  void initState() {
    super.initState();
    _buildingCubit = context.read<BuildingCubit>();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.building] ??
        AuthorizationModel();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _newDocumentTitleController = TextEditingController();
    _searchDocumentNameC = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expandedDocumentIds.dispose();
    _childDocuments.dispose();
    _loadingChildDocuments.dispose();
    _newDocumentTitleController.dispose();
    _searchDocumentNameC.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      if (_tabController.index != 2) _searchDocumentNameC.clear();
      _buildingCubit.onTabChanged(
        _tabController.index,
        context,
        _project.projectId,
        widget.building.buildingId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Building",
        authorization: _routeAuthorizationModel,
      ),
      body: SafeArea(
        child: Column(
          children: [
            ChipStyleTabBar(
              controller: _tabController,
              tabs: ["Overview", "Details", "Document"],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: BuildingOverview(building: widget.building),
                  ),
                  BuildingDetailsView(
                    canAction: _routeAuthorizationModel.isAction,
                  ),
                  BuildingDocumentView(building: widget.building),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
