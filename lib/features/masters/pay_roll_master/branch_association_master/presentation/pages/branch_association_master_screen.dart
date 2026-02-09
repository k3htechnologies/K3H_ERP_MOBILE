import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/model/branch_association_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/cubit/branch_association_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BranchAssociationMasterScreen extends StatefulWidget {
  const BranchAssociationMasterScreen({super.key});

  @override
  State<BranchAssociationMasterScreen> createState() =>
      _BranchAssociationMasterScreenState();
}

class _BranchAssociationMasterScreenState
    extends State<BranchAssociationMasterScreen> {
  // CUBIT
  late BranchAssociationMasterCubit _branchAssociationMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _branchAssociationMasterCubit =
        context.read<BranchAssociationMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.branchAssociation] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _branchAssociationMasterCubit.getBranchAssociationList(
      context: context,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    super.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_branchAssociationMasterCubit.state.isLoading ?? false) &&
          _branchAssociationMasterCubit.state.branchAssociationList.length <
              _branchAssociationMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _branchAssociationMasterCubit.getBranchAssociationList(
            context: context,
            pageNumber: _branchAssociationMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE ASSET MAPPING ---->
  Future<void> _showPopupToDeleteBranchAssociationMaster(
    BuildContext context,
    BranchAssociationModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Branch Association?',
      'Deleting this Branch Association will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _branchAssociationMasterCubit.deleteBranchAssociation(
        index,
        obj,
        context,
      );
    }
  }

  // SORT BOTTOM SHEET - BRANCH ASSOCIATION (EMPLOYEE NAME)
  Future<void> _showSortBottomSheetForBranchAssociation(
    BuildContext context,
  ) async {
    final state = _branchAssociationMasterCubit.state;

    String? selectedDirection =
        state.currentSortColumn == "Employee Name"
            ? state.currentSortDirection
            : null;

    final String? initialDirection = selectedDirection;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        applyEnabled.value = selectedDirection != initialDirection;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Sort Branch Association",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Sort By Employee Name", style: AppTextStyle.ts14M()),
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
            ],
          );
        },
      ),
      onClear: () {
        _branchAssociationMasterCubit.applyFilterAndSort(
          context: context,
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        applied = true;
        _branchAssociationMasterCubit.applyFilterAndSort(
          context: context,
          sortColumn: "Employee Name",
          sortDirection: selectedDirection,
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
        screenTitle: "Branch Association Master",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {
          _branchAssociationMasterCubit.searchAssetMapping(value, context);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addBranchAssociation);
          if (context.mounted) {
            _branchAssociationMasterCubit.getBranchAssociationList(
              context: context,
              pageNumber: 1,
            );
          }
        },
        onExportCallback: (value) {
          if (_branchAssociationMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _branchAssociationMasterCubit.exportExcelPdf(context, value);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showSortBottomSheetForBranchAssociation(context);
        },
      ),
      body: BlocBuilder<
        BranchAssociationMasterCubit,
        BranchAssociationMasterState
      >(
        builder: (context, state) {
          if ((state.isLoading ?? true) &&
              state.branchAssociationList.isEmpty) {
            return Center(child: loader());
          }
          if (state.branchAssociationList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.branchAssociationList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.branchAssociationList.length) {
                return state.branchAssociationList.length <
                        state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var branchAssociation = state.branchAssociationList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              goRouter.pushNamed(
                                AppRoutes.viewBranchAssociation,
                                queryParameters: {
                                  "branchAssociation": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(branchAssociation.toJson()),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColor.primary),
                                ),
                              ),
                              child: Text(
                                branchAssociation.employeeName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          verticalSpacing(height: 5),
                          Text(
                            branchAssociation.branchName,
                            style: AppTextStyle.ts12M(color: AppColor.grey),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 10,
                      children: [
                        CustomIconButton.edit(
                          onPressed: () async {
                            goRouter.pushNamed(
                              AppRoutes.addBranchAssociation,
                              queryParameters: {
                                "branchAssociation": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(branchAssociation.toJson()),
                                  ),
                                ),
                                "index": index.toString(),
                              },
                            );
                          },
                        ),
                        CustomIconButton.delete(
                          onPressed: () {
                            _showPopupToDeleteBranchAssociationMaster(
                              context,
                              branchAssociation,
                              index,
                            );
                          },
                        ),
                      ],
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
