import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // CUBIT
  late LoginCubit _loginCubit;
  late BookingCubit _bookingCubit;

  // AUTHORIZATION
  late AuthorizationModel _routhAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // PROJECT
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _applicantNameC,
      _applicantMobileC,
      _wingC,
      _mobileNumberC,
      _flatC,
      _floorC,
      _agreementValueC,
      _bookingTypeC;
  // DATE VARIABLES
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSourceNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSubSourceNotifier =
      ValueNotifier(null);
  final List<Map<String, dynamic>> sourceTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Source'},
    {'zAttributesId': 1, 'DisplayName': 'Channel Partner'},
    {'zAttributesId': 2, 'DisplayName': 'Direct Walking'},
  ];
  final List<Map<String, dynamic>> channelPartnerActivityList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Activity'},
    {'zAttributesId': 1, 'DisplayName': 'Channel Partner Data Calling'},
    {'zAttributesId': 2, 'DisplayName': 'Channel Partner Walked In'},
    {'zAttributesId': 3, 'DisplayName': 'Digital Activity'},
  ];
  final List<Map<String, dynamic>> directWalkingSubSourceList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Sub Source'},
    {'zAttributesId': 1, 'DisplayName': 'Advertisement'},
    {'zAttributesId': 2, 'DisplayName': 'Exhibition'},
    {'zAttributesId': 3, 'DisplayName': 'Employee Reference'},
    {'zAttributesId': 4, 'DisplayName': 'HRR Website'},
    {'zAttributesId': 5, 'DisplayName': 'Loyalty'},
    {'zAttributesId': 6, 'DisplayName': 'Management Reference'},
    {'zAttributesId': 7, 'DisplayName': 'Property Search Portal'},
    {'zAttributesId': 8, 'DisplayName': 'SMS'},
    {'zAttributesId': 9, 'DisplayName': 'Site Branding'},
    {'zAttributesId': 10, 'DisplayName': 'Reference'},
    {'zAttributesId': 11, 'DisplayName': 'Other'},
  ];
  @override
  void initState() {
    super.initState();
    _loginCubit = context.read<LoginCubit>();
    _bookingCubit = context.read<BookingCubit>();
    _project = getProject();
    _routhAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.booking]!;
    _selectedSourceNotifier.value = sourceTypeList.first;
    _selectedSubSourceNotifier.value = channelPartnerActivityList.first;
    _initializeTextEditingController();
    _onScroll();
    _bookingCubit.getBookingList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    _searchC.dispose();
    _agreementValueC.dispose();
    _applicantNameC.dispose();
    _applicantMobileC.dispose();
    _bookingTypeC.dispose();
    _wingC.dispose();
    _mobileNumberC.dispose();
    _flatC.dispose();
    _floorC.dispose();
    scrollController.dispose();
    _selectedSourceNotifier.dispose();
    _selectedSubSourceNotifier.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _applicantNameC = TextEditingController();
    _applicantMobileC = TextEditingController();
    _wingC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _flatC = TextEditingController();
    _floorC = TextEditingController();
    _agreementValueC = TextEditingController();
    _bookingTypeC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_bookingCubit.state.isLoading! &&
          _bookingCubit.state.bookingList.length <
              _bookingCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _bookingCubit.getBookingList(
            context,
            _bookingCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterBooking(BuildContext context) async {
    final state = _bookingCubit.state;

    final DateTime? initialStartDate = state.filterStartDate;
    final DateTime? initialEndDate = state.filterEndDate;

    final String? initialDirection =
        state.currentSortColumn == "ApplicantName"
            ? state.currentSortDirection
            : null;

    final initialWing = state.filterWing;
    final initialMobile = state.filterMobileNumber;
    final initialFlat = state.filterFlat;
    final initialFloor = state.filterFloor;
    final initialAgreement = state.filterAgreementValue;
    final initialBookingType = state.filterBookingType;
    final initialSource = state.filterSource;
    final initialSubSource = state.filterSubSource;

    _wingC.text = initialWing;
    _mobileNumberC.text = initialMobile;
    _flatC.text = initialFlat;
    _floorC.text = initialFloor;
    _agreementValueC.text =
        initialAgreement > 0 ? initialAgreement.toString() : "";
    _bookingTypeC.text = initialBookingType;

    _startDateNotifier.value = initialStartDate;
    _endDateNotifier.value = initialEndDate;

    _selectedSourceNotifier.value = sourceTypeList.firstWhere(
      (e) => e['DisplayName'] == initialSource,
      orElse: () => sourceTypeList.first,
    );

    _selectedSubSourceNotifier.value =
        (initialSubSource.isNotEmpty)
            ? (channelPartnerActivityList + directWalkingSubSourceList)
                .firstWhere(
                  (e) => e['DisplayName'] == initialSubSource,
                  orElse:
                      () =>
                          (_selectedSourceNotifier.value?['zAttributesId'] == 1
                              ? channelPartnerActivityList.first
                              : directWalkingSubSourceList.first),
                )
            : null;

    String? selectedDirection = initialDirection;

    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState() {
      final int agreementValue =
          _agreementValueC.text.trim().isEmpty
              ? 0
              : int.tryParse(_agreementValueC.text.trim()) ?? 0;

      final currentSource =
          (_selectedSourceNotifier.value?['zAttributesId'] == -1)
              ? ''
              : _selectedSourceNotifier.value?['DisplayName'] ?? '';

      final currentSubSource =
          (_selectedSubSourceNotifier.value?['zAttributesId'] == -1)
              ? ''
              : _selectedSubSourceNotifier.value?['DisplayName'] ?? '';

      final bool manualChange =
          (_startDateNotifier.value != initialStartDate) ||
          (_endDateNotifier.value != initialEndDate) ||
          (_wingC.text.trim() != initialWing) ||
          (_mobileNumberC.text.trim() != initialMobile) ||
          (_flatC.text.trim() != initialFlat) ||
          (_floorC.text.trim() != initialFloor) ||
          (currentSource != initialSource) ||
          (currentSubSource != initialSubSource) ||
          (agreementValue != initialAgreement) ||
          (_bookingTypeC.text.trim() != initialBookingType) ||
          (selectedDirection != initialDirection);

      final bool onlyOneDateSet =
          (_startDateNotifier.value != null &&
              _endDateNotifier.value == null) ||
          (_endDateNotifier.value != null && _startDateNotifier.value == null);

      final bool invalidRange =
          (_startDateNotifier.value != null &&
              _endDateNotifier.value != null &&
              _startDateNotifier.value!.isAfter(_endDateNotifier.value!));

      applyEnabled.value = manualChange && !onlyOneDateSet && !invalidRange;
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Booking",
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
                Text("Sort By Applicant Name", style: AppTextStyle.ts14M()),
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
                CustomTextField(
                  textController: _mobileNumberC,
                  title: "Applicant Mobile Number",
                  hint: "Enter Applicant Mobile Number",
                  keyboardType: TextInputType.number,
                  inputFormatterList: InputValidator.digit(10),
                  onChangeFunction: (_) => updateApplyState(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _startDateNotifier,
                        builder: (_, startDate, __) {
                          return CustomDatePicker(
                            title: "From Date",
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
                        builder: (_, endDate, __) {
                          return CustomDatePicker(
                            title: "To Date",
                            initialDate: endDate,
                            setValue: (value) {
                              _endDateNotifier.value = value;
                              updateApplyState();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                CustomTextField(
                  textController: _wingC,
                  title: "Wing",
                  hint: "Enter Wing",
                  onChangeFunction: (_) => updateApplyState(),
                ),
                CustomTextField(
                  textController: _flatC,
                  title: "Flat",
                  hint: "Enter Flat",
                  onChangeFunction: (_) => updateApplyState(),
                ),
                CustomTextField(
                  textController: _floorC,
                  title: "Floor",
                  hint: "Enter Floor",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                ValueListenableBuilder(
                  valueListenable: _selectedSourceNotifier,
                  builder: (context, selectedSource, _) {
                    final bool isChannelPartner =
                        selectedSource?['zAttributesId'] == 1;

                    return Column(
                      children: [
                        CustomDropDownWidget(
                          title: 'Source',
                          initialValue: selectedSource ?? sourceTypeList.first,
                          dataList: sourceTypeList,
                          onSelected: (v) {
                            _selectedSourceNotifier.value = v;
                            _selectedSubSourceNotifier.value =
                                v['zAttributesId'] == 1
                                    ? channelPartnerActivityList.first
                                    : directWalkingSubSourceList.first;
                            updateApplyState();
                          },
                        ),

                        if ((selectedSource?['zAttributesId'] ?? -1) != -1)
                          ValueListenableBuilder(
                            valueListenable: _selectedSubSourceNotifier,
                            builder: (context, selectedSubSource, _) {
                              return CustomDropDownWidget(
                                title: "Sub Source",
                                initialValue:
                                    selectedSubSource ??
                                    (isChannelPartner
                                        ? channelPartnerActivityList.first
                                        : directWalkingSubSourceList.first),
                                dataList:
                                    isChannelPartner
                                        ? channelPartnerActivityList
                                        : directWalkingSubSourceList,
                                onSelected: (v) {
                                  _selectedSubSourceNotifier.value = v;
                                  updateApplyState();
                                },
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),

                CustomTextField(
                  textController: _agreementValueC,
                  title: "Agreement Value",
                  hint: "Enter Agreement Value",
                  keyboardType: TextInputType.number,
                  onChangeFunction: (_) => updateApplyState(),
                ),
                CustomTextField(
                  textController: _bookingTypeC,
                  title: "Booking Type",
                  hint: "Enter Booking Type",
                  onChangeFunction: (_) => updateApplyState(),
                ),
              ],
            ),
          );
        },
      ),

      /// CLEAR
      onClear: () {
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _wingC.clear();
        _mobileNumberC.clear();
        _flatC.clear();
        _floorC.clear();
        _agreementValueC.clear();
        _bookingTypeC.clear();
        selectedDirection = null;

        _selectedSourceNotifier.value = null;
        _selectedSubSourceNotifier.value = null;

        _bookingCubit.applyEnquiryFilterAndSort(
          context: context,
          filterStartDate: null,
          filterEndDate: null,
          filterWing: '',
          filterMobileNumber: '',
          filterFlat: '',
          filterFloor: '',
          filterSource: '',
          filterSubSource: '',
          filterAgreementValue: 0,
          filterBookingType: '',
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },

      /// APPLY
      onApply: () {
        applied = true;

        final int agreementValue =
            _agreementValueC.text.trim().isEmpty
                ? 0
                : int.tryParse(_agreementValueC.text.trim()) ?? 0;

        _bookingCubit.applyEnquiryFilterAndSort(
          context: context,
          filterStartDate: _startDateNotifier.value,
          filterEndDate: _endDateNotifier.value,
          filterWing: _wingC.text.trim(),
          filterMobileNumber: _mobileNumberC.text.trim(),
          filterFlat: _flatC.text.trim(),
          filterFloor: _floorC.text.trim(),
          filterSource:
              (_selectedSourceNotifier.value != null &&
                      _selectedSourceNotifier.value!['zAttributesId'] != -1)
                  ? _selectedSourceNotifier.value!['DisplayName']
                  : '',
          filterSubSource:
              (_selectedSubSourceNotifier.value != null &&
                      _selectedSubSourceNotifier.value!['zAttributesId'] != -1)
                  ? _selectedSubSourceNotifier.value!['DisplayName']
                  : '',
          sortColumn:
              selectedDirection != null ? "ApplicantName" : "Created Date",
          sortDirection: selectedDirection ?? "DESC",
          filterAgreementValue: agreementValue,
          filterBookingType: _bookingTypeC.text.trim(),
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    if (!applied) {
      _startDateNotifier.value = initialStartDate;
      _endDateNotifier.value = initialEndDate;
      selectedDirection = initialDirection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Booking",
        authorization: _routhAuthorizationModel,
        textController: _searchC,
        searchHintText: "Search by Applicant Name",
        onSearchSubmit: (value) {
          _bookingCubit.searchBooking(context, value);
        },
        onExportCallback: (value) {
          if (_bookingCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _bookingCubit.exportExcelPdf(context, value, getProject().projectId);
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _bookingCubit.getBookingList(context, 1, value.projectId);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterBooking(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _bookingCubit.searchBooking(context, "");
        },
        child: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.bookingList.isEmpty) {
              return Center(child: loader());
            }

            return state.bookingList.isEmpty
                ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: noDataWidget(message: "No Booking Data Found"),
                      ),
                    ),
                  ],
                )
                : ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _bookingCubit.state.bookingList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.bookingList.length) {
                      return state.bookingList.length <
                              state.totalNumberOfRecord
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    var booking = state.bookingList[index];
                    final bool isActionAllowed = booking.isApproval;

                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(12),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    goRouter.pushNamed(
                                      AppRoutes.viewBooking,
                                      queryParameters: {
                                        "bookingId": Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            booking.bookingId.toString(),
                                          ),
                                        ),
                                        "projectId": Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            booking.projectId.toString(),
                                          ),
                                        ),
                                      },
                                    );
                                  },
                                  child: Text(
                                    booking.applicantName,
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.primary,
                                    ).copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColor.primary,
                                    ),
                                  ),
                                ),
                              ),

                              _routhAuthorizationModel.isAction &&
                                      (booking.approvalStatus.toLowerCase() ==
                                              'pending' ||
                                          booking.approvalStatus
                                                  .toLowerCase() ==
                                              'refund')
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconButton.edit(
                                        onPressed: () {
                                          goRouter.pushNamed(
                                            AppRoutes.addBooking,
                                            queryParameters: {
                                              "booking": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(booking),
                                                ),
                                              ),
                                              "index": index.toString(),
                                            },
                                          );
                                        },
                                      ),
                                      horizontalSpacing(),
                                    ],
                                  )
                                  : SizedBox.shrink(),
                              approvalStatusWidget(booking.approvalStatus),
                            ],
                          ),
                          verticalSpacing(height: 5),
                          buildRowTitleValue(
                            title: "Enquiry Code",
                            value: booking.systemGeneratedCode,
                            fixesWidth: 170,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Flat",
                            value: booking.flat,
                            fixesWidth: 170,
                          ),
                          buildRowTitleValue(
                            title: "Category",
                            value: booking.flatType,
                            fixesWidth: 170,
                          ),
                          buildRowTitleValue(
                            title: "Flat Configuration:",
                            value: booking.flatConfiguration,
                            fixesWidth: 170,
                          ),
                          buildRowTitleValue(
                            title: "Agreement Value (₹)",
                            value: booking.agreementValue.toString(),
                            fixesWidth: 170,
                          ),
                          buildRowTitleValue(
                            title: "Expected Registration",
                            value: formatDateTimeAsDDMMMYYYY(
                              booking.registrationDate,
                            ),
                            fixesWidth: 170,
                          ),
                          verticalSpacing(),
                          ApproveRejectWidget(
                            actionTitle:
                                isActionAllowed ? "Actions" : "History",
                            popupTitle:
                                "${booking.applicantName} ${booking.flat.isNotEmpty ? " > ${booking.flat}" : ""}",

                            isActionAlreadyPerformed: !isActionAllowed,
                            onApprove: (val) async {
                              await _loginCubit.updateModulesWorkflowApproval(
                                context: context,
                                moduleName: 'BOOKING APPROVAL',
                                id: booking.bookingId,
                                projectId: _project.projectId,
                                isApproved: true,
                                remark: val.trim(),
                              );
                              if (context.mounted) {
                                _bookingCubit.getBookingList(
                                  context,
                                  1,
                                  _project.projectId,
                                );
                              }
                            },
                            onReject: (val) async {
                              await _loginCubit.updateModulesWorkflowApproval(
                                context: context,
                                moduleName: 'BOOKING APPROVAL',
                                id: booking.bookingId,
                                projectId: _project.projectId,
                                isApproved: false,
                                remark: val.trim(),
                              );
                              if (context.mounted) {
                                _bookingCubit.getBookingList(
                                  context,
                                  1,
                                  _project.projectId,
                                );
                              }
                            },
                            onThirdTap: () async {
                              final approvalLogHistoryList = await _loginCubit
                                  .getApprovalLogHistory(
                                    context: context,
                                    projectId: _project.projectId,
                                    id: booking.bookingId,
                                    moduleName: "BOOKING APPROVAL",
                                  );

                              if (context.mounted) {
                                goRouter.pushNamed(
                                  AppRoutes.approvalLogHistory,
                                  queryParameters: {
                                    "subTitle": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        "${booking.applicantName} ${booking.flat.isNotEmpty ? " > ${booking.flat}" : ""}",
                                      ),
                                    ),
                                    "title": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        "Booking Log History",
                                      ),
                                    ),
                                    "approvalList": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          approvalLogHistoryList
                                              .map((e) => e.toJson())
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  },
                                );
                              }
                            },
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
