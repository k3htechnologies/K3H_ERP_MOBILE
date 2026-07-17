import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
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
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  // CUBIT
  late TenantCubit _tenantCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PROJECT
  late ProjectModel _project;

  // BUILDING SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);

  // SCROLL CONTROLLER
  final ScrollController scrollController = ScrollController();
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterFlatTypeC,
      _filterFlatConfigurationC,
      _filterApplicantNameC,
      _filterFlatCarpetAreaSqFtC,
      _filterBuildingNumberC,
      _filterWingC,
      _filterFlatC,
      _filterParkingNumberC;

  // FLAGS TO PREVENT INFINITE CALLS
  int? _lastFetchedBuildingId;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _project = getProject();
    _tenantCubit = context.read<TenantCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.tenant] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBuildingsForProject(_project.projectId);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
    _searchC.dispose();
    _filterFlatTypeC.dispose();
    _filterApplicantNameC.dispose();
    _filterFlatCarpetAreaSqFtC.dispose();
    _filterBuildingNumberC.dispose();
    _filterWingC.dispose();
    _filterFlatC.dispose();
    _filterParkingNumberC.dispose();
    _filterFlatConfigurationC.dispose();
    _selectedBuildingNotifier.dispose();
    _filterCount.dispose();
    super.dispose();
  }

  // LOAD BUILDINGS FOR PROJECT
  Future<void> _loadBuildingsForProject(int projectId) async {
    if (_tenantCubit.state.buildingList.isEmpty ||
        _tenantCubit.state.buildingList.any((b) => b.projectId != projectId)) {
      await _tenantCubit.getBuildingList(context, 1, 15, projectId);
    }
    if (mounted) {
      _selectedBuildingNotifier.value = [];
      _lastFetchedBuildingId = null;
    }
  }

  // DELETE TENANT
  Future<void> _showPopupToDeleteTenant(
    BuildContext context,
    TenantModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Tenant?',
      'Deleting this Tenant will permanently remove its contents.',
    );

    if (shouldDelete &&
        context.mounted &&
        _selectedBuildingNotifier.value.isNotEmpty) {
      _tenantCubit.deleteTenant(
        _project.projectId,
        _selectedBuildingNotifier.value.first["zAttributesId"] as int,
        obj,
        context,
        index,
      );
    }
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterFlatTypeC = TextEditingController();
    _filterFlatConfigurationC = TextEditingController();
    _filterApplicantNameC = TextEditingController();
    _filterFlatCarpetAreaSqFtC = TextEditingController();
    _filterBuildingNumberC = TextEditingController();
    _filterWingC = TextEditingController();
    _filterFlatC = TextEditingController();
    _filterParkingNumberC = TextEditingController();
  }

  // FETCH BUILDINGS — when [value] is set, calls API with search param; otherwise uses/paginates loaded list
  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 12;

    //  SEARCH MODE
    if (value != null) {
      await _tenantCubit.getBuildingList(
        context,
        pageNumber,
        pageSize,
        _project.projectId,
        searchQuery: value,
      );

      final buildingList =
          _tenantCubit.state.buildingList
              .where((b) => b.projectId == _project.projectId)
              .toList();
      final totalCount = _tenantCubit.state.buildingTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};
      for (final b in buildingList) {
        uniqueFiltered[b.buildingId] = {
          "zAttributesId": b.buildingId,
          "DisplayName": b.buildingName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    // No search: use/paginate already loaded buildings
    final buildingList =
        _tenantCubit.state.buildingList
            .where((b) => b.projectId == _project.projectId)
            .toList();
    final totalCount = _tenantCubit.state.buildingTotalCount;
    final currentLoadedCount = buildingList.length;

    if (currentLoadedCount < totalCount) {
      await _tenantCubit.getBuildingList(
        context,
        pageNumber,
        pageSize,
        _project.projectId,
      );
    }

    final updatedList =
        _tenantCubit.state.buildingList
            .where((b) => b.projectId == _project.projectId)
            .toList();

    final Map<int, Map<String, dynamic>> uniqueBuildings = {};
    for (final b in updatedList) {
      uniqueBuildings[b.buildingId] = {
        "zAttributesId": b.buildingId,
        "DisplayName": b.buildingName,
      };
    }

    return {
      "itemList": uniqueBuildings.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueBuildings.length,
    };
  }

  // PAGINATION
  void _onScroll() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !_tenantCubit.state.isLoading! &&
          _tenantCubit.state.tenantList.length <
              _tenantCubit.state.totalNumberOfRecord &&
          _selectedBuildingNotifier.value.isNotEmpty) {
        _tenantCubit.getTenantList(
          context: context,
          projectId: _project.projectId,
          buildingId:
              _selectedBuildingNotifier.value.first['zAttributesId'] as int,
          pageNumber: _tenantCubit.state.currentPage + 1,
        );
      }
    });
  }

  // BUILDING FILTER
  Future<void> _showBottomSheetToFilterTenant(BuildContext context) async {
    final state = _tenantCubit.state;

    _filterFlatTypeC.text = state.filterFlatType;
    _filterFlatConfigurationC.text = state.filterFlatConfiguration;
    _filterApplicantNameC.text = state.filterApplicantName;
    _searchC.text = state.searchText;
    _filterFlatCarpetAreaSqFtC.text = state.filterFlatCarpetAreaSqFt;
    _filterBuildingNumberC.text = state.filterBuildingNumber;
    _filterWingC.text = state.filterWing;
    _filterFlatC.text = state.filterFlat;
    _filterParkingNumberC.text = state.filterParkingNumber;

    String? selectedDirection =
        state.currentSortColumn == "Applicant Name"
            ? state.currentSortDirection
            : null;

    final String initialFlatType = _filterFlatTypeC.text;
    final String initialApplicantName = _filterApplicantNameC.text;
    final String initialFlatConfiguration = _filterFlatConfigurationC.text;
    final String? initialDirection = selectedDirection;
    final String initialFlatNumber = _searchC.text;
    final String initialFlatCarpetAreaSqFt = _filterFlatCarpetAreaSqFtC.text;
    final String initialBuildingNumber = _filterBuildingNumberC.text;
    final String initialWing = _filterWingC.text;
    final String initialFlat = _filterFlatC.text;
    final String initialParkingNumber = _filterParkingNumberC.text;
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterFlatTypeC.text.trim() != initialFlatType) ||
            (_filterApplicantNameC.text.trim() != initialApplicantName) ||
            (_filterFlatConfigurationC.text.trim() !=
                initialFlatConfiguration) ||
            (_searchC.text.trim() != initialFlatNumber) ||
            (_filterFlatCarpetAreaSqFtC.text.trim() !=
                initialFlatCarpetAreaSqFt) ||
            (_filterBuildingNumberC.text.trim() != initialBuildingNumber) ||
            (_filterWingC.text.trim() != initialWing) ||
            (_filterFlatC.text.trim() != initialFlat) ||
            (_filterParkingNumberC.text.trim() != initialParkingNumber) ||
            (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Tenant",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Applicant Name", style: AppTextStyle.ts14M()),
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
                  title: "Unit / Annexure / Survey Number",
                  hint: "Enter Unit / Annexure / Survey Number",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Applicant Name",
                  hint: "Enter Applicant Name",
                  textController: _filterApplicantNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Exisiting Unit Type",
                  hint: "Enter Exisiting Unit Type",
                  textController: _filterFlatTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Existing Configuration",
                  hint: "Enter Existing Configuration",
                  textController: _filterFlatConfigurationC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Existing Carpet Area (SqFt)",
                  hint: "Enter Existing Carpet Area (SqFt)",
                  textController: _filterFlatCarpetAreaSqFtC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Building Number",
                  hint: "Enter Building Number",
                  textController: _filterBuildingNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Wing",
                  hint: "Enter Wing",
                  textController: _filterWingC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "New Unit Number",
                  hint: "Enter New Unit Number",
                  textController: _filterFlatC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Parking Number",
                  hint: "Enter Parking Number",
                  textController: _filterParkingNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _tenantCubit.applyFilterAndSort(
          context: context,
          projectId: _project.projectId,
          buildingId:
              _selectedBuildingNotifier.value.isNotEmpty
                  ? _selectedBuildingNotifier.value.first["zAttributesId"]
                      as int
                  : 0,
          filterFlatType: "",
          filterFlatConfiguration: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
          filterApplicantName: "",
          filterFlatNumber: "",
          filterFlatCarpetAreaSqFt: "",
          filterBuildingNumber: "",
          filterWing: "",
          filterFlat: "",
          filterParkingNumber: "",
        );
        _searchC.clear();
      },
      onApply: () {
        applied = true;
        _tenantCubit.applyFilterAndSort(
          context: context,
          filterFlatType: _filterFlatTypeC.text,
          filterFlatConfiguration: _filterFlatConfigurationC.text,
          projectId: _project.projectId,
          buildingId:
              _selectedBuildingNotifier.value.isNotEmpty
                  ? _selectedBuildingNotifier.value.first["zAttributesId"]
                      as int
                  : 0,
          sortColumn: selectedDirection != null ? "Applicant Name" : null,
          sortDirection: selectedDirection,
          filterApplicantName: _filterApplicantNameC.text.trim(),
          filterFlatCarpetAreaSqFt: _filterFlatCarpetAreaSqFtC.text.trim(),
          filterBuildingNumber: _filterBuildingNumberC.text.trim(),
          filterWing: _filterWingC.text.trim(),
          filterFlat: _filterFlatC.text.trim(),
          filterParkingNumber: _filterParkingNumberC.text.trim(),
          filterFlatNumber: _searchC.text.trim(),
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterFlatC.clear();
      _filterFlatTypeC.clear();
      _filterFlatConfigurationC.clear();
      _filterApplicantNameC.clear();
      _filterFlatCarpetAreaSqFtC.clear();
      _filterBuildingNumberC.clear();
      _filterWingC.clear();
      _filterFlatC.clear();
      _filterParkingNumberC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TenantCubit, TenantState>(
      listener: (context, state) {
        _filterCount.value = _tenantCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Tenant",
          authorization: _routeAuthorizationModel,
          onSearchSubmit: (value) {
            if (_selectedBuildingNotifier.value.isNotEmpty) {
              _tenantCubit.searchTenant(
                value,
                context,
                _project.projectId,
                _selectedBuildingNotifier.value.first["zAttributesId"] as int,
              );
            }
          },
          textController: _searchC,
          searchHintText: "Search By Flat Number",
          filterCountNotifier: _filterCount,
          onAddCallback: () async {
            if (_selectedBuildingNotifier.value.isNotEmpty) {
              await goRouter.pushNamed(
                AppRoutes.addTenant,
                queryParameters: {
                  'projectId': _project.projectId.toString(),
                  'buildingId':
                      _selectedBuildingNotifier.value.first["zAttributesId"]
                          .toString(),
                },
              );
              if (context.mounted) {
                _tenantCubit.getTenantList(
                  context: context,
                  projectId: _project.projectId,
                  buildingId:
                      _selectedBuildingNotifier.value.first["zAttributesId"],
                  pageNumber: 1,
                );
              }
            } else {
              showErrorMessage(context, "Error", "Please select building");
            }
          },
          onExportCallback: (value) {
            if (_selectedBuildingNotifier.value.isNotEmpty) {
              _tenantCubit.exportExcelPdf(
                context,
                value,
                _project.projectId,
                _selectedBuildingNotifier.value.first["zAttributesId"] as int,
              );
            } else {
              showErrorMessage(context, "Error", "Please select building");
            }
          },
          onProjectChangeCallback: (project) {
            _project = project;
            _selectedBuildingNotifier.value = [];
            _lastFetchedBuildingId = null;
            _loadBuildingsForProject(_project.projectId);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterTenant(context);
          },
          extraHeight: 140.h,
          widgets: BlocBuilder<TenantCubit, TenantState>(
            bloc: _tenantCubit,
            builder: (context, state) {
              return ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _selectedBuildingNotifier,
                builder: (context, selectedBuilding, child) {
                  return Column(
                    children: [
                      verticalSpacing(),
                      showSiteSelectedWidget(projectName: _project.projectName),
                      CustomMultipleSelectPopup(
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
                            final newBuildingId =
                                value.first['zAttributesId'] as int;
                            if (_lastFetchedBuildingId != newBuildingId) {
                              _lastFetchedBuildingId = newBuildingId;
                              await _tenantCubit.getTenantList(
                                context: context,
                                projectId: _project.projectId,
                                buildingId: newBuildingId,
                                pageNumber: 1,
                              );
                            }
                          } else if (mounted) {
                            _lastFetchedBuildingId = null;
                          }
                        },
                        dataFetchCallBack: _fetchBuildings,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Building is required";
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _selectedBuildingNotifier,
                builder: (context, selectedBuilding, child) {
                  if (selectedBuilding.isEmpty) {
                    return Center(
                      child: Text(
                        'Please select a building',
                        style: AppTextStyle.ts14R(color: AppColor.grey),
                      ),
                    );
                  }
                  return BlocBuilder<TenantCubit, TenantState>(
                    bloc: _tenantCubit,
                    builder: (context, state) {
                      if ((state.isLoading ?? true) &&
                          state.tenantList.isEmpty) {
                        return Center(child: loader());
                      }
                      if (state.tenantList.isEmpty) {
                        return Center(child: noDataWidget());
                      }
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.tenantList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.tenantList.length) {
                            return state.tenantList.length <
                                    state.totalNumberOfRecord
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }
                          var tenant = state.tenantList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () {
                                          goRouter.pushNamed(
                                            AppRoutes.viewTenant,
                                            queryParameters: {
                                              "tenant":
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(tenant.toJson()),
                                                  ),
                                            },
                                          );
                                        },
                                        child: Text(
                                          tenant.tenantApplicantData
                                              .firstWhere(
                                                (e) =>
                                                    e.applicantType
                                                        .toLowerCase() ==
                                                    "applicant",
                                              )
                                              .applicantName,
                                          style: AppTextStyle.ts16M(
                                            color: AppColor.primary,
                                          ).copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: AppColor.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        CustomIconButton.edit(
                                          onPressed: () async {
                                            if (_selectedBuildingNotifier
                                                .value
                                                .isEmpty) {
                                              showErrorMessage(
                                                context,
                                                'Error',
                                                'Please select a building',
                                              );
                                              return;
                                            }
                                            final buildingId =
                                                _selectedBuildingNotifier
                                                        .value
                                                        .first["zAttributesId"]
                                                    as int;
                                            await goRouter.pushNamed(
                                              AppRoutes.addTenant,
                                              queryParameters: {
                                                "tenant": Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(tenant.toJson()),
                                                  ),
                                                ),
                                                'index': index.toString(),
                                                'projectId':
                                                    _project.projectId
                                                        .toString(),
                                                'buildingId':
                                                    buildingId.toString(),
                                              },
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        CustomIconButton.delete(
                                          onPressed: () {
                                            _showPopupToDeleteTenant(
                                              context,
                                              tenant,
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
                                  title: "Existing Flat No.",
                                  value: tenant.flatNumber,
                                ),
                                buildRowTitleValue(
                                  title: "Existing Flat Type",
                                  value: tenant.flatType,
                                ),
                                buildRowTitleValue(
                                  title: "New Flat No",
                                  value:
                                      tenant.inventoryFlatType.isEmpty
                                          ? "-"
                                          : tenant.inventoryFlatType,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
