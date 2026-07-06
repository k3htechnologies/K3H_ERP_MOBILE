import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/model/holiday_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/cubit/holiday_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class HolidayMasterScreen extends StatefulWidget {
  const HolidayMasterScreen({super.key});

  @override
  State<HolidayMasterScreen> createState() => _HolidayMasterScreenState();
}

class _HolidayMasterScreenState extends State<HolidayMasterScreen> {
  // CUBIT
  late HolidayMasterCubit _holidayMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _holidayMasterCubit = context.read<HolidayMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.holidayMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _holidayMasterCubit.getHolidayList(context: context, pageNumber: 1);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
    _searchC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_holidayMasterCubit.state.isLoading ?? false) &&
          _holidayMasterCubit.state.holidays.length <
              _holidayMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _holidayMasterCubit.getHolidayList(
            context: context,
            pageNumber: _holidayMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // DELETE HOLIDAY
  Future<void> _showPopupToDeleteHolidayMaster(
    BuildContext context,
    HolidayMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Holiday?',
      'Deleting this Holiday will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _holidayMasterCubit.deleteHoliday(index, obj, context);
    }
  }

  // SORT BOTTOM SHEET - HOLIDAY (HOLIDAY NAME)
  Future<void> _showSortBottomSheetForHoliday(BuildContext context) async {
    final state = _holidayMasterCubit.state;

    String? selectedDirection =
        state.currentSortColumn == "Holiday Name"
            ? state.currentSortDirection
            : null;
    _searchC.text = state.searchText;

    final String? initialDirection = selectedDirection;
    final String initialHolidayName = _searchC.text;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        applyEnabled.value =
            (_searchC.text.trim() != initialHolidayName) ||
            selectedDirection != initialDirection;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Sort Holiday",
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
              Text("Sort By Holiday Name", style: AppTextStyle.ts14M()),
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
                textController: _searchC,
                hint: "Enter Holiday Name",
                title: "Holiday Name",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),
      onClear: () {
        _holidayMasterCubit.applyFilterAndSort(
          context: context,
          holidayName: '',
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
        _searchC.clear();
      },
      onApply: () {
        _holidayMasterCubit.applyFilterAndSort(
          context: context,
          holidayName: _searchC.text.trim(),
          sortColumn: "Holiday Name",
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HolidayMasterCubit, HolidayMasterState>(
      listener: (context, state) {
        _filterCount.value = _holidayMasterCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Holiday Master",
          authorization: _routeAuthorizationModel,
          filterCountNotifier: _filterCount,
          onSearchSubmit: (value) {
            _holidayMasterCubit.searchHolidays(value, context);
          },
          textController: _searchC,
          searchHintText: "Search by Holiday Name",
          onAddCallback: () {
            goRouter.pushNamed(AppRoutes.addHolidayMaster);
            if (context.mounted) {
              _holidayMasterCubit.searchHolidays("", context);
            }
          },
          onExportCallback: (value) {
            if (_holidayMasterCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No Data Found");
              return;
            }
            _holidayMasterCubit.exportExcelPdf(context, value);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showSortBottomSheetForHoliday(context);
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _holidayMasterCubit.searchHolidays("", context);
          },
          child: BlocBuilder<HolidayMasterCubit, HolidayMasterState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) && state.holidays.isEmpty) {
                return Center(child: loader());
              }
              if (state.holidays.isEmpty) {
                return ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: getActualHeight(context) * .7,
                      child: Center(
                        child: noDataWidget(message: "No Holiday Data Found"),
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: state.holidays.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.holidays.length) {
                    return state.holidays.length < state.totalNumberOfRecord
                        ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  var holiday = state.holidays[index];
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
                                    AppRoutes.viewHolidayMaster,
                                    queryParameters: {
                                      "holiday": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(holiday.toJson()),
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
                                  child: Text(
                                    holiday.holidayName,
                                    style: AppTextStyle.ts16M(
                                      color: AppColor.primary,
                                    ).copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColor.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                CustomIconButton.edit(
                                  onPressed: () async {
                                    await goRouter.pushNamed(
                                      AppRoutes.addHolidayMaster,
                                      queryParameters: {
                                        "holiday": Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(holiday.toJson()),
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
                                    _showPopupToDeleteHolidayMaster(
                                      context,
                                      holiday,
                                      state.currentPage,
                                      index,
                                    );
                                  },
                                ),
                              ],
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
        ),
      ),
    );
  }
}
