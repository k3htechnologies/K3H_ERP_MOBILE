import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/data/model/dar_allocation.model.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/presentation/cubit/dar_allocation_cubit.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/presentation/pages/widgets/expanded_text.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DARAllocationScreen extends StatefulWidget {
  const DARAllocationScreen({super.key});

  @override
  State<DARAllocationScreen> createState() => _DARAllocationScreenState();
}

class _DARAllocationScreenState extends State<DARAllocationScreen> {
  // CUBIT
  late DarAllocationCubit _darAllocationCubit;

  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _searchC, _filterByEmployeeNameC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FILTER COUNT
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _darAllocationCubit = context.read<DarAllocationCubit>();

    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.darAllocation] ??
        AuthorizationModel();
    initialiseControllers();

    _onScroll();

    _darAllocationCubit.getDarAllocationList(context, 1);
  }

  void initialiseControllers() {
    _searchC = TextEditingController();
    _filterByEmployeeNameC = TextEditingController();
  }

  @override
  void dispose() {
    _searchC.dispose();
    _filterByEmployeeNameC.dispose();
    scrollController.dispose();
    _debounce?.cancel();

    _filterCount.dispose();
    super.dispose();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_darAllocationCubit.state.isLoading! &&
          _darAllocationCubit.state.darAllocationList.length <
              _darAllocationCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _darAllocationCubit.getDarAllocationList(
            context,
            _darAllocationCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteDarAllocation(
    BuildContext context,
    DarAllocationModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a DAR Allocation ?',
      'Deleting this DAR Allocation will permanently remove all associated data.',
    );
    if (shouldDelete && context.mounted) {
      _darAllocationCubit.deleteDarAllocation(obj, context, index);
    }
  }

  Future<void> _showBottomSheetToFilterDarAllocation(
    BuildContext context,
  ) async {
    final state = _darAllocationCubit.state;
    String? selectedDirection =
        state.currentSortColumn == "Employee Name"
            ? state.currentSortDirection
            : null;
    _searchC.text = state.searchText;
    _filterByEmployeeNameC.text = state.searchText;

    final String initialName = _searchC.text;
    final String initialEmployeeName = _filterByEmployeeNameC.text;

    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialEmployeeName) ||
            (_filterByEmployeeNameC.text.trim() != initialName) ||
            (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Dar Allocation",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                verticalSpacing(height: 20),

                CustomTextField(
                  title: "Employee Name",
                  hint: "Enter Employee Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _searchC.clear();
        _filterByEmployeeNameC.clear();

        _darAllocationCubit.applyDarAllocationFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _darAllocationCubit.applyDarAllocationFilterAndSort(
          context: context,
          employeeName: _searchC.text.trim(),

          sortColumn: selectedDirection != null ? "Employee Name" : null,
          sortDirection: selectedDirection,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterByEmployeeNameC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DarAllocationCubit, DarAllocationState>(
      listener: (context, state) {
        _filterCount.value = _darAllocationCubit.updateDarAllocationFilterCount(
          state,
        );
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "DAR Allocation",
          authorization: _routeAuthorizationModel,
          searchHintText: "Search By Employee Name",
          textController: _searchC,
          onSearchSubmit: (value) {
            _darAllocationCubit.searchDarAllocation(context, value);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterDarAllocation(context);
          },
          filterCountNotifier: _filterCount,
          onAddCallback: () {
            goRouter.pushNamed(AppRoutes.addDarAllocation);
          },
          onExportCallback: (value) {
            _darAllocationCubit.exportExcelPdf(context, value);
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _darAllocationCubit.searchDarAllocation(context, "");
          },
          child: BlocBuilder<DarAllocationCubit, DarAllocationState>(
            builder: (context, state) {
              if (state.isLoading == true && state.darAllocationList.isEmpty) {
                return Center(child: loader());
              }
              if (state.darAllocationList.isEmpty) {
                return Center(
                  child: noDataWidget(message: "No DAR Allocation Data Found"),
                );
              }
              return ListView.builder(
                controller: scrollController,
                itemCount: state.darAllocationList.length + 1,
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  if (index == state.darAllocationList.length) {
                    return state.darAllocationList.length <
                            state.totalNumberOfRecord
                        ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  final darAllocation = state.darAllocationList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              darAllocation.employeeName,
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomIconButton.edit(
                                  isDisabled:
                                      !_routeAuthorizationModel.isAction,
                                  onPressed: () {
                                    goRouter.pushNamed(
                                      AppRoutes.addDarAllocation,
                                      queryParameters: {
                                        "darAllocation":
                                            Uri.encodeQueryComponent(
                                              EncryptionManager.encryptData(
                                                jsonEncode(darAllocation),
                                              ),
                                            ),
                                        "index": index.toString(),
                                      },
                                    );
                                  },
                                ),
                                horizontalSpacing(),
                                CustomIconButton.delete(
                                  isDisabled:
                                      !_routeAuthorizationModel.isAction,
                                  onPressed: () {
                                    _showPopupToDeleteDarAllocation(
                                      context,
                                      darAllocation,
                                      state.currentPage,
                                      index,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        ExpandableVillageColumn(
                          title: "Village Name",
                          village: darAllocation.villageName,
                        ),
                        buildRowTitleValue(
                          title: "Number Of CP",
                          value:
                              darAllocation.numberOfChannelPartner.toString(),
                        ),
                        buildRowTitleValue(
                          title: "Created By / Date",
                          value:
                              "${darAllocation.createdBy}- ${formatDate(darAllocation.createdDate)}",
                          singleLine: false,
                        ),
                        if (darAllocation.modifiedBy.isNotEmpty &&
                            darAllocation.modifiedDate != null)
                          buildRowTitleValue(
                            title: "Modified By / Date",
                            value:
                                "${darAllocation.modifiedBy}- ${formatDate(darAllocation.modifiedDate)}",
                            singleLine: false,
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
}
