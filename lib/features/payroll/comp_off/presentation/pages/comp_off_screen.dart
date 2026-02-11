import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off.model.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/presentation/cubit/comp_off_cubit.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/pages/leave_screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompOffScreen extends StatefulWidget {
  const CompOffScreen({super.key});

  @override
  State<CompOffScreen> createState() => _CompOffScreenState();
}

class _CompOffScreenState extends State<CompOffScreen> {
  // CUBIT
  late CompOffCubit _compOffCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FILTER
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  @override
  void initState() {
    super.initState();
    _compOffCubit = context.read<CompOffCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.compOff]!;
    _onScroll();
    _compOffCubit.getCompOffList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_compOffCubit.state.isLoading! &&
          _compOffCubit.state.compOffList.length <
              _compOffCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _compOffCubit.getCompOffList(
            context,
            _compOffCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE COMP OFF ---->
  Future<void> _showPopupToDeleteDepartmentMaster(
    BuildContext context,
    CompOffModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a comp off?',
      'Deleting this comp off will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _compOffCubit.deleteCompOff(
        context: context,
        compOffId: obj.compOffId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
        index: index,
      );
    }
  }

  void _prefillFilterFromState() {
    final s = _compOffCubit.state;
    _startDateNotifier.value = s.filterStartDate;
    _endDateNotifier.value = s.filterEndDate;
  }

  // COMP OFF FILTER
  Future<void> _showBottomSheetToFilterCompOff(BuildContext context) async {
    _prefillFilterFromState();
    final state = _compOffCubit.state;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(
      state.filterStartDate != null || state.filterEndDate != null,
    );
    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Comp-Off",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _startDateNotifier,
                      builder: (context, startDate, child) {
                        return CustomDatePicker(
                          title: "Start Date",
                          initialDate: startDate,
                          setValue: (value) {
                            _startDateNotifier.value = value;
                            applyEnabled.value = true;
                          },
                          validator: (value) => null,
                        );
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _endDateNotifier,
                      builder: (context, endDate, child) {
                        return ValueListenableBuilder<DateTime?>(
                          valueListenable: _startDateNotifier,
                          builder: (context, startDate, child) {
                            return CustomDatePicker(
                              title: "End Date",
                              isRequired: false,
                              initialDate: endDate,
                              setValue: (value) {
                                _endDateNotifier.value = value;
                                applyEnabled.value = true;
                              },
                              validator: (value) {
                                if (value == null) return null;
                                if (startDate != null) {
                                  final startDateOnly = DateTime(
                                    startDate.year,
                                    startDate.month,
                                    startDate.day,
                                  );
                                  final endDateOnly = DateTime(
                                    value.year,
                                    value.month,
                                    value.day,
                                  );
                                  if (endDateOnly.isBefore(startDateOnly)) {
                                    return 'End Date cannot be before Start Date';
                                  }
                                }
                                return null;
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      onClear: () {
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _compOffCubit.clearFilterOnCompOff(context);
      },
      onApply: () {
        final startDate = _startDateNotifier.value;
        final endDate = _endDateNotifier.value;
        if (startDate != null && endDate != null) {
          final startOnly = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
          if (endOnly.isBefore(startOnly)) {
            showErrorMessage(
              context,
              "Invalid dates",
              "End Date cannot be before Start Date",
            );
            return;
          }
        }
        _compOffCubit.applyFilterOnCompOff(
          context: context,
          startDate: startDate,
          endDate: endDate,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Comp Off',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _compOffCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addCompOff);
          if (context.mounted) {
            await _compOffCubit.getCompOffList(context, 1);
          }
        },
        isMenuButton: true,
        onFilterTap: () {
          _showBottomSheetToFilterCompOff(context);
        },
      ),
      body: BlocBuilder<CompOffCubit, CompOffState>(
        builder: (context, state) {
          return Column(children: [Expanded(child: _buildBody(state))]);
        },
      ),
    );
  }

  Widget _buildBody(CompOffState state) {
    if ((state.isLoading ?? true) && state.compOffList.isEmpty) {
      return Center(child: loader());
    }
    if (state.compOffList.isEmpty) {
      return Center(child: noDataWidget());
    }
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _compOffCubit.state.compOffList.length + 1,
      itemBuilder: (context, index) {
        if (index == state.compOffList.length) {
          return state.compOffList.length < state.totalNumberOfRecord
              ? Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
              : const SizedBox.shrink();
        }
        var compOff = state.compOffList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(12),
          decoration: commonCardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            goRouter.pushNamed(
                              AppRoutes.viewCompOff,
                              queryParameters: {
                                "compOff": Uri.encodeComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(compOff),
                                  ),
                                ),
                              },
                            );
                          },
                          child: Text(
                            formatDateTimeAsDDMMMYYYY(compOff.compOffDate),
                            style: AppTextStyle.ts16M(color: AppColor.primary),
                          ),
                        ),
                        horizontalSpacing(width: 20),
                        _statusWidget("Pending"),
                      ],
                    ),
                    verticalSpacing(),
                    buildRowTitleValue(
                      title: "Working Date",
                      value: formatDateTimeAsDDMMMYYYY(compOff.workingDate),
                    ),
                    buildRowTitleValue(title: "Reason", value: compOff.reason),
                  ],
                ),
              ),
              horizontalSpacing(),
              Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconButton.edit(
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addCompOff,
                        queryParameters: {
                          "compOff": Uri.encodeComponent(
                            EncryptionManager.encryptData(jsonEncode(compOff)),
                          ),
                        },
                      );
                    },
                  ),
                  CustomIconButton.delete(
                    onPressed: () {
                      _showPopupToDeleteDepartmentMaster(
                        context,
                        compOff,
                        state.currentPage,
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
  }

  // STATUS WIDGET
  Widget _statusWidget(String status) {
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusConfig.label,
        style: AppTextStyle.ts12M().copyWith(color: statusConfig.textColor),
      ),
    );
  }

  // HELPER METHOD TO GET STATUS CONFIG
  StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return StatusConfig(
          label: "Pending",
          textColor: AppColor.white,
          backgroundColor: AppColor.darkBlue,
        );

      case "approved":
        return StatusConfig(
          label: "Approved",
          textColor: AppColor.white,
          backgroundColor: AppColor.green,
        );

      case "upcoming":
        return StatusConfig(
          label: "Upcoming",
          textColor: AppColor.white,
          backgroundColor: AppColor.warning,
        );

      case "rejected":
        return StatusConfig(
          label: "Rejected",
          textColor: AppColor.white,
          backgroundColor: AppColor.error,
        );

      default:
        return StatusConfig(
          label: status,
          textColor: AppColor.grey,
          backgroundColor: AppColor.grey.withValues(alpha: 0.1),
        );
    }
  }
}
