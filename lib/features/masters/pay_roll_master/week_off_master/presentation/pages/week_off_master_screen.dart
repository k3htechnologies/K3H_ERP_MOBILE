import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/cubit/week_off_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/cubit/week_off_master_state.dart';
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

class WeekOffMasterScreen extends StatefulWidget {
  const WeekOffMasterScreen({super.key});

  @override
  State<WeekOffMasterScreen> createState() => _WeekOffMasterScreenState();
}

class _WeekOffMasterScreenState extends State<WeekOffMasterScreen> {
  //CUBIT
  late WeekOffMasterCubit _weekOffMasterCubit;

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
    _weekOffMasterCubit = context.read<WeekOffMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.weekOffMaster] ??
        AuthorizationModel();
    _onScroll();
    _initializeTextEditingController();
    _weekOffMasterCubit.getWeekOffList(context: context, pageNumber: 1);
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
          !(_weekOffMasterCubit.state.isLoading ?? false) &&
          _weekOffMasterCubit.state.weekOffMasterList.length <
              _weekOffMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _weekOffMasterCubit.getWeekOffList(
            context: context,
            pageNumber: _weekOffMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // DELETE WEEK OFF
  Future<void> _showPopupToDeleteWeekOffMaster(
    BuildContext context,
    WeekOffMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Week Off?',
      'Deleting this Week Off will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _weekOffMasterCubit.deleteWeekOff(index, obj, context);
    }
  }

  // SORT BOTTOM SHEET - WEEK OFF (WEEK OFF NAME)
  Future<void> _showSortBottomSheetForEarning(BuildContext context) async {
    final state = _weekOffMasterCubit.state;

    String? selectedDirection =
        state.currentSortColumn == "Week Off Policy Name"
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
      title: "Sort Week Off",
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
              Text("Sort By Week Off Name", style: AppTextStyle.ts14M()),
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
        _weekOffMasterCubit.applyFilterAndSort(
          context: context,
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        _weekOffMasterCubit.applyFilterAndSort(
          context: context,
          sortColumn: "Week Off Policy Name",
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
        screenTitle: "Week Off Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addWeekOffMaster);
          if (context.mounted) {
            _weekOffMasterCubit.searchWeekOff("", context);
          }
        },
        textController: _searchC,
        searchHintText: "Search by Week Off Name",
        onExportCallback: (value) {
          if (_weekOffMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _weekOffMasterCubit.exportExcelPdf(context, value);
        },
        onSearchSubmit: (value) {
          _weekOffMasterCubit.searchWeekOff(value, context);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showSortBottomSheetForEarning(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _weekOffMasterCubit.searchWeekOff("", context);
        },
        child: BlocBuilder<WeekOffMasterCubit, WeekOffMasterState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.weekOffMasterList.isEmpty) {
              return Center(child: loader());
            }
            if (state.weekOffMasterList.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                      height: getActualHeight(context) * .7,
                      child: Center(child: noDataWidget(message: "No Week Off Found"))),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: state.weekOffMasterList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.weekOffMasterList.length) {
                  return state.weekOffMasterList.length <
                          state.totalNumberOfRecord
                      ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var weekOffMaster = state.weekOffMasterList[index];
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
                                  AppRoutes.viewWeekOffMaster,
                                  queryParameters: {
                                    "weekOff": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(weekOffMaster.toJson()),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Text(
                                weekOffMaster.weekOffPolicyName,
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomIconButton.edit(
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addWeekOffMaster,
                                    queryParameters: {
                                      "weekOff": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(weekOffMaster.toJson()),
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
                                  _showPopupToDeleteWeekOffMaster(
                                    context,
                                    weekOffMaster,
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
                        title: "Week Off Code",
                        value: weekOffMaster.weekOffPolicyCode,
                      ),
                      buildRowTitleValue(
                        title: "Week Days",
                        value: weekOffMaster.weekDays.toString(),
                      ),
                      buildRowTitleValue(
                        title: "Week Days Starts On",
                        value: weekOffMaster.weekDaysStartsOn,
                      ),
                      buildRowTitleValue(
                        title: "Weekly Off",
                        value: weekOffMaster.weeklyOff,
                      ),
                      buildRowTitleValue(
                        title: "Weekly Off2",
                        value:
                            weekOffMaster.weeklyOff2.isEmpty
                                ? "N/A"
                                : weekOffMaster.weeklyOff2,
                      ),
                      buildRowTitleValue(
                        title: "Weekly Off2 Type",
                        value:
                            weekOffMaster.weeklyOff2Type.isEmpty
                                ? "N/A"
                                : weekOffMaster.weeklyOff2Type,
                      ),
                      buildRowTitleValue(
                        title: "Not Applicable For Months",
                        value: weekOffMaster.notApplicableForMonths,
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
    );
  }
}
