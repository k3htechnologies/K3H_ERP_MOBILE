import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/model/outdoor.model.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/cubit/outdoor_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
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
  }

  // INITIALIZE TEXT CONTROLLERS
  void _initializeTextEditingController() {
    _conclusionC = TextEditingController();
  }

  // <---- PAGINATION ---->
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
        // Disable Apply when only one of Start/End is set (both or neither required)
        final bool onlyOneSet =
            (filterStartDate != null && filterEndDate == null) ||
            (filterEndDate != null && filterStartDate == null);
        // Disable Apply when Start > End (invalid range)
        final bool invalidRange =
            filterStartDate != null &&
            filterEndDate != null &&
            filterStartDate!.isAfter(
              DateTime(
                filterEndDate!.year,
                filterEndDate!.month,
                filterEndDate!.day,
              ),
            );
        final bool dobInvalid = onlyOneSet || invalidRange;
        applyEnabled.value = manualClose && !dobInvalid;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Outdoor",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: filterFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: CustomDatePicker(
                        title: "Start Date",
                        initialDate: filterStartDate,
                        setValue: (value) {
                          innerState(() {
                            filterStartDate = value;
                            updateApplyState(innerState);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomDatePicker(
                        title: "End Date",
                        initialDate: filterEndDate,
                        setValue: (value) {
                          innerState(() {
                            filterEndDate = value;
                            updateApplyState(innerState);
                          });
                        },
                        validator: (value) {
                          if (filterStartDate != null && value == null) {
                            return 'End Date is required when Start Date is selected';
                          }
                          if (filterStartDate != null &&
                              value != null &&
                              filterStartDate!.isAfter(
                                DateTime(value.year, value.month, value.day),
                              )) {
                            return 'Invalid Date range';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                if (filterStartDate != null && filterEndDate == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Text(
                      'Please select End Date also',
                      style: AppTextStyle.ts12R().copyWith(
                        color: AppColor.error,
                        fontSize: 11,
                      ),
                    ),
                  ),

                if (filterEndDate != null && filterStartDate == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Text(
                      'Please select Start Date also',
                      style: AppTextStyle.ts12R().copyWith(
                        color: AppColor.error,
                        fontSize: 11,
                      ),
                    ),
                  ),

                if (filterStartDate != null &&
                    filterEndDate != null &&
                    filterStartDate!.isAfter(
                      DateTime(
                        filterEndDate!.year,
                        filterEndDate!.month,
                        filterEndDate!.day,
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
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Outdoor",
        isMenuButton: true,
        authorization: _routeAuthorizationModel,
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
                      children: [
                        _punchOutMissingWidget(
                          outdoor.punchIn,
                          outdoor.punchOut,
                        ),
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
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Row(
                          children: [
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
                    _statusButton(outdoor, index),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // HELPER WIDGET
  Widget _statusButton(OutdoorModel outdoor, int index) {
    String status;

    if (outdoor.punchIn == null) {
      status = "punchin";
    } else if (outdoor.punchOut == null) {
      status = "punchout";
    } else {
      status = "conclusion";
    }

    late String buttonText;
    late Color bgColor;
    late Color textColor;

    VoidCallback? onTap;

    switch (status) {
      case "punchin":
        buttonText = "Punch In";
        bgColor = AppColor.lightGreen;
        textColor = AppColor.darkGreen;
        onTap = () {
          _outdoorCubit.addOutdoorAttendance(
            context: context,
            outdoorId: outdoor.outdoorId,
            punchTime: DateTime.now().toIso8601String(),
            address: "Maheshmati .... SaamRajya....",
            index: index,
          );
        };
        break;

      case "punchout":
        buttonText = "Punch Out";
        bgColor = AppColor.lightBlue;
        textColor = AppColor.primary;
        onTap = () {
          _outdoorCubit.addOutdoorAttendance(
            context: context,
            outdoorId: outdoor.outdoorId,
            punchTime: DateTime.now().toIso8601String(),
            address: "Maheshmati .... SaamRajya....",
            index: index,
          );
        };
        break;

      default:
        buttonText = "Conclusion";
        bgColor = AppColor.purple20;
        textColor = AppColor.purple;
        onTap = () {
          // Set conclusion text right before opening the dialog
          _conclusionC.text = outdoor.conclusion;

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
                    backgroundColor: AppColor.grey,
                  ),
                ),
                Spacer(),
                SizedBox(
                  width: 120,
                  child: CustomButton(
                    text: "Save",
                    onPressed: () {
                      goRouter.pop();
                      _outdoorCubit.addUpdateConclusion(
                        context: context,
                        outdoorId: outdoor.outdoorId,
                        conclusion: _conclusionC.text,
                        index: index,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        };
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint, size: 16, color: textColor),
            const SizedBox(width: 4),
            Text(buttonText, style: AppTextStyle.ts14M(color: textColor)),
          ],
        ),
      ),
    );
  }

  // <---- PADDING WIDGET ---->
  Widget _punchOutMissingWidget(DateTime? punchInTime, DateTime? punchOutTime) {
    final DateTime today = DateTime.now();

    bool isPreviousDay = false;

    if (punchInTime != null) {
      final DateTime punchDate = DateTime(
        punchInTime.year,
        punchInTime.month,
        punchInTime.day,
      );

      final DateTime currentDate = DateTime(today.year, today.month, today.day);

      isPreviousDay = punchDate.isBefore(currentDate);
    }

    final bool isVisible =
        punchInTime != null && punchOutTime == null && isPreviousDay;

    return Visibility(
      visible: isVisible,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: AppColor.warning, size: 16),
          horizontalSpacing(),
        ],
      ),
    );
  }
}
