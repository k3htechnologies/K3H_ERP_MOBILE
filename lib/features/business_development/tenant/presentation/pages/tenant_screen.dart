import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/business_development/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/business_development/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';
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
  late TenantCubit _tenantCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late ProjectModel _project;
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);
  final ScrollController scrollController = ScrollController();
  Timer? _debounce;
  late TextEditingController _searchC,
      _filterTenantCodeC,
      _filterFlatTypeC,
      _filterFlatConfigurationC,
      _filterByApplicantNameC,
      _filterFlatCarpetAreaSqFtC,
      _filterBuildingNumberC,
      _filterWingC,
      _filterFlatC,
      _filterParkingNumberC;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();
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
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
    _searchC.dispose();
    _filterTenantCodeC.dispose();
    _filterFlatTypeC.dispose();
    _filterByApplicantNameC.dispose();
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

  Future<void> _showPopupToDeleteTenant(
    BuildContext context,
    TenantModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Tenant?',
      'Deleting this tenant will permanently remove all associated data.',
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

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterTenantCodeC = TextEditingController();
    _filterFlatTypeC = TextEditingController();
    _filterFlatConfigurationC = TextEditingController();
    _filterByApplicantNameC = TextEditingController();
    _filterFlatCarpetAreaSqFtC = TextEditingController();
    _filterBuildingNumberC = TextEditingController();
    _filterWingC = TextEditingController();
    _filterFlatC = TextEditingController();
    _filterParkingNumberC = TextEditingController();
  }

  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: _project.projectId,
      queryParams:
          value != null && value.isNotEmpty
              ? {"BuildingName": value, "isCheckPermission": false}
              : {"isCheckPermission": false},
    );
    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project =
            response['data'] as List<BusinessDevelopmentBuildingModel>;
        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.buildingId,
                  "DisplayName": pr.buildingName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

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

  Future<void> _showBottomSheetToFilterTenant(BuildContext context) async {
    final state = _tenantCubit.state;
    _filterTenantCodeC.text = state.filterByTenantCode;
    _filterFlatTypeC.text = state.filterByFlatType;
    _filterFlatConfigurationC.text = state.filterByFlatConfiguration;
    _filterByApplicantNameC.text = state.filterByApplicantName;
    _searchC.text = state.searchText;
    _filterFlatCarpetAreaSqFtC.text = state.filterByFlatCarpetAreaSqFt;
    _filterBuildingNumberC.text = state.filterByBuildingNumber;
    _filterWingC.text = state.filterByWing;
    _filterFlatC.text = state.filterByFlat;
    _filterParkingNumberC.text = state.filterByParkingNumber;
    String? selectedDirection =
        state.currentSortColumn == "Unit / Annx / Svy No."
            ? state.currentSortDirection
            : null;
    final String initialTenantCode = _filterTenantCodeC.text;
    final String initialFlatType = _filterFlatTypeC.text;
    final String initialApplicantName = _filterByApplicantNameC.text;
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
            (_filterTenantCodeC.text.trim() != initialTenantCode) ||
            (_filterFlatTypeC.text.trim() != initialFlatType) ||
            (_filterByApplicantNameC.text.trim() != initialApplicantName) ||
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
                Text(
                  "Sort By Unit / Annx / Svy No",
                  style: AppTextStyle.ts14M(),
                ),
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
                  title: "Tenant Code",
                  hint: "Enter Tenant Code",
                  textController: _filterTenantCodeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Applicant Name",
                  hint: "Enter Applicant Name",
                  textController: _filterByApplicantNameC,
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
          filterByTenantCode: "",
          filterByFlatType: "",
          filterByFlatConfiguration: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
          filterByApplicantName: "",
          filterByFlatNumber: "",
          filterByFlatCarpetAreaSqFt: "",
          filterByBuildingNumber: "",
          filterByWing: "",
          filterByFlat: "",
          filterByParkingNumber: "",
        );
        _searchC.clear();
      },
      onApply: () {
        applied = true;
        _tenantCubit.applyFilterAndSort(
          context: context,
          filterByFlatType: _filterFlatTypeC.text,
          filterByFlatConfiguration: _filterFlatConfigurationC.text,
          projectId: _project.projectId,
          buildingId:
              _selectedBuildingNotifier.value.isNotEmpty
                  ? _selectedBuildingNotifier.value.first["zAttributesId"]
                      as int
                  : 0,
          sortColumn:
              selectedDirection != null ? "Unit / Annx / Svy No." : null,
          sortDirection: selectedDirection,
          filterByApplicantName: _filterByApplicantNameC.text.trim(),
          filterByFlatCarpetAreaSqFt: _filterFlatCarpetAreaSqFtC.text.trim(),
          filterByBuildingNumber: _filterBuildingNumberC.text.trim(),
          filterByWing: _filterWingC.text.trim(),
          filterByFlat: _filterFlatC.text.trim(),
          filterByParkingNumber: _filterParkingNumberC.text.trim(),
          filterByFlatNumber: _searchC.text.trim(),
          filterByTenantCode: _filterTenantCodeC.text.trim(),
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    if (!applied && manualClose) {
      _filterTenantCodeC.clear();
      _filterFlatC.clear();
      _filterFlatTypeC.clear();
      _filterFlatConfigurationC.clear();
      _filterByApplicantNameC.clear();
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
            _tenantCubit.searchTenant(
              value,
              context,
              _project.projectId,
              _selectedBuildingNotifier.value.isEmpty
                  ? null
                  : _selectedBuildingNotifier.value.first["zAttributesId"]
                      as int,
            );
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
            _tenantCubit.resetState();
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterTenant(context);
          },
        ),
        body: Column(
          children: [
            BlocBuilder<TenantCubit, TenantState>(
              bloc: _tenantCubit,
              builder: (context, state) {
                return ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: _selectedBuildingNotifier,
                  builder: (context, selectedBuilding, child) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          showSiteSelectedWidget(
                            projectName: _project.projectName,
                          ),
                          CustomMultipleSelectPopup(
                            title: "Building",
                            isRequired: true,
                            isMultiSelect: false,
                            hintText: "Select Building",
                            initialValue: selectedBuilding,
                            dataList: const [],
                            onSelected: (value) async {
                              final newBuildingId =
                                  value.isEmpty
                                      ? null
                                      : value.first['zAttributesId'] as int;

                              if (newBuildingId == null ||
                                  (_selectedBuildingNotifier.value.isNotEmpty &&
                                      _selectedBuildingNotifier
                                              .value
                                              .first['zAttributesId'] ==
                                          newBuildingId)) {
                                return;
                              }

                              _selectedBuildingNotifier.value = value;

                              await _tenantCubit.getTenantList(
                                context: context,
                                projectId: _project.projectId,
                                buildingId: newBuildingId,
                                pageNumber: 1,
                              );
                            },
                            dataFetchCallBack: _fetchBuildings,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Building is required";
                              }
                              return null;
                            },
                            onClear: () {
                              _selectedBuildingNotifier.value = [];
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

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
                        return Center(
                          child: noDataWidget(message: 'No Tenants Found'),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          _searchC.clear();
                          _tenantCubit.searchTenant(
                            "",
                            context,
                            _project.projectId,
                            _selectedBuildingNotifier
                                    .value
                                    .first["zAttributesId"]
                                as int,
                          );
                        },
                        child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemCount: state.tenantList.length + 1,
                          separatorBuilder:
                              (context, index) => verticalSpacing(height: 12),
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
                            final applicant = tenant.tenantApplicantData.where(
                              (e) =>
                                  e.applicantType.toLowerCase() == "applicant",
                            );
                            final applicantName =
                                applicant.isNotEmpty
                                    ? applicant.first.applicantName
                                    : '';
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: commonCardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    tenant.systemGeneratedCode,
                                                    style: AppTextStyle.ts12M(),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      copy(
                                                        context: context,
                                                        text:
                                                            tenant
                                                                .systemGeneratedCode,
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 10,
                                                          ),
                                                      child: Icon(
                                                        Icons.copy,
                                                        size: 16,
                                                        color: AppColor.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            GestureDetector(
                                              onTap: () async {
                                                await _tenantCubit
                                                    .clearTenantDocument();
                                                goRouter.pushNamed(
                                                  AppRoutes.viewTenant,
                                                  queryParameters: {
                                                    "tenant":
                                                        EncryptionManager.encryptData(
                                                          jsonEncode(
                                                            tenant.toJson(),
                                                          ),
                                                        ),
                                                  },
                                                );
                                              },
                                              child: Text(
                                                tenant.unitAnnexureSurveyNumber,
                                                style: AppTextStyle.ts16M(
                                                  color: AppColor.primary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            RichText(
                                              text: TextSpan(
                                                text: applicantName,
                                                style: AppTextStyle.ts14M(),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "\n • ${tenant.unitType}",
                                                    style: AppTextStyle.ts12M(
                                                      color: AppColor.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          CustomIconButton.edit(
                                            isDisabled:
                                                !_routeAuthorizationModel
                                                    .isAction,
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
                                                  "tenant":
                                                      Uri.encodeQueryComponent(
                                                        EncryptionManager.encryptData(
                                                          jsonEncode(
                                                            tenant.toJson(),
                                                          ),
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
                                            isDisabled:
                                                !_routeAuthorizationModel
                                                    .isAction,
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
                                  Divider(
                                    height: 28,
                                    color: AppColor.grey2.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  _sectionChip(
                                    "ELIGIBILITY",
                                    Colors.deepPurple.shade50,
                                    Colors.deepPurple,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Free Offer Area",
                                        value:
                                            "${tenant.extraFreeCarpetAreaOfferedPercent}%",
                                      ),
                                      buildColumnTitleValue(
                                        title: "Free MOFA",
                                        value:
                                            "${tenant.freeMOFACarpetAreaSqFt} SqFt",
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: 28,
                                    color: AppColor.grey2.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  buildRowWrapper(
                                    child: buildColumnTitleValue(
                                      title:
                                          "Total New RERA CA With Deck & Terrace",
                                      value:
                                          "${tenant.totalNewRERACarpetAreaSqFt + tenant.deckAreaSqFt + tenant.areaAgainstTerraceSqFt} SqFt",
                                    ),
                                  ),
                                  Divider(
                                    height: 28,
                                    color: AppColor.grey2.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  _sectionChip(
                                    "NEW UNIT",
                                    Colors.green.shade50,
                                    Colors.green,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Building",
                                        value: tenant.buildingNumber,
                                      ),
                                      buildColumnTitleValue(
                                        title: "Wing | Floor",
                                        value:
                                            tenant.wing.isNotEmpty &&
                                                    tenant.floor.isNotEmpty
                                                ? "${tenant.wing} | ${tenant.floor}"
                                                : '-',
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: 28,
                                    color: AppColor.grey2.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Unit No.",
                                        value: tenant.inventoryFlatType,
                                      ),
                                      buildColumnTitleValue(
                                        title: "Unit Type",
                                        value: tenant.inventoryFlatType,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
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
    );
  }
}

Widget _sectionChip(String title, Color bgColor, Color dotColor) {
  return statusChip(
    title,
    bgColor,
    dotColor,
    textStyle: AppTextStyle.ts10M().copyWith(color: dotColor),
    leading: Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    ),
  );
}
