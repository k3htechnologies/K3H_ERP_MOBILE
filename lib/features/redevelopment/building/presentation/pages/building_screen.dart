import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
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
  // CUBIT
  late BuildingCubit _buildingCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PROJECT
  late ProjectModel _project;

  // SCROLL CONTROLLER
  final ScrollController scrollController = ScrollController();

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchC, _filterCTSNumberC;

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
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterCTSNumberC = TextEditingController();
  }

  // PAGINATION
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

  // DELETE BUILDING
  Future<void> _showPopupToDeleteBuilding(
    BuildContext context,
    RedevelopmentBuildingModel obj,
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

  // BUILDING FILTER
  Future<void> _showBottomSheetToFilterBuilding(BuildContext context) async {
    final state = _buildingCubit.state;

    _filterCTSNumberC.text = state.filterCTSNumber;

    String? selectedDirection =
        state.currentSortColumn == "Building Name"
            ? state.currentSortDirection
            : null;

    final String initialCTSNumber = _filterCTSNumberC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterCTSNumberC.text.trim() != initialCTSNumber) ||
            (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Building",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
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
                  title: "CTS Number",
                  hint: "Enter CTS Number",
                  textController: _filterCTSNumberC,
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
          filterCTSNumber: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        applied = true;
        _buildingCubit.applyFilterAndSort(
          context: context,
          filterCTSNumber: _filterCTSNumberC.text,
          projectId: _project.projectId,
          sortColumn: selectedDirection != null ? "Building Name" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterCTSNumberC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Building",
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
          if (context.mounted) {
            _buildingCubit.getBuildingList(context, 1, _project.projectId);
          }
        },
        onExportCallback: (value) {
          _buildingCubit.exportExcelPdf(context, value, _project.projectId);
        },
        onProjectChangeCallback: (project) {
          _project = project;
          _buildingCubit.searchBuilding(context, _project.projectId, "");
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterBuilding(context);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<BuildingCubit, BuildingState>(
              key: ValueKey('building_list_${_project.projectId}'),
              bloc: _buildingCubit,
              builder: (context, state) {
                if (state.isLoading == true && state.buildingList.isEmpty) {
                  return Center(child: loader());
                }
                if (state.buildingList.isEmpty) {
                  return Center(child: noDataWidget());
                }
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: state.buildingList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.buildingList.length) {
                      return state.buildingList.length <
                              state.totalNumberOfRecord
                          ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    var building = state.buildingList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    goRouter.pushNamed(
                                      AppRoutes.viewBuilding,
                                      queryParameters: {
                                        "building": Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(building.toJson()),
                                          ),
                                        ),
                                      },
                                    );
                                  },
                                  child: Text(
                                    building.buildingName,
                                    style: AppTextStyle.ts16M(
                                      color: AppColor.primary,
                                    ).copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColor.primary,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  CustomIconButton.edit(
                                    onPressed: () async {
                                      await goRouter.pushNamed(
                                        AppRoutes.addBuilding,
                                        queryParameters: {
                                          "building": Uri.encodeQueryComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(building.toJson()),
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
                            value: building.ctsNumber,
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
    );
  }
}
