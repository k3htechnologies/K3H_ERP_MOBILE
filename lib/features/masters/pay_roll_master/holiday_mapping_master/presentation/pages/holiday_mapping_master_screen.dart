import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/cubit/holiday_mapping_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class HolidayMappingMasterScreen extends StatefulWidget {
  const HolidayMappingMasterScreen({super.key});

  @override
  State<HolidayMappingMasterScreen> createState() =>
      _HolidayMappingMasterScreenState();
}

class _HolidayMappingMasterScreenState
    extends State<HolidayMappingMasterScreen> {
  // CUBIT
  late HolidayMappingMasterCubit _holidayMappingMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _filterBranchNameC;

  @override
  void initState() {
    super.initState();
    _holidayMappingMasterCubit = context.read<HolidayMappingMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.holidayMappingMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _holidayMappingMasterCubit.getHolidayMappingList(
      context: context,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _filterBranchNameC.dispose();

    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterBranchNameC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_holidayMappingMasterCubit.state.isLoading ?? false) &&
          _holidayMappingMasterCubit.state.holidayMappingList.length <
              _holidayMappingMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _holidayMappingMasterCubit.getHolidayMappingList(
            context: context,
            pageNumber: _holidayMappingMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE HOLIDAY MAPPING  ---->
  Future<void> _showPopupToDeleteHolidayMappingMaster(
    BuildContext context,
    HolidayMappingModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Holiday Mapping?',
      'Deleting this Holiday Mapping will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _holidayMappingMasterCubit.deleteHolidayMapping(index, obj, context);
    }
  }

  // SORT BOTTOM SHEET - HOLIDAY (HOLIDAY NAME)
  Future<void> _showBottomSheetToFilterHolidayMapping(
    BuildContext context,
  ) async {
    final state = _holidayMappingMasterCubit.state;

    _filterBranchNameC.text = state.filterBranchName;

    String? selectedDirection =
        state.currentSortColumn == "Holiday Name"
            ? state.currentSortDirection
            : null;

    final String initialBranchName = _filterBranchNameC.text;
    final String? initialDirection = selectedDirection;

    DateTime? filterFromDate = state.filterFromHolidayDate;
    DateTime? filterToDate = state.filterToHolidayDate;
    final DateTime? initialFromDate = state.filterFromHolidayDate;
    final DateTime? initialToDate = state.filterToHolidayDate;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;
    final filterFormKey = GlobalKey<FormState>();

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterBranchNameC.text.trim() != initialBranchName) ||
            (selectedDirection != initialDirection) ||
            (filterFromDate != initialFromDate) ||
            (filterToDate != initialToDate);

        final bool onlyOneSet =
            (filterFromDate != null && filterToDate == null) ||
            (filterToDate != null && filterFromDate == null);

        final bool invalidRange =
            filterFromDate != null &&
            filterToDate != null &&
            filterFromDate!.isAfter(
              DateTime(
                filterToDate!.year,
                filterToDate!.month,
                filterToDate!.day,
              ),
            );
        final bool dobInvalid = onlyOneSet || invalidRange;
        applyEnabled.value = manualClose && !dobInvalid;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Holiday Mapping",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return Form(
            key: filterFormKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sort By Holiday Name", style: AppTextStyle.ts14M()),
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
                    textController: _filterBranchNameC,
                    hint: "Enter Branch Name",
                    title: "Branch Name",
                    onChangeFunction: (_) => updateApplyState(innerState),
                  ),

                  CustomDatePicker(
                    title: "Date of Holiday (From)",
                    initialDate: filterFromDate,
                    setValue: (value) {
                      innerState(() {
                        filterFromDate = value;
                        updateApplyState(innerState);
                      });
                    },
                  ),
                  if (filterFromDate != null && filterToDate == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Please select To date also',
                        style: AppTextStyle.ts12R().copyWith(
                          color: AppColor.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (filterToDate != null && filterFromDate == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Please select From date also',
                        style: AppTextStyle.ts12R().copyWith(
                          color: AppColor.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (filterFromDate != null &&
                      filterToDate != null &&
                      filterFromDate!.isAfter(
                        DateTime(
                          filterToDate!.year,
                          filterToDate!.month,
                          filterToDate!.day,
                        ),
                      ))
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Invalid Date range',
                        style: AppTextStyle.ts12R().copyWith(
                          color: AppColor.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  CustomDatePicker(
                    title: "Date of Holiday (To)",
                    initialDate: filterToDate,
                    setValue: (value) {
                      innerState(() {
                        filterToDate = value;
                        updateApplyState(innerState);
                      });
                    },
                    validator: (value) {
                      if (filterFromDate != null && value == null) {
                        return 'Date of Birth (To) is required when Date of Birth (From) is entered';
                      }
                      if (filterFromDate != null &&
                          value != null &&
                          filterFromDate!.isAfter(
                            DateTime(value.year, value.month, value.day),
                          )) {
                        return 'Invalid Date range';
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(),
                ],
              ),
            ),
          );
        },
      ),
      onClear: () {
        _filterBranchNameC.clear();

        _holidayMappingMasterCubit.applyFilterAndSort(
          context: context,
          filterFromHolidayDate: null,
          filterToHolidayDate: null,
          sortColumn: "Created Date",
          sortDirection: "DESC",
          filterBranchName: '',
        );
      },
      onApply: () {
        if (filterFormKey.currentState?.validate() ?? false) {
          applied = true;
          _holidayMappingMasterCubit.applyFilterAndSort(
            context: context,
            filterBranchName: _filterBranchNameC.text,
            filterFromHolidayDate: filterFromDate,
            filterToHolidayDate: filterToDate,
            sortColumn: selectedDirection != null ? "Holiday Name" : null,
            sortDirection: selectedDirection,
          );
        }
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterBranchNameC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Holiday Mapping Master",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _holidayMappingMasterCubit.searchHolidayMapping(value, context);
        },
        textController: _searchC,
        searchHintText: "Search by Holiday Name",
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addHolidayMappingMaster);
          if (context.mounted) {
            _holidayMappingMasterCubit.searchHolidayMapping("", context);
          }
        },
        onExportCallback: (value) {
          if (_holidayMappingMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _holidayMappingMasterCubit.exportExcelPdf(context, value);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterHolidayMapping(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _holidayMappingMasterCubit.searchHolidayMapping("", context);
        },
        child: BlocBuilder<
          HolidayMappingMasterCubit,
          HolidayMappingMasterState
        >(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.holidayMappingList.isEmpty) {
              return Center(child: loader());
            }
            if (state.holidayMappingList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: getActualHeight(context) * .7,
                    child: Center(
                      child: noDataWidget(
                        message: "No Holiday Mapping Data Found",
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: state.holidayMappingList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.holidayMappingList.length) {
                  return state.holidayMappingList.length <
                          state.totalNumberOfRecord
                      ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var holidayMapping = state.holidayMappingList[index];
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
                              onTap: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.viewHolidayMappingMaster,
                                  queryParameters: {
                                    "holidayMapping": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(holidayMapping.toJson()),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Text(
                                holidayMapping.holidayName,
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
                                    AppRoutes.addHolidayMappingMaster,
                                    queryParameters: {
                                      "holidayMapping":
                                          Uri.encodeQueryComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(
                                                holidayMapping.toJson(),
                                              ),
                                            ),
                                          ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                              horizontalSpacing(),
                              CustomIconButton.delete(
                                onPressed: () {
                                  _showPopupToDeleteHolidayMappingMaster(
                                    context,
                                    holidayMapping,
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
                        title: "Holiday Date",
                        value: formatDateTimeAsDDMMMYYYY(
                          holidayMapping.holidayDate,
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
}
