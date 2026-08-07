import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/cubit/outdoor_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class OutdoorScreen extends StatefulWidget {
  const OutdoorScreen({super.key});

  @override
  State<OutdoorScreen> createState() => _OutdoorScreenState();
}

class _OutdoorScreenState extends State<OutdoorScreen> {
  // CUBIT
  late OutdoorCubit _outdoorCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _conclusionC;

  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _outdoorCubit = context.read<OutdoorCubit>();
    scrollController = ScrollController();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.outdoor]!;
    _initializeTextEditingController();
    _onScroll();
    _outdoorCubit.getOutdoorList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _conclusionC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
  }

  // INITIALIZE TEXT CONTROLLERS
  void _initializeTextEditingController() {
    _conclusionC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_outdoorCubit.state.isLoading! &&
          _outdoorCubit.state.outdoorList.length <
              _outdoorCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _outdoorCubit.getOutdoorList(
            context,
            _outdoorCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterOutdoor(BuildContext context) async {
    final state = _outdoorCubit.state;

    DateTime? filterStartDate = state.filterStartDate;
    DateTime? filterEndDate = state.filterEndDate;
    final DateTime? initialStartDate = state.filterStartDate;
    final DateTime? initialEndDate = state.filterEndDate;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    final filterFormKey = GlobalKey<FormState>();

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (filterStartDate != initialStartDate) ||
            (filterEndDate != initialEndDate);
        //DISABLED WHEN ONLY ONE DATE IS SELECTED
        final bool onlyOneSet =
            (filterStartDate != null && filterEndDate == null) ||
            (filterEndDate != null && filterStartDate == null);

        applyEnabled.value = manualClose && !onlyOneSet;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Outdoor",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: filterFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFromToDatePicker(
                  fromDateTitle: "From Date",
                  toDateTitle: "To Date",
                  removeBottomMargin: false,
                  initialFromDate: filterStartDate,
                  initialToDate: filterEndDate,
                  onToDateChanged: (DateTime? fromDate, DateTime? toDate) {
                    filterStartDate = fromDate;
                    filterEndDate = toDate;

                    updateApplyState(innerState);
                  },
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _outdoorCubit.applyFilterAndSort(
          context: context,
          filterFromHolidayDate: null,
          filterToHolidayDate: null,
        );
      },
      onApply: () {
        if (filterFormKey.currentState?.validate() ?? false) {
          _outdoorCubit.applyFilterAndSort(
            context: context,
            filterFromHolidayDate: filterStartDate,
            filterToHolidayDate: filterEndDate,
          );
        }
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OutdoorCubit, OutdoorState>(
      listener: (context, state) {
        _filterCount.value = _outdoorCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Outdoor",
          isMenuButton: true,
          authorization: _routeAuthorizationModel,
          filterCountNotifier: _filterCount,
          onExportCallback: (value) {
            _outdoorCubit.exportExcelPdf(context, value);
          },
          onAddCallback: () async {
            await goRouter.pushNamed(AppRoutes.addOutdoor);
            if (context.mounted) {
              _outdoorCubit.getOutdoorList(context, 1);
            }
          },
          onFilterTap: () {
            _showBottomSheetToFilterOutdoor(context);
          },
        ),
        body: BlocBuilder<OutdoorCubit, OutdoorState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.outdoorList.isEmpty) {
              return Center(child: loader());
            }
            if (state.outdoorList.isEmpty) {
              return Center(
                child: noDataWidget(message: "No Outdoor Records Found"),
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _outdoorCubit.state.outdoorList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.outdoorList.length) {
                  return state.outdoorList.length < state.totalNumberOfRecord
                      ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var outdoor = state.outdoorList[index];
                // FOR CONCLUSION BUTTON COLOR AND DISABILITY HANDLING
                DateTime now = DateTime.now();

                DateTime today = DateTime(now.year, now.month, now.day);
                DateTime outdoorDate = DateTime(
                  outdoor.outDoorDate.year,
                  outdoor.outDoorDate.month,
                  outdoor.outDoorDate.day,
                );

                bool isValidDate =
                    outdoorDate.isAfter(today) ||
                    outdoorDate.isAtSameMomentAs(today);
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: commonCardDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                goRouter.pushNamed(
                                  AppRoutes.viewOutdoor,
                                  queryParameters: {
                                    "outdoor": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(outdoor),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Text(
                                formatDateTimeAsDDMMMYYYY(outdoor.outDoorDate),
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),

                          if (outdoor.status.isNotEmpty)
                            approvalStatusWidget(outdoor.status),
                          Row(
                            spacing: 10,
                            children: [
                              CustomIconButton(
                                onPressed:
                                    isValidDate
                                        ? () {
                                          _conclusionC.text =
                                              outdoor.conclusion;

                                          DialogHelper.showCustomDialogue(
                                            context,
                                            title: "Add Conclusion",
                                            childContent: Column(
                                              children: [
                                                CustomTextField(
                                                  textController: _conclusionC,
                                                  isRequired: true,
                                                  hint: "Enter Conclusion",
                                                  minLines: 3,
                                                  maxLines: 3,
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return "Please enter conclusion";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                            bottomSection: Row(
                                              children: [
                                                SizedBox(
                                                  width: 120,
                                                  child: CustomButton(
                                                    text: "Clear",
                                                    onPressed: () {
                                                      _conclusionC.clear();
                                                    },
                                                    backgroundColor:
                                                        AppColor.grey,
                                                  ),
                                                ),
                                                Spacer(),
                                                SizedBox(
                                                  width: 120,
                                                  child: CustomButton(
                                                    text: "Save",
                                                    onPressed: () {
                                                      goRouter.pop();
                                                      _outdoorCubit
                                                          .addUpdateConclusion(
                                                            context: context,
                                                            outdoorId:
                                                                outdoor
                                                                    .outdoorId,
                                                            conclusion:
                                                                _conclusionC
                                                                    .text,
                                                            index: index,
                                                          );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        : () {},
                                backgroundColor:
                                    isValidDate
                                        ? outdoor.conclusion.isNotEmpty
                                            ? AppColor.lightPurple
                                            : AppColor.lightBlue
                                        : AppColor.lightGreyBackground,
                                icon: Icon(
                                  grade: 100.0,
                                  Icons.assignment_turned_in_outlined,
                                  color:
                                      isValidDate
                                          ? outdoor.conclusion.isNotEmpty
                                              ? AppColor.purple
                                              : AppColor.primary
                                          : AppColor.grey2,
                                  size: 18,
                                ),
                              ),
                              CustomIconButton.edit(
                                onPressed: () {
                                  goRouter.pushNamed(
                                    AppRoutes.addOutdoor,
                                    queryParameters: {
                                      "outdoor": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(outdoor),
                                        ),
                                      ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        DateFormat('hh:mm a').format(outdoor.outDoorTime),
                        style: AppTextStyle.ts14M(),
                      ),
                      verticalSpacing(),
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
