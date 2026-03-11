import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/cubit/shift_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/cubit/shift_master_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ShiftMasterScreen extends StatefulWidget {
  const ShiftMasterScreen({super.key});

  @override
  State<ShiftMasterScreen> createState() => _ShiftMasterScreenState();
}

class _ShiftMasterScreenState extends State<ShiftMasterScreen> {
  //CUBIT
  late ShiftMasterCubit _shiftMasterCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;
  @override
  void initState() {
    super.initState();
    _shiftMasterCubit = context.read<ShiftMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.shiftMaster] ??
        AuthorizationModel();
    _onScroll();
    _initializeTextEditingController();
    _shiftMasterCubit.getShiftList(context: context, pageNumber: 1);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _searchC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_shiftMasterCubit.state.isLoading ?? false) &&
          _shiftMasterCubit.state.shiftMasterList.length <
              _shiftMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _shiftMasterCubit.getShiftList(
            context: context,
            pageNumber: _shiftMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // DELETE SHIFT
  Future<void> _showPopupToDeleteShiftMaster(
    BuildContext context,
    ShiftMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Shift?',
      'Deleting this Shift will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _shiftMasterCubit.deleteShift(index, obj, context);
    }
  }

  // SORT BOTTOM SHEET - SHIFT (SHIFT NAME)
  Future<void> _showSortBottomSheetForShift(BuildContext context) async {
    final state = _shiftMasterCubit.state;

    String? selectedDirection =
        state.currentSortColumn == "Shift Name"
            ? state.currentSortDirection
            : null;

    final String? initialDirection = selectedDirection;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        applyEnabled.value = selectedDirection != initialDirection;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Sort Shift",
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
              Text("Sort By Shift Name", style: AppTextStyle.ts14M()),
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
        _shiftMasterCubit.applyFilterAndSort(
          context: context,
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        _shiftMasterCubit.applyFilterAndSort(
          context: context,
          sortColumn: "Shift Name",
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
        screenTitle: "Shift Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addShiftMaster);
          if (context.mounted) {
            _shiftMasterCubit.searchShift("", context);
          }
        },
        textController: _searchC,
        searchHintText: "Search by Shift Name",
        onExportCallback: (value) {
          if (_shiftMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _shiftMasterCubit.exportExcelPdf(context, value);
        },
        onSearchSubmit: (value) {
          _shiftMasterCubit.searchShift(value, context);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showSortBottomSheetForShift(context);
        },
      ),
      body: BlocBuilder<ShiftMasterCubit, ShiftMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.shiftMasterList.isEmpty) {
            return Center(child: loader());
          }
          if (state.shiftMasterList.isEmpty) {
            return Center(child: noDataWidget(message: "No Shift Data Found"));
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.shiftMasterList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.shiftMasterList.length) {
                return state.shiftMasterList.length < state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var shiftMaster = state.shiftMasterList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              goRouter.pushNamed(
                                AppRoutes.viewShiftMaster,
                                queryParameters: {
                                  "shift": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(shiftMaster.toJson()),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Text(
                              shiftMaster.shiftName,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ).copyWith(decoration: TextDecoration.underline,decorationColor: AppColor.primary),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addShiftMaster,
                                  queryParameters: {
                                    "shift": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(shiftMaster.toJson()),
                                      ),
                                    ),
                                    'index': index.toString(),
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteShiftMaster(
                                  context,
                                  shiftMaster,
                                  state.currentPage,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 10),
                    buildRowTitleValue(
                      title: "Shift Code",
                      value: shiftMaster.shiftCode,
                    ),
                    buildRowTitleValue(
                      title: "Shift Begin Time",
                      value: shiftMaster.shiftBeginTime,
                    ),
                    buildRowTitleValue(
                      title: "Shift End Time",
                      value: shiftMaster.shiftEndTime,
                    ),
                    buildRowTitleValue(
                      title: "Shift Duration Time",
                      value: shiftMaster.shiftDurationTime,
                    ),

                    buildRowTitleValue(
                      title: "Shift Work Duration Time",
                      value: shiftMaster.shiftWorkDurationTime,
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
