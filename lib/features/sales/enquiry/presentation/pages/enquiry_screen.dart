import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  // CUBIT
  late EnquiryCubit _enquiryCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // PROJECT
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _systemCodeC,
      _mobileNumberC,
      _followUpDaysC,
      _requirementC,
      _stageC;

  // DATE VARIABLES
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier(null);

  Future<void> openWhatsApp({
    required String phoneNumber,
    String message = 'Hi',
  }) async {
    final encodedMsg = Uri.encodeComponent(message);

    // WhatsApp app URL (mobile)
    final Uri appUri = Uri.parse(
      "whatsapp://send?phone=$phoneNumber&text=$encodedMsg",
    );

    // Web fallback
    final Uri webUri = Uri.parse("https://wa.me/$phoneNumber?text=$encodedMsg");

    try {
      // Try opening WhatsApp app
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to WhatsApp Web
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Final fallback
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();
    _enquiryCubit = context.read<EnquiryCubit>();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.enquiry]!;
    _initializeTextEditingController();
    _onScroll();
    _enquiryCubit.getEnquiryList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    // Dispose text controllers
    _searchC.dispose();
    _systemCodeC.dispose();
    _mobileNumberC.dispose();
    _followUpDaysC.dispose();
    _requirementC.dispose();
    _stageC.dispose();

    // Dispose scroll controller
    scrollController.dispose();

    // Cancel debounce timer if active
    _debounce?.cancel();

    super.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _systemCodeC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _followUpDaysC = TextEditingController();
    _requirementC = TextEditingController();
    _stageC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_enquiryCubit.state.isLoading! &&
          _enquiryCubit.state.enquiryList.length <
              _enquiryCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _enquiryCubit.getEnquiryList(
            context,
            _enquiryCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterEnquiry(BuildContext context) async {
    final state = _enquiryCubit.state;

    // Initialize notifiers with current state values
    _startDateNotifier.value = state.filterStartDate;
    _endDateNotifier.value = state.filterEndDate;

    String? selectedDirection =
        state.currentSortColumn == "Name" ? state.currentSortDirection : null;

    final String? initialDirection = selectedDirection;
    final DateTime? initialStartDate = state.filterStartDate;
    final DateTime? initialEndDate = state.filterEndDate;

    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState() {
      final bool manualChange =
          (_startDateNotifier.value != initialStartDate) ||
          (_endDateNotifier.value != initialEndDate) ||
          (_systemCodeC.text.trim() != (state.filterSystemCode)) ||
          (_mobileNumberC.text.trim() != (state.filterMobileNumber)) ||
          (_followUpDaysC.text.trim() != (state.filterFollowUpDays)) ||
          (_requirementC.text.trim() != (state.filterRequirement)) ||
          (_stageC.text.trim() != (state.filterStage)) ||
          (selectedDirection != initialDirection);

      // Disable Apply if only one date is set
      final bool onlyOneDateSet =
          (_startDateNotifier.value != null &&
              _endDateNotifier.value == null) ||
          (_endDateNotifier.value != null && _startDateNotifier.value == null);

      // Disable Apply if From > To
      final bool invalidRange =
          (_startDateNotifier.value != null &&
              _endDateNotifier.value != null &&
              _startDateNotifier.value!.isAfter(_endDateNotifier.value!));

      applyEnabled.value = manualChange && !onlyOneDateSet && !invalidRange;
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Enquiry",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
              updateApplyState();
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SORT OPTIONS
                Text("Sort By Name", style: AppTextStyle.ts14M()),
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
                          border: Border.all(color: AppColor.grey, width: 0.5),
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
                          border: Border.all(color: AppColor.grey, width: 0.5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(height: 20),

                // DATE PICKERS
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _startDateNotifier,
                        builder: (context, startDate, _) {
                          return CustomDatePicker(
                            title: "Start Date",
                            initialDate: startDate,
                            setValue: (value) {
                              _startDateNotifier.value = value;
                              updateApplyState();
                            },
                            validator: (_) => null,
                          );
                        },
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _endDateNotifier,
                        builder: (context, endDate, _) {
                          return CustomDatePicker(
                            title: "End Date",
                            initialDate: endDate,
                            setValue: (value) {
                              _endDateNotifier.value = value;
                              updateApplyState();
                            },
                            validator: (value) {
                              final start = _startDateNotifier.value;
                              if (start != null && value == null) {
                                return 'End Date required';
                              }
                              if (start != null &&
                                  value != null &&
                                  start.isAfter(value)) {
                                return 'End Date cannot be before Start Date';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // TEXT FIELDS
                CustomTextField(
                  textController: _systemCodeC,
                  title: "System Generated Code",
                  hint: "Enter System Generated Code",
                  onChangeFunction: (_) => updateApplyState(),
                ),
                CustomTextField(
                  textController: _mobileNumberC,
                  title: "Mobile Number",
                  hint: "Enter Mobile Number",
                  keyboardType: TextInputType.phone,
                  onChangeFunction: (_) => updateApplyState(),
                ),
                CustomTextField(
                  textController: _followUpDaysC,
                  title: "Follow Up Days",
                  hint: "Enter Follow Up Days",
                  onChangeFunction: (_) => updateApplyState(),
                ),
                CustomTextField(
                  textController: _requirementC,
                  title: "Requirement",
                  hint: "Enter Requirement",
                  onChangeFunction: (_) => updateApplyState(),
                ),
                CustomTextField(
                  textController: _stageC,
                  title: "Stage",
                  hint: "Enter Stage",
                  onChangeFunction: (_) => updateApplyState(),
                ),
              ],
            ),
          );
        },
      ),

      /// CLEAR BUTTON
      onClear: () {
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _systemCodeC.clear();
        _mobileNumberC.clear();
        _followUpDaysC.clear();
        _requirementC.clear();
        _stageC.clear();
        selectedDirection = null;

        _enquiryCubit.applyEnquiryFilterAndSort(
          context: context,
          filterStartDate: null,
          filterEndDate: null,
          filterSystemCode: '',
          filterMobileNumber: '',
          filterFollowUpDays: '',
          filterRequirement: '',
          filterStage: '',
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },

      /// APPLY BUTTON
      onApply: () {
        applied = true;
        _enquiryCubit.applyEnquiryFilterAndSort(
          context: context,
          filterStartDate: _startDateNotifier.value,
          filterEndDate: _endDateNotifier.value,
          filterSystemCode:
              _systemCodeC.text.trim().isEmpty ? '' : _systemCodeC.text.trim(),
          filterMobileNumber:
              _mobileNumberC.text.trim().isEmpty
                  ? ''
                  : _mobileNumberC.text.trim(),
          filterFollowUpDays:
              _followUpDaysC.text.trim().isEmpty
                  ? ''
                  : _followUpDaysC.text.trim(),
          filterRequirement:
              _requirementC.text.trim().isEmpty
                  ? ''
                  : _requirementC.text.trim(),
          filterStage: _stageC.text.trim().isEmpty ? '' : _stageC.text.trim(),
          sortColumn: selectedDirection != null ? "Name" : "Created Date",
          sortDirection: selectedDirection ?? "DESC",
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // Reset bottom sheet fields if closed manually
    if (!applied) {
      _startDateNotifier.value = initialStartDate;
      _endDateNotifier.value = initialEndDate;
      selectedDirection = initialDirection;
    }
  }

  String getFollowUpStatus(DateTime? nextFollowUpDate) {
    if (nextFollowUpDate == null) return "-";

    final DateTime today = DateTime.now();

    // Remove time part for accurate day comparison
    final DateTime currentDate = DateTime(today.year, today.month, today.day);
    final DateTime followUpDate = DateTime(
      nextFollowUpDate.year,
      nextFollowUpDate.month,
      nextFollowUpDate.day,
    );

    final int difference = followUpDate.difference(currentDate).inDays;

    if (difference == 0) {
      return "Today follow up";
    } else if (difference > 0) {
      return "Follow up in $difference day(s)";
    } else {
      return "Follow up overdue by ${difference.abs()} day(s)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Enquiry",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        searchHintText: "Search by Name",
        onSearchSubmit: (value) {
          _enquiryCubit.search(context, value);
        },
        onExportCallback: (value) {
          _enquiryCubit.exportExcelPdf(context, value);
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _enquiryCubit.getEnquiryList(context, 1, value.projectId);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterEnquiry(context);
        },
      ),
      body: BlocBuilder<EnquiryCubit, EnquiryState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.enquiryList.isEmpty) {
            return Center(child: loader());
          }
          if (state.enquiryList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _enquiryCubit.state.enquiryList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.enquiryList.length) {
                return state.enquiryList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var enquiry = state.enquiryList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await goRouter.pushNamed(
                                AppRoutes.viewEnquiry,
                                queryParameters: {
                                  "enquiryId": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      enquiry.enquiryId.toString(),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Text(
                              enquiry.name,
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        CustomIconButton(
                          onPressed: () {
                            openWhatsApp(phoneNumber: enquiry.mobileNumber);
                          },
                          icon: SvgPicture.asset(
                            AppAssets.whatsAppIcon,
                            height: 16,
                            width: 16,
                          ),
                        ),
                        horizontalSpacing(),
                        CustomIconButton.edit(
                          onPressed: () {
                            goRouter.pushNamed(
                              AppRoutes.addEnquiry,
                              queryParameters: {
                                "enquiry": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(enquiry.toJson()),
                                  ),
                                ),
                                'index': index.toString(),
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    buildRowTitleValue(
                      title: "Unique Code",
                      value: enquiry.systemGeneratedCode,
                    ),
                    buildRowTitleValue(
                      title: "Mobile Number",
                      value: enquiry.mobileNumber,
                      customValueWidget: CustomClickToContactText(
                        value: enquiry.mobileNumber,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Enquiry Follow Up Days",
                      value: getFollowUpStatus(enquiry.nextFollowUpDate),
                      singleLine: false
                    ),
                    buildRowTitleValue(
                      title: "Requirement",
                      value: enquiry.requirement,
                        singleLine: false
                    ),
                    buildRowTitleValue(
                      title: "Stage",
                      value: enquiry.finalStage,
                      customValueWidget: statusWidget(enquiry.finalStage),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2.5,
        shape: CircleBorder(side: BorderSide(color: AppColor.primary)),
        backgroundColor: AppColor.lightBlue,
        child: Icon(Icons.add, color: AppColor.primary),
        onPressed: () {
          goRouter.pushNamed(AppRoutes.addEnquiry);
        },
      ),
    );
  }

  // Helper Widget
  Widget statusWidget(String status) {
    final trimmed = status.trim();

    // If empty → show dash
    if (trimmed.isEmpty) {
      return statusChip("-", AppColor.lightGreyBackground, AppColor.black);
    }

    final s = trimmed.toLowerCase();

    switch (s) {
      case 'booking done':
        return statusChip(status, AppColor.green20, AppColor.green);

      case 'blocked':
        return statusChip(status, AppColor.purple20, AppColor.purple);

      case 'cancelled':
        return statusChip(status, AppColor.black10, AppColor.darkGrey);

      case 'negotiation':
        return statusChip(status, AppColor.lightYellow, AppColor.brown);

      case 'lost':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      case 'retention':
        return statusChip(status, AppColor.lightBlue2, AppColor.info);

      case 're - visit scheduled':
        return statusChip(status, AppColor.lightGreenBg, AppColor.darkGreen);

      case 're - visit proposed':
        return statusChip(status, AppColor.lightOrangenBg, AppColor.orange);

      case 'site visit':
        return statusChip(
          status,
          AppColor.lightRed,
          AppColor.priorityHighColor,
        );

      case 'unit selection / blocked':
        return statusChip(
          status,
          AppColor.lightRed,
          AppColor.priorityHighColor,
        );

      default:
        return statusChip(status, AppColor.lightGreyBackground, AppColor.black);
    }
  }
}
