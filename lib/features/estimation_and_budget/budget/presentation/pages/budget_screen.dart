import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/budget.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/presentation/cubit/budget_cubit.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/presentation/cubit/budget_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/status/budget_level_status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BudgetMasterScreen extends StatefulWidget {
  const BudgetMasterScreen({super.key});
  @override
  State<BudgetMasterScreen> createState() => _BudgetMasterScreenState();
}

class _BudgetMasterScreenState extends State<BudgetMasterScreen> {
  // CUBIT
  late BudgetCubit _budgetCubit;
  late UtilsCubit _utilsCubit;
  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _filterFlatC, _filterUomC;
  late ProjectModel _selectedProject;
  final ValueNotifier<Map<String, dynamic>?> _selectedLevelTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<int> _filterCount = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
    _budgetCubit = context.read<BudgetCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.budget]!;
    _initializeTextEditingController();
    _selectedProject = getProject();
    _budgetCubit.getBudgetList(
      context,
      1,
      projectId: _selectedProject.projectId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterFlatC.dispose();
    _filterUomC.dispose();
    _filterCount.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterFlatC = TextEditingController();
    _filterUomC = TextEditingController();
  }

  Future<void> _showBottomSheetToFilterBudget(BuildContext context) async {
    final state = _budgetCubit.state;
    _filterFlatC.text = state.filterByFlatType;
    _filterUomC.text = state.filterByUom;
    _searchC.text = state.searchText;
    final initialLevelType = state.filterByLevelType;
    if (initialLevelType.isNotEmpty) {
      _selectedLevelTypeNotifier.value = budgetLevelTypeList.firstWhere(
        (e) => e['DisplayName'] == initialLevelType,
        orElse: () => budgetLevelTypeList.first,
      );
    }
    final String initialCategoryName = _searchC.text;
    final String initialUom = _filterUomC.text;
    final String initialFlatLevelType = _filterFlatC.text;
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;
    void updateApplyState(StateSetter innerState) {
      final currentLevelType =
          (_selectedLevelTypeNotifier.value?['zAttributesId'] == -1)
              ? ''
              : _selectedLevelTypeNotifier.value?['DisplayName'] ?? '';
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialCategoryName) ||
            (_filterUomC.text.trim() != initialUom) ||
            (currentLevelType != initialLevelType) ||
            (_filterFlatC.text.trim() != initialFlatLevelType);
        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Budget",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEVEL TYPE
                ValueListenableBuilder(
                  valueListenable: _selectedLevelTypeNotifier,
                  builder: (context, value, child) {
                    return CustomDropDownWidget(
                      title: "Level Type",
                      hintText: "Select Level Type",
                      initialValue: value,
                      dataList: budgetLevelTypeList,
                      onSelected: (v) {
                        innerState(() {
                          _selectedLevelTypeNotifier.value = v;
                        });
                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        _selectedLevelTypeNotifier.value = null;
                        updateApplyState(innerState);
                      },
                    );
                  },
                ),
                // CATEGORY NAME
                CustomTextField(
                  title: "Category Name",
                  hint: "Enter Category Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                // UOM
                CustomTextField(
                  title: "UOM",
                  hint: "Enter UOM",
                  textController: _filterUomC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                // FLAT LEVEL TYPE
                CustomTextField(
                  title: "Flat",
                  hint: "Enter Flat",
                  textController: _filterFlatC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _filterFlatC.clear();
        _filterUomC.clear();
        _filterFlatC.clear();
        _selectedLevelTypeNotifier.value = null;
        _budgetCubit.applyBudgetFilter(
          context: context,
          isClear: true,
          projectId: _selectedProject.projectId,
        );
      },
      onApply: () {
        applied = true;
        _budgetCubit.applyBudgetFilter(
          context: context,
          categoryName: _searchC.text.trim(),
          uom: _filterUomC.text.trim(),
          levelType:
              (_selectedLevelTypeNotifier.value != null)
                  ? _selectedLevelTypeNotifier.value!['DisplayName']
                  : '',
          flatType: _filterFlatC.text.trim(),
          projectId: _selectedProject.projectId,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterFlatC.clear();
      _filterUomC.clear();
      _selectedLevelTypeNotifier.value = null;
      _filterFlatC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetCubit, BudgetState>(
      listener: (context, state) {
        _filterCount.value = _budgetCubit.updateFilterCount(state);
        if (state.searchText.trim().isEmpty) {
          _searchC.clear();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: 'Budget',
          authorization: _routeAuthorizationModel,
          onExportCallback: (value) {
            _budgetCubit.exportExcelPdf(
              context,
              value,
              projectId: _selectedProject.projectId,
            );
          },
          searchHintText: "Search by Category Name",
          onSearchSubmit: (value) {
            _budgetCubit.searchBudget(
              context,
              value,
              _selectedProject.projectId,
            );
          },
          onProjectChangeCallback: (project) {
            _selectedProject = project;
            _budgetCubit.searchBudget(context, "", _selectedProject.projectId);
            _searchC.clear();
          },
          textController: _searchC,
          isFilterOn: true,
          filterCountNotifier: _filterCount,
          onFilterTap: () {
            _showBottomSheetToFilterBudget(context);
          },
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<BudgetCubit, BudgetState>(
                builder: (context, state) {
                  return showSiteSelectedWidget();
                },
              ),
              BlocBuilder<BudgetCubit, BudgetState>(
                builder: (context, state) {
                  if (state.budgetList.isEmpty) {
                    return SizedBox.shrink();
                  }
                  final budget = state.budgetList.first;
                  return Container(
                    decoration: commonCardDecoration(),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: EdgeInsets.only(bottom: 8),
                    child: ApproveRejectWidget(
                      actionTitle: budget.approvalStatus,
                      isActionAlreadyPerformed: !budget.isApproval,
                      isMaster: true,
                      popupTitle: "Approve Budget",
                      showApproval: budget.isApproval,
                      onApprove: (val) async {
                        final success = await _utilsCubit
                            .updateModulesWorkflowApproval(
                              context: context,
                              moduleName: 'BUDGET APPROVAL',
                              id: _selectedProject.projectId,
                              projectId: _selectedProject.projectId,
                              isApproved: true,
                              remark: val.trim(),
                            );
                        if (context.mounted && success) {
                          _budgetCubit.getBudgetList(
                            context,
                            1,
                            projectId: _selectedProject.projectId,
                          );
                        }
                      },
                      onReject: (val) async {
                        final success = await _utilsCubit
                            .updateModulesWorkflowApproval(
                              context: context,
                              moduleName: 'BUDGET APPROVAL',
                              id: _selectedProject.projectId,
                              projectId: _selectedProject.projectId,
                              isApproved: false,
                              remark: val.trim(),
                            );
                        if (context.mounted && success) {
                          _budgetCubit.getBudgetList(
                            context,
                            1,
                            projectId: _selectedProject.projectId,
                          );
                        }
                      },
                      onThirdTap: () async {
                        final approvalLogHistoryList = await _utilsCubit
                            .getApprovalLogHistory(
                              context: context,
                              projectId: _selectedProject.projectId,
                              id: _selectedProject.projectId,
                              moduleName: "BUDGET APPROVAL",
                            );
                        if (context.mounted) {
                          goRouter.pushNamed(
                            AppRoutes.approvalLogHistory,
                            queryParameters: {
                              "title": Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  "Budget Log History",
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
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<BudgetCubit, BudgetState>(
                  builder: (context, state) {
                    if ((state.isLoading ?? false) &&
                        state.budgetList.isEmpty) {
                      return Center(child: loader());
                    } else if (state.budgetList.isEmpty) {
                      return Center(
                        child: noDataWidget(message: "No Budget Data Found"),
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () async {
                          _searchC.clear();
                          _budgetCubit.searchBudget(
                            context,
                            "",
                            _selectedProject.projectId,
                          );
                        },
                        child: ListView.builder(
                          itemCount: state.budgetList.length,
                          itemBuilder: (context, index) {
                            final budget = state.budgetList[index];
                            return estimatedWorkCard(
                              budget,
                              state.originalBudgetList,
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<BudgetCubit, BudgetState>(
          builder: (context, state) {
            final grandTotal = state.originalBudgetList
                .where((element) => element.levelType == 'L1')
                .fold(0.0, (a, b) => a + b.budgetAmount);
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColor.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: IntrinsicHeight(
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Grand Total Project Budget:",
                      style: AppTextStyle.ts14M(color: AppColor.lightBlue),
                    ),
                    Text(
                      grandTotal.toIndianCurrency(),
                      style: AppTextStyle.ts14M(color: AppColor.lightBlue),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget estimatedWorkCard(BudgetModel budget, List<BudgetModel> budgetList) {
    final groupItems =
        budgetList.where((e) => e.levelId1 == budget.levelId1).toList();
    final l2Count =
        groupItems
            .where((e) => e.levelType == 'L2')
            .map((e) => e.levelId2)
            .toSet()
            .length;
    final l3Count =
        groupItems
            .where((e) => e.levelType == 'L3')
            .map((e) => e.levelId3)
            .toSet()
            .length;
    final l4Count =
        groupItems
            .where((e) => e.levelType == 'L4')
            .map((e) => e.levelId4)
            .toSet()
            .length;
    if (budget.levelType != "L1" && _searchC.text.isEmpty) {
      return SizedBox.shrink();
    }
    final config = budgetLevelConfig[budget.levelType];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8FF),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFD0D5E2)),
      ),
      child: Column(
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: config?.backgroundColor ?? AppColor.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  budget.levelType,
                  style: AppTextStyle.ts12M(
                    color: config?.textColor ?? Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  budget.categoryName,
                  style: AppTextStyle.ts14SB(color: AppColor.darkBlue900),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.r),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: Text(
                  'WBS: ${budget.wBSCode}',
                  style: AppTextStyle.ts12M(
                    color: AppColor.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          buildRowTitleValue(
            title: "Total Amount",
            value: budget.totalRate.toIndianCurrency(),
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Budget Amount",
            value: budget.budgetAmount.toIndianCurrency(),
            singleLine: false,
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, thickness: 1, color: AppColor.grey30),
          SizedBox(height: 7.h),
          Row(
            children: [
              Text(
                'L2 : $l2Count',
                style: AppTextStyle.ts12M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(width: 18.w),
              Text(
                'L3 : $l3Count',
                style: AppTextStyle.ts12M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(width: 18.w),
              Text(
                'L4 : $l4Count',
                style: AppTextStyle.ts12M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () async {
                  final budgetListJson = jsonEncode(
                    groupItems.map((item) => item.toJson()).toList(),
                  );
                  final encryptedData = EncryptionManager.encryptData(
                    budgetListJson,
                  );
                  await goRouter.pushNamed(
                    AppRoutes.viewBudget,
                    queryParameters: {
                      'budgetList': Uri.encodeComponent(encryptedData),
                    },
                  );
                },
                child: Text(
                  'View Details',
                  style: AppTextStyle.ts14M(color: AppColor.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
