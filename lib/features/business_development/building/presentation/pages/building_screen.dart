import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BuildingScreen extends StatefulWidget {
  const BuildingScreen({super.key});

  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {
  late BuildingCubit _buildingCubit;

  late AuthorizationModel _routeAuthorizationModel;

  late ProjectModel _project;

  final ScrollController scrollController = ScrollController();

  late TextEditingController _searchC,
      _filterCTSNumberC,
      _filterRoadWidthC,
      _filterCityC,
      _filterVillageC,
      _filterWardC;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _project = getProject();
    _buildingCubit = context.read<BuildingCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.building] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _buildingCubit.getBuildingList(context, 1, _project.projectId);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _filterCTSNumberC.dispose();
    _filterCount.dispose();
    _filterRoadWidthC.dispose();
    _filterCityC.dispose();
    _filterVillageC.dispose();
    _filterWardC.dispose();
    super.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterCTSNumberC = TextEditingController();
    _filterRoadWidthC = TextEditingController();
    _filterCityC = TextEditingController();
    _filterVillageC = TextEditingController();
    _filterWardC = TextEditingController();
  }

  void _onScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !_buildingCubit.state.isLoading! &&
          _buildingCubit.state.buildingList.length <
              _buildingCubit.state.totalNumberOfRecord) {
        _buildingCubit.getBuildingList(
          context,
          _buildingCubit.state.currentPage + 1,
          _project.projectId,
        );
      }
    });
  }

  Future<void> _showPopupToDeleteBuilding(
    BuildContext context,
    BusinessDevelopmentBuildingModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Building?',
      'Deleting this Building will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _buildingCubit.deleteBuilding(_project.projectId, obj, context, index);
    }
  }

  Future<void> _showBottomSheetToFilterBuilding(BuildContext context) async {
    final state = _buildingCubit.state;

    _filterCTSNumberC.text = state.filterCTSNumber;
    _searchC.text = state.searchText;
    _filterCTSNumberC.text = state.filterCTSNumber;
    _filterRoadWidthC.text = state.filterRoadWidth;
    _filterCityC.text = state.filterCity;
    _filterVillageC.text = state.filterVillage;
    _searchC.text = state.searchText;
    _filterWardC.text = state.filterWard;
    String? selectedDirection =
        state.currentSortColumn == "Building Name"
            ? state.currentSortDirection
            : null;

    final String initialBuildingName = _searchC.text;
    final String initialCTSNumber = _filterCTSNumberC.text;
    final String initialRoadWidth = _filterRoadWidthC.text;
    final String initialCity = _filterCityC.text;
    final String initialVillage = _filterVillageC.text;
    final String initialWard = _filterWardC.text;
    final String? initialDirection = selectedDirection;
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialBuildingName) ||
            (_filterCTSNumberC.text.trim() != initialCTSNumber) ||
            (_filterRoadWidthC.text.trim() != initialRoadWidth) ||
            (_filterCityC.text.trim() != initialCity) ||
            (_filterVillageC.text.trim() != initialVillage) ||
            (_filterWardC.text.trim() != initialWard) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Building",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Building Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => selectDirection("ASC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "ASC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("A-Z", style: AppTextStyle.ts12R()),
                      ),
                    ),
                    horizontalSpacing(),
                    GestureDetector(
                      onTap: () => selectDirection("DESC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "DESC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(height: 20),
                CustomTextField(
                  title: "Building Name",
                  hint: "Enter Building Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "CTS Number",
                  hint: "Enter CTS Number",
                  textController: _filterCTSNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Road Width",
                  hint: "Enter Road Width",
                  textController: _filterRoadWidthC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "City",
                  hint: "Enter City",
                  textController: _filterCityC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Village",
                  hint: "Enter Village",
                  textController: _filterVillageC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Ward",
                  hint: "Enter Ward",
                  textController: _filterWardC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _buildingCubit.applyFilterAndSort(
          context: context,
          projectId: _project.projectId,
          filterBuildingName: "",
          filterCTSNumber: "",
          filterRoadWidth: "",
          filterCity: "",
          filterVillage: "",
          filterWard: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        applied = true;
        _buildingCubit.applyFilterAndSort(
          context: context,
          projectId: _project.projectId,
          filterBuildingName: _searchC.text,
          filterCTSNumber: _filterCTSNumberC.text,
          filterRoadWidth: _filterRoadWidthC.text,
          filterCity: _filterCityC.text,
          filterVillage: _filterVillageC.text,
          sortColumn: selectedDirection != null ? "Building Name" : null,
          sortDirection: selectedDirection,
          filterWard: _filterWardC.text,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _searchC.clear();
      _filterCTSNumberC.clear();
      _filterRoadWidthC.clear();
      _filterCityC.clear();
      _filterVillageC.clear();
      _filterWardC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BuildingCubit, BuildingState>(
      listener: (context, state) {
        _filterCount.value = _buildingCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Building",
          searchHintText: "Search By Building Name",
          authorization: _routeAuthorizationModel,
          onSearchSubmit: (value) {
            _buildingCubit.searchBuilding(context, _project.projectId, value);
          },
          textController: _searchC,
          onAddCallback: () async {
            await goRouter.pushNamed(
              AppRoutes.addBuilding,
              queryParameters: {'projectId': _project.projectId.toString()},
            );
          },
          onExportCallback: (value) {
            _buildingCubit.exportExcelPdf(context, value, _project.projectId);
          },
          onProjectChangeCallback: (project) {
            _project = project;
            _buildingCubit.searchBuilding(context, _project.projectId, "");
          },
          isFilterOn: true,
          filterCountNotifier: _filterCount,
          onFilterTap: () {
            _showBottomSheetToFilterBuilding(context);
          },
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              BlocBuilder<BuildingCubit, BuildingState>(
                builder: (context, state) {
                  return showSiteSelectedWidget(
                    projectName: _project.projectName,
                  );
                },
              ),
              verticalSpacing(height: 5),
              Expanded(
                child: BlocBuilder<BuildingCubit, BuildingState>(
                  key: ValueKey('building_list_${_project.projectId}'),
                  bloc: _buildingCubit,
                  builder: (context, state) {
                    if (state.isLoading == true && state.buildingList.isEmpty) {
                      return Center(child: loader());
                    }
                    if (state.buildingList.isEmpty) {
                      return Center(
                        child: noDataWidget(message: "No Buildings Data Found"),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: state.buildingList.length + 1,
                      separatorBuilder:
                          (context, index) => verticalSpacing(height: 12),
                      itemBuilder: (context, index) {
                        if (index == state.buildingList.length) {
                          return state.buildingList.length <
                                  state.totalNumberOfRecord
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        var building = state.buildingList[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 10,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        goRouter.pushNamed(
                                          AppRoutes.viewBuilding,
                                          queryParameters: {
                                            "building":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(
                                                      building.toJson(),
                                                    ),
                                                  ),
                                                ),
                                          },
                                        );
                                      },
                                      child: Text(
                                        building.buildingName,
                                        style: AppTextStyle.ts16M(
                                          color: AppColor.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      CustomIconButton.edit(
                                        isDisabled:
                                            !_routeAuthorizationModel.isAction,
                                        onPressed: () async {
                                          await goRouter.pushNamed(
                                            AppRoutes.addBuilding,
                                            queryParameters: {
                                              "building":
                                                  Uri.encodeQueryComponent(
                                                    EncryptionManager.encryptData(
                                                      jsonEncode(
                                                        building.toJson(),
                                                      ),
                                                    ),
                                                  ),
                                              'index': index.toString(),
                                              'projectId':
                                                  _project.projectId.toString(),
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      CustomIconButton.delete(
                                        isDisabled:
                                            !_routeAuthorizationModel.isAction,
                                        onPressed: () {
                                          _showPopupToDeleteBuilding(
                                            context,
                                            building,
                                            state.currentPage,
                                            index,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              verticalSpacing(height: 8),
                              buildRowTitleValue(
                                title: "CTS Number",
                                value: building.cTSNumber,
                              ),
                              buildRowTitleValue(
                                title: "Total Plot Area(Sq. ft)",
                                value: building.totalPlotAreaSqFt.toString(),
                              ),
                              buildRowTitleValue(
                                title: "Road Width",
                                value: building.roadWidth,
                              ),
                              buildRowTitleValue(
                                title: "Total Floor",
                                value: building.numberOfFloors.toString(),
                              ),
                              buildRowTitleValue(
                                title: "Total Units",
                                value: building.totalNumberOfUnits.toString(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
