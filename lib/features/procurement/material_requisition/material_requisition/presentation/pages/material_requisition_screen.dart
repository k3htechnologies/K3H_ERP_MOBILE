import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MaterialRequisitonScreen extends StatefulWidget {
  const MaterialRequisitonScreen({super.key});

  @override
  State<MaterialRequisitonScreen> createState() =>
      _MaterialRequisitonScreenState();
}

class _MaterialRequisitonScreenState extends State<MaterialRequisitonScreen> {
  // CUBIT
  late MaterialRequisitionCubit _materialRequisitionCubit;
  late UtilsCubit _utilsCubit;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _searchC;
  // FILTER
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  Map<String, dynamic>? selectedMaterialRequisitionStage;
  Map<String, dynamic>? selectedMaterialRequisitionStatus;

  @override
  void initState() {
    super.initState();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.materialRequisition]!;
    _materialRequisitionCubit.getMaterialRequisitionList(context, 1);
    _onScroll();
    _initializeTextEditingController();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_materialRequisitionCubit.state.isLoading! &&
          _materialRequisitionCubit.state.materialRequisitionList.length <
              _materialRequisitionCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _materialRequisitionCubit.getMaterialRequisitionList(
            context,
            _materialRequisitionCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _filterCount.dispose();
    _searchC.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // void _showPopupToDeleteMaterialRequisition({
  //   required int index,
  //   required MaterialRequisitionModel materialRequisitionModel,
  //   required BuildContext context,
  // }) async {
  //   var result = await DialogHelper.deleteDialog(
  //     context,
  //     'You are about to delete this Material Requisition',
  //     'Deleting this Material Requisition will permanently remove its contents.',
  //   );

  //   if (result && context.mounted) {
  //     _materialRequisitionCubit.deleteMaterialRequisition(
  //       index: index,
  //       materialRequisitionModel: materialRequisitionModel,
  //       context: context,
  //     );
  //   }
  // }

  Future<void> _showBottomSheetToFilterMaterialRequisition(
    BuildContext context,
  ) async {
    final s = _materialRequisitionCubit.state;

    String? selectedDirection =
        s.currentSortColumn == "SystemGeneratedCode"
            ? s.currentSortDirection
            : null;

    final String initialUniqueId = s.searchText;

    final String initialStage = s.filterByMaterialRequisitionStage;

    final String initialStatus = s.filterByMaterialRequisitionStatus;

    final DateTime? initialFromDate = s.filterByFromDate;

    final DateTime? initialToDate = s.filterByToDate;

    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        final bool onlyOneDateSet =
            (_startDateNotifier.value != null &&
                _endDateNotifier.value == null) ||
            (_startDateNotifier.value == null &&
                _endDateNotifier.value != null);

        manualClose =
            _searchC.text.trim() != initialUniqueId ||
            _startDateNotifier.value != initialFromDate ||
            _endDateNotifier.value != initialToDate ||
            (selectedMaterialRequisitionStage?['DisplayName'] ?? '') !=
                initialStage ||
            (selectedMaterialRequisitionStatus?['DisplayName'] ?? '') !=
                initialStatus ||
            selectedDirection != initialDirection;

        applyEnabled.value = manualClose && !onlyOneDateSet;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Material Requisition",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(),
                Text("Sort By Unique Id", style: AppTextStyle.ts14M()),

                verticalSpacing(),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        selectedDirection = "ASC";
                        updateApplyState(innerState);
                      },
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
                      onTap: () {
                        selectedDirection = "DESC";
                        updateApplyState(innerState);
                      },
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
                  title: "Unique Id",
                  hint: "Enter Unique Id",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomDropDownWidget(
                  title: "Material Requisition Stage",
                  hintText: "Select Stage",
                  initialValue: selectedMaterialRequisitionStage,
                  dataList: materialRequisitionStagesList,
                  onSelected: (v) {
                    selectedMaterialRequisitionStage = v;

                    updateApplyState(innerState);
                  },

                  onValueClear: () {
                    selectedMaterialRequisitionStage = null;

                    updateApplyState(innerState);
                  },
                ),

                CustomDropDownWidget(
                  title: "Material Requisition Status",
                  hintText: "Select Status",
                  initialValue: selectedMaterialRequisitionStatus,
                  dataList: materialRequisitionStatusList,
                  onSelected: (v) {
                    selectedMaterialRequisitionStatus = v;

                    updateApplyState(innerState);
                  },

                  onValueClear: () {
                    selectedMaterialRequisitionStatus = null;

                    updateApplyState(innerState);
                  },
                ),

                AnimatedBuilder(
                  animation: Listenable.merge([
                    _startDateNotifier,
                    _endDateNotifier,
                  ]),
                  builder: (context, child) {
                    return CustomFromToDatePicker(
                      fromDateTitle: "From Date",
                      toDateTitle: "To Date",
                      removeBottomMargin: false,
                      initialFromDate: _startDateNotifier.value,
                      initialToDate: _endDateNotifier.value,
                      onToDateChanged: (DateTime? fromDate, DateTime? toDate) {
                        _startDateNotifier.value = fromDate;
                        _endDateNotifier.value = toDate;

                        updateApplyState(innerState);
                      },
                    );
                  },
                ),
                verticalSpacing(),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _searchC.clear();

        selectedMaterialRequisitionStage = null;
        selectedMaterialRequisitionStatus = null;

        _startDateNotifier.value = null;
        _endDateNotifier.value = null;

        _materialRequisitionCubit.applyFilterAndSort(
          context: context,
          filterByUniqueId: "",
          filterByMaterialRequisitionStage: "",
          filterByMaterialRequisitionStatus: "",
          filterByFromDate: null,
          filterByToDate: null,
          sortColumn: "Created Date",
          sortDirection: "DESC",
          projectId: 0,
        );
      },

      onApply: () {
        applied = true;
        final startDate = _startDateNotifier.value;

        final endDate = _endDateNotifier.value;

        if (startDate != null && endDate != null) {
          final startOnly = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );

          final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

          if (endOnly.isBefore(startOnly)) {
            showErrorMessage(
              context,
              "Invalid dates",
              "End Date cannot be before Start Date",
            );

            return;
          }
        }

        _materialRequisitionCubit.applyFilterAndSort(
          context: context,
          filterByUniqueId: _searchC.text.trim(),
          filterByMaterialRequisitionStage:
              selectedMaterialRequisitionStage?['DisplayName'],
          filterByMaterialRequisitionStatus:
              selectedMaterialRequisitionStatus?['DisplayName'],
          filterByFromDate: startDate,
          filterByToDate: endDate,
          sortColumn: selectedDirection != null ? "SystemGeneratedCode" : null,
          sortDirection: selectedDirection,
          projectId: 0,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    if (!applied && manualClose) {
      _searchC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaterialRequisitionCubit, MaterialRequisitionState>(
      listener: (context, state) {
        _filterCount.value = _materialRequisitionCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Material Requisition",
          authorization: _routeAuthorizationModel,
          textController: _searchC,
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterMaterialRequisition(context);
          },
          searchHintText: "Search By Unique ID",
          onSearchSubmit: (value) {
            _materialRequisitionCubit.searchMaterialRequisition(context, value);
          },
          onAddCallback: () async {
            await _materialRequisitionCubit.clearMaterialList();
            await goRouter.pushNamed(AppRoutes.addMaterialRequisition);
          },
          onExportCallback: (value) {
            if (_materialRequisitionCubit
                .state
                .materialRequisitionList
                .isEmpty) {
              showErrorMessage(context, "", "No Data Found");
              return;
            }
            _materialRequisitionCubit.exportExcelPdf(context, value);
          },
          filterCountNotifier: _filterCount,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _materialRequisitionCubit.searchMaterialRequisition(context, "");
          },
          child: BlocBuilder<
            MaterialRequisitionCubit,
            MaterialRequisitionState
          >(
            builder: (context, state) {
              if ((state.isLoading ?? true) &&
                  state.materialRequisitionList.isEmpty) {
                return Center(child: loader());
              }
              if (state.materialRequisitionList.isEmpty) {
                return Center(
                  child: noDataWidget(message: "No Material Data Found"),
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount:
                    _materialRequisitionCubit
                        .state
                        .materialRequisitionList
                        .length +
                    1,
                itemBuilder: (context, index) {
                  if (index == state.materialRequisitionList.length) {
                    return state.materialRequisitionList.length <
                            state.totalNumberOfRecord
                        ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  var materialRequisition =
                      state.materialRequisitionList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await _materialRequisitionCubit
                                        .resetOverview();
                                    await goRouter.pushNamed(
                                      AppRoutes.viewMaterialRequisition,
                                      queryParameters: {
                                        "materialRequisitionId":
                                            Uri.encodeQueryComponent(
                                              EncryptionManager.encryptData(
                                                materialRequisition
                                                    .materialRequisitionId
                                                    .toString(),
                                              ),
                                            ),
                                        "projectId": Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            materialRequisition.projectId
                                                .toString(),
                                          ),
                                        ),
                                        "uniquekey": Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            materialRequisition.uniquekey,
                                          ),
                                        ),
                                      },
                                    );
                                  },
                                  child: Text(
                                    materialRequisition.systemGeneratedCode,
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    copy(
                                      context: context,
                                      text:
                                          materialRequisition
                                              .systemGeneratedCode,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.copy,
                                      size: 16,
                                      color: AppColor.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            materialRequisitionStatusWidget(
                              materialRequisition.materialRequisitionStatus,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              materialRequisition.projectName,
                              style: AppTextStyle.ts14SB(),
                            ),
                            Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  LucideIcons.building,
                                  size: 12,
                                  color: AppColor.grey,
                                ),
                                Text(
                                  materialRequisition.companyName,
                                  style: AppTextStyle.ts12M(
                                    color: AppColor.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        infoCard(
                          bgColor: AppColor.lightGreyBackground,
                          borderColor: AppColor.grey2,

                          [
                            {
                              'title': 'Department',
                              'value': materialRequisition.department,
                            },
                            {
                              'title': 'Type',
                              'value':
                                  materialRequisition.materialRequisitionType,
                            },
                          ],
                        ),
                        infoCard(
                          bgColor: AppColor.lightGreyBackground,
                          borderColor: AppColor.grey2,
                          [
                            {
                              'title': 'Total PO Amount',
                              'value':
                                  materialRequisition.totalPoAmount
                                      .toIndianCurrency(),
                              'widget': Text(
                                materialRequisition.totalPoAmount
                                    .toIndianCurrency(),
                                style: AppTextStyle.ts14SB(
                                  color: AppColor.darkGreen50,
                                ),
                              ),
                            },
                            {
                              'title': 'Total Invoice Amount',
                              'value':
                                  materialRequisition.totalInvoiceAmount
                                      .toIndianCurrency(),
                            },
                            {
                              'title': 'Paid Amount',
                              'value':
                                  materialRequisition.paidAmount
                                      .toIndianCurrency(),
                            },
                            {
                              'title': 'TDS Paid Amount',
                              'value':
                                  materialRequisition.tdsPaidAmount
                                      .toIndianCurrency(),
                            },
                          ],
                        ),

                        Divider(height: 1, color: AppColor.lightGrey),
                        buildRowTitleValue(
                          title: "Total Invoices",
                          value: materialRequisition.totalInvoice.addCommas(),
                          fixesWidth: 110,
                          customValueWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IntrinsicWidth(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.lightOrangeBg.withValues(
                                      alpha: 0.5,
                                    ),
                                    // shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColor.rustOrange,
                                    ),
                                  ),
                                  child: Text(
                                    materialRequisition.totalInvoice
                                        .addCommas(),
                                    style: AppTextStyle.ts12SB(
                                      color: AppColor.rustOrange,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ApproveRejectWidget(
                          actionTitle: materialRequisition.approvalStatus,
                          showApproval: materialRequisition.isApproval,
                          popupTitle:
                              "${materialRequisition.systemGeneratedCode} > ${materialRequisition.projectName} > ${materialRequisition.createdBy}",
                          onApprove: (val) async {
                            final isSuccess = await _utilsCubit
                                .updateModulesWorkflowApproval(
                                  context: context,
                                  moduleName: 'MATERIAL REQUISITION APPROVAL',
                                  id: materialRequisition.materialRequisitionId,
                                  projectId: materialRequisition.projectId,
                                  isApproved: true,
                                  remark: val.trim(),
                                );
                            if (context.mounted && isSuccess) {
                              _materialRequisitionCubit
                                  .getMaterialRequisitionList(context, 1);
                            }
                          },
                          onReject: (val) async {
                            final isSuccess = await _utilsCubit
                                .updateModulesWorkflowApproval(
                                  context: context,
                                  moduleName: 'MATERIAL REQUISITION APPROVAL',
                                  id: materialRequisition.materialRequisitionId,
                                  projectId: materialRequisition.projectId,
                                  isApproved: false,
                                  remark: val.trim(),
                                );
                            if (context.mounted && isSuccess) {
                              _materialRequisitionCubit
                                  .getMaterialRequisitionList(context, 1);
                            }
                          },
                          onThirdTap: () async {
                            final approvalLogHistoryList = await _utilsCubit
                                .getApprovalLogHistory(
                                  context: context,
                                  moduleName: 'MATERIAL REQUISITION APPROVAL',
                                  id: materialRequisition.materialRequisitionId,
                                  projectId: materialRequisition.projectId,
                                );

                            if (context.mounted) {
                              goRouter.pushNamed(
                                AppRoutes.approvalLogHistory,
                                queryParameters: {
                                  "subTitle": Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      "${materialRequisition.systemGeneratedCode} > ${materialRequisition.projectName} > ${materialRequisition.createdBy}",
                                    ),
                                  ),
                                  "title": Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      "Material Requisition Log History",
                                    ),
                                  ),
                                  "approvalList": Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(
                                        approvalLogHistoryList
                                            .map((e) => e.toJson())
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget statusWidget(String status) {
    final trimmed = status.trim();

    // IF EMPTY SHOW TEXT
    if (trimmed.isEmpty) {
      return statusChip("-", AppColor.lightGreyBackground, AppColor.black);
    }

    final s = trimmed.toLowerCase();

    switch (s) {
      case 'completed':
        return statusChip(
          status,
          AppColor.green20.withValues(alpha: 0.1),
          AppColor.green,
        );

      case 'closed':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      case 'ongoing':
        return statusChip(status, AppColor.lightBlue2, AppColor.info);

      default:
        return statusChip(status, AppColor.lightGreyBackground, AppColor.black);
    }
  }
}
