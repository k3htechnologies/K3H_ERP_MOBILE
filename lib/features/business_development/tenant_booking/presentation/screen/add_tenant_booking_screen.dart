import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/business_development/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/business_development/tenant_booking/presentation/cubit/tenant_booking_cubit.dart';
import 'package:k3h_erp_app/features/business_development/tenant_booking/presentation/cubit/tenant_booking_state.dart';
import 'package:k3h_erp_app/features/business_development/tenant_booking/presentation/screen/add_tenant_booking_payment_schedule_screen.dart';
import 'package:k3h_erp_app/features/masters/company_setup/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/data/repository/payment_schedule_scheme.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:k3h_erp_app/features/masters/company_setup/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';

// ONE FILE PER TAB (they share this file's imports and private members)
part 'tabs/details_tab.dart';
part 'tabs/payment_schedule_tab.dart';
part 'tabs/other_charges_tab.dart';
part 'tabs/payment_details_tab.dart';
part 'tabs/terms_tab.dart';
part 'tabs/remark_tab.dart';

class AddTenantBookingScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? inventoryObject;
  final BookingModel? tenantBookingModel;
  final int? index;

  const AddTenantBookingScreen({
    super.key,
    this.inventoryObject,
    this.tenantBookingModel,
    this.index,
  });

  @override
  State<AddTenantBookingScreen> createState() => _AddTenantBookingScreenState();
}

class _AddTenantBookingScreenState extends State<AddTenantBookingScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late TenantBookingCubit _bookingCubit;

  // TAB CONTROLLER
  late TabController _tabController;

  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);

  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();

  // TEXT EDITING CONTROLLER
  late final List<TextEditingController> _controllers;
  late TextEditingController _tenantUniqueCodeC,
      _permanentAddressC,
      _communicationAddressC,
      _agreementValueWithTdsC,
      _tdsC,
      _agreementValueWithoutTdsC,
      _agreementGstPercentageC,
      _agreementGstAmountC,
      _stampDutyPercentageC,
      _stampDutyAmountC,
      _registrationFeesC,
      _otherRemarkC,
      _unitModCustomizationRemarkC,
      _paymentRemarkC,
      _termsAndConditionDescriptionC,
      _bookingAmountC,
      _chequeNoC,
      _otpController,
      _noOfParkingC;

  final ValueNotifier<bool> _isRERA = ValueNotifier(true);

  // AGREEMENT VALUE NOTIFIER
  final ValueNotifier<double> _agreementValueNotifier = ValueNotifier<double>(
    0.0,
  );

  // TDS NOTIFIER
  final ValueNotifier<double> _tdsNotifier = ValueNotifier<double>(0.0);

  // WITHOUT TDS NOTIFIER
  final ValueNotifier<double> _withoutTdsNotifier = ValueNotifier<double>(0.0);

  // AGREEMENT GST AMOUNT NOTIFIER
  final ValueNotifier<double> _agreementGstAmountNotifier =
      ValueNotifier<double>(0.0);

  // STAMP DUTY AMOUNT NOTIFIER
  final ValueNotifier<double> _stampDutyAmountNotifier = ValueNotifier<double>(
    0.0,
  );

  // REGISTRATION FEES NOTIFIER
  final ValueNotifier<double> _registrationFeesNotifier = ValueNotifier<double>(
    0.0,
  );

  // SEARCH SYSTEM GENERATED CODE
  Timer? _debounce;

  // PROJECT
  late ProjectModel _project;

  // FLAGS TO PREVENT INFINITE CALLS
  int? _lastFetchedBuildingId;

  // DATE PICKER
  final ValueNotifier<DateTime?> _selectedExpectedRegistrationDate =
      ValueNotifier<DateTime?>(null);
  // fetching flag for tenant API to avoid relying on global isLoading
  final ValueNotifier<bool> _isFetchingTenant = ValueNotifier<bool>(false);
  // track whether we've attempted to fetch for current code (so we don't show "Invalid" before any call)
  final ValueNotifier<bool> _tenantFetchTried = ValueNotifier<bool>(false);
  DateTime? _selectedChequeDate;

  // STATIC HAND OVER TYPE LIST
  List<Map<String, dynamic>> handOverTypeList = [
    {"zAttributesId": 1, "DisplayName": "Bare Shell"},
    {"zAttributesId": 2, "DisplayName": "Builder Finished"},
  ];

  // SELECTED HAND OVER TYPE
  final ValueNotifier<Map<String, dynamic>?> _selectedHandOverType =
      ValueNotifier({});

  // STATIC HAND OVER TYPE LIST
  final List<Map<String, dynamic>> fundingSourceList = [
    {'zAttributesId': 1, 'DisplayName': 'Loan'},
    {'zAttributesId': 2, 'DisplayName': 'Self-funded'},
    {'zAttributesId': 3, 'DisplayName': 'Sale Of Property'},
  ];

  // SELECTED SOURCE OF FUNDING
  final ValueNotifier<Map<String, dynamic>?> _selectedFundingSource =
      ValueNotifier({});

  // METHODS TO CHECK IF APPLICANT TYPE IS PRIMARY
  bool _isApplicantType(String type) =>
      type.toLowerCase().trim() == 'applicant';

  bool _hasPrimaryApplicant(List<TenantApplicantData> applicants) =>
      applicants.any((e) => _isApplicantType(e.applicantType));

  bool get isTenantEditMode =>
      (widget.tenantBookingModel != null ||
          widget.inventoryObject?[0]["tenantId"] != 0);

  // APPLICANT LIST
  final ValueNotifier<List<TenantApplicantData>> _applicants =
      ValueNotifier<List<TenantApplicantData>>([]);

  // PARKING SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedParkingNotifier =
      ValueNotifier([]);

  // TERMS AND CONDITIONS SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedTermsNotifier =
      ValueNotifier([]);

  // BANK SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier =
      ValueNotifier([]);

  // FORM KEY
  final _detailsFormKey = GlobalKey<FormState>();
  final _otherChargesFormKey = GlobalKey<FormState>();
  final _paymentScheduleFormKey = GlobalKey<FormState>();
  final _remarkFormKey = GlobalKey<FormState>();
  final _termsFormKey = GlobalKey<FormState>();
  final _paymentDetailsFormKey = GlobalKey<FormState>();

  //EDIT MODE
  bool get _isEditMode => widget.tenantBookingModel != null;

  // REPOSITORY
  final PaymentScheduleSchemeRepository _paymentScheduleSchemeRepository =
      serviceLocator<PaymentScheduleSchemeRepository>();
  // SCHEME DROPDOWN VARIABLES
  late ValueNotifier<List<Map<String, dynamic>>> schemeListNotifier;
  late ValueNotifier<Map<String, dynamic>> selectedScheme;

  // MANUAL PAYMENT SCHEDULE HANDLER
  final ValueNotifier<bool> isAutoPaymentSchedule = ValueNotifier(false);

  // OTHER CHARGERS IS APPLICABLE
  final ValueNotifier<bool> _isOtherChargeApplicable = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
    _bookingCubit = context.read<TenantBookingCubit>();
    _project = getProject();

    _tabController = TabController(length: 6, vsync: this);
    _bookingCubit.onTabChangedAddForm(0, context);
    _agreementValueNotifier.addListener(_calculateTds);

    schemeListNotifier = ValueNotifier([]);
    selectedScheme = ValueNotifier({});

    if (_isEditMode || widget.inventoryObject?[0]["tenantId"] != 0) {
      _initEditMode();
    } else {
      loadPaymentScheduleSchemes();
    }
  }

  Future<void> _initEditMode() async {
    final bm = widget.tenantBookingModel;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogHelper.showProcessingOverlay(context);
    });

    try {
      _tenantUniqueCodeC.text =
          widget.inventoryObject?.isNotEmpty == true
              ? (widget.inventoryObject![0]["tenantSystemGeneratedCode"] ?? '')
                  .toString()
              : (bm?.systemGeneratedCode ?? '');
      await _bookingCubit.getTenantList(
        context: context,
        projectId: _project.projectId,
        systemGeneratedCode:
            widget.inventoryObject?[0]["tenantSystemGeneratedCode"] ??
            bm?.systemGeneratedCode,
        buildingId:
            widget.inventoryObject?[0]["tenantBuildingId"] ??
            (bm?.tenantBuildingId ?? 0),
        tenantId: widget.inventoryObject?[0]["tenantId"] ?? (bm?.tenantId ?? 0),
      );
      _applicants.value = List<TenantApplicantData>.from(
        _bookingCubit.state.tenantList.first.tenantApplicantData,
      );
      _selectedBuildingNotifier.value = [
        {
          "DisplayName": _bookingCubit.state.tenantList.first.buildingName,
          "zAttributesId": _bookingCubit.state.tenantList.first.buildingId,
        },
      ];
      await loadPaymentScheduleSchemes();

      if (_isEditMode) _prefill(bm!);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        goRouter.pop();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    //DISPOSE TEXTCONTROLLERS
    for (final controller in _controllers) {
      controller.dispose();
    }
    _bookingCubit.clearTenantList();
    _agreementValueNotifier.dispose();
    _tdsNotifier.dispose();
    _withoutTdsNotifier.dispose();
    _agreementGstAmountNotifier.dispose();
    _stampDutyAmountNotifier.dispose();
    _registrationFeesNotifier.dispose();
    _isFetchingTenant.dispose();
    _isOtherChargeApplicable.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT CONTROLLERS
  void _initializeTextControllers() {
    _controllers = [
      _tenantUniqueCodeC = TextEditingController(),
      _permanentAddressC = TextEditingController(),
      _communicationAddressC = TextEditingController(),
      _agreementValueWithTdsC = TextEditingController(),
      _tdsC = TextEditingController(),
      _agreementValueWithoutTdsC = TextEditingController(),
      _agreementGstPercentageC = TextEditingController(text: "0"),
      _agreementGstAmountC = TextEditingController(text: "0"),
      _stampDutyPercentageC = TextEditingController(text: "0"),
      _stampDutyAmountC = TextEditingController(text: "0"),
      _registrationFeesC = TextEditingController(),
      _otherRemarkC = TextEditingController(),
      _unitModCustomizationRemarkC = TextEditingController(),
      _paymentRemarkC = TextEditingController(),
      _termsAndConditionDescriptionC = TextEditingController(),
      _bookingAmountC = TextEditingController(),
      _chequeNoC = TextEditingController(),
      _otpController = TextEditingController(),
      _noOfParkingC = TextEditingController(),
    ];
  }

  // PREFILL DATA
  void _prefill(BookingModel bm) {
    // ADDRESS
    _permanentAddressC.text = bm.permanentAddress;
    _communicationAddressC.text = bm.communicationAddress;
    final tenant = _bookingCubit.state.tenantList.first;

    _tenantUniqueCodeC.text = tenant.systemGeneratedCode;

    // AGREEMENT AND TAX DETAILS
    _agreementValueWithTdsC.text = bm.agreementValue.toString();
    _agreementValueNotifier.value = bm.agreementValue;
    _tdsC.text = bm.agreementValueTDS.toString();
    _agreementGstPercentageC.text = bm.agreementValueGSTPercentage.toString();
    _agreementGstAmountNotifier.value = bm.agreementValueGSTAmount;
    _agreementGstAmountC.text = bm.agreementValueGSTAmount.toString();
    _stampDutyPercentageC.text = bm.stampDutyPercentage.toString();
    _stampDutyAmountC.text = bm.stampDutyAmount.toString();
    _stampDutyAmountNotifier.value = bm.stampDutyAmount;
    _registrationFeesC.text = bm.registrationFees.toString();

    // PARKING DETAILS
    if (bm.parkingData.isNotEmpty) {
      _selectedParkingNotifier.value =
          bm.parkingData
              .map(
                (p) => {
                  "zAttributesId": p.parkingId,
                  "DisplayName": p.parkingNumber,
                },
              )
              .toList();
    }
    // OTHER DETAILS
    _selectedHandOverType.value = handOverTypeList.firstWhere(
      (item) => item["DisplayName"] == bm.handoverType,
      orElse: () => handOverTypeList.first,
    );
    _selectedFundingSource.value = fundingSourceList.firstWhere(
      (item) => item["DisplayName"] == bm.sourceOfFunding,
      orElse: () => fundingSourceList.first,
    );

    _noOfParkingC.text = bm.numberOfParking.toString();
    _selectedExpectedRegistrationDate.value = bm.registrationDate;

    // UPDATE PAYMENT SCHEDULE LIST
    _bookingCubit.updatePaymentScheduleList(bm.bookingPaymentScheduleData);
    selectedScheme.value = schemeListNotifier.value.firstWhere(
      (item) => item["DisplayName"] == bm.paymentScheduleScheme,
      orElse: () => {},
    );
    isAutoPaymentSchedule.value =
        selectedScheme.value["DisplayName"] != "Other" ? true : false;
    // OTHER CHARGES
    _isOtherChargeApplicable.value = bm.isApplicableOtherCharge;
    _bookingCubit.updateOtherChargesList(bm.bookingOtherChargesData);

    // PAYMENT DETAILS
    _bookingAmountC.text = bm.bookingAmount.toString();
    _chequeNoC.text = bm.chequeRTGSNumber;
    _selectedChequeDate = bm.chequeRTGSDate;

    // BANK - SET SELECTED BANK IF PRESENT
    if (bm.bankListMasterId != 0) {
      _selectedBankNotifier.value = [
        {"zAttributesId": bm.bankListMasterId, "DisplayName": bm.bankName},
      ];
    }

    // TERM AND CONDITION
    if (bm.termsAndConditionsDescription.isNotEmpty) {
      _selectedTermsNotifier.value = [
        {
          "zAttributesId": 1,
          "DisplayName": "Terms & Conditions",
          "Description": bm.termsAndConditionsDescription,
        },
      ];
    }
    _termsAndConditionDescriptionC.text = _selectedTermsNotifier.value
        .map((e) => e['Description'] ?? '')
        .join('\n\n');

    // REMARK
    _unitModCustomizationRemarkC.text = bm.flatAlterationRemark;
    _paymentRemarkC.text = bm.paymentRemark;
    _otherRemarkC.text = bm.otherRemark;
  }

  // CALCULATE TDS
  void _calculateTds() {
    final value = _agreementValueNotifier.value;

    const limit = 4999999.99;

    double tds = 0;
    double withoutTds = value;

    if (value > limit) {
      tds = value * 0.01;
    }
    withoutTds = value - tds;
    _tdsNotifier.value = tds;
    _withoutTdsNotifier.value = withoutTds;

    _tdsC.text = tds == 0 ? "" : tds.toStringAsFixed(2);
    _agreementValueWithoutTdsC.text = withoutTds.toStringAsFixed(2);

    _calculateGst();
    _calculateStampDuty();
    _calculateRegistrationFees();
    _bookingCubit.onUpdateBookingAmount(
      agreementValueWithTds:
          _agreementValueWithoutTdsC.text.isNotEmpty
              ? double.tryParse(_agreementValueWithoutTdsC.text.trim()) ?? 0.0
              : 0.0,
      agreementValueGST: _agreementGstAmountNotifier.value,
      agreementValueTds: _tdsNotifier.value,
    );
  }

  // CALCULATE GST
  void _calculateGst() {
    final agreementValue = _agreementValueNotifier.value;
    final percent = double.tryParse(_agreementGstPercentageC.text) ?? 0;

    if (agreementValue == 0 || percent == 0) {
      _agreementGstAmountNotifier.value = 0;
      _agreementGstAmountC.clear();
      return;
    }

    final amount = agreementValue * percent / 100;

    _agreementGstAmountNotifier.value = amount;
    _agreementGstAmountC.text = amount.toStringAsFixed(2);
  }

  // CALCULATE STAMP DUTY
  void _calculateStampDuty() {
    final agreementValue = _agreementValueNotifier.value;
    final percent = double.tryParse(_stampDutyPercentageC.text) ?? 0;

    if (agreementValue == 0 || percent == 0) {
      _stampDutyAmountNotifier.value = 0;
      _stampDutyAmountC.clear();
      return;
    }

    final amount = agreementValue * percent / 100;

    _stampDutyAmountNotifier.value = amount;
    _stampDutyAmountC.text = amount.toStringAsFixed(2);
  }

  // CALCULATE REGISTRATION FEES
  void _calculateRegistrationFees() {
    final value = _agreementValueNotifier.value;

    if (value == 0) {
      _registrationFeesNotifier.value = 0;
      _registrationFeesC.clear();
      return;
    }

    const limit = 2999999.99;

    double fees;

    if (value <= limit) {
      //  1% if <= 29,99,999.99
      fees = value * 0.01;
    } else {
      //  Fixed 30,000 if above limit
      fees = 30000;
    }

    _registrationFeesNotifier.value = fees;
    _registrationFeesC.text = fees.toStringAsFixed(2);
  }

  // OPEN PAYMENT SCHEDULE FORM
  Future<void> _openPaymentScheduleForm({int? index}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTenantBookingPaymentScheduleScreen(
              inventoryBuildingId:
                  widget.inventoryObject?[0]["inventoryBuildingId"] ??
                  widget.tenantBookingModel!.inventoryBuildingId,
              inventoryFlatFloorBasementPodiumWingId:
                  widget
                      .inventoryObject?[0]["inventoryFlatFloorBasementPodiumWingId"] ??
                  widget
                      .tenantBookingModel!
                      .inventoryFlatFloorBasementPodiumWingId,
              agreementValueWithoutTDS: double.parse(
                _agreementValueWithoutTdsC.text,
              ),
              agreementValueGST: _agreementGstAmountNotifier.value,
              agreementValueTds: _tdsNotifier.value,
              index: index,
            ),
      ),
    );

    isAutoPaymentSchedule.value = false;
  }

  // FETCHING PARKING METHODS
  Future<Map<String, dynamic>> _fetchParking(
    int pageNumber, {
    String? value,
  }) async {
    final isSearch = value != null && value.isNotEmpty;

    if (pageNumber == 1) {
      _bookingCubit.clearParkingList();
    }

    await _bookingCubit.getParkingList(
      context,
      pageNumber,
      _project.projectId,
      searchQuery: isSearch ? value : null,
      displayParkingId:
          _isEditMode ? widget.tenantBookingModel!.parkingId : null,
    );

    final updatedList = _bookingCubit.state.parkingList;
    final totalCount = _bookingCubit.state.totalNumberOfRecordParking;

    final Map<int, Map<String, dynamic>> uniqueParking = {};
    for (final p in updatedList) {
      uniqueParking[p.parkingId] = {
        "zAttributesId": p.parkingId,
        "DisplayName": p.parkingNumber,
      };
    }

    return {
      "itemList": uniqueParking.values.toList(),
      "totalNumberOfRecord": totalCount > 0 ? totalCount : uniqueParking.length,
    };
  }

  // FETCHING TERMS AND CONDITIONS METHODS
  Future<Map<String, dynamic>> _fetchTerms(
    int pageNumber, {
    String? value,
  }) async {
    final isSearch = value != null && value.isNotEmpty;

    if (pageNumber == 1) {
      _bookingCubit.clearTermsList();
    }

    await _bookingCubit.getTermsAndConditionsList(
      context,
      pageNumber,
      moduleName: "BOOKING",
      searchQuery: isSearch ? value : null,
    );

    final updatedList = _bookingCubit.state.termsList;
    final totalCount = _bookingCubit.state.totalNumberOfRecordTerms;

    final Map<int, Map<String, dynamic>> uniqueTerms = {};
    for (final t in updatedList) {
      uniqueTerms[t.termsAndConditionsMasterId] = {
        "zAttributesId": t.termsAndConditionsMasterId,
        "DisplayName": t.title,
        "Description": t.description,
      };
    }

    return {
      "itemList": uniqueTerms.values.toList(),
      "totalNumberOfRecord": totalCount > 0 ? totalCount : uniqueTerms.length,
    };
  }

  // FETCHING BANK METHODS
  Future<Map<String, dynamic>> _fetchBanks(
    int pageNumber, {
    String? value,
  }) async {
    final employeeRepo = serviceLocator<EmployeeMasterRepository>();
    // SEARCH MODE
    if (value != null && value.isNotEmpty) {
      final result = await employeeRepo.getBankList(
        pageNumber: pageNumber,
        pageSize: 10,
        query: {"BankName": value},
      );
      return result.fold(
        (failure) {
          return {"itemList": [], "totalNumberOfRecord": 0};
        },
        (response) {
          final banks = response['data'] as List<BankListMasterModel>;

          return {
            "itemList":
                banks.map((bank) {
                  return {
                    "zAttributesId": bank.bankListMasterId,
                    "DisplayName": bank.bankNameWithCode,
                  };
                }).toList(),
            "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
          };
        },
      );
    }

    // NO SEARCH: paginate using API
    final result = await employeeRepo.getBankList(
      pageNumber: pageNumber,
      pageSize: 10,
      query: null,
    );
    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project = response['data'] as List<BankListMasterModel>;

        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.bankListMasterId,
                  "DisplayName": pr.bankNameWithCode,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // VALIDATE ALL TABS
  Future<bool> _validateAllTabs() async {
    // STEP 1: DETAILS TAB
    if (!(_detailsFormKey.currentState?.validate() ?? false)) {
      _bookingCubit.onTabChangedAddForm(0, context);
      _tabController.animateTo(0);
      return false;
    }

    if (_applicants.value.isEmpty) {
      _bookingCubit.onTabChangedAddForm(0, context);
      _tabController.animateTo(0);
      showErrorMessage(context, "", "At least one applicant is required");
      return false;
    }

    if (!_hasPrimaryApplicant(_applicants.value)) {
      _bookingCubit.onTabChangedAddForm(0, context);
      _tabController.animateTo(0);
      showErrorMessage(context, "", "One Applicant is required");
      return false;
    }

    // STEP 2: PAYMENT SCHEDULE
    if (_bookingCubit.state.bookingPaymentScheduleList.isEmpty) {
      _bookingCubit.onTabChangedAddForm(1, context);
      _tabController.animateTo(1);
      showErrorMessage(context, "", "Add Payment Schedule Details");
      return false;
    }
    // PAYMENT SCHEDULE SHOULD BE 100 PERCENTAGE COMPLETED
    if (_bookingCubit.totalCumulativePercentage != 100) {
      _bookingCubit.onTabChangedAddForm(1, context);
      _tabController.animateTo(1);
      showErrorMessage(
        context,
        "",
        "Payment schedule total must be exactly 100%. Current total is ${_bookingCubit.remainingPercentage}",
      );
      return false;
    }

    // STEP 3 : TERMS AND CONDITIONS
    if (!(_termsFormKey.currentState?.validate() ?? false)) {
      _bookingCubit.onTabChangedAddForm(4, context);
      _tabController.animateTo(4);
      return false;
    }
    // STEP 4: REMARK
    if (!(_remarkFormKey.currentState?.validate() ?? false)) {
      _bookingCubit.onTabChangedAddForm(5, context);
      _tabController.animateTo(5);
      return false;
    }

    return await _bookingCubit.validateTenant(
      context: context,
      tenantList: _bookingCubit.state.tenantList,
    );
  }

  // LOAD PAYMENT SCHEDULE SCHEMES
  Future<void> loadPaymentScheduleSchemes({int pageNumber = 1}) async {
    final result = await _paymentScheduleSchemeRepository
        .getPaymentScheduleSchemeList(
          pageNumber: pageNumber,
          pageSize: 40,
          projectId: _project.projectId,
          queryParams: <String, dynamic>{
            "InventoryBuildingId":
                widget.inventoryObject?[0]["inventoryBuildingId"] ??
                widget.tenantBookingModel?.inventoryBuildingId,
            "InventoryFlatFloorBasementPodiumWingId":
                widget
                    .inventoryObject?[0]["inventoryFlatFloorBasementPodiumWingId"] ??
                widget
                    .tenantBookingModel
                    ?.inventoryFlatFloorBasementPodiumWingId,
          },
        );

    result.fold(
      (failure) {
        schemeListNotifier.value = <Map<String, dynamic>>[];
        selectedScheme.value = <String, dynamic>{};
      },
      (response) {
        final paymentScheduleSchemes =
            response['data'] as List<PaymentScheduleSchemeModel>;

        final List<Map<String, dynamic>> apiList =
            paymentScheduleSchemes
                .map<Map<String, dynamic>>(
                  (scheme) => <String, dynamic>{
                    "zAttributesId": scheme.paymentScheduleSchemeMasterId,
                    "DisplayName": scheme.paymentScheduleSchemeName,
                    "inventoryFlatFloorBasementPodiumWingId":
                        scheme.inventoryFlatFloorBasementPodiumWingId,
                    "inventoryBuildingId": scheme.inventoryBuildingId,
                  },
                )
                .toList();

        apiList.add(<String, dynamic>{
          "zAttributesId": -1,
          "DisplayName": "Other",
        });

        schemeListNotifier.value = apiList;
      },
    );
  }

  // PARKING STRING GETTER
  String get selectedParkings => _selectedParkingNotifier.value
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");

  // SUBMIT BOOKING FORM
  void _saveForm() async {
    final registrationDate =
        _selectedExpectedRegistrationDate.value ?? DateTime.now();
    final chequeDate = _selectedChequeDate;
    final parkingId = selectedParkings;
    final handoverType = _selectedHandOverType.value!['DisplayName'] ?? "";
    final inventoryFlatId =
        widget.inventoryObject?[0]['inventoryFlatId'] ??
        widget.tenantBookingModel!.inventoryFlatId;
    final bankId =
        _selectedBankNotifier.value.isNotEmpty
            ? _selectedBankNotifier.value.first['zAttributesId']
            : 0;

    if (_isEditMode) {
      await _bookingCubit.updateBooking(
        context: context,
        index: widget.index!,
        bookingId: widget.tenantBookingModel!.bookingId,
        uniqueKey: widget.tenantBookingModel!.uniquekey,
        projectId: _project.projectId,
        tenantId: _bookingCubit.state.tenantList.first.tenantId,
        permanentAddress: _permanentAddressC.text.trim(),
        communicationAddress: _communicationAddressC.text.trim(),
        inventoryFlatId: inventoryFlatId,
        agreementValue: _agreementValueNotifier.value,
        agreementValueTds: _tdsNotifier.value,
        sourceOfFunding: _selectedFundingSource.value!['DisplayName'] ?? "",
        agreementValueGSTPercentage:
            double.tryParse(_agreementGstPercentageC.text) ?? 0.0,
        agreementValueGSTAmount: _agreementGstAmountNotifier.value,
        stampDutyPercentage: double.tryParse(_stampDutyPercentageC.text) ?? 0.0,
        stampDutyAmount: _stampDutyAmountNotifier.value,
        registrationFees: double.parse(_registrationFeesC.text.trim()),
        parkingId: parkingId,
        handoverType: handoverType,
        registrationDate: registrationDate,
        flatAlterationRemark: _unitModCustomizationRemarkC.text.trim(),
        paymentRemark: _paymentRemarkC.text.trim(),
        otherRemark: _otherRemarkC.text.trim(),
        termsAndConditionsDescription:
            _termsAndConditionDescriptionC.text.trim(),
        bookingType: 'FLAT',
        otherChargesDetailJSON: _bookingCubit.state.otherChargesList,
        paymentScheduleScheme: selectedScheme.value["DisplayName"],
        paymentScheduleSchemeMasterId:
            selectedScheme.value["zAttributesId"] == -1
                ? 0
                : selectedScheme.value["zAttributesId"],
        paymentScheduleDetailJSON:
            _bookingCubit.state.bookingPaymentScheduleList,
        bookingAmount: double.tryParse(_bookingAmountC.text) ?? 0.0,
        chequeRTGSNumber: _chequeNoC.text.trim(),
        chequeRTGSDate: chequeDate,
        bankListMasterId: bankId,
        transferBookingId: null,
        otp: _otpController.text.trim(),
        addUpdateBookingApplicant: _applicants.value,
        numberOfParking:
            _noOfParkingC.text.trim().isNotEmpty
                ? int.parse(_noOfParkingC.text.trim())
                : 0,
        isApplicableOtherCharge: _isOtherChargeApplicable.value,
        tenantBuildingId: _bookingCubit.state.tenantList.first.buildingId,
        carpetAreaPurchaseSqFt: _isRERA.value ? "RERA" : "MOFA",
      );
    } else {
      await _bookingCubit.addTenantBooking(
        context: context,
        projectId: _project.projectId,
        tenantId: _bookingCubit.state.tenantList.first.tenantId,
        tenantBuildingId: _bookingCubit.state.tenantList.first.buildingId,
        permanentAddress: _permanentAddressC.text.trim(),
        communicationAddress: _communicationAddressC.text.trim(),
        inventoryFlatId: inventoryFlatId,
        agreementValue: _agreementValueNotifier.value,
        agreementValueTds: _tdsNotifier.value,
        agreementValueGSTPercentage:
            double.tryParse(_agreementGstPercentageC.text) ?? 0.0,
        agreementValueGSTAmount: _agreementGstAmountNotifier.value,
        stampDutyPercentage: double.tryParse(_stampDutyPercentageC.text) ?? 0.0,
        stampDutyAmount: _stampDutyAmountNotifier.value,
        registrationFees: double.parse(_registrationFeesC.text.trim()),
        sourceOfFunding: _selectedFundingSource.value!['DisplayName'] ?? "",
        parkingId: parkingId,
        numberOfParking:
            _noOfParkingC.text.trim().isNotEmpty
                ? int.parse(_noOfParkingC.text.trim())
                : 0,
        handoverType: handoverType,
        carpetAreaPurchaseSqFt: _isRERA.value ? "RERA" : "MOFA",
        registrationDate: registrationDate,
        flatAlterationRemark: _unitModCustomizationRemarkC.text.trim(),
        paymentRemark: _paymentRemarkC.text.trim(),
        otherRemark: _otherRemarkC.text.trim(),
        termsAndConditionsDescription:
            _termsAndConditionDescriptionC.text.trim(),
        bookingType: 'FLAT',
        otherChargesDetailJSON: _bookingCubit.state.otherChargesList,
        paymentScheduleScheme: selectedScheme.value["DisplayName"],
        paymentScheduleSchemeMasterId:
            selectedScheme.value["zAttributesId"] == -1
                ? 0
                : selectedScheme.value["zAttributesId"],
        paymentScheduleDetailJSON:
            _bookingCubit.state.bookingPaymentScheduleList,
        bookingAmount: double.tryParse(_bookingAmountC.text) ?? 0.0,
        chequeRTGSNumber: _chequeNoC.text.trim(),
        chequeRTGSDate: chequeDate,
        bankListMasterId: bankId,
        transferBookingId: 0,
        otp: _otpController.text.trim(),
        addUpdateBookingApplicant: _applicants.value,
        buildingIndex: widget.inventoryObject?[0]["buildingIndex"],
        wingIndex: widget.inventoryObject?[0]["wingIndex"],
        floorIndex: widget.inventoryObject?[0]["floorIndex"],
        flatIndex: widget.inventoryObject?[0]["flatIndex"],
        isApplicableOtherCharge: _isOtherChargeApplicable.value,
      );
    }
  }

  // DELETE PAYMENT SCHEDULE
  Future<void> _showPopupToDeletePaymentSchedule(
    BuildContext context,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete this payment schedule?',
      'Deleting this payment schedule will permanently remove it.',
    );

    if (result && context.mounted) {
      _bookingCubit.deletePaymentSchedule(index, context);
    }
  }

  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: _project.projectId,
      queryParams:
          value != null && value.isNotEmpty
              ? {"BuildingName": value, "isCheckPermission": false}
              : {"isCheckPermission": false},
    );
    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project =
            response['data'] as List<BusinessDevelopmentBuildingModel>;
        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.buildingId,
                  "DisplayName": pr.buildingName,
                  "building": pr,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Tenant Booking Form",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<TenantBookingCubit, TenantBookingState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: showSiteSelectedWidget(),
              ),
              ChipStyleTabBar(
                controller: _tabController,
                tabs: const [
                  'Details',
                  'Payment Schedule',
                  'Other Charges',
                  'Payment Details',
                  'Terms & Condition',
                  'Remark',
                ],
                onTabChanged: (index) {
                  _bookingCubit.onTabChangedAddForm(index, context);
                },
              ),
              Expanded(
                child: IndexedStack(
                  index: state.currentTabIndexAddForm,
                  children: [
                    _buildDetails(),
                    _buildPaymentSchedule(),
                    _buildOtherCharges(),
                    _buildPaymentDetails(),
                    _buildTermsAndCondition(),
                    _buildRemark(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: _isEditMode ? 'Update Booking' : 'Add Booking',
            onPressed: () async {
              if (await _validateAllTabs()) {
                _saveForm();
              }
            },
          ),
        ),
      ),
    );
  }
}
