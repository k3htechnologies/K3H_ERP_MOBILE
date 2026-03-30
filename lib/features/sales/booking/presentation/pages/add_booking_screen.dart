import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/add_booking_applicant_screen.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/add_booking_payment_schedule_screen.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/repository/payment_schedule_scheme.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_verification_dialog.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';

class AddBookingScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? inventoryObject;
  final BookingModel? bookingModel;
  final int? index;

  const AddBookingScreen({
    super.key,
    this.inventoryObject,
    this.bookingModel,
    this.index,
  });

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late LoginCubit _loginCubit;
  late BookingCubit _bookingCubit;

  // TAB CONTROLLER
  late TabController _tabController;

  // TEXT EDITING CONTROLLER
  late final List<TextEditingController> _controllers;
  late TextEditingController _enquiryUniqueCodeC,
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
      _referencePercentageC,
      _referenceAmountC,
      _employeeRefPercentageC,
      _employeeRefAmountC,
      _loyaltyPercentageC,
      _loyaltyAmountC,
      _brokeragePercentageC,
      _brokerageAmountC,
      _noOfParkingC;

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
  // fetching flag for enquiry API to avoid relying on global isLoading
  final ValueNotifier<bool> _isFetchingEnquiry = ValueNotifier<bool>(false);
  // track whether we've attempted to fetch for current code (so we don't show "Invalid" before any call)
  final ValueNotifier<bool> _enquiryFetchTried = ValueNotifier<bool>(false);
  DateTime? _selectedChequeDate;

  // STATIC HAND OVER TYPE LIST
  List<Map<String, dynamic>> handOverTypeList = [
    {"zAttributesId": -1, "DisplayName": "Select Handover Type"},
    {"zAttributesId": 1, "DisplayName": "Bare Shell"},
    {"zAttributesId": 2, "DisplayName": "Builder Finished"},
  ];

  // SELECTED HAND OVER TYPE
  final ValueNotifier<Map<String, dynamic>> _selectedHandOverType =
      ValueNotifier({});

  // STATIC HAND OVER TYPE LIST
  final List<Map<String, dynamic>> fundingSourceList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Funding Source'},
    {'zAttributesId': 1, 'DisplayName': 'Loan'},
    {'zAttributesId': 2, 'DisplayName': 'Self-funded'},
    {'zAttributesId': 3, 'DisplayName': 'Sale Of Property Funding'},
  ];

  // SELECTED SOURCE OF FUNDING
  final ValueNotifier<Map<String, dynamic>> _selectedFundingSource =
      ValueNotifier({});

  // METHODS TO CHECK IF APPLICANT TYPE IS PRIMARY
  bool _isApplicantType(String type) =>
      type.toLowerCase().trim() == 'applicant';

  bool _hasPrimaryApplicant(List<BookingApplicantData> applicants) =>
      applicants.any((e) => _isApplicantType(e.applicantType));

  // APPLICANT LIST
  final ValueNotifier<List<BookingApplicantData>> _applicants =
      ValueNotifier<List<BookingApplicantData>>([]);

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
  bool get _isEditMode => widget.bookingModel != null;

  // REPOSITORY
  final PaymentScheduleSchemeRepository _paymentScheduleSchemeRepository =
      serviceLocator<PaymentScheduleSchemeRepository>();
  // SCHEME DROPDOWN VARIABLES
  late ValueNotifier<List<Map<String, dynamic>>> schemeListNotifier;
  late ValueNotifier<Map<String, dynamic>> selectedScheme;

  // MANUAL PAYMENT SCHEDULE HANDLER
  bool isAutoPaymentSchedule = false;

  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
    _bookingCubit = context.read<BookingCubit>();
    _loginCubit = context.read<LoginCubit>();
    _project = getProject();

    _tabController = TabController(length: 6, vsync: this);
    _bookingCubit.onTabChangedAddForm(0, context);
    _selectedHandOverType.value = handOverTypeList.first;
    _selectedFundingSource.value = fundingSourceList.first;

    _agreementValueNotifier.addListener(_calculateTds);

    schemeListNotifier = ValueNotifier([]);
    selectedScheme = ValueNotifier({});

    if (_isEditMode) {
      _initEditMode();
    } else {
      loadPaymentScheduleSchemes();
      _bookingCubit.getOtherChargesList(
        context,
        1,
        _project.projectId,
        widget.inventoryObject?[0]["reraCarpetAreaSqFt"],
      );
    }
  }

  Future<void> _initEditMode() async {
    final bm = widget.bookingModel!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogHelper.showProcessingOverlay(context);
    });

    try {
      await _bookingCubit.getEnquiryList(
        context,
        1,
        _project.projectId,
        null,
        bm.enquiryId,
      );

      await loadPaymentScheduleSchemes();

      _prefill(bm);
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
    _bookingCubit.clearEnquiryList();
    _agreementValueNotifier.dispose();
    _tdsNotifier.dispose();
    _withoutTdsNotifier.dispose();
    _agreementGstAmountNotifier.dispose();
    _stampDutyAmountNotifier.dispose();
    _registrationFeesNotifier.dispose();
    _isFetchingEnquiry.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT CONTROLLERS
  void _initializeTextControllers() {
    _controllers = [
      _enquiryUniqueCodeC = TextEditingController(),
      _permanentAddressC = TextEditingController(),
      _communicationAddressC = TextEditingController(),
      _agreementValueWithTdsC = TextEditingController(),
      _tdsC = TextEditingController(),
      _agreementValueWithoutTdsC = TextEditingController(),
      _agreementGstPercentageC = TextEditingController(),
      _agreementGstAmountC = TextEditingController(),
      _stampDutyPercentageC = TextEditingController(),
      _stampDutyAmountC = TextEditingController(),
      _registrationFeesC = TextEditingController(),
      _otherRemarkC = TextEditingController(),
      _unitModCustomizationRemarkC = TextEditingController(),
      _paymentRemarkC = TextEditingController(),
      _termsAndConditionDescriptionC = TextEditingController(),
      _bookingAmountC = TextEditingController(),
      _chequeNoC = TextEditingController(),
      _otpController = TextEditingController(),
      _referencePercentageC = TextEditingController(),
      _referenceAmountC = TextEditingController(),

      _employeeRefPercentageC = TextEditingController(),
      _employeeRefAmountC = TextEditingController(),

      _loyaltyPercentageC = TextEditingController(),
      _loyaltyAmountC = TextEditingController(),

      _brokeragePercentageC = TextEditingController(),
      _brokerageAmountC = TextEditingController(),
      _noOfParkingC = TextEditingController(),
    ];
  }

  // PREFILL DATA
  void _prefill(BookingModel bm) {
    // ADDRESS
    _permanentAddressC.text = bm.permanentAddress;
    _communicationAddressC.text = bm.communicationAddress;

    // APPLICANT
    _applicants.value = List<BookingApplicantData>.from(
      bm.bookingApplicantData,
    );
    final enquiry = _bookingCubit.state.enquiryList.first;

    _enquiryUniqueCodeC.text = enquiry.systemGeneratedCode;

    // AGREEMENT AND TAX DETAILS
    _agreementValueWithTdsC.text = bm.agreementValue.toString();
    _agreementValueNotifier.value = bm.agreementValue;
    _tdsC.text = bm.agreementValueTDS.toString();
    _agreementGstPercentageC.text = bm.agreementValueGSTPercentage.toString();
    _agreementGstAmountNotifier.value = bm.agreementValueGSTAmount;
    _agreementGstAmountC.text = bm.agreementValueGSTAmount.toString();
    _stampDutyPercentageC.text = bm.stampDutyPercentage.toString();
    _stampDutyAmountC.text = bm.stampDutyAmount.toString();
    _registrationFeesC.text = bm.registrationFees.toString();
    //FILLED COMMISSION TEXTCONTROLLERS
    _referencePercentageC.text = bm.referelPercentage.toString();
    _referenceAmountC.text = bm.referelAmount.toString();

    _employeeRefPercentageC.text = bm.employeeReferencePercentage.toString();
    _employeeRefAmountC.text = bm.employeeReferenceAmount.toString();

    _loyaltyPercentageC.text = bm.loyaltyPercentage.toString();
    _loyaltyAmountC.text = bm.loyaltyAmount.toString();

    _brokeragePercentageC.text = bm.brokeragePercentage.toString();
    _brokerageAmountC.text = bm.brokerageAmount.toString();

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
    // OTHER CHARGES
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
      agreementValue: _agreementValueNotifier.value,
      agreementValueGST: _agreementGstAmountNotifier.value,
      agreementValueTds: _tdsNotifier.value,
    );
  }

  // REMOVE HTML TAGS
  String _stripHtmlTags(String html) {
    if (html.isEmpty) return '';
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
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

  // OPEN APPLICANT FORM
  Future<void> _openApplicantForm({
    BookingApplicantData? applicant,
    int? index,
  }) async {
    if (mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddBookingApplicantScreen(
              applicant: applicant,
              index: index,
              hasPrimaryApplicant: _hasPrimaryApplicant(_applicants.value),
            ),
      ),
    );

    if (result == null || result['applicant'] == null) return;

    final BookingApplicantData updatedApplicant = result['applicant'];
    final int? updatedIndex = result['index'] as int?;

    final currentApplicants = List<BookingApplicantData>.from(
      _applicants.value,
    );
    final existingApplicantIndex = currentApplicants.indexWhere(
      (e) => _isApplicantType(e.applicantType),
    );
    final bool isUpdatingExisting =
        updatedIndex != null && updatedIndex < currentApplicants.length;
    if (_isApplicantType(updatedApplicant.applicantType) &&
        existingApplicantIndex != -1 &&
        (!isUpdatingExisting || existingApplicantIndex != updatedIndex) &&
        mounted) {
      await showErrorMessage(
        context,
        'Error',
        'Only one Applicant type is allowed.',
      );
      return;
    }

    if (isUpdatingExisting) {
      final int targetIndex = updatedIndex;
      currentApplicants[targetIndex] = updatedApplicant;
    } else {
      currentApplicants.add(updatedApplicant);
    }
    _applicants.value = currentApplicants;
  }

  // OPEN PAYMENT SCHEDULE FORM
  Future<void> _openPaymentScheduleForm({int? index}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddBookingPaymentScheduleScreen(
              inventoryBuildingId:
                  widget.inventoryObject?[0]["inventoryBuildingId"] ??
                  widget.bookingModel!.inventoryBuildingId,
              inventoryFlatFloorBasementPodiumWingId:
                  widget
                      .inventoryObject?[0]["inventoryFlatFloorBasementPodiumWingId"] ??
                  widget.bookingModel!.inventoryFlatFloorBasementPodiumWingId,
              agreementValue: _agreementValueNotifier.value,
              agreementValueGST: _agreementGstAmountNotifier.value,
              agreementValueTds: _tdsNotifier.value,
              index: index,
            ),
      ),
    );

    isAutoPaymentSchedule = false;
  }

  // DELETE APPLICANT
  void _deleteApplicant(int index) {
    final currentApplicants = List<BookingApplicantData>.from(
      _applicants.value,
    );
    if (index < 0 || index >= currentApplicants.length) return;
    currentApplicants.removeAt(index);
    _applicants.value = currentApplicants;
  }

  // FETCHING PARKING METHODS
  Future<Map<String, dynamic>> _fetchParking(
    int pageNumber, {
    String? value,
  }) async {
    if (value != null && value.isNotEmpty) {
      await _bookingCubit.getParkingList(
        context,
        pageNumber,
        _project.projectId,
        searchQuery: value,
        displayParkingId: _isEditMode ? widget.bookingModel!.parkingId : null,
      );

      final parkingList = _bookingCubit.state.parkingList;
      final totalCount = _bookingCubit.state.totalNumberOfRecordParking;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};
      for (final p in parkingList) {
        uniqueFiltered[p.parkingId] = {
          "zAttributesId": p.parkingId,
          "DisplayName": p.parkingNumber,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    final parkingList = _bookingCubit.state.parkingList;
    final totalCount = _bookingCubit.state.totalNumberOfRecordParking;
    final currentLoadedCount = parkingList.length;

    if (currentLoadedCount == 0 || currentLoadedCount < totalCount) {
      await _bookingCubit.getParkingList(
        context,
        pageNumber,
        _project.projectId,
        displayParkingId: _isEditMode ? widget.bookingModel!.parkingId : null,
      );
    }

    final updatedList = _bookingCubit.state.parkingList;

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
    // SEARCH MODE
    if (value != null && value.isNotEmpty) {
      await _bookingCubit.getTermsAndConditionsList(
        context,
        pageNumber,
        moduleName: "BOOKING",
        searchQuery: value,
      );

      final termsList = _bookingCubit.state.termsList;
      final totalCount = _bookingCubit.state.totalNumberOfRecordTerms;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};
      for (final t in termsList) {
        uniqueFiltered[t.termsAndConditionsMasterId] = {
          "zAttributesId": t.termsAndConditionsMasterId,
          "DisplayName": t.title,
          "Description": t.description,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    final termsList = _bookingCubit.state.termsList;
    final totalCount = _bookingCubit.state.totalNumberOfRecordTerms;
    final currentLoadedCount = termsList.length;

    if (currentLoadedCount == 0 || currentLoadedCount < totalCount) {
      await _bookingCubit.getTermsAndConditionsList(
        context,
        pageNumber,
        moduleName: "BOOKING",
      );
    }

    final updatedList = _bookingCubit.state.termsList;

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
          final data = response['data'] as List? ?? [];
          final banks =
              data
                  .map(
                    (e) => Map<String, dynamic>.from(e as Map<String, dynamic>),
                  )
                  .toList();
          final Map<int, Map<String, dynamic>> unique = {};
          for (final b in banks) {
            final id =
                b['BankListMasterId'] is int
                    ? b['BankListMasterId'] as int
                    : int.tryParse(b['BankListMasterId'].toString()) ?? -1;
            unique[id] = {
              "zAttributesId": id,
              "DisplayName": b['BankNameWithCode'],
            };
          }
          final total = response['totalNumberOfRecord'] ?? unique.length;
          return {
            "itemList": unique.values.toList(),
            "totalNumberOfRecord": total,
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
    // VALIDATE DETAILS TAB
    if (!(_detailsFormKey.currentState?.validate() ?? false)) {
      _tabController.animateTo(0);
      _bookingCubit.onTabChangedAddForm(0, context);
      //CHECK APPLICANTS

      if (_applicants.value.isEmpty) {
        showErrorMessage(context, "", "At least one applicant is required");
        return false;
      }
    }

    if (!_hasPrimaryApplicant(_applicants.value)) {
      _tabController.animateTo(0);
      _bookingCubit.onTabChangedAddForm(0, context);
      showErrorMessage(
        context,
        "",
        "In Applicant List - One Applicant is required",
      );
      return false;
    }

    // VALIDATE PAYMENT SCHEDULE
    if (_bookingCubit.state.bookingPaymentScheduleList.isEmpty) {
      _tabController.animateTo(1);
      _bookingCubit.onTabChangedAddForm(1, context);
      showErrorMessage(context, "", "Add Payment Schedule Details");
      return false;
    }

    if (_bookingCubit.totalCumulativePercentage.toStringAsFixed(2) !=
        "100.00") {
      _tabController.animateTo(1);
      _bookingCubit.onTabChangedAddForm(1, context);
      showErrorMessage(
        context,
        "",
        "Payment schedule total must be exactly 100%. Current total is ${_bookingCubit.totalCumulativePercentage.toStringAsFixed(2)}%",
      );
      return false;
    }

    return true;
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
                widget.bookingModel?.inventoryBuildingId,
            "InventoryFlatFloorBasementPodiumWingId":
                widget
                    .inventoryObject?[0]["inventoryFlatFloorBasementPodiumWingId"] ??
                widget.bookingModel?.inventoryFlatFloorBasementPodiumWingId,
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
  void _submitForm() async {
    if (_isEditMode) {
      _submitDetails();
      return;
    }
    {
      String applicantMobile =
          _applicants.value
              .firstWhere((a) => a.applicantType == "Applicant")
              .applicantMobileNumber;
      // CHECK DETAILS FILLED
      bool isPaymentDetails =
          _bookingAmountC.text.isNotEmpty &&
          _chequeNoC.text.isNotEmpty &&
          _selectedChequeDate != null &&
          _selectedBankNotifier.value.isNotEmpty;
      bool isOtherDetails = _bookingCubit.state.otherChargesList.isNotEmpty;
      // TRIGGER OTP SEND FIST TIME
      _loginCubit.sendOTPModuleBased(
        context: context,
        mobileNumber: applicantMobile,
        module: "BOOKING",
      );
      showCompleteVerificationDialog(
        context,
        otpController: _otpController,
        verificationSteps: {
          "Applicant Details": true,
          "Project Details": true,
          "Payment Schedule": true,
          "Payment Details": isPaymentDetails,
          "Other Charge Details": isOtherDetails,
        },
        onVerifyOTP: () async {
          _submitDetails();
        },
      );
    }
  }

  //SUBMIT DETAILS
  void _submitDetails() async {
    final enquiry = _bookingCubit.state.enquiryList.first;

    // COMMISSION VARIABLE
    double brokeragePercentage = 0.0, brokerageAmount = 0.0;
    double referencePercentage = 0.0, referenceAmount = 0.0;
    double employeeRefPercentage = 0.0, employeeRefAmount = 0.0;
    double loyaltyPercentage = 0.0, loyaltyAmount = 0.0;

    //SET BASED ON ENQUIRY TYPE (SOURCE)
    switch (enquiry.subSource) {
      case "Reference":
        referencePercentage =
            double.tryParse(_referencePercentageC.text) ?? 0.0;
        referenceAmount = double.tryParse(_referenceAmountC.text) ?? 0.0;
        break;
      case "Employee Reference":
        employeeRefPercentage =
            double.tryParse(_employeeRefPercentageC.text) ?? 0.0;
        employeeRefAmount = double.tryParse(_employeeRefAmountC.text) ?? 0.0;
        break;
      case "Loyalty":
        loyaltyPercentage = double.tryParse(_loyaltyPercentageC.text) ?? 0.0;
        loyaltyAmount = double.tryParse(_loyaltyAmountC.text) ?? 0.0;
        break;
    }

    if (enquiry.source == "Channel Partner") {
      brokeragePercentage = double.tryParse(_brokeragePercentageC.text) ?? 0.0;
      brokerageAmount = double.tryParse(_brokerageAmountC.text) ?? 0.0;
    }

    final registrationDate =
        _selectedExpectedRegistrationDate.value ?? DateTime.now();
    final chequeDate = _selectedChequeDate;
    final parkingId = selectedParkings;
    final modeOfPayment = _selectedFundingSource.value['DisplayName'] ?? "";
    final handoverType = _selectedHandOverType.value['DisplayName'] ?? "";
    final inventoryFlatId =
        widget.inventoryObject?[0]['inventoryFlatId'] ??
        widget.bookingModel!.inventoryFlatId;
    final bankId =
        _selectedBankNotifier.value.isNotEmpty
            ? _selectedBankNotifier.value.first['zAttributesId']
            : null;

    if (_isEditMode) {
      await _bookingCubit.updateBooking(
        context: context,
        index: widget.index!,
        bookingId: widget.bookingModel!.bookingId,
        uniqueKey: widget.bookingModel!.uniquekey,
        projectId: _project.projectId,
        enquiryId: _bookingCubit.state.enquiryList.first.enquiryId,
        permanentAddress: _permanentAddressC.text.trim(),
        communicationAddress: _communicationAddressC.text.trim(),
        brokeragePercentage: brokeragePercentage,
        brokerageAmount: brokerageAmount,
        referelPercentage: referencePercentage,
        referelAmount: referenceAmount,
        employeeReferencePercentage: employeeRefPercentage,
        employeeReferenceAmount: employeeRefAmount,
        loyaltyPercentage: loyaltyPercentage,
        loyaltyAmount: loyaltyAmount,
        inventoryFlatId: inventoryFlatId,
        agreementValue: _agreementValueNotifier.value,
        agreementValueTds: _tdsNotifier.value,
        sourceOfFunding: _selectedFundingSource.value['DisplayName'] ?? "",

        agreementValueGSTPercentage:
            double.tryParse(_agreementGstPercentageC.text) ?? 0.0,
        agreementValueGSTAmount: _agreementGstAmountNotifier.value,
        stampDutyPercentage: double.tryParse(_stampDutyPercentageC.text) ?? 0.0,
        stampDutyAmount: double.parse(_stampDutyAmountC.text.trim()),
        registrationFees: double.parse(_registrationFeesC.text.trim()),
        parkingId: parkingId,
        handoverType: handoverType,
        registrationDate: registrationDate,
        modeOfPayment: modeOfPayment,
        flatAlterationRemark: _unitModCustomizationRemarkC.text.trim(),
        paymentRemark: _paymentRemarkC.text.trim(),
        otherRemark: _otherRemarkC.text.trim(),
        termsAndConditionsDescription:
            _termsAndConditionDescriptionC.text.trim(),
        bookingType: 'FLAT',
        otherChargesDetailJSON: _bookingCubit.state.otherChargesList,
        paymentScheduleDetailJSON:
            _bookingCubit.state.bookingPaymentScheduleList,
        bookingAmount: double.tryParse(_bookingAmountC.text) ?? 0.0,
        chequeRTGSNumber: _chequeNoC.text.trim(),
        chequeRTGSDate: chequeDate,
        bankListMasterId: bankId,
        transferBookingId: null,
        tenantId: 0,
        otp: _otpController.text.trim(),
        addUpdateBookingApplicant: _applicants.value,
        numberOfParking:
            _noOfParkingC.text.trim().isNotEmpty
                ? int.parse(_noOfParkingC.text.trim())
                : 0,
      );
    } else {
      await _bookingCubit.addBooking(
        context: context,
        projectId: _project.projectId,
        enquiryId: _bookingCubit.state.enquiryList.first.enquiryId,
        permanentAddress: _permanentAddressC.text.trim(),
        communicationAddress: _communicationAddressC.text.trim(),
        brokeragePercentage: brokeragePercentage,
        brokerageAmount: brokerageAmount,
        referelPercentage: referencePercentage,
        referelAmount: referenceAmount,
        employeeReferencePercentage: employeeRefPercentage,
        employeeReferenceAmount: employeeRefAmount,
        loyaltyPercentage: loyaltyPercentage,
        loyaltyAmount: loyaltyAmount,
        inventoryFlatId: inventoryFlatId,
        agreementValue: _agreementValueNotifier.value,
        agreementValueTds: _tdsNotifier.value,
        agreementValueGSTPercentage:
            double.tryParse(_agreementGstPercentageC.text) ?? 0.0,
        agreementValueGSTAmount: _agreementGstAmountNotifier.value,
        stampDutyPercentage: double.tryParse(_stampDutyPercentageC.text) ?? 0.0,
        stampDutyAmount: double.parse(_stampDutyAmountC.text.trim()),
        registrationFees: double.parse(_registrationFeesC.text.trim()),
        sourceOfFunding: _selectedFundingSource.value['DisplayName'] ?? "",
        parkingId: parkingId,
        numberOfParking:
            _noOfParkingC.text.trim().isNotEmpty
                ? int.parse(_noOfParkingC.text.trim())
                : 0,
        handoverType: handoverType,
        registrationDate: registrationDate,
        modeOfPayment: modeOfPayment,
        flatAlterationRemark: _unitModCustomizationRemarkC.text.trim(),
        paymentRemark: _paymentRemarkC.text.trim(),
        otherRemark: _otherRemarkC.text.trim(),
        termsAndConditionsDescription:
            _termsAndConditionDescriptionC.text.trim(),
        bookingType: 'FLAT',
        otherChargesDetailJSON: _bookingCubit.state.otherChargesList,

        paymentScheduleDetailJSON:
            _bookingCubit.state.bookingPaymentScheduleList,
        bookingAmount: double.tryParse(_bookingAmountC.text) ?? 0.0,
        chequeRTGSNumber: _chequeNoC.text.trim(),
        chequeRTGSDate: chequeDate,
        bankListMasterId: bankId,
        transferBookingId: null,
        tenantId: 0,
        otp: _otpController.text.trim(),
        addUpdateBookingApplicant: _applicants.value,
        buildingIndex: widget.inventoryObject?[0]["buildingIndex"],
        wingIndex: widget.inventoryObject?[0]["wingIndex"],
        floorIndex: widget.inventoryObject?[0]["floorIndex"],
        flatIndex: widget.inventoryObject?[0]["flatIndex"],
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

  // CALCULATE COMMISTION AMOUNT
  void calculateCommissionAmount({
    required double agreementAmount,
    required TextEditingController percentController,
    required TextEditingController amountController,
  }) {
    final percent = double.tryParse(percentController.text) ?? 0.0;
    final amount = (agreementAmount * percent) / 100;
    amountController.text = amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Booking Form",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          return Column(
            children: [
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
            text: _isEditMode ? 'Update' : 'Add',
            onPressed: () async {
              if (await _validateAllTabs()) {
                _submitForm();
              }
            },
          ),
        ),
      ),
    );
  }

  // BUILD DETAILS
  Widget _buildDetails() {
    return Form(
      key: _detailsFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // ENQUIRY SYSTEM GENERATED CODE
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  BlocConsumer<BookingCubit, BookingState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      final enquiry =
                          state.enquiryList.isNotEmpty
                              ? state.enquiryList.first
                              : null;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            title: "Enquiry Code",
                            isRequired: true,
                            readOnly: _isEditMode,
                            inputFormatterList: [
                              UpperCaseTextFormatter(),
                              LengthLimitingTextInputFormatter(18),
                            ],
                            hint: "Enter Enquiry Code",
                            textController: _enquiryUniqueCodeC,
                            onChangeFunction: (value) {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }

                              if (value.length != 18) {
                                // CLEAR ANY PREVIOUS ENQUIRY RESULT AND FETCH FLAGS
                                _bookingCubit.clearEnquiryList();
                                _enquiryFetchTried.value = false;
                                _isFetchingEnquiry.value = false;
                                return;
                              }

                              _debounce = Timer(
                                const Duration(milliseconds: 500),
                                () async {
                                  if (value.length == 18) {
                                    _isFetchingEnquiry.value = true;
                                    _enquiryFetchTried.value = true;
                                    await _bookingCubit.getEnquiryList(
                                      context,
                                      1,
                                      _project.projectId,
                                      value,
                                      null,
                                    );
                                    _isFetchingEnquiry.value = false;
                                  }
                                },
                              );
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enquiry Code is required';
                              }
                              return null;
                            },
                          ),
                          if (enquiry != null &&
                              (enquiry.finalStage.toLowerCase() !=
                                      'booking done' ||
                                  _isEditMode)) ...[
                            infoCard([
                              {
                                "title": "Enquiry Code",
                                "value": enquiry.systemGeneratedCode,
                              },
                              {"title": "Name", "value": enquiry.name},
                              {
                                "title": "Mobile No",
                                "value": enquiry.mobileNumber,
                                "widget": CustomClickToContactText(
                                  value: enquiry.mobileNumber,
                                ),
                              },
                              {"title": "Source", "value": enquiry.source},
                              {
                                "title": "Sub Source",
                                "value": enquiry.subSource,
                              },
                              {
                                "title": "Sales Advisor",
                                "value": enquiry.salesAdvisor,
                              },
                              {
                                "title": "Sourcing Manager",
                                "value": enquiry.sourcingManager,
                              },
                              {"title": "Stage", "value": enquiry.finalStage},
                              {
                                "title": "Current Location",
                                "value": enquiry.currentLocation,
                              },
                            ]),
                            Column(
                              children: [
                                if (enquiry.subSource == "Reference")
                                  infoCard([
                                    {
                                      "title": "Referral Name",
                                      "value": enquiry.referelName,
                                    },
                                    {
                                      "title": "Referral Mobile",
                                      "value": enquiry.referelMobileNumber,
                                    },
                                    {
                                      "title": "Referral Project",
                                      "value": enquiry.referelProjectName,
                                    },
                                    {
                                      "title": "Referral Unit No",
                                      "value": enquiry.referelUnitNumber,
                                    },
                                  ]),

                                if (enquiry.subSource == "Employee Reference")
                                  infoCard([
                                    {
                                      "title": "Employee Name",
                                      "value": enquiry.employeeReferenceName,
                                    },
                                    {
                                      "title": "Employee Mobile",
                                      "value":
                                          enquiry.employeeReferenceMobileNumber,
                                    },
                                  ]),

                                if (enquiry.subSource == "Loyalty")
                                  infoCard([
                                    {
                                      "title": "Existing Project",
                                      "value":
                                          enquiry.loyaltyExistingProjectName,
                                    },
                                    {
                                      "title": "Existing Unit No",
                                      "value":
                                          enquiry.loyaltyExistingUnitNumber,
                                    },
                                  ]),
                                if (enquiry.source == "Channel Partner")
                                  infoCard([
                                    {
                                      "title": "Channel Partner",
                                      "value": enquiry.channelPartnerName,
                                    },
                                    {
                                      "title": "CP Mobile",
                                      "value":
                                          enquiry.channelPartnerMobileNumber,
                                    },
                                    {
                                      "title": "CP Team Member",
                                      "value":
                                          enquiry.channelPartnerTeamMemberName,
                                    },
                                    {
                                      "title": "CP Team Mobile",
                                      "value":
                                          enquiry
                                              .channelPartnerTeamMemberMobileNumber,
                                    },
                                  ]),
                              ],
                            ),
                            verticalSpacing(),
                          ] else if (_enquiryUniqueCodeC.text.trim().length ==
                                  18 &&
                              (_isFetchingEnquiry.value ||
                                  (_debounce?.isActive ?? false) ||
                                  state.isLoading == true)) ...[
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColor.lightBlue,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColor.primary,
                                  width: .5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  horizontalSpacing(width: 10),
                                  Text(
                                    "Fetching enquiry...",
                                    style: AppTextStyle.ts14M(),
                                  ),
                                ],
                              ),
                            ),
                            verticalSpacing(),
                          ] else if (enquiry != null &&
                              enquiry.finalStage.toLowerCase() ==
                                  'booking done') ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.lightRed,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColor.error,
                                  width: .5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Booking already done for this enquiry",
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ] else if (_enquiryUniqueCodeC.text.trim().length ==
                                  18 &&
                              _enquiryFetchTried.value &&
                              enquiry == null &&
                              !(_isFetchingEnquiry.value ||
                                  (_debounce?.isActive ?? false) ||
                                  state.isLoading == true)) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.lightRed,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColor.error,
                                  width: .5,
                                ),
                              ),
                              child: Text(
                                "No Enquiry details found for this Enquiry Code",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ] else ...[
                            SizedBox(),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // APPLICANT
            Container(
              decoration: commonCardDecoration(),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Applicant Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  Row(
                    children: [
                      Text(
                        "Add Applicant Details",
                        style: AppTextStyle.ts14M(),
                      ),
                      Spacer(),
                      CustomButton(
                        leading: Icon(
                          Icons.add,
                          size: 18,
                          color: AppColor.white,
                        ),
                        text: "Add Applicant",
                        onPressed: () async => _openApplicantForm(),
                        backgroundColor: AppColor.primary,
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  ValueListenableBuilder<List<BookingApplicantData>>(
                    valueListenable: _applicants,
                    builder: (context, applicants, child) {
                      if (applicants.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              'No applicants added yet',
                              style: AppTextStyle.ts14R(color: AppColor.grey),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 450,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: applicants.length,
                          itemBuilder: (context, index) {
                            final applicant = applicants[index];

                            return _buildApplicantCard(applicant, index);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // ADDRESS
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Address Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  CustomTextField(
                    key: const ValueKey("permanent_address"),
                    title: "Permanent Address",
                    isRequired: true,
                    hint: "Enter Permanent Address",
                    textController: _permanentAddressC,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Permanent Address is required";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: "Communication Address",
                    key: const ValueKey("communication_address"),
                    isRequired: true,
                    hint: "Enter Communication Address",
                    textController: _communicationAddressC,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Communication Address is required";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            // PROJECT DETAILS
            infoCard(title: "Project Details", [
              {
                "title": "Building Number",
                "value":
                    widget.inventoryObject?[0]["buildingNumber"] ??
                    widget.bookingModel!.buildingNumber,
              },
              {
                "title": "Wing",
                "value":
                    widget.inventoryObject?[0]["wing"] ??
                    widget.bookingModel!.wing,
              },
              {
                "title": "Floor",
                "value":
                    widget.inventoryObject?[0]["floor"] ??
                    widget.bookingModel!.floor,
              },
              {
                "title": "Unit No",
                "value":
                    widget.inventoryObject?[0]["flat"] ??
                    widget.bookingModel!.flat,
              },
              {
                "title": "Flat Type",
                "value":
                    widget.inventoryObject?[0]["flatType"] ??
                    widget.bookingModel!.flatType,
              },
              {
                "title": "Flat Configuration",
                "value":
                    widget.inventoryObject?[0]["flatConfiguration"] ??
                    widget.bookingModel!.flatConfiguration,
              },
              {
                "title": "RERA Carpet Area (SqFt)",
                "value":
                    widget.inventoryObject?[0]["reraCarpetAreaSqFt"]
                        .toString() ??
                    widget.bookingModel!.reraCarpetAreaSqFt.toString(),
              },
            ]),
            // AGREEMENT DETAILS
            Container(
              decoration: commonCardDecoration(),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Agreement Details", style: AppTextStyle.ts16SB()),
                  verticalSpacing(),
                  CustomTextField(
                    title: "Agreement Value (With TDS) (₹)",
                    hint: "Enter Agreement Value (with TDS)",
                    isRequired: true,
                    textController: _agreementValueWithTdsC,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatterList: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,16}(\.\d{0,2})?'),
                      ),
                    ],
                    onChangeFunction: (value) {
                      final parsed = double.tryParse(value) ?? 0.0;
                      _agreementValueNotifier.value = parsed;
                      _bookingCubit.onUpdateBookingAmount(
                        agreementValue: _agreementValueNotifier.value,
                        agreementValueGST: _agreementGstAmountNotifier.value,
                        agreementValueTds: _tdsNotifier.value,
                      );
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Agreement Value (with TDS) is required";
                      }
                      return null;
                    },
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _tdsNotifier,
                    builder: (_, tds, __) {
                      return CustomTextField(
                        readOnly: true,
                        title: "TDS (₹)",
                        hint: "TDS",
                        textController: _tdsC,
                      );
                    },
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _withoutTdsNotifier,
                    builder: (_, value, __) {
                      return CustomTextField(
                        readOnly: true,
                        title: "Agreement Value (Without TDS) (₹)",
                        hint: "Agreement Value (without TDS)",
                        textController: _agreementValueWithoutTdsC,
                      );
                    },
                  ),
                ],
              ),
            ),
            // TAX DETAILS
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tax Details", style: AppTextStyle.ts16SB()),
                  Column(
                    children: [
                      CustomTextField(
                        isRequired: true,
                        title: "Agreement GST (%)",
                        hint: "Enter Agreement GST Percentage",
                        textController: _agreementGstPercentageC,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatterList: InputValidator.percentage(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Agreement GST Percentage is required";
                          }
                          return null;
                        },
                        onChangeFunction: (value) {
                          _calculateGst();
                          _bookingCubit.onUpdateBookingAmount(
                            agreementValue: _agreementValueNotifier.value,
                            agreementValueGST:
                                _agreementGstAmountNotifier.value,
                            agreementValueTds: _tdsNotifier.value,
                          );
                        },
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: _agreementGstAmountNotifier,
                        builder: (_, value, __) {
                          return CustomTextField(
                            readOnly: true,
                            title: "Agreement GST Amount (₹)",
                            hint: "Agreement GST Amount",
                            textController: _agreementGstAmountC,
                          );
                        },
                      ),
                      CustomTextField(
                        isRequired: true,
                        title: "Stamp Duty (%)",
                        hint: "Enter Stamp Duty Percentage",
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatterList: InputValidator.percentage(),
                        textController: _stampDutyPercentageC,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Stamp Duty Percentage is required";
                          }
                          return null;
                        },
                        onChangeFunction: (value) {
                          _calculateStampDuty();
                        },
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: _stampDutyAmountNotifier,
                        builder: (_, value, __) {
                          return CustomTextField(
                            readOnly: true,
                            title: "Stamp Duty Amount (₹)",
                            hint: "Stamp Duty Amount",
                            textController: _stampDutyAmountC,
                          );
                        },
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: _registrationFeesNotifier,
                        builder: (_, value, __) {
                          return CustomTextField(
                            readOnly: true,
                            title: "Registration Fees (₹)",
                            hint: "Registration Fees",
                            textController: _registrationFeesC,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                final enquiry =
                    state.enquiryList.isNotEmpty
                        ? state.enquiryList.first
                        : null;

                if (enquiry == null) return const SizedBox();

                return Column(
                  children: [
                    if (enquiry.subSource == "Reference")
                      commissionSection(
                        title: "Referel Details",
                        percentageTitle: "Referel",
                        amountTitle: "Referel Amount",
                        percentController: _referencePercentageC,
                        amountController: _referenceAmountC,
                        agreementNotifier: _agreementValueNotifier,
                      ),

                    if (enquiry.subSource == "Employee Reference")
                      commissionSection(
                        title: "Employee Reference Details",
                        percentageTitle: "Employee Reference",
                        amountTitle: "Employee Reference Amount",
                        percentController: _employeeRefPercentageC,
                        amountController: _employeeRefAmountC,
                        agreementNotifier: _agreementValueNotifier,
                      ),

                    if (enquiry.subSource == "Loyalty")
                      commissionSection(
                        title: "Loyalty Details",
                        percentageTitle: "Loyalty",
                        amountTitle: "Loyalty Amount",
                        percentController: _loyaltyPercentageC,
                        amountController: _loyaltyAmountC,
                        agreementNotifier: _agreementValueNotifier,
                      ),

                    if (enquiry.source == "Channel Partner")
                      commissionSection(
                        title: "Brokerage Details",
                        percentageTitle: "Channel Partner Brokerage",
                        amountTitle: "Brokerage Amount",
                        percentController: _brokeragePercentageC,
                        amountController: _brokerageAmountC,
                        agreementNotifier: _agreementValueNotifier,
                      ),
                  ],
                );
              },
            ),

            // PARKING SECTION
            (!_isEditMode || widget.bookingModel!.parkingData.isEmpty)
                ? SizedBox.shrink()
                : Container(
                  height: 350,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Parking Details", style: AppTextStyle.ts16SB()),
                      verticalSpacing(),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 10,
                          ),
                          shrinkWrap: true,
                          itemCount: widget.bookingModel!.parkingData.length,
                          itemBuilder: (_, index) {
                            final parking =
                                widget.bookingModel!.parkingData[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.primary,
                                  width: .3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                spacing: 10,
                                children: [
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Parking Number",
                                        value: parking.parkingNumber,
                                      ),
                                      buildColumnTitleValue(
                                        title: "Building",
                                        value: parking.buildingNumber,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Wing",
                                        value: parking.wing,
                                      ),
                                      buildColumnTitleValue(
                                        title: "Floor",
                                        value: parking.floor,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Category",
                                        value: parking.parkingCategory,
                                      ),
                                      buildColumnTitleValue(
                                        title: "Type",
                                        value: parking.parkingType,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "EV Charging",
                                        value:
                                            parking.isEVChargingAvailable
                                                ? "Yes"
                                                : "No",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            // OTHER DETAILS
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Other Details", style: AppTextStyle.ts16SB()),
                  verticalSpacing(),
                  BlocBuilder<BookingCubit, BookingState>(
                    bloc: _bookingCubit,
                    builder: (context, state) {
                      return ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: _selectedParkingNotifier,
                        builder: (context, selectedBuilding, child) {
                          return CustomMultipleSelectPopup(
                            title: "Parking",
                            hintText: "Select Parking",
                            isMultiSelect: true,
                            initialValue: selectedBuilding,
                            dataList: const [],
                            onSelected: (value) async {
                              _selectedParkingNotifier.value = value;
                              if (value.isNotEmpty &&
                                  value.first['zAttributesId'] != null &&
                                  mounted) {
                                final newBuildingId =
                                    value.first['zAttributesId'] as int;
                                if (_lastFetchedBuildingId != newBuildingId) {
                                  _lastFetchedBuildingId = newBuildingId;
                                  await _bookingCubit.getParkingList(
                                    context,
                                    1,
                                    _project.projectId,
                                    displayParkingId:
                                        _isEditMode
                                            ? widget.bookingModel!.parkingId
                                            : null,
                                  );
                                }
                              } else if (mounted) {
                                _lastFetchedBuildingId = null;
                              }
                            },
                            dataFetchCallBack: _fetchParking,
                          );
                        },
                      );
                    },
                  ),
                  CustomTextField(
                    title: "Number Of Parking",
                    textController: _noOfParkingC,
                    keyboardType: TextInputType.number,
                    hint: "Enter Number Of Parking",
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedHandOverType,
                    builder: (context, selectedHandOverType, child) {
                      return CustomDropDownWidget(
                        title: "Handover Type",
                        isRequired: true,
                        initialValue: selectedHandOverType,
                        dataList: handOverTypeList,
                        onSelected: (value) {
                          _selectedHandOverType.value = value;
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value["zAttributesId"] == -1) {
                            return "Handover Type is required";
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedExpectedRegistrationDate,
                    builder: (
                      context,
                      selectedExpectedRegistrationDate,
                      child,
                    ) {
                      return CustomDatePicker(
                        title: "Expected Registration Date",
                        isRequired: true,
                        initialDate: selectedExpectedRegistrationDate,
                        setValue: (value) {
                          _selectedExpectedRegistrationDate.value = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Expected Registration Date is required";
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedFundingSource,
                    builder: (context, selectedFundingSource, child) {
                      return CustomDropDownWidget(
                        title: "Source Of Funding",
                        isRequired: true,
                        initialValue: selectedFundingSource,
                        dataList: fundingSourceList,
                        onSelected: (value) {
                          _selectedFundingSource.value = value;
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value["zAttributesId"] == -1) {
                            return "Funding Source is required";
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD PAYMENT SCHEDULE
  Widget _buildPaymentSchedule() {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final list = state.bookingPaymentScheduleList;
        return Form(
          key: _paymentScheduleFormKey,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(height: 20),
                _buildAgreementCard(),
                verticalSpacing(),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: schemeListNotifier,
                  builder: (context, schemeList, _) {
                    return ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: selectedScheme,
                      builder: (context, selectedValue, __) {
                        return CustomDropDownWidget(
                          title: "Payment Schedule Scheme",
                          isRequired: true,
                          dataList: schemeList,
                          initialValue:
                              selectedValue.isEmpty ? null : selectedValue,
                          onSelected: (value) async {
                            if (selectedScheme.value["zAttributesId"] !=
                                value["zAttributesId"]) {
                              selectedScheme.value = value;

                              if (selectedScheme.value["DisplayName"] !=
                                  'Other') {
                                isAutoPaymentSchedule = await _bookingCubit
                                    .getPaymentScheduleMasterList(
                                      context,
                                      1,
                                      paymentScheduleSchemeMasterId:
                                          selectedScheme.value["zAttributesId"],
                                      inventoryBuildingId:
                                          selectedScheme
                                              .value["inventoryBuildingId"],
                                      inventoryFlatFloorBasementPodiumWingId:
                                          selectedScheme
                                              .value["inventoryFlatFloorBasementPodiumWingId"],
                                      agreementValue:
                                          _agreementValueNotifier.value,
                                      agreementValueGST:
                                          _agreementGstAmountNotifier.value,
                                      agreementValueTds: _tdsNotifier.value,
                                    );
                              } else {
                                _bookingCubit.clearPaymentScheduleList();
                              }
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                value["zAttributesId"] == null) {
                              return "Payment Schedule Scheme is required";
                            }
                            return null;
                          },
                        );
                      },
                    );
                  },
                ),

                /// Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Schedule",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),

                    ValueListenableBuilder(
                      valueListenable: selectedScheme,
                      builder: (context, value, child) {
                        if (_bookingCubit.totalCumulativePercentage == 100) {
                          return RichText(
                            text: TextSpan(
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                              children: [
                                TextSpan(
                                  text: "Total: ",
                                  style: AppTextStyle.ts14M(),
                                ),
                                TextSpan(
                                  text:
                                      "${_bookingCubit.totalCumulativePercentage.toStringAsFixed(2)}%",
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Visibility(
                          visible:
                              (value['DisplayName'] == 'Other' &&
                                  _bookingCubit.totalCumulativePercentage !=
                                      100 &&
                                  _agreementValueNotifier.value > 0),
                          child: CustomButton(
                            leading: const Icon(Icons.add, size: 16),
                            text: "Add",
                            onPressed: _openPaymentScheduleForm,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: selectedScheme,
                  builder: (context, value, child) {
                    // HIDE WHEN SCHEME IS NOT SELECTED
                    if (selectedScheme.value.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // HIDE WHEN CUMULATIVE IS 100
                    if (_bookingCubit.totalCumulativePercentage >= 100) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        verticalSpacing(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: AppTextStyle.ts12M(color: AppColor.grey),
                                children: [
                                  const TextSpan(text: "Total: "),
                                  TextSpan(
                                    text:
                                        "${_bookingCubit.totalCumulativePercentage.toStringAsFixed(2)}%",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: AppTextStyle.ts12M(color: AppColor.grey),
                                children: [
                                  const TextSpan(text: "Missing: "),
                                  TextSpan(
                                    text:
                                        "${_bookingCubit.remainingPercentage.toStringAsFixed(2)}%",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                verticalSpacing(height: 15),

                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.isLoading! && list.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (list.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Payment Schedule Available",
                          ),
                        );
                      }

                      return ReorderableListView.builder(
                        itemCount: list.length,
                        onReorder: (oldIndex, newIndex) {
                          _bookingCubit.reorderPaymentSchedule(
                            oldIndex,
                            newIndex,
                          );
                        },
                        buildDefaultDragHandles: false,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          String stageName =
                              (item.date != null)
                                  ? formatDateTimeAsDDMMMYYYY(item.date!)
                                  : item.name;
                          return Row(
                            key: ValueKey(stageName + index.toString()),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: CircleAvatar(
                                  maxRadius: 15,
                                  backgroundColor: AppColor.lightBlue,
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: AppColor.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                              horizontalSpacing(),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: commonCardDecoration(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildColumnTitleValue(
                                            title: "Stage Name",
                                            value: stageName,
                                          ),
                                          if (!isAutoPaymentSchedule)
                                            Row(
                                              spacing: 10,
                                              children: [
                                                CustomIconButton.edit(
                                                  onPressed: () {
                                                    _openPaymentScheduleForm(
                                                      index: index,
                                                    );
                                                  },
                                                ),
                                                CustomIconButton.delete(
                                                  onPressed: () {
                                                    _showPopupToDeletePaymentSchedule(
                                                      context,
                                                      index,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      verticalSpacing(),

                                      Row(
                                        children: [
                                          buildColumnTitleValue(
                                            title: "Ranking",
                                            value: item.ranking.toString(),
                                          ),
                                          buildColumnTitleValue(
                                            title: "Cumulative (%)",
                                            value:
                                                "${item.paymentCummulativePercentage}",
                                          ),
                                        ],
                                      ),

                                      verticalSpacing(),

                                      Row(
                                        children: [
                                          buildColumnTitleValue(
                                            title: "Percentage (%)",
                                            value:
                                                "${item.paymentSchedulePercentage}",
                                          ),
                                          buildColumnTitleValue(
                                            title: "Amount (₹)",
                                            value: addCommasToInteger(
                                              item.paymentScheduleAmount,
                                            ),
                                          ),
                                        ],
                                      ),
                                      verticalSpacing(),
                                      Row(
                                        children: [
                                          buildColumnTitleValue(
                                            title: "GST Amount (₹)",
                                            value: addCommasToInteger(
                                              item.paymentScheduleGSTAmount,
                                            ),
                                          ),
                                          buildColumnTitleValue(
                                            title: "TDS Amount (₹)",
                                            value: addCommasToInteger(
                                              item.paymentScheduleTDSAmount,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // BUILD EXTRA CHARGES
  Widget _buildOtherCharges() {
    return Form(
      key: _otherChargesFormKey,
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state.otherChargesList.isEmpty ||
              _agreementValueNotifier.value == 0) {
            return Center(child: noDataWidget(message: "No Charges Available"));
          }
          return Column(
            children: [
              verticalSpacing(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _buildAgreementCard(),
              ),
              verticalSpacing(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shrinkWrap: true,
                  itemCount: state.otherChargesList.length,
                  itemBuilder: (_, index) {
                    final oc = state.otherChargesList[index];

                    return Container(
                      decoration: commonCardDecoration(),
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Text(oc.chargeName, style: AppTextStyle.ts14M()),
                          Row(
                            children: [
                              buildColumnTitleValue(
                                title: "Calculated On",
                                value: oc.calculatedOn,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              buildColumnTitleValue(
                                title: "Amount (₹)",
                                value: addCommasToInteger(oc.value),
                              ),
                              buildColumnTitleValue(
                                title: "GST(%)",
                                value: "${oc.gstPercentage} %",
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              buildColumnTitleValue(
                                title: "GST Value (₹)",
                                value: addCommasToInteger(oc.gstValue),
                              ),
                              buildColumnTitleValue(
                                title: "Total Value (₹)",
                                value: addCommasToInteger(
                                  oc.value + oc.gstValue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // PAYMENTS DETAILS
  Widget _buildPaymentDetails() {
    return Form(
      key: _paymentDetailsFormKey,
      child: Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Payment Details",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      title: "Booking Amount (₹)",
                      hint: "Enter Booking Amount",
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textController: _bookingAmountC,
                    ),
                    CustomTextField(
                      title: "Cheque/ RTGS No.",
                      hint: "Enter Cheque/ RTGS No.",
                      textController: _chequeNoC,
                    ),
                    CustomDatePicker(
                      title: "Cheque/ RTGS Date",
                      initialDate: _selectedChequeDate,
                      setValue: (value) {
                        _selectedChequeDate = value;
                      },
                    ),
                    // BANK MULTI SELECT
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedBankNotifier,
                      builder: (context, selectedBanks, child) {
                        return CustomMultipleSelectPopup(
                          title: "Bank",
                          isMultiSelect: false,
                          initialValue: selectedBanks,
                          dataList: const [],
                          onSelected: (value) {
                            _selectedBankNotifier.value =
                                value
                                    .map((e) => Map<String, dynamic>.from(e))
                                    .toList();
                          },
                          dataFetchCallBack: _fetchBanks,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BUILD TERMS AND CONDITION
  Widget _buildTermsAndCondition() {
    return Form(
      key: _termsFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpacing(),
            BlocBuilder<BookingCubit, BookingState>(
              bloc: _bookingCubit,
              builder: (context, state) {
                return ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: _selectedTermsNotifier,
                  builder: (context, selectedTerms, child) {
                    return CustomMultipleSelectPopup(
                      title: "Terms & Conditions",
                      isRequired: false,
                      isMultiSelect: false,
                      initialValue: selectedTerms,
                      dataList: const [],
                      onSelected: (value) {
                        final copied =
                            value
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList();
                        _selectedTermsNotifier.value = copied;
                        if (copied.isNotEmpty) {
                          _termsAndConditionDescriptionC.text = copied
                              .map((e) => e['Description'] ?? '')
                              .join('\n\n');
                        } else {
                          _termsAndConditionDescriptionC.clear();
                        }
                      },
                      dataFetchCallBack: _fetchTerms,
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedTermsNotifier,
              builder: (context, selectedTerms, child) {
                if (selectedTerms.isEmpty) return SizedBox.shrink();
                return Column(
                  children:
                      selectedTerms.map((term) {
                        final title = term['DisplayName']?.toString() ?? '';
                        final desc = term['Description']?.toString() ?? '';
                        if (desc.isEmpty && title.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 8),
                          decoration: commonCardDecoration(),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [if (desc.isNotEmpty) Html(data: desc)],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // BUILD REMARK
  Widget _buildRemark() {
    return Form(
      key: _remarkFormKey,
      child: Container(
        margin: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Remark",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      title: "Unit / Modulation / Customization Remark",
                      hint: "Enter Unit / Modulation / Customization Remark",
                      minLines: 3,
                      maxLines: 3,
                      textController: _unitModCustomizationRemarkC,
                    ),
                    CustomTextField(
                      title: "Payment Related Remark",
                      hint: "Enter Payment Related Remark",
                      minLines: 3,
                      maxLines: 3,
                      textController: _paymentRemarkC,
                    ),
                    CustomTextField(
                      title: "Other Remark",
                      hint: "Enter Other Remark",
                      minLines: 3,
                      maxLines: 3,
                      textController: _otherRemarkC,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BUILD APPLICANT CARD
  Widget _buildApplicantCard(BookingApplicantData applicant, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.primary, width: .3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.applicantName,
                      style: AppTextStyle.ts14M(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      applicant.applicantType,
                      style: AppTextStyle.ts12M(color: AppColor.grey),
                    ),
                  ],
                ),
              ),
              horizontalSpacing(width: 5),
              Row(
                children: [
                  CustomIconButton.edit(
                    onPressed:
                        () => _openApplicantForm(
                          applicant: applicant,
                          index: index,
                        ),
                  ),
                  horizontalSpacing(width: 8),
                  CustomIconButton.delete(
                    onPressed: () => _deleteApplicant(index),
                  ),
                ],
              ),
            ],
          ),

          verticalSpacing(),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Contact Number",
                value:
                    applicant.applicantMobileNumber.isEmpty
                        ? "-"
                        : applicant.applicantMobileNumber,
              ),
              buildColumnTitleValue(
                title: "Email ID",
                value:
                    applicant.applicantEmailId.isEmpty
                        ? "-"
                        : applicant.applicantEmailId,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Aadhaar Card No.",
                value:
                    applicant.aadharCardNumber.isEmpty
                        ? "-"
                        : applicant.aadharCardNumber,
              ),
              buildColumnTitleValue(
                title: "Aadhaar Card",
                value:
                    applicant.aadharCardURL.isEmpty
                        ? "-"
                        : applicant.aadharCardURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.aadharCardURL.isNotEmpty) {
                      showFilePreviewDialog(
                        context,
                        applicant.aadharCardURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.aadharCardURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "PAN Card No.",
                value: applicant.panNumber.isEmpty ? "-" : applicant.panNumber,
              ),
              buildColumnTitleValue(
                title: "PAN Card",
                value:
                    applicant.panCardURL.isEmpty ? "-" : applicant.panCardURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.panCardURL.isNotEmpty) {
                      showFilePreviewDialog(
                        context,
                        applicant.panCardURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.panCardURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Driving License",
                value:
                    applicant.drivingLicenseNumber.isEmpty
                        ? "-"
                        : applicant.drivingLicenseNumber,
              ),
              buildColumnTitleValue(
                title: "Driving License",
                value:
                    applicant.drivingLicenseURL.isEmpty
                        ? "-"
                        : applicant.drivingLicenseURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.drivingLicenseURL.isNotEmpty) {
                      showFilePreviewDialog(
                        context,
                        applicant.drivingLicenseURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.drivingLicenseURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Voting ID No.",
                value:
                    applicant.votingIdNumber.isEmpty
                        ? "-"
                        : applicant.votingIdNumber,
              ),
              buildColumnTitleValue(
                title: "Voting ID",
                value:
                    applicant.votingIdURL.isEmpty ? "-" : applicant.votingIdURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.votingIdURL.isNotEmpty) {
                      showFilePreviewDialog(
                        context,
                        applicant.votingIdURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.votingIdURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Passport No.",
                value:
                    applicant.passportNumber.isEmpty
                        ? "-"
                        : applicant.passportNumber,
              ),
              buildColumnTitleValue(
                title: "Passport",
                value:
                    applicant.passportURL.isEmpty ? "-" : applicant.passportURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.passportURL.isNotEmpty) {
                      showFilePreviewDialog(
                        context,
                        applicant.passportURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.passportURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "GST No.",
                value: applicant.gstNumber.isEmpty ? "-" : applicant.gstNumber,
              ),
              buildColumnTitleValue(
                title: "GST",
                value:
                    applicant.gstNumberURL.isEmpty
                        ? "-"
                        : applicant.gstNumberURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.gstNumberURL.isNotEmpty) {
                      showFilePreviewDialog(
                        context,
                        applicant.gstNumberURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.gstNumberURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Profile Photo",
                value: applicant.photoURL.isEmpty ? "-" : applicant.photoURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.photoURL.isNotEmpty) {
                      showFilePreviewDialog(
                        context,
                        applicant.photoURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.photoURL.isEmpty,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  // INFO HELPER CARD
  Widget infoCard(List<Map<String, dynamic>> items, {String? title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.lightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.primary, width: .5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: AppTextStyle.ts16SB()),
            verticalSpacing(),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate((items.length / 2).ceil(), (index) {
              final first = items[index * 2];
              final second =
                  (index * 2 + 1 < items.length) ? items[index * 2 + 1] : null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: first["title"] ?? "",
                      value:
                          first["widget"] != null ? "" : first["value"] ?? "",
                      customValueWidget: first["widget"],
                    ),
                    const SizedBox(width: 20),

                    second != null
                        ? buildColumnTitleValue(
                          title: second["title"] ?? "",
                          value:
                              second["widget"] != null
                                  ? ""
                                  : second["value"] ?? "",
                          customValueWidget: second["widget"],
                        )
                        : const SizedBox(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // COMMISSION SECTION FOR ENQUIRY WHICH HAD SOURCE: CHANNEL PARTNER (BROKERAGE) OR SUBSOURCE: REFERENCE, EMPLOYEE REFERENCE, LOYALTY
  Widget commissionSection({
    required String title,
    required String percentageTitle,
    required String amountTitle,
    required TextEditingController percentController,
    required TextEditingController amountController,
    required ValueNotifier<double> agreementNotifier,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: agreementNotifier,
      builder: (context, agreementAmount, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          calculateCommissionAmount(
            percentController: percentController,
            amountController: amountController,
            agreementAmount: agreementAmount,
          );
        });

        return Container(
          decoration: commonCardDecoration(),
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.ts16SB()),
              verticalSpacing(),

              CustomTextField(
                title: "$percentageTitle (%)",
                hint: "Enter Percentage",
                isRequired: true,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatterList: InputValidator.percentage(),
                textController: percentController,
                onChangeFunction: (value) {
                  calculateCommissionAmount(
                    percentController: percentController,
                    amountController: amountController,
                    agreementAmount: agreementAmount,
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Percentage';
                  }
                  return null;
                },
              ),

              CustomTextField(
                readOnly: true,
                isRequired: true,
                title: "$amountTitle (₹)",
                hint: "$title Amount",
                textController: amountController,
              ),
            ],
          ),
        );
      },
    );
  }

  // AGGREMENT CARD
  Widget _buildAgreementCard() {
    return infoCard(title: "Agreement Details", [
      {
        "title": "Agreement Value (With TDS) (₹)",
        "value": _agreementValueWithTdsC.text.trim(),
      },
      {
        "title": "Agreement GST Amount (₹)",
        "value": _agreementGstAmountC.text.trim(),
      },
      {"title": "TDS Amount(₹)", "value": _tdsC.text.trim()},
    ]);
  }
}
