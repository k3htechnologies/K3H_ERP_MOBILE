import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class MaterialRequisitonScreen extends StatefulWidget {
  const MaterialRequisitonScreen({super.key});

  @override
  State<MaterialRequisitonScreen> createState() =>
      _MaterialRequisitonScreenState();
}

class _MaterialRequisitonScreenState extends State<MaterialRequisitonScreen> {
  // CUBIT
  late MaterialRequisitionCubit _materialRequisitionCubit;
  // SELECTION OF PROJECT
  late ProjectModel _project;
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

  Map<String, dynamic>? selectedMaterialRequisitionStage;
  Map<String, dynamic>? selectedMaterialRequisitionStatus;

  @override
  void initState() {
    super.initState();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.materialRequisition]!;
    _materialRequisitionCubit.getMaterialRequisitionList(
      context,
      1,
      _project.projectId,
    );
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
            _project.projectId,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();

    _debounce?.cancel();
    super.dispose();
  }

  void _showPopupToDeleteMaterialRequisition({
    required int index,
    required MaterialRequisitionModel materialRequisitionModel,
    required BuildContext context,
  }) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete this Material Requisition',
      'Deleting this Material Requisition will permanently remove its contents.',
    );

    if (result && context.mounted) {
      _materialRequisitionCubit.deleteMaterialRequisition(
        index: index,
        materialRequisitionModel: materialRequisitionModel,
        context: context,
      );
    }
  }

  void _prefillFilterFromState() {
    final s = _materialRequisitionCubit.state;

    _startDateNotifier.value = s.filterByFromDate;
    _endDateNotifier.value = s.filterByToDate;

    if (s.filterByMaterialRequisitionStage.isNotEmpty) {
      selectedMaterialRequisitionStage =
          materialRequisitionStagesList
              .where(
                (m) => m['DisplayName'] == s.filterByMaterialRequisitionStage,
              )
              .firstOrNull;
    } else {
      selectedMaterialRequisitionStage = null;
    }

    if (s.filterByMaterialRequisitionStatus.isNotEmpty) {
      selectedMaterialRequisitionStatus =
          materialRequisitionStatusList
              .where(
                (m) => m['DisplayName'] == s.filterByMaterialRequisitionStatus,
              )
              .firstOrNull;
    } else {
      selectedMaterialRequisitionStatus = null;
    }
  }

  Future<void> _showBottomSheetToFilterMaterialRequisition(
    BuildContext context,
  ) async {
    _prefillFilterFromState();

    final s = _materialRequisitionCubit.state;

    bool manualClose = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _startDateNotifier.value != s.filterByFromDate ||
            _endDateNotifier.value != s.filterByToDate ||
            selectedMaterialRequisitionStage?['DisplayName'] !=
                s.filterByMaterialRequisitionStage ||
            selectedMaterialRequisitionStatus?['DisplayName'] !=
                s.filterByMaterialRequisitionStatus;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Material Requisition",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),

              CustomDropDownWidget(
                title: "Material Requisition Stage",
                hintText: "Select Stage",
                initialValue: selectedMaterialRequisitionStage,
                dataList: materialRequisitionStagesList,
                isRequired: true,

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
                isRequired: true,

                onSelected: (v) {
                  selectedMaterialRequisitionStatus = v;

                  updateApplyState(innerState);
                },

                onValueClear: () {
                  selectedMaterialRequisitionStatus = null;

                  updateApplyState(innerState);
                },
              ),

              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _startDateNotifier,
                      builder: (context, startDate, child) {
                        return CustomDatePicker(
                          title: "Start Date",
                          initialDate: startDate,

                          setValue: (value) {
                            _startDateNotifier.value = value;

                            updateApplyState(innerState);
                          },

                          validator: (value) => null,
                        );
                      },
                    ),
                  ),

                  horizontalSpacing(),

                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _endDateNotifier,
                      builder: (context, endDate, child) {
                        return ValueListenableBuilder<DateTime?>(
                          valueListenable: _startDateNotifier,
                          builder: (context, startDate, child) {
                            return CustomDatePicker(
                              title: "End Date",
                              isRequired: false,
                              initialDate: endDate,

                              setValue: (value) {
                                _endDateNotifier.value = value;

                                updateApplyState(innerState);
                              },

                              validator: (value) {
                                if (value == null) {
                                  return null;
                                }

                                if (startDate != null) {
                                  final startDateOnly = DateTime(
                                    startDate.year,
                                    startDate.month,
                                    startDate.day,
                                  );

                                  final endDateOnly = DateTime(
                                    value.year,
                                    value.month,
                                    value.day,
                                  );

                                  if (endDateOnly.isBefore(startDateOnly)) {
                                    return 'End Date cannot be before Start Date';
                                  }
                                }

                                return null;
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),

      onClear: () {
        selectedMaterialRequisitionStage = null;

        selectedMaterialRequisitionStatus = null;

        _startDateNotifier.value = null;
        _endDateNotifier.value = null;

        _materialRequisitionCubit.applyFilterAndSort(
          context: context,
          filterByMaterialRequisitionStage: "",
          filterByMaterialRequisitionStatus: "",
          filterByFromDate: null,
          filterByToDate: null,
          projectId: _project.projectId,
        );
      },

      onApply: () {
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
          filterByMaterialRequisitionStage:
              selectedMaterialRequisitionStage?['DisplayName'],
          filterByMaterialRequisitionStatus:
              selectedMaterialRequisitionStatus?['DisplayName'],
          projectId: _project.projectId,
          filterByFromDate: startDate,
          filterByToDate: endDate,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          _materialRequisitionCubit.searchMaterialRequisition(
            context,
            value,
            _project.projectId,
          );
        },
        onAddCallback: () async {
          await _materialRequisitionCubit.clearMaterialList();
          await goRouter.pushNamed(AppRoutes.addMaterialRequisition);
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _materialRequisitionCubit.applyFilterAndSort(
            context: context,
            filterByMaterialRequisitionStage: "",
            filterByMaterialRequisitionStatus: "",
            filterByFromDate: null,
            filterByToDate: null,
            projectId: _project.projectId,
          );
          _materialRequisitionCubit.getMaterialRequisitionList(
            context,
            1,
            _project.projectId,
          );
        },
        onExportCallback: (value) {
          if (_project.projectId == 0) {
            showErrorMessage(context, "Error", "Please Select a project");
            return;
          }
          if (_materialRequisitionCubit.state.materialRequisitionList.isEmpty) {
            showErrorMessage(context, "", "No Data Found");
            return;
          }
          _materialRequisitionCubit.exportExcelPdf(
            context,
            value,
            _project.projectId,
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _materialRequisitionCubit.searchMaterialRequisition(
            context,
            "",
            _project.projectId,
          );
        },
        child: BlocBuilder<MaterialRequisitionCubit, MaterialRequisitionState>(
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
                var materialRequisition = state.materialRequisitionList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: commonCardDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          GestureDetector(
                            onTap: () async {
                              await _materialRequisitionCubit.resetOverview();
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
                                      materialRequisition.projectId.toString(),
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
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                          horizontalSpacing(width: 2),

                          if (_routeAuthorizationModel.isAction) ...[
                            Row(
                              spacing: 10,
                              children: [
                                CustomIconButton.edit(
                                  isDisabled:
                                      (materialRequisition
                                              .materialRequisitionStage
                                              .toLowerCase() !=
                                          'get quotation'),
                                  onPressed: () async {
                                    await _materialRequisitionCubit
                                        .clearMaterialList();
                                    await goRouter.pushNamed(
                                      AppRoutes.addMaterialRequisition,
                                      queryParameters: {
                                        "materialRequisition":
                                            Uri.encodeQueryComponent(
                                              EncryptionManager.encryptData(
                                                jsonEncode(
                                                  materialRequisition.toJson(),
                                                ),
                                              ),
                                            ),
                                        'index': index.toString(),
                                      },
                                    );
                                  },
                                ),
                                CustomIconButton.delete(
                                  isDisabled:
                                      (materialRequisition
                                              .materialRequisitionStage
                                              .toLowerCase() !=
                                          'get quotation'),
                                  onPressed: () {
                                    _showPopupToDeleteMaterialRequisition(
                                      context: context,
                                      index: index,
                                      materialRequisitionModel:
                                          materialRequisition,
                                    );
                                  },
                                ),
                                CustomIconButton(
                                  onPressed: () async {
                                    if (materialRequisition.isCopy) {
                                      goRouter.goNamed(
                                        AppRoutes.copyMaterialRequisition,
                                        queryParameters: {
                                          "materialRequisition":
                                              Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(
                                                    materialRequisition
                                                        .toJson(),
                                                  ),
                                                ),
                                              ),
                                        },
                                      );
                                    }
                                  },
                                  backgroundColor: AppColor.white,

                                  icon: Icon(
                                    Icons.copy,

                                    size: 16,
                                    color:
                                        materialRequisition.isCopy
                                            ? AppColor.primary
                                            : AppColor.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      buildRowTitleValue(
                        title: "Vendor's Name",
                        fixesWidth: 150,
                        value: materialRequisition.finalVendor,
                      ),
                      buildRowTitleValue(
                        title: "Stage",
                        fixesWidth: 150,
                        value: materialRequisition.materialRequisitionStage,
                      ),
                      buildRowTitleValue(
                        title: "Total PO Amount",
                        fixesWidth: 150,
                        value: addCommasToInteger(
                          materialRequisition.totalPoAmount,
                        ),
                      ),
                      buildRowTitleValue(
                        title: "Invoice Amount",
                        fixesWidth: 150,
                        value: addCommasToInteger(
                          materialRequisition.totalInvoice,
                        ),
                      ),

                      buildRowTitleValue(
                        title: "Status",
                        fixesWidth: 150,
                        value: materialRequisition.materialRequisitionStatus,
                        customValueWidget: statusWidget(
                          materialRequisition.materialRequisitionStatus,
                        ),
                      ),
                      buildRowTitleValue(
                        title: "Purchase Order",
                        fixesWidth: 150,
                        value: materialRequisition.materialRequisitionStatus,
                        customValueWidget: CustomIconButton(
                          onPressed: () {
                            if (materialRequisition
                                .purchaseOrderURL
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                context,
                                materialRequisition.purchaseOrderURL.split(","),
                              );
                            }
                          },
                          backgroundColor: AppColor.white,
                          icon: Icon(
                            Icons.remove_red_eye_outlined,
                            size: 20,
                            color:
                                materialRequisition.purchaseOrderURL.isNotEmpty
                                    ? AppColor.primary
                                    : AppColor.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget statusWidget(String status) {
    final trimmed = status.trim();

    // If empty → show dash
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
