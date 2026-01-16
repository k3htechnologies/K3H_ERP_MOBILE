import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/presentation/cubit/rent_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';

class RentScreen extends StatefulWidget {
  const RentScreen({super.key});

  @override
  State<RentScreen> createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late RentCubit _rentCubit;

  // PROJECT
  late ProjectModel _project;

  // TAB CONTROLLERS
  late TabController _tabController;

  // BUILDING SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);



  final List<String> tabTitles = [
    'Additional Rent',
    'Rent',
    'Corpus',
    'Brokerage',
    'Shifting',
  ];

  @override
  void initState() {
    super.initState();
    _rentCubit = context.read<RentCubit>();
    _project = getProject();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    // Call API directly in initState, similar to BuildingScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBuildingsForProject(_project.projectId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {

      final int tabIndex = _tabController.index;
      final String tabName = tabTitles[tabIndex];

      final int projectId = _project.projectId;

      final int? buildingId =
      _selectedBuildingNotifier.value.isNotEmpty
          ? _selectedBuildingNotifier.value.first['zAttributesId']
          : null;

      /// Call cubit / API here
      _rentCubit.onTabChanged(
        tabIndex,
        context,
        projectId: projectId,
        buildingId: buildingId,
        tabName: tabName,
        tenure: ""
      );
    }
  }

  // LOAD BUILDINGS FOR PROJECT
  Future<void> _loadBuildingsForProject(int projectId) async {
    if (_rentCubit.state.buildingList.isEmpty ||
        _rentCubit.state.buildingList.any((b) => b.projectId != projectId)) {
      await _rentCubit.getBuildingList(context, 1, 100, projectId);
    }
    if (mounted) {
      _selectedBuildingNotifier.value = [];
    }
  }

  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    final buildingList =
        _rentCubit.state.buildingList
            .where((b) => b.projectId == _project.projectId)
            .toList();

    if (value != null && value.isNotEmpty) {
      final filteredBuildings =
          buildingList
              .where(
                (building) => building.buildingName.toLowerCase().contains(
                  value.toLowerCase(),
                ),
              )
              .toList();

      return {
        "itemList":
            filteredBuildings.map((building) {
              return {
                "zAttributesId": building.buildingId,
                "DisplayName": building.buildingName,
              };
            }).toList(),
        "totalNumberOfRecord": filteredBuildings.length,
      };
    }
    return {
      "itemList":
          buildingList.map((building) {
            return {
              "zAttributesId": building.buildingId,
              "DisplayName": building.buildingName,
            };
          }).toList(),
      "totalNumberOfRecord": buildingList.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Rent",
        authorization: AuthorizationModel(),
        onProjectChangeCallback: (project) {
          _project = project;
        },
        extraHeight: 70,
        widgets: BlocBuilder<RentCubit, RentState>(
          bloc: _rentCubit,
          builder: (context, state) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedBuildingNotifier,
              builder: (context, selectedBuilding, child) {
                return CustomMultipleSelectPopup(
                  title: "Building",
                  isRequired: true,
                  isMultiSelect: false,
                  initialValue: selectedBuilding,
                  dataList: const [],
                  onSelected: (value) async {
                    _selectedBuildingNotifier.value = value;

                    if (value.isNotEmpty &&
                        value.first['zAttributesId'] != null &&
                        mounted) {

                      final int buildingId = value.first['zAttributesId'];
                      final int projectId = _project.projectId;

                      final int tabIndex = _tabController.index;
                      final String tabName = tabTitles[tabIndex];

                      _rentCubit.onTabChanged(
                        tabIndex,
                        context,
                        projectId: projectId,
                        buildingId: buildingId,
                        tabName: tabName,
                        tenure: ""
                      );
                    }
                  },
                  dataFetchCallBack: _fetchBuildings,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Building is required";
                    }
                    return null;
                  },
                );
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IntrinsicWidth(
              child: Container(
                height: 40,
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
                  tabs: tabTitles
                      .map((title) => Tab(text: title))
                      .toList(),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Text("Additional Rent"),
                Text("Rent"),
                Text("Corpus"),
                Text("Brokerage"),
                Text("Shifting"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
