import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/add_booking_applicant_screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/model/other_charges.model.dart';

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
  late BookingCubit _bookingCubit;

  // TAB CONTROLLER
  late TabController _tabController;

  final Set<int> _invalidRankingIndexes = {};

  late List<TextEditingController> _rankingControllers = [];

  // TEXT EDITING CONTROLLER
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
      _remarkC,
      _termsAndConditionDescriptionC,
      _bookingAmountC,
      _chequeNoC;

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
  DateTime? _selectedExpectedRegistrationDate;
  // subscription to booking cubit stream
  StreamSubscription<BookingState>? _bookingSubscription;
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
  late Map<String, dynamic> _selectedHandOverType;

  // STATIC HAND OVER TYPE LIST
  final List<Map<String, dynamic>> fundingSourceList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Funding Source'},
    {'zAttributesId': 1, 'DisplayName': 'Loan'},
    {'zAttributesId': 2, 'DisplayName': 'Self-funded'},
    {'zAttributesId': 3, 'DisplayName': 'Sale Of Property Funding'},
  ];

  // SELECTED SOURCE OF FUNDING
  late Map<String, dynamic> _selectedFundingSource;

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

  // LOCAL COPY OF OTHER CHARGES (editable by UI, not tied to cubit)
  final ValueNotifier<List<OtherChargeModel>> _localOtherCharges =
      ValueNotifier<List<OtherChargeModel>>([]);

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

  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
    _bookingCubit = context.read<BookingCubit>();
    _project = getProject();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
    _selectedHandOverType = handOverTypeList.first;
    _selectedFundingSource = fundingSourceList.first;
    _agreementValueNotifier.addListener(_calculateTds);

    // PULL PAYMENT SCHEDULE MASTER
    _bookingCubit.getPaymentScheduleMasterList(
      context,
      1,
      _project.projectId,
      widget.inventoryObject?[0]["wing"] ?? widget.bookingModel!.wing,
    );
    // OTHER CHARGES
    _bookingCubit.getOtherChargesList(context, 1, _project.projectId);

    if (_isEditMode) {
      final bm = widget.bookingModel!;
      _prefill(bm);

      // subscribe to cubit to listen for enquiryListById results (to fill enquiry unique code)
      _bookingSubscription = _bookingCubit.stream.listen((state) {
        if (state.enquiryListById.isNotEmpty) {
          final enquiry = state.enquiryListById.first;
          _enquiryUniqueCodeC.text = enquiry.systemGeneratedCode;
        }
      });

      // Still fetch server-side details for consistency
      _bookingCubit.getBookingListById(
        context,
        1,
        _project.projectId,
        bm.bookingId,
      );

      // Fetch enquiry by id to get system generated code and populate enquiry field
      if (bm.enquiryId != 0) {
        _isFetchingEnquiry.value = true;
        _enquiryFetchTried.value = true;
        _bookingCubit
            .getEnquiryListById(context, 1, _project.projectId, bm.enquiryId)
            .whenComplete(() => _isFetchingEnquiry.value = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeTextControllers();
    _bookingCubit.clearEnquiryList();
    _agreementValueNotifier.dispose();
    _tdsNotifier.dispose();
    _withoutTdsNotifier.dispose();
    _agreementGstAmountNotifier.dispose();
    _stampDutyAmountNotifier.dispose();
    _registrationFeesNotifier.dispose();
    _localOtherCharges.dispose();
    _bookingSubscription?.cancel();
    _isFetchingEnquiry.dispose();
    for (final controller in _rankingControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
      _bookingCubit.onTabChangedAddForm(_tabController.index, context);
    }
  }

  // INITIALIZE TEXT CONTROLLERS
  void _initializeTextControllers() {
    _enquiryUniqueCodeC = TextEditingController();
    _permanentAddressC = TextEditingController();
    _communicationAddressC = TextEditingController();
    _agreementValueWithTdsC = TextEditingController();
    _tdsC = TextEditingController();
    _agreementValueWithoutTdsC = TextEditingController();
    _agreementGstPercentageC = TextEditingController();
    _agreementGstAmountC = TextEditingController();
    _stampDutyPercentageC = TextEditingController();
    _stampDutyAmountC = TextEditingController();
    _registrationFeesC = TextEditingController();
    _remarkC = TextEditingController();
    _termsAndConditionDescriptionC = TextEditingController();
    _bookingAmountC = TextEditingController();
    _chequeNoC = TextEditingController();
  }

  // Prefill form from booking model
  void _prefill(BookingModel bm) {
    // Addresses
    _permanentAddressC.text = bm.permanentAddress;
    _communicationAddressC.text = bm.communicationAddress;

    // Applicants
    _applicants.value = List<BookingApplicantData>.from(
      bm.bookingApplicantData,
    );

    // Agreement / financials
    _agreementValueWithTdsC.text = bm.agreementValue.toString();
    _agreementValueNotifier.value = bm.agreementValue;
    _tdsC.text = bm.agreementValueTDS.toString();
    _agreementGstPercentageC.text = bm.agreementValueGSTPercentage.toString();
    _agreementGstAmountC.text = bm.agreementValueGSTAmount.toString();
    _stampDutyPercentageC.text = bm.stampDutyPercentage.toString();
    _stampDutyAmountC.text = bm.stampDutyAmount.toString();
    _registrationFeesC.text = bm.registrationFees.toString();

    // Remark / terms description
    _remarkC.text = bm.flatAlterationRemark;
    _termsAndConditionDescriptionC.text = bm.termsAndConditionsDescription;

    // Other charges - initialize local editable copy
    _localOtherCharges.value = List<OtherChargeModel>.from(
      bm.bookingOtherChargesData,
    );

    // Parking - convert to select maps
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

    // Payment details
    _bookingAmountC.text = bm.bookingAmount.toString();
    _chequeNoC.text = bm.chequeRTGSNumber;
    _selectedChequeDate = bm.chequeRTGSDate;

    // Banks - set selected bank if present
    if (bm.bankListMasterId != 0) {
      _selectedBankNotifier.value = [
        {"zAttributesId": bm.bankListMasterId, "DisplayName": bm.bankName},
      ];
    }
  }

  // DISPOSE TEXT CONTROLLERS
  void _disposeTextControllers() {
    _enquiryUniqueCodeC.dispose();
    _permanentAddressC.dispose();
    _communicationAddressC.dispose();
    _agreementValueWithTdsC.dispose();
    _tdsC.dispose();
    _agreementValueWithoutTdsC.dispose();
    _agreementGstPercentageC.dispose();
    _agreementGstAmountC.dispose();
    _stampDutyPercentageC.dispose();
    _stampDutyAmountC.dispose();
    _registrationFeesC.dispose();
    _remarkC.dispose();
    _termsAndConditionDescriptionC.dispose();
    _bookingAmountC.dispose();
    _chequeNoC.dispose();
  }

  // CALCULATE TDS
  void _calculateTds() {
    final value = _agreementValueNotifier.value;

    const limit = 4999999.99;

    double tds = 0;
    double withoutTds = value;

    if (value > limit) {
      tds = value * 0.01;
      withoutTds = value - tds;
    }

    _tdsNotifier.value = tds;
    _withoutTdsNotifier.value = withoutTds;

    _tdsC.text = tds == 0 ? "" : tds.toStringAsFixed(2);
    _agreementValueWithoutTdsC.text =
        tds == 0 ? "" : withoutTds.toStringAsFixed(2);

    _calculateGst();
    _calculateStampDuty();
    _calculateRegistrationFees();
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

    const limit = 4999999.99;

    double fees;

    if (value <= limit) {
      //  1% if <= 49,99,999.99
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

  // VALIDATE ALL TABS
  Future<bool> _validateAllTabs() async {
    bool detailsValid = _detailsFormKey.currentState?.validate() ?? false;

    bool rankingValid =
        _paymentScheduleFormKey.currentState?.validate() ?? false;

    // Manual validation for Payment Details (NO TAB SWITCH)
    bool paymentDetailsValid = true;

    bool remarkValid = true;

    if (_bookingAmountC.text.trim().isEmpty) {
      paymentDetailsValid = false;
    }

    if (_chequeNoC.text.trim().isEmpty) {
      paymentDetailsValid = false;
    }

    if (_selectedChequeDate == null) {
      paymentDetailsValid = false;
    }

    // Trigger rebuild so CustomTextField shows errors
    if (!paymentDetailsValid) {
      _paymentDetailsFormKey.currentState?.validate();
    }

    if (_remarkC.text.trim().isEmpty) {
      remarkValid = false;
    }

    // Trigger rebuild so CustomTextField shows errors
    if (!remarkValid) {
      _remarkFormKey.currentState?.validate();
    }
    // Now decide where to go

    if (!detailsValid) {
      _tabController.animateTo(0);
      return false;
    }

    if (!rankingValid) {
      _tabController.animateTo(2);
      showErrorMessage(context, "", "Ranking cannot be 0");
      return false;
    }

    if (!remarkValid) {
      _tabController.animateTo(3);
      return false;
    }

    if (!paymentDetailsValid) {
      _tabController.animateTo(5);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Booking Form",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IntrinsicWidth(
              child: Container(
                height: 35,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColor.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColor.primary,
                  unselectedLabelColor: AppColor.grey,
                  indicator: BoxDecoration(
                    color: AppColor.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: AppTextStyle.ts14M(),
                  unselectedLabelStyle: AppTextStyle.ts14M(),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: 'Details'),
                    Tab(text: 'Other Charges'),
                    Tab(text: 'Payment Schedule'),
                    Tab(text: 'Remark'),
                    Tab(text: 'Terms & Condition'),
                    Tab(text: 'Payment Details'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tabController.index,
              children: [
                _buildDetails(),
                _buildOtherCharges(),
                _buildPaymentSchedule(),
                _buildRemark(),
                _buildTermsAndCondition(),
                _buildPaymentDetails(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(
            text: "Save",
            onPressed: () async {
              //Temporary Commented
              // _printAllBookingData();
              if (await _validateAllTabs()) {
                final formValues = {
                  "enquiryUniqueCode": _enquiryUniqueCodeC.text,
                  "permanentAddress": _permanentAddressC.text,
                  "communicationAddress": _communicationAddressC.text,
                  "agreementValueWithTds": _agreementValueWithTdsC.text,
                  "tds": _tdsC.text,
                  "agreementValueWithoutTds": _agreementValueWithoutTdsC.text,
                  "agreementGstPercentage": _agreementGstPercentageC.text,
                  "agreementGstAmount": _agreementGstAmountC.text,
                  "stampDutyPercentage": _stampDutyPercentageC.text,
                  "stampDutyAmount": _stampDutyAmountC.text,
                  "registrationFees": _registrationFeesC.text,
                  "remark": _remarkC.text,
                  "selectedParking": _selectedParkingNotifier.value,
                  "selectedTerms": _selectedTermsNotifier.value,
                  "otherChargesLocal":
                      _localOtherCharges.value.map((e) => e.toJson()).toList(),
                  "selectedBanks": _selectedBankNotifier.value,
                  "bookingAmount": _bookingAmountC.text,
                  "chequeNo": _chequeNoC.text,
                  "chequeDate": _selectedChequeDate?.toIso8601String(),
                };
                print("AddBooking form values: $formValues");
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
                    listener: (context, state) {
                      final hasEnquiry =
                          state.enquiryList.isNotEmpty ||
                          state.enquiryListById.isNotEmpty;
                      if (hasEnquiry) {
                        final enquiry =
                            state.enquiryList.isNotEmpty
                                ? state.enquiryList.first
                                : state.enquiryListById.first;
                        _permanentAddressC.text = enquiry.currentLocation;
                        _communicationAddressC.text = enquiry.currentLocation;
                      }
                    },
                    builder: (context, state) {
                      final enquiry =
                          state.enquiryList.isNotEmpty
                              ? state.enquiryList.first
                              : (state.enquiryListById.isNotEmpty
                                  ? state.enquiryListById.first
                                  : null);
                      return Column(
                        children: [
                          CustomTextField(
                            title: "Enquiry Unique Code",
                            isRequired: true,
                            inputFormatterList: [
                              LengthLimitingTextInputFormatter(8),
                            ],
                            hint: "Enter Enquiry Unique Code",
                            textController: _enquiryUniqueCodeC,
                            onChangeFunction: (value) {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }

                              if (value.length != 8) {
                                // Clear any previous enquiry results and fetch flags
                                _bookingCubit.clearEnquiryList();
                                _permanentAddressC.clear();
                                _communicationAddressC.clear();
                                _enquiryFetchTried.value = false;
                                _isFetchingEnquiry.value = false;
                                return;
                              }

                              _debounce = Timer(
                                const Duration(milliseconds: 500),
                                () async {
                                  if (value.length == 8) {
                                    _isFetchingEnquiry.value = true;
                                    _enquiryFetchTried.value = true;
                                    await _bookingCubit.getEnquiryList(
                                      context,
                                      1,
                                      _project.projectId,
                                      value,
                                    );
                                    _isFetchingEnquiry.value = false;
                                  }
                                },
                              );
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Enquiry Unique Code';
                              }
                              return null;
                            },
                          ),
                          if (enquiry != null) ...[
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
                              child: Column(
                                spacing: 10,
                                children: [
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: 'Enquiry Code',
                                        value: enquiry.systemGeneratedCode,
                                      ),
                                      buildColumnTitleValue(
                                        title: 'Name',
                                        value: enquiry.name,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: 'Mobile No',
                                        value: enquiry.mobileNumber,
                                      ),
                                      buildColumnTitleValue(
                                        title: 'Source',
                                        value: enquiry.source,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: 'Sub Source',
                                        value: enquiry.subSource,
                                      ),
                                      buildColumnTitleValue(
                                        title: 'Sales Advisor',
                                        value: enquiry.salesAdvisor,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: 'Sub Source',
                                        value: enquiry.subSource,
                                      ),
                                      buildColumnTitleValue(
                                        title: 'Sales Advisor',
                                        value: enquiry.salesAdvisor,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: 'Sourcing Manager',
                                        value: enquiry.sourcingManager,
                                      ),
                                      buildColumnTitleValue(
                                        title: 'Current Location',
                                        value: enquiry.currentLocation,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                "Invalid Enquiry Unique Code",
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
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              applicants
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => SizedBox(
                                      width: 320,
                                      child: _buildApplicantCard(
                                        entry.value,
                                        entry.key,
                                      ),
                                    ),
                                  )
                                  .toList(),
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
            Container(
              decoration: BoxDecoration(
                color: AppColor.lightBlue.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.primary, width: .3),
              ),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Project Details", style: AppTextStyle.ts16SB()),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Building Number",
                        value:
                            widget.inventoryObject?[0]["buildingNumber"] ??
                            widget.bookingModel!.buildingNumber,
                      ),
                      buildColumnTitleValue(
                        title: "Wing",
                        value:
                            widget.inventoryObject?[0]["wing"] ??
                            widget.bookingModel!.wing,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Floor",
                        value:
                            widget.inventoryObject?[0]["floor"] ??
                            widget.bookingModel!.floor,
                      ),
                      buildColumnTitleValue(
                        title: "Flat",
                        value:
                            widget.inventoryObject?[0]["flat"] ??
                            widget.bookingModel!.flat,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Flat Type",
                        value:
                            widget.inventoryObject?[0]["flatType"] ??
                            widget.bookingModel!.flatType,
                      ),
                      buildColumnTitleValue(
                        title: "Flat Configuration",
                        value:
                            widget.inventoryObject?[0]["flatConfiguration"] ??
                            widget.bookingModel!.flatConfiguration,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "RERA Carpet Area (SqFt)",
                        value:
                            widget.inventoryObject?[0]["reraCarpetAreaSqFt"]
                                .toString() ??
                            widget.bookingModel!.reraCarpetAreaSqFt.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // PARKING SECTION
            !_isEditMode
                ? SizedBox()
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
                        child:
                            widget.bookingModel!.parkingData.isNotEmpty
                                ? ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 10,
                                  ),
                                  shrinkWrap: true,
                                  itemCount:
                                      widget.bookingModel!.parkingData.length,
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
                                )
                                : Center(child: Text("No Parking")),
                      ),
                    ],
                  ),
                ),
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
                    keyboardType: TextInputType.number,
                    onChangeFunction: (value) {
                      final parsed = double.tryParse(value) ?? 0.0;
                      _agreementValueNotifier.value = parsed;
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Agreement GST Percentage is required";
                          }
                          return null;
                        },
                        onChangeFunction: (value) {
                          _calculateGst();
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
                            isRequired: true,
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
                                  );
                                }
                              } else if (mounted) {
                                _lastFetchedBuildingId = null;
                              }
                            },
                            dataFetchCallBack: _fetchParking,
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return "Parking is required";
                            //   }
                            //   return null;
                            // },
                          );
                        },
                      );
                    },
                  ),
                  CustomDropDownWidget(
                    title: "Handover Type",
                    isRequired: true,
                    dataList: handOverTypeList,
                    onSelected: (value) {
                      _selectedHandOverType = value;
                    },
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value["zAttributesId"] == -1) {
                        return "Handover Type is required";
                      }
                      return null;
                    },
                  ),
                  CustomDatePicker(
                    title: "Expected Registration Date",
                    isRequired: true,
                    initialDate: _selectedExpectedRegistrationDate,
                    setValue: (value) {
                      _selectedExpectedRegistrationDate = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Expected Registration Date is required";
                      }
                      return null;
                    },
                  ),
                  CustomDropDownWidget(
                    title: "Source Of Funding",
                    isRequired: true,
                    dataList: fundingSourceList,
                    onSelected: (value) {
                      _selectedFundingSource = value;
                    },
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value["zAttributesId"] == -1) {
                        return "Funding Source is required";
                      }
                      return null;
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

  // BUILD EXTRA CHARGES
  Widget _buildOtherCharges() {
    return Form(
      key: _otherChargesFormKey,
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          // Initialize local copy only once when cubit returns data
          if (state.otherChargesList.isNotEmpty &&
              _localOtherCharges.value.isEmpty) {
            _localOtherCharges.value =
                state.otherChargesList.map((e) => e).toList();
          }

          if (_localOtherCharges.value.isEmpty) {
            return Center(child: Text("No Charges Available"));
          }

          return ValueListenableBuilder<List<OtherChargeModel>>(
            valueListenable: _localOtherCharges,
            builder: (context, localList, child) {
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shrinkWrap: true,
                itemCount: localList.length,
                itemBuilder: (_, index) {
                  final oc = localList[index];
                  return Container(
                    decoration: commonCardDecoration(),
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      spacing: 10,
                      children: [
                        Row(
                          children: [
                            Text(oc.chargeName, style: AppTextStyle.ts14M()),
                            Spacer(),
                            CustomIconButton.delete(
                              onPressed: () {
                                final updated = List<OtherChargeModel>.from(
                                  localList,
                                )..removeAt(index);
                                _localOtherCharges.value = updated;
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            buildColumnTitleValue(
                              title: "Calculated On",
                              value: oc.calculatedOn,
                            ),
                            buildColumnTitleValue(
                              title: "Amount",
                              value: "₹ ${oc.value}",
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            buildColumnTitleValue(
                              title: "GST(%)",
                              value: "${oc.gstPercentage} %",
                            ),
                            buildColumnTitleValue(
                              title: "GST Value",
                              value: "₹ ${oc.gstValue}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // BUILD PAYMENT SCHEDULE
  Widget _buildPaymentSchedule() {
    return Form(
      key: _paymentScheduleFormKey,
      child: Container(
        padding: EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Payment Schedule",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  Spacer(),
                  CustomIconButton(
                    icon: Icon(Icons.add, size: 16, color: AppColor.darkGreen),
                    onPressed: () {},
                    backgroundColor: AppColor.lightGreen,
                  ),
                ],
              ),
              verticalSpacing(),
              Expanded(
                child: BlocBuilder<BookingCubit, BookingState>(
                  buildWhen: (prev, curr) => true,
                  builder: (context, state) {
                    if (state.isLoading == true &&
                        state.paymentScheduleMasterList.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (state.paymentScheduleMasterList.isEmpty) {
                      return Center(
                        child: Text("No Payment Schedule Available"),
                      );
                    }

                    if (_rankingControllers.length !=
                        state.paymentScheduleMasterList.length) {
                      _rankingControllers = List.generate(
                        state.paymentScheduleMasterList.length,
                        (index) => TextEditingController(
                          text:
                              state.paymentScheduleMasterList[index].ranking ==
                                      0
                                  ? ""
                                  : state
                                      .paymentScheduleMasterList[index]
                                      .ranking
                                      .toString(),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          state.paymentScheduleMasterList.length,
                          (index) {
                            final paymentScheduleMaster =
                                state.paymentScheduleMasterList[index];

                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(12),
                              decoration: commonCardDecoration(),
                              child: Column(
                                spacing: 10,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 15,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Ranking",
                                              style: AppTextStyle.ts12R(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            /*TextFormField(
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: _invalidRankingIndexes.contains(index)
                                                        ? Colors.red
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: _invalidRankingIndexes.contains(index)
                                                        ? Colors.red
                                                        : AppColor.primary,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                final parsed = int.tryParse(value) ?? 0;
                                                _bookingCubit.updateRanking(index, parsed);

                                                if (_invalidRankingIndexes.contains(index) && parsed != 0) {
                                                  setState(() {
                                                    _invalidRankingIndexes.remove(index);
                                                  });
                                                }
                                              },
                                            )*/
                                            CustomTextField(
                                              textController:
                                                  _rankingControllers[index],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatterList: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              onChangeFunction: (value) {
                                                final parsed =
                                                    int.tryParse(value) ?? 0;

                                                _bookingCubit.updateRanking(
                                                  index,
                                                  parsed,
                                                );

                                                if (_invalidRankingIndexes
                                                        .contains(index) &&
                                                    parsed != 0) {
                                                  setState(() {
                                                    _invalidRankingIndexes
                                                        .remove(index);
                                                  });
                                                }
                                              },
                                              validator: (value) {
                                                final parsed = int.tryParse(
                                                  value ?? '',
                                                );

                                                if (parsed == null) {
                                                  return "Ranking is required";
                                                }
                                                if (parsed == 0) {
                                                  return "Ranking cannot be 0";
                                                }

                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      buildColumnTitleValue(
                                        title: "Name",
                                        value: paymentScheduleMaster.name,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Percentage (%)",
                                        value:
                                            "${paymentScheduleMaster.paymentSchedulePercentage}",
                                      ),
                                      buildColumnTitleValue(
                                        title: "Cumulative (%)",
                                        value:
                                            "${paymentScheduleMaster.paymentScheduleCummulativePercentage}",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Remark", style: AppTextStyle.ts14M(color: AppColor.grey)),
            verticalSpacing(),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              child: CustomTextField(
                title: "Remark",
                isRequired: true,
                hint: "Enter Remark",
                minLines: 3,
                maxLines: 3,
                textController: _remarkC,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    print("Remark Val: $value");
                    return "Remark is required";
                  }
                  return null;
                },
              ),
            ),
          ],
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
            Text("Terms & Condition", style: AppTextStyle.ts16SB()),
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
                // Show each selected term with its title and cleaned description
                return Column(
                  children:
                      selectedTerms.map((term) {
                        final title = term['DisplayName']?.toString() ?? '';
                        final desc = term['Description']?.toString() ?? '';
                        final cleaned = _stripHtmlTags(desc);
                        if (cleaned.isEmpty && title.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 8),
                          decoration: commonCardDecoration(),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title.isNotEmpty)
                                Text(title, style: AppTextStyle.ts14SB()),
                              if (title.isNotEmpty) verticalSpacing(height: 6),
                              if (cleaned.isNotEmpty)
                                Text(cleaned, style: AppTextStyle.ts14R()),
                            ],
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

  // PAYMENTS DETAILS
  Widget _buildPaymentDetails() {
    return Form(
      key: _paymentDetailsFormKey,
      child: Container(
        padding: EdgeInsets.all(16),
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
                    isRequired: true,
                    title: "Booking Amount (₹)",
                    hint: "Enter Booking Amount",
                    textController: _bookingAmountC,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Booking Amount is required";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    isRequired: true,
                    title: "Cheque/ RTGS No.",
                    hint: "Enter Cheque/ RTGS No.",
                    textController: _chequeNoC,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Cheque/ RTGS No. is required";
                      }
                      return null;
                    },
                  ),
                  CustomDatePicker(
                    isRequired: true,
                    title: "Cheque/ RTGS Date",
                    initialDate: _selectedChequeDate,
                    setValue: (value) {
                      _selectedChequeDate = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Cheque/ RTGS Date is required";
                      }
                      return null;
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
    );
  }

  // BUILD APPLICANT CARD
  Widget _buildApplicantCard(BookingApplicantData applicant, int index) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.lightBlue),
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
                    Text(applicant.applicantName, style: AppTextStyle.ts14M()),
                    verticalSpacing(height: 4),
                    Text(
                      applicant.applicantType,
                      style: AppTextStyle.ts12R(color: AppColor.grey),
                    ),
                  ],
                ),
              ),
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
          verticalSpacing(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailField(
                  "Contact No.",
                  applicant.applicantMobileNumber,
                ),
              ),
              Expanded(
                child: _buildDetailField("Email", applicant.applicantEmailId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BUILD DETAIL FIELD
  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.ts12R(color: AppColor.grey)),
          Text(
            value.isEmpty ? "-" : value,
            style: AppTextStyle.ts14R(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _printAllBookingData() {
    print("\n================= BOOKING DATA =================");
    print("Enquiry Code                : ${_enquiryUniqueCodeC.text}");

    print("\nApplicants Count            : ${_applicants.value.length}");
    for (var applicant in _applicants.value) {
      print("Applicant                   : ${applicant.toJson()}");
    }

    print("Permanent Address           : ${_permanentAddressC.text}");
    print("Communication Address       : ${_communicationAddressC.text}");

    print("\n================ AGREEMENT DETAILS ================");
    print("Agreement Value             : ${_agreementValueNotifier.value}");
    print("TDS                         : ${_tdsNotifier.value}");
    print("Without TDS                 : ${_withoutTdsNotifier.value}");

    print("\n=================== TAX DETAILS ===================");
    print("GST %                       : ${_agreementGstPercentageC.text}");
    print("GST Amount                  : ${_agreementGstAmountNotifier.value}");
    print("Stamp Duty %                : ${_stampDutyPercentageC.text}");
    print("Stamp Duty Amount           : ${_stampDutyAmountNotifier.value}");
    print("Registration Fees           : ${_registrationFeesNotifier.value}");

    print("\n================== OTHER DETAILS ==================");
    print("Parking Selected            : ${_selectedParkingNotifier.value}");
    print("Selected HandOver Type      : $_selectedHandOverType");
    print("Expected Registration Date  : $_selectedExpectedRegistrationDate");
    print("Selected Funding Source     : $_selectedFundingSource");

    print("\n================== OTHER CHARGES ==================");
    print("Other Charges Count         : ${_localOtherCharges.value.length}");
    for (var otherCharge in _localOtherCharges.value) {
      print("Other Charge                : ${otherCharge.toJson()}");
    }

    print("\n================ PAYMENT SCHEDULE =================");
    for (
      int i = 0;
      i < _bookingCubit.state.paymentScheduleMasterList.length;
      i++
    ) {
      final item = _bookingCubit.state.paymentScheduleMasterList[i];
      final rankingText =
          i < _rankingControllers.length ? _rankingControllers[i].text : "";

      print("\n---------- ITEM ${i + 1} ----------");
      print("Name                         : ${item.name}");
      print("Ranking (Controller)         : $rankingText");
      print("Ranking (From Model)         : ${item.ranking}");
      print("Percentage                   : ${item.paymentSchedulePercentage}");
      print(
        "Cumulative Percentage        : ${item.paymentScheduleCummulativePercentage}",
      );
    }

    print("\n==================== REMARK ====================");
    print("Remark                      : ${_remarkC.text}");

    print("\n====================== TnC =====================");
    print(
      "Terms                       : ${_termsAndConditionDescriptionC.text}",
    );

    print("\n================= PAYMENT DETAILS ===============");
    print("Booking Amount              : ${_bookingAmountC.text}");
    print("Cheque No                   : ${_chequeNoC.text}");
    print("Cheque Date                 : $_selectedChequeDate");
    print("Bank Selected               : ${_selectedBankNotifier.value}");

    print("\n=================================================\n");
  }
}
