import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/cubit/branch_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BranchMasterScreen extends StatefulWidget {
  const BranchMasterScreen({super.key});

  @override
  State<BranchMasterScreen> createState() => _BranchMasterScreenState();
}

class _BranchMasterScreenState extends State<BranchMasterScreen> {
  // CUBIT
  late BranchMasterCubit _branchMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterBranchCodeC,
      _filterBranchLocationC;

  @override
  void initState() {
    super.initState();
    _branchMasterCubit = context.read<BranchMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.branchMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _branchMasterCubit.getBranchList(context: context, pageNumber: 1);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _filterBranchCodeC.dispose();
    _filterBranchLocationC.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterBranchCodeC = TextEditingController();
    _filterBranchLocationC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_branchMasterCubit.state.isLoading ?? false) &&
          _branchMasterCubit.state.branchList.length <
              _branchMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _branchMasterCubit.getBranchList(
            context: context,
            pageNumber: _branchMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE ASSET MAPPING ---->
  Future<void> _showPopupToDeleteAssetMappingMaster(
    BuildContext context,
    BranchMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Asset Mapping?',
      'Deleting this Asset Mapping will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _branchMasterCubit.deleteBranchMaster(
        context: context,
        branchMasterId: obj.branchMasterId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  // <---- FILTER BRANCH ---->
  Future<void> _showBottomSheetToFilterBranch(BuildContext context) async {
    final state = _branchMasterCubit.state;

    _filterBranchCodeC.text = state.filterBranchCode;
    _filterBranchLocationC.text = state.filterBranchLocation;

    String? selectedDirection =
        state.currentSortColumn == "Branch Name"
            ? state.currentSortDirection
            : null;

    final String initialBranchCode = _filterBranchCodeC.text;
    final String initialBranchLocation = _filterBranchLocationC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterBranchCodeC.text.trim() != initialBranchCode) ||
            (_filterBranchLocationC.text.trim() != initialBranchLocation) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Branch",
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
                Text("Sort By Branch Code", style: AppTextStyle.ts14M()),
                verticalSpacing(),
                Row(
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
                  title: "Branch Code",
                  hint: "Enter Branch Code",
                  textController: _filterBranchCodeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Branch Location",
                  hint: "Enter Branch Location",
                  textController: _filterBranchLocationC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _branchMasterCubit.applyFilterAndSort(
          context: context,
          filterBranchCode: "",
          filterBranchLocation: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        applied = true;
        _branchMasterCubit.applyFilterAndSort(
          context: context,
          filterBranchCode: _filterBranchCodeC.text,
          filterBranchLocation: _filterBranchLocationC.text,
          sortColumn: selectedDirection != null ? "Branch Name" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    if (!applied && manualClose) {
      _filterBranchCodeC.clear();
      _filterBranchLocationC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Branch Master",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _branchMasterCubit.searchBranch(value, context);
        },
        textController: _searchC,
        searchHintText: "Search  by Branch Name",
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addBranchMaster);
          if (context.mounted) {
            _branchMasterCubit.searchBranch("", context);
          }
        },
        onExportCallback: (value) {
          if (_branchMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _branchMasterCubit.exportExcelPdf(context, value);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterBranch(context);
        },
      ),
      body: BlocBuilder<BranchMasterCubit, BranchMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.branchList.isEmpty) {
            return Center(child: loader());
          }
          if (state.branchList.isEmpty) {
            return Center(child: noDataWidget(message: "No Branch Data Found"));
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.branchList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.branchList.length) {
                return state.branchList.length < state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var branch = state.branchList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              goRouter.pushNamed(
                                AppRoutes.viewBranchMaster,
                                queryParameters: {
                                  "branchMaster": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(branch.toJson()),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Text(
                              branch.branchName,
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
                                  AppRoutes.addBranchMaster,
                                  queryParameters: {
                                    "branchMaster": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(branch.toJson()),
                                      ),
                                    ),
                                    'index': index.toString(),
                                  },
                                );
                              },
                            ),
                            if (branch.numberOfEmployee == 0) ...[
                              const SizedBox(width: 8),
                              CustomIconButton.delete(
                                onPressed: () {
                                  _showPopupToDeleteAssetMappingMaster(
                                    context,
                                    branch,
                                    state.currentPage,
                                    index,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 8),
                    buildRowTitleValue(
                      title: "Branch Code",
                      value: branch.branchCode,
                    ),
                    buildRowTitleValue(
                      title: "Location",
                      value: branch.location,
                    ),
                    buildRowTitleValue(
                      title: "Employee Count",
                      value: branch.numberOfEmployee.toString(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
