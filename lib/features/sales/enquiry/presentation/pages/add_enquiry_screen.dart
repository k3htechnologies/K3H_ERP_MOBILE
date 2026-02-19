// SAME IMPORTS (unchanged)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class AddEnquiryScreen extends StatefulWidget {
  final EnquiryModel? enquiryModel;
  final int index;

  const AddEnquiryScreen({super.key, this.enquiryModel, this.index = 0});

  @override
  State<AddEnquiryScreen> createState() => _AddEnquiryScreenState();
}

class _AddEnquiryScreenState extends State<AddEnquiryScreen> {
  // CUBIT
  late EnquiryCubit _enquiryCubit;

  // EDIT MODE
  bool get _isEditMode => widget.enquiryModel != null;
  // VARIABLE FOR VALIDATION
  final _formKey = GlobalKey<FormState>();
  // TIME VARIABLE
  String? _timeInC;
  // DATE VARIABLE
  DateTime? _enquiryDate;
  DateTime? _nextFollowUpDate;

  final List<int> budgetOptions = [1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 25];
  // BUDGET INITIAL VALUE
  int _budgetInitialVaue = 1;

  // VALUE NOTIFIERS FOR REACTIVE STATE
  final ValueNotifier<Map<String, dynamic>?> _selectedAccommodationNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedRequirementNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedResidentialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedCommercialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?>
  _selectedCommercialLeasingNotifier = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSourceNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSubSourceNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSubSubSourceNotifier =
      ValueNotifier(null);
  final ValueNotifier<List<Map<String, dynamic>>>
  _selectedChannelPartnerNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> _selectedSaleAdvisorNotifier =
      ValueNotifier([]);
  final ValueNotifier<DateTime?> _dateOfBirthNotifier = ValueNotifier(null);
  final ValueNotifier<List<Map<String, dynamic>>> _selectedTeamMemberNotifier =
      ValueNotifier([]);
  final ValueNotifier<String> _channelPartnerMobileNotifier = ValueNotifier('');

  // DROPDOWN VARIABLES
  Map<String, dynamic>? _selectedOccupationType;
  Map<String, dynamic>? _selectedPossessionType;
  Map<String, dynamic>? _selectedTimeline;
  Map<String, dynamic>? _selectedFloorBand;
  Map<String, dynamic>? _selectedFunding;
  Map<String, dynamic>? _selectedEthnicity;
  Map<String, dynamic>? _selectedFinalStage;
  List<Map<String, dynamic>> _selectedLocations = [];
  List<Map<String, dynamic>> _selectedSourcingManager = [];

  late TextEditingController _uniqueKey,
      _nameC,
      _mobileC,
      _emailC,
      _ageC,
      _locationC,
      _areaPrefC,
      _budgetC,
      // NRI Fields
      _countryOfResidenceC,
      _cityOfResidenceC,
      // Channel Partner
      _channelPartnerMobileC,
      _teamMemberNameC,
      _teamMemberMobileC,
      // Employee Reference
      _employeeName,
      _employeeMobileNumber,
      // Loyalty
      _existingProjectName,
      _existingUnitNumber,
      // Referral (Reference)
      _referralName,
      _referralMobile,
      _referralProjectName,
      _referralUnitNumber,
      _remarkC,
      otpController;

  // STATIC DROPDOWN LISTS
  final List<Map<String, dynamic>> currentAccommodation = [
    {'zAttributesId': -1, 'DisplayName': 'Select Current Accomodation'},
    {'zAttributesId': 1, 'DisplayName': 'Rented'},
    {'zAttributesId': 2, 'DisplayName': 'Self-Owned'},
  ];

  final List<Map<String, dynamic>> occupationType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Occupation Type'},
    {'zAttributesId': 1, 'DisplayName': 'Business'},
    {'zAttributesId': 2, 'DisplayName': 'Homemaker'},
    {'zAttributesId': 3, 'DisplayName': 'Professional'},
    {'zAttributesId': 4, 'DisplayName': 'Salaried'},
    {'zAttributesId': 5, 'DisplayName': 'Retired'},
  ];

  final List<Map<String, dynamic>> sourceTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Source'},
    {'zAttributesId': 1, 'DisplayName': 'Channel Partner'},
    {'zAttributesId': 2, 'DisplayName': 'Direct Walking'},
  ];

  final List<Map<String, dynamic>> residentialType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Unit Type'},
    {'zAttributesId': 1, 'DisplayName': '1 RK'},
    {'zAttributesId': 2, 'DisplayName': '1 BHK'},
    {'zAttributesId': 3, 'DisplayName': '2 BHK'},
    {'zAttributesId': 4, 'DisplayName': '3 BHK'},
    {'zAttributesId': 5, 'DisplayName': '4 BHK'},
    {'zAttributesId': 6, 'DisplayName': '1 + 1 JODI'},
    {'zAttributesId': 7, 'DisplayName': '2 + 1 JODI'},
    {'zAttributesId': 8, 'DisplayName': '2 + 2 JODI'},
    {'zAttributesId': 9, 'DisplayName': '2 + 3 JODI'},
    {'zAttributesId': 10, 'DisplayName': 'PENTHOUSE'},
  ];

  final List<Map<String, dynamic>> floorBrand = [
    {'zAttributesId': -1, 'DisplayName': 'Select Floor Brand'},
    {'zAttributesId': 1, 'DisplayName': 'Higher'},
    {'zAttributesId': 2, 'DisplayName': 'Middle'},
    {'zAttributesId': 3, 'DisplayName': 'Lower'},
  ];

  final List<Map<String, dynamic>> possessionType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Possession Type'},
    {'zAttributesId': 1, 'DisplayName': 'RTMI'},
    {'zAttributesId': 2, 'DisplayName': 'Under 1 Year'},
    {'zAttributesId': 3, 'DisplayName': '1 Years To 2 Years'},
    {'zAttributesId': 4, 'DisplayName': '2 Years To 3 Years'},
    {'zAttributesId': 5, 'DisplayName': '3 Years & Above'},
  ];

  final List<Map<String, dynamic>> requirementType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Requirement'},
    {'zAttributesId': 1, 'DisplayName': 'Commercial'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial Leasing'},
    {'zAttributesId': 3, 'DisplayName': 'Residential'},
  ];

  final List<Map<String, dynamic>> commercialUnitTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Type'},
    {'zAttributesId': 1, 'DisplayName': 'OFFICE'},
    {'zAttributesId': 2, 'DisplayName': 'SHOP'},
  ];

  final List<Map<String, dynamic>> timelineTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Timeline'},
    {'zAttributesId': 1, 'DisplayName': 'Within 1 Month'},
    {'zAttributesId': 2, 'DisplayName': 'Beyond 1 Month'},
  ];

  final List<Map<String, dynamic>> fundingSourceList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Funding Source'},
    {'zAttributesId': 1, 'DisplayName': 'Loan'},
    {'zAttributesId': 2, 'DisplayName': 'Self-funded'},
    {'zAttributesId': 3, 'DisplayName': 'Sale Of Property Funding'},
  ];

  final List<Map<String, dynamic>> ethnicityList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Ethnicity'},
    {'zAttributesId': 1, 'DisplayName': 'Bengali'},
    {'zAttributesId': 2, 'DisplayName': 'Christian'},
    {'zAttributesId': 3, 'DisplayName': 'Gujarati'},
    {'zAttributesId': 4, 'DisplayName': 'Jain'},
    {'zAttributesId': 5, 'DisplayName': 'Muslim'},
    {'zAttributesId': 6, 'DisplayName': 'Marwari'},
    {'zAttributesId': 7, 'DisplayName': 'Maharashtrian'},
    {'zAttributesId': 8, 'DisplayName': 'North Indian'},
    {'zAttributesId': 9, 'DisplayName': 'Parsi'},
    {'zAttributesId': 10, 'DisplayName': 'Punjabi'},
    {'zAttributesId': 11, 'DisplayName': 'Sindhi'},
    {'zAttributesId': 12, 'DisplayName': 'South Indian'},
    {'zAttributesId': 13, 'DisplayName': 'Others'},
  ];

  final List<Map<String, dynamic>> stageTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Stage'},
    {'zAttributesId': 1, 'DisplayName': 'Site Visit'},
    {'zAttributesId': 2, 'DisplayName': 'Re-Visit Proposed'},
    {'zAttributesId': 3, 'DisplayName': 'Re-Visit Scheduled'},
    {'zAttributesId': 4, 'DisplayName': 'Negotiation'},
    {'zAttributesId': 5, 'DisplayName': 'Unit Selection / Blocked'},
    {'zAttributesId': 6, 'DisplayName': 'Blocked'},
    {'zAttributesId': 7, 'DisplayName': 'Booking Done'},
    {'zAttributesId': 8, 'DisplayName': 'Retention'},
    {'zAttributesId': 9, 'DisplayName': 'Lost'},
    {'zAttributesId': 10, 'DisplayName': 'Cancelled'},
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

  final List<Map<String, dynamic>> subSubSourceList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Sub-Sub Source'},
    {'zAttributesId': 1, 'DisplayName': 'Facebook'},
    {'zAttributesId': 2, 'DisplayName': 'Hoarding'},
    {'zAttributesId': 3, 'DisplayName': 'Instagram'},
    {'zAttributesId': 4, 'DisplayName': 'Google Ads'},
    {'zAttributesId': 5, 'DisplayName': 'Newspaper'},
  ];

  @override
  void initState() {
    super.initState();
    _enquiryCubit = context.read<EnquiryCubit>();
    _initControllers();
    _enquiryCubit.clearChannelPartner();
    if (_isEditMode) {
      _populateForm(widget.enquiryModel!);
    } else {
      _timeInC = DateTime.now().toIso8601String().split("T")[1].split(".")[0];
      _enquiryDate = DateTime.now();
      _budgetC.text = ">1";
    }
  }

  // INITIALIZED TEXTEDITING CONTROLLERS
  void _initControllers() {
    _uniqueKey = TextEditingController();
    _nameC = TextEditingController();
    _mobileC = TextEditingController();
    _emailC = TextEditingController();
    _ageC = TextEditingController();
    _locationC = TextEditingController();
    _areaPrefC = TextEditingController();
    _budgetC = TextEditingController();
    _countryOfResidenceC = TextEditingController();
    _cityOfResidenceC = TextEditingController();
    _channelPartnerMobileC = TextEditingController();
    _teamMemberNameC = TextEditingController();
    _teamMemberMobileC = TextEditingController();
    _employeeName = TextEditingController();
    _employeeMobileNumber = TextEditingController();
    _existingProjectName = TextEditingController();
    _existingUnitNumber = TextEditingController();
    _referralName = TextEditingController();
    _referralMobile = TextEditingController();
    _referralProjectName = TextEditingController();
    _referralUnitNumber = TextEditingController();
    _remarkC = TextEditingController();
    otpController = TextEditingController();
  }

  void _populateForm(EnquiryModel model) async {
    // TEXT CONTROLLERS
    _uniqueKey.text = model.systemGeneratedCode;
    _nameC.text = model.name;
    _mobileC.text = model.mobileNumber;
    _emailC.text = model.emailId;
    _locationC.text = model.currentLocation;
    _areaPrefC.text = model.areaPreferred.toString();
    _budgetC.text = model.budget;
    _remarkC.text = model.remark;

    // SOURCE BASED TEXT FIELDS
    _employeeName.text = model.employeeReferenceName;
    _employeeMobileNumber.text = model.employeeReferenceMobileNumber;
    _existingProjectName.text = model.loyaltyExistingProjectName;
    _existingUnitNumber.text = model.loyaltyExistingUnitNumber;
    _referralName.text = model.referelName;
    _referralMobile.text = model.referelMobileNumber;
    _referralProjectName.text = model.referelProjectName;
    _referralUnitNumber.text = model.referelUnitNumber;
    _channelPartnerMobileC.text = model.channelPartnerMobileNumber;
    _channelPartnerMobileNotifier.value = model.channelPartnerMobileNumber;
    _teamMemberNameC.text = model.channelPartnerName;
    _teamMemberMobileC.text = model.channelPartnerTeamMemberMobileNumber;

    // TIME
    _timeInC = model.enquiryTimeIn;

    // DATES
    _dateOfBirthNotifier.value = model.dateOfBirth;
    _enquiryDate = model.enquiryDate;
    _nextFollowUpDate = model.nextFollowUpDate;

    // NRI FIELDS
    _countryOfResidenceC.text = model.countryOfResidence;
    _cityOfResidenceC.text = model.cityOfResidence;

    _updateAge();

    // HELPER: Find item in list by DisplayName
    Map<String, dynamic> findItem(
      List<Map<String, dynamic>> list,
      String value,
    ) {
      return list.firstWhere(
        (e) =>
            e["DisplayName"].toString().toLowerCase().trim() ==
            value.toLowerCase().trim(),
        orElse: () => list.first,
      );
    }

    // DROPDOWNS - NOTIFIER
    _selectedAccommodationNotifier.value = findItem(
      currentAccommodation,
      model.accommodation,
    );
    _selectedRequirementNotifier.value = findItem(
      requirementType,
      model.requirement,
    );

    // DROPDOWNS - PLAIN VARIABLES
    _selectedOccupationType = findItem(occupationType, model.occupationType);
    _selectedPossessionType = findItem(possessionType, model.possessionType);
    _selectedFloorBand = findItem(floorBrand, model.desiredFloorBand);
    _selectedFunding = findItem(fundingSourceList, model.sourceOfFunding);
    _selectedEthnicity = findItem(ethnicityList, model.ethnicity);
    _selectedFinalStage = findItem(stageTypeList, model.finalStage);
    _selectedTimeline = findItem(timelineTypeList, model.timeline);

    // DEPENDENT REQUIREMENT TYPE DROPDOWNS
    final reqDisplay = model.requirement;
    if (reqDisplay == "Residential") {
      _selectedResidentialTypeNotifier.value = findItem(
        residentialType,
        model.requirementType,
      );
    } else if (reqDisplay == "Commercial") {
      _selectedCommercialTypeNotifier.value = findItem(
        commercialUnitTypeList,
        model.requirementType,
      );
    } else if (reqDisplay == "Commercial Leasing") {
      _selectedCommercialLeasingNotifier.value = findItem(
        commercialUnitTypeList,
        model.requirementType,
      );
    }

    _selectedSourceNotifier.value = findItem(sourceTypeList, model.source);

    // SUB SOURCE
    if (model.source == "Channel Partner") {
      _selectedChannelPartnerNotifier.value = [
        {
          "zAttributesId": model.subSubSource,
          "DisplayName": model.channelPartnerName,
          "Mobile": model.channelPartnerMobileNumber,
        },
      ];
      _selectedSubSubSourceNotifier.value =
          _selectedChannelPartnerNotifier.value.first;
      _selectedSubSourceNotifier.value = channelPartnerActivityList.firstWhere(
        (e) => e['DisplayName'] == model.subSource,
        orElse: () => channelPartnerActivityList.first,
      );

      // AUTO-FETCH CHANNEL PARTNER CARD IN EDIT MODE
      if (model.channelPartnerMobileNumber.isNotEmpty) {
        _enquiryCubit.fetchChannelPartners(
          1,
          value: model.channelPartnerMobileNumber,
        );
      }

      // AUTO-FETCH TEAM MEMBER BY ID IN EDIT MODE
      if (model.channelPartnerTeamMemberId != 0) {
        // FETCH BY ID
        await _enquiryCubit
            .fetchEmployees(1, employeeId: model.channelPartnerTeamMemberId)
            .then((result) {
              if (!mounted) return;
              final List<Map<String, dynamic>> items =
                  result["itemList"] as List<Map<String, dynamic>>;
              if (items.isNotEmpty) {
                final member = items.first;
                _selectedTeamMemberNotifier.value = [member];
                // ALSO SET TEXT FIELDS IN CASE DROPDOWN DOESN'T SHOW
                _teamMemberMobileC.text = member['MobileNo'] ?? '';
              }
            });
      } else if (model.channelPartnerTeamMemberMobileNumber.isNotEmpty ||
          model.channelPartnerName.isNotEmpty) {
        // NO ID BUT HAS NAME/MOBILE
        _selectedTeamMemberNotifier.value = [];
        _teamMemberNameC.text = model.channelPartnerName;
        _teamMemberMobileC.text = model.channelPartnerTeamMemberMobileNumber;
      }
    } else {
      _selectedSubSourceNotifier.value = findItem(
        directWalkingSubSourceList,
        model.subSource,
      );
      _selectedSubSubSourceNotifier.value = findItem(
        subSubSourceList,
        model.subSubSource,
      );
    }

    // PREFILL LOCATIONS
    if (model.villageName.isNotEmpty) {
      _selectedLocations =
          model.villageName
              .split(',')
              .map(
                (e) => {
                  "DisplayName": e.trim(),
                  "zAttributesId": model.villageMasterId,
                },
              )
              .toList();
    }

    // PREFILL SALES ADVISOR
    if (model.salesAdvisor.isNotEmpty) {
      _selectedSaleAdvisorNotifier.value = [
        {
          "zAttributesId": model.salesAdvisorId,
          "DisplayName": model.salesAdvisor,
        },
      ];
    }

    // PREFILL SOURCING MANAGER
    if (model.sourcingManager.isNotEmpty) {
      _selectedSourcingManager = [
        {
          "zAttributesId": model.sourcingManagerId,
          "DisplayName": model.sourcingManager,
        },
      ];
    }

    // BUDGET SLIDER
    if (model.budget.isNotEmpty) {
      final cleaned = model.budget.replaceAll("+", "").replaceAll(">", "");
      final value = int.tryParse(cleaned);
      if (value != null && budgetOptions.contains(value)) {
        _budgetInitialVaue = value;
      }
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Send OTP FIRST (shows loading + success)
    _enquiryCubit.sendOTP(context: context, mobileNumber: _mobileC.text.trim());

    // ✅ THEN show verification dialog
    showCompleteVerificationDialog(
      context,
      otpController: otpController,
      mobileNumber: _mobileC.text.trim(),
      module: "Enquiry",
      onResendOTP: () {
        _enquiryCubit.sendOTP(
          context: context,
          mobileNumber: _mobileC.text.trim(),
        );
      },
      onVerifyOTP: () {
        // ✅ AFTER OTP → AUTO SUBMIT ENQUIRY
        _submitEnquiryData();
      },
    );
  }

  void _submitEnquiryData() async {
    // SOURCE & SUB SUB SOURCE
    final source = _selectedSourceNotifier.value?["DisplayName"] ?? "";
    final subSubSource =
        source == "Channel Partner"
            ? (_selectedSubSubSourceNotifier.value?["zAttributesId"]
                    ?.toString() ??
                "")
            : (_selectedSubSubSourceNotifier.value?["DisplayName"] ?? "");

    // CUSTOMER CLASSIFICATION LOGIC
    int selectedCount = 0;
    if ((_selectedPossessionType?["DisplayName"] ?? "").trim().isNotEmpty)
      selectedCount++;
    if ((_selectedRequirementNotifier.value?["DisplayName"] ?? "")
        .trim()
        .isNotEmpty)
      selectedCount++;
    if (_locationC.text.trim().isNotEmpty) selectedCount++;
    if (_budgetC.text.trim().isNotEmpty) selectedCount++;

    final timeline = getDisplayOrEmpty(_selectedTimeline);
    String customerClassification;
    if (selectedCount >= 3 && timeline.contains("Within 1 Month")) {
      customerClassification = "Hot";
    } else if (selectedCount >= 2 && timeline.contains("Beyond 1 Month")) {
      customerClassification = "Warm";
    } else {
      customerClassification = "Cold";
    }

    // REQUIREMENT TYPE FROM CASCADING DROPDOWN
    final req = _selectedRequirementNotifier.value?["DisplayName"] ?? "";
    final String requirementTypeValue;
    if (req == "Residential") {
      requirementTypeValue =
          _selectedResidentialTypeNotifier.value?["DisplayName"] ?? "";
    } else if (req == "Commercial") {
      requirementTypeValue =
          _selectedCommercialTypeNotifier.value?["DisplayName"] ?? "";
    } else if (req == "Commercial Leasing") {
      requirementTypeValue =
          _selectedCommercialLeasingNotifier.value?["DisplayName"] ?? "";
    } else {
      requirementTypeValue = "";
    }

    final payload = {
      "EnquiryId": _isEditMode ? widget.enquiryModel!.enquiryId : 0,
      if (_isEditMode) "Uniquekey": widget.enquiryModel!.uniquekey,
      "ProjectId": getProject().projectId,
      "EnquiryTimeIn": _timeInC,
      "EnquiryTimeOut":
          DateTime.now().toIso8601String().split("T")[1].split(".")[0],
      "Name": _nameC.text.trim(),
      "MobileNumber": _mobileC.text.trim(),
      "EmailId": _emailC.text.trim(),
      "DateOfBirth": _dateOfBirthNotifier.value?.toIso8601String(),
      "Accommodation": getDisplayOrEmpty(_selectedAccommodationNotifier.value),
      "OccupationType": getDisplayOrEmpty(_selectedOccupationType),
      "Source": source,
      "SubSource": getDisplayOrEmpty(_selectedSubSourceNotifier.value),
      "SubSubSource": subSubSource,
      "ReferelName": _referralName.text.trim(),
      "ReferelMobileNumber": _referralMobile.text.trim(),
      "ReferelProjectName": _referralProjectName.text.trim(),
      "ReferelUnitNumber": _referralUnitNumber.text.trim(),
      "LoyaltyExistingProjectName": _existingProjectName.text.trim(),
      "LoyaltyExistingUnitNumber": _existingUnitNumber.text.trim(),
      "EmployeeReferenceName": _employeeName.text.trim(),
      "EmployeeReferenceMobileNumber": _employeeMobileNumber.text.trim(),
      "ChannelPartnerTeamMemberId":
          _selectedTeamMemberNotifier.value.isNotEmpty
              ? _selectedTeamMemberNotifier.value.first["zAttributesId"]
              : 0,
      "ChannelPartnerTeamMemberName": _teamMemberNameC.text.trim(),
      "ChannelPartnerTeamMemberMobileNumber": _teamMemberMobileC.text.trim(),
      "Nationality": _enquiryCubit.state.selectedNationality,
      "CountryOfResidence": _countryOfResidenceC.text.trim(),
      "CityOfResidence": _cityOfResidenceC.text.trim(),
      "CurrentLocation": _locationC.text.trim(),
      "VillageMasterId": selectedVillages,
      "PossessionType": getDisplayOrEmpty(_selectedPossessionType),
      "AreaPreferred": int.tryParse(_areaPrefC.text.trim()) ?? 0,
      "DesiredFloorBand": getDisplayOrEmpty(_selectedFloorBand),
      "Budget": _budgetC.text.trim(),
      "Requirement": getDisplayOrEmpty(_selectedRequirementNotifier.value),
      "RequirementType": requirementTypeValue,
      "CustomerClassification": customerClassification,
      "SourceOfFunding": getDisplayOrEmpty(_selectedFunding),
      "Ethnicity": getDisplayOrEmpty(_selectedEthnicity),
      "FinalStage": getDisplayOrEmpty(_selectedFinalStage),
      "FinalStageDetail": "",
      "EnquiryDate": _enquiryDate?.toIso8601String(),
      "NextFollowUpDate": _nextFollowUpDate?.toIso8601String(),
      "SalesAdvisorId":
          _selectedSaleAdvisorNotifier.value.isNotEmpty
              ? _selectedSaleAdvisorNotifier.value.first["zAttributesId"]
              : 0,
      "SourcingManagerId":
          _selectedSourcingManager.isNotEmpty
              ? _selectedSourcingManager.first["zAttributesId"]
              : 0,
      "Remark": _remarkC.text.trim(),
      "Timeline": timeline,
      "OTP": otpController.text.trim(),
    };

    // ✅ SUBMIT ENQUIRY AFTER OTP VERIFICATION
    await _enquiryCubit.addUpdateEnquiry(
      context: context,
      body: payload,
      index: _isEditMode ? widget.index : null,
    );
  }

  String getDisplayOrEmpty(Map<String, dynamic>? item) {
    if (item == null) return "";
    if (item["zAttributesId"] == -1) return "";
    return item["DisplayName"] ?? "";
  }

  String get selectedVillages => _selectedLocations
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");

  void _updateAge() {
    if (_dateOfBirthNotifier.value != null) {
      _ageC.text = calculateAge(_dateOfBirthNotifier.value);
    }
  }

  @override
  void dispose() {
    // TEXT CONTROLLERS
    _uniqueKey.dispose();
    _nameC.dispose();
    _mobileC.dispose();
    _emailC.dispose();
    _ageC.dispose();
    _locationC.dispose();
    _areaPrefC.dispose();
    _budgetC.dispose();
    _countryOfResidenceC.dispose();
    _cityOfResidenceC.dispose();

    // CHANNEL PARTNER CONTROLLERS
    _channelPartnerMobileC.dispose();
    _teamMemberNameC.dispose();
    _teamMemberMobileC.dispose();

    // EMPLOYEE REFERENCE CONTROLLERS
    _employeeName.dispose();
    _employeeMobileNumber.dispose();

    // LOYALTY CONTROLLERS
    _existingProjectName.dispose();
    _existingUnitNumber.dispose();

    // REFERRAL CONTROLLERS
    _referralName.dispose();
    _referralMobile.dispose();
    _referralProjectName.dispose();
    _referralUnitNumber.dispose();

    // OTHER CONTROLLERS
    _remarkC.dispose();

    // VALUE NOTIFIERS
    _dateOfBirthNotifier.dispose();
    _selectedAccommodationNotifier.dispose();
    _selectedRequirementNotifier.dispose();
    _selectedResidentialTypeNotifier.dispose();
    _selectedCommercialTypeNotifier.dispose();
    _selectedCommercialLeasingNotifier.dispose();
    _selectedSourceNotifier.dispose();
    _selectedSubSourceNotifier.dispose();
    _selectedSubSubSourceNotifier.dispose();
    _selectedTeamMemberNotifier.dispose();
    _channelPartnerMobileNotifier.dispose();
    _selectedSaleAdvisorNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Enquiry" : "Add Enquiry",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _basicCard(),
              verticalSpacing(height: 16),
              _sourceCard(),
              verticalSpacing(height: 16),
              _addressCard(),
              verticalSpacing(height: 16),
              _propertyPrefCard(),
              verticalSpacing(height: 16),
              _customerDetailsCard(),
              verticalSpacing(height: 16),
              _enquiryInfoCard(),
              verticalSpacing(height: 16),
              _followUpCard(),
              verticalSpacing(height: 16),
              _salesCard(),
              verticalSpacing(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: !_isEditMode ? 'Add' : 'Update',
            onPressed: _submitForm,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }

  // BASIC ENQUIRY DETAILS
  Widget _basicCard() {
    return BlocBuilder<EnquiryCubit, EnquiryState>(
      builder: (context, state) {
        final bool isNRI = state.selectedNationality == 'NRI';
        return _card("Basic Enquiry Details", [
          CustomTextField(
            readOnly: true,
            textController: _uniqueKey,
            title: 'Unique key',
            hint: "System Generated Unique key",
          ),
          CustomTimePicker(
            title: 'Customer Time In',
            isRequired: true,
            readOnly: true,
            initialTime: parseTimeOfDayFromHHmm(_timeInC),
            setValue: (val) => _timeInC = formatTimeOfDayHHmm(val),
          ),
          CustomTextField(
            title: "Full Name",
            textController: _nameC,
            hint: "Enter Name",
            isRequired: true,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return "Name is required";
              return null;
            },
          ),
          CustomTextField(
            title: "Mobile Number",
            textController: _mobileC,
            hint: "Enter Mobile Number",
            keyboardType: TextInputType.number,
            isRequired: true,
            inputFormatterList: InputValidator.digit(10),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "Mobile number is required";
              }
              return null;
            },
          ),
          CustomTextField(
            title: "E-mail ID",
            textController: _emailC,
            keyboardType: TextInputType.emailAddress,
            hint: "Enter Email",
          ),
          ValueListenableBuilder<DateTime?>(
            valueListenable: _dateOfBirthNotifier,
            builder: (context, dateOfBirth, child) {
              return CustomDatePicker(
                title: "DOB",
                isRequired: true,
                initialDate: dateOfBirth,
                validator: (value) {
                  if (value == null) return "DOB is required";
                  final today = DateTime.now();
                  int age = today.year - value.year;
                  if (today.month < value.month ||
                      (today.month == value.month && today.day < value.day)) {
                    age--;
                  }
                  if (age < 18) return "Age must be 18 or above";
                  return null;
                },
                setValue: (v) {
                  _dateOfBirthNotifier.value = v;
                  _updateAge();
                },
              );
            },
          ),
          CustomTextField(
            isRequired: true,
            readOnly: true,
            title: "Age",
            textController: _ageC,
            hint: "System calculated Age",
          ),
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedAccommodationNotifier,
            builder: (context, selectedAccommodation, child) {
              return CustomDropDownWidget(
                title: "Current Accommodation",
                initialValue:
                    selectedAccommodation ?? currentAccommodation.first,
                isRequired: true,
                dataList: currentAccommodation,
                onSelected: (v) => _selectedAccommodationNotifier.value = v,
                validator: (val) {
                  if (val?['zAttributesId'] == -1) {
                    return "Please select accommodation";
                  }
                  return null;
                },
              );
            },
          ),
          CustomDropDownWidget(
            title: "Occupation Type",
            isRequired: true,
            initialValue: _selectedOccupationType ?? occupationType.first,
            dataList: occupationType,
            onSelected: (v) => _selectedOccupationType = v,
            validator: (val) {
              if (val?['zAttributesId'] == -1) {
                return "Please select occupation type";
              }
              return null;
            },
          ),
          Text("Nationality", style: AppTextStyle.ts14R()),
          Row(
            children: [
              Radio<String>(
                value: state.options[0],
                // ignore: deprecated_member_use
                groupValue: state.selectedNationality,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  _enquiryCubit.onSelectedOptionChanged(value!);
                  if (value == 'Indian') {
                    _countryOfResidenceC.clear();
                    _cityOfResidenceC.clear();
                  }
                },
              ),
              Text("Indian", style: AppTextStyle.ts14R()),
              horizontalSpacing(),
              Radio<String>(
                value: state.options[1],
                // ignore: deprecated_member_use
                groupValue: state.selectedNationality,
                // ignore: deprecated_member_use
                onChanged:
                    (value) => _enquiryCubit.onSelectedOptionChanged(value!),
              ),
              Text("NRI", style: AppTextStyle.ts14R()),
            ],
          ),
          if (isNRI) ...[
            verticalSpacing(),
            CustomTextField(
              title: "Country Of Residence",
              hint: "Enter Country Of Residence",
              textController: _countryOfResidenceC,
              isRequired: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Country of residence is required";
                }
                return null;
              },
            ),
            CustomTextField(
              title: "City Of Residence",
              hint: "Enter City Of Residence",
              textController: _cityOfResidenceC,
              isRequired: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "City of residence is required";
                }
                return null;
              },
            ),
          ],
        ]);
      },
    );
  }

  // SOURCE
  Widget _sourceCard() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: _selectedSourceNotifier,
      builder: (context, selectedSource, child) {
        final bool isChannelPartner = selectedSource?['zAttributesId'] == 1;
        final bool isDirectWalking = selectedSource?['zAttributesId'] == 2;

        return ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: _selectedSubSourceNotifier,
          builder: (context, selectedSubSource, child) {
            final int subSourceId = selectedSubSource?['zAttributesId'] ?? -1;

            return _card("Source", [
              CustomDropDownWidget(
                title: "Source",
                isRequired: true,
                initialValue: selectedSource ?? sourceTypeList.first,
                dataList: sourceTypeList,
                onSelected: (v) {
                  _selectedSourceNotifier.value = v;
                  _selectedSubSourceNotifier.value =
                      v['zAttributesId'] == 1
                          ? channelPartnerActivityList.first
                          : directWalkingSubSourceList.first;
                  _selectedSubSubSourceNotifier.value = subSubSourceList.first;
                  _channelPartnerMobileC.clear();
                  _channelPartnerMobileNotifier.value = '';
                  _selectedTeamMemberNotifier.value = [];
                  _teamMemberNameC.clear();
                  _teamMemberMobileC.clear();
                },
                validator: (value) {
                  if (value?['zAttributesId'] == -1) {
                    return "Source is required";
                  }
                  return null;
                },
              ),

              if ((selectedSource?['zAttributesId'] ?? -1) != -1)
                CustomDropDownWidget(
                  title: "Sub Source",
                  isRequired: true,
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
                    _selectedSubSubSourceNotifier.value =
                        subSubSourceList.first;
                    if (isChannelPartner) {
                      _channelPartnerMobileC.clear();
                      _channelPartnerMobileNotifier.value = '';
                      _selectedTeamMemberNotifier.value = [];
                      _teamMemberNameC.clear();
                      _teamMemberMobileC.clear();
                    }
                  },
                  validator: (value) {
                    if (value?['zAttributesId'] == -1) {
                      return "Sub source is required";
                    }
                    return null;
                  },
                ),

              if (isChannelPartner && subSourceId != -1) ...[
                CustomTextField(
                  title: "Channel Partner",
                  hint: "Search by Channel Partner Mobile No.",
                  textController: _channelPartnerMobileC,
                  isRequired: true,
                  inputFormatterList: InputValidator.digit(10),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Channel Partner mobile number is required";
                    }
                    if (val.trim().length != 10) {
                      return "Mobile number must be 10 digits";
                    }
                    return null;
                  },
                  onChangeFunction: (value) async {
                    _channelPartnerMobileNotifier.value = value;
                    if (value.length != 10) {
                      _selectedTeamMemberNotifier.value = [];
                      _teamMemberNameC.clear();
                      _teamMemberMobileC.clear();
                      _selectedSubSubSourceNotifier.value = null;
                      _enquiryCubit.clearChannelPartner();
                      return;
                    }
                    final result = await _enquiryCubit.fetchChannelPartners(
                      1,
                      value: value,
                    );
                    if (result.isNotEmpty) {
                      _selectedSubSubSourceNotifier.value = {
                        "zAttributesId":
                            _enquiryCubit
                                .state
                                .channelPartnerModel!
                                .channelPartnerId,
                        "DisplayName":
                            _enquiryCubit.state.channelPartnerModel!.name,
                      };
                    }
                  },
                ),
                BlocBuilder<EnquiryCubit, EnquiryState>(
                  builder: (context, state) {
                    final partner = state.channelPartnerModel;
                    if (partner == null) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColor.lightBlue,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(width: 0.5, color: AppColor.primary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Full Name",
                                value: partner.name,
                              ),
                              buildColumnTitleValue(
                                title: "Company Name",
                                value: partner.companyName,
                              ),
                            ],
                          ),
                          verticalSpacing(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Firms Type",
                                value: partner.firmsType,
                              ),
                              buildColumnTitleValue(
                                title: "Mobile",
                                value: partner.mobileNumber,
                              ),
                            ],
                          ),
                          verticalSpacing(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Designation",
                                value: partner.designation,
                              ),
                              buildColumnTitleValue(
                                title: "Type",
                                value: partner.type,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              ValueListenableBuilder<String>(
                valueListenable: _channelPartnerMobileNotifier,
                builder: (context, mobileValue, child) {
                  if (!isChannelPartner ||
                      subSourceId == -1 ||
                      mobileValue.length != 10) {
                    return const SizedBox.shrink();
                  }
                  return ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _selectedTeamMemberNotifier,
                    builder: (context, selectedTeamMember, child) {
                      final bool hasTeamMemberSelected =
                          selectedTeamMember.isNotEmpty;
                      return Column(
                        children: [
                          CustomMultipleSelectPopup(
                            key: ValueKey(
                              selectedTeamMember.isNotEmpty
                                  ? selectedTeamMember.first['zAttributesId']
                                  : 'empty',
                            ),
                            title: 'Team Member',
                            isRequired: false,
                            isMultiSelect: false,
                            initialValue: selectedTeamMember,
                            dataList: const [],
                            dataFetchCallBack: _enquiryCubit.fetchEmployees,
                            onSelected: (value) {
                              _teamMemberNameC.clear();
                              _teamMemberMobileC.clear();
                              _selectedTeamMemberNotifier.value = value;
                              if (value.isNotEmpty) {
                                final member = value.first;
                                _teamMemberNameC.text =
                                    member['DisplayName'] ?? '';
                                _teamMemberMobileC.text =
                                    member['MobileNo'] ?? '';
                              }
                            },
                          ),
                          // SHOW TEXT FIELDS ONLY IF NO TEAM MEMBER SELECTED FROM DROPDOWN
                          if (!hasTeamMemberSelected) ...[
                            CustomTextField(
                              title: "Team Member Name",
                              hint: "Enter Team Member Name",
                              textController: _teamMemberNameC,
                              isRequired: true,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Team Member name is required";
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              title: "Team Member Mobile Number",
                              hint: "Enter Mobile Number",
                              textController: _teamMemberMobileC,
                              keyboardType: TextInputType.number,
                              isRequired: true,
                              inputFormatterList: InputValidator.digit(10),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Team Member mobile number is required";
                                }
                                if (val.trim().length != 10) {
                                  return "Mobile number must be 10 digits";
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
              if (isDirectWalking && subSourceId == 1)
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: _selectedSubSubSourceNotifier,
                  builder: (context, selectedSubSubSource, child) {
                    return CustomDropDownWidget(
                      title: "Sub Sub Source",
                      isRequired: true,
                      initialValue:
                          selectedSubSubSource ?? subSubSourceList.first,
                      dataList: subSubSourceList,
                      onSelected:
                          (v) => _selectedSubSubSourceNotifier.value = v,
                      validator: (value) {
                        if (value?['zAttributesId'] == -1) {
                          return "Sub Sub Source is required";
                        }
                        return null;
                      },
                    );
                  },
                ),

              if (isDirectWalking && subSourceId == 3) ...[
                CustomTextField(
                  title: "Employee Name",
                  hint: "Enter Employee Name",
                  textController: _employeeName,
                  isRequired: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Employee name is required";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: "Employee Mobile Number",
                  hint: "Enter Mobile Number",
                  textController: _employeeMobileNumber,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  inputFormatterList: InputValidator.digit(10),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Employee mobile number is required";
                    }
                    if (val.trim().length != 10) {
                      return "Mobile number must be 10 digits";
                    }
                    return null;
                  },
                ),
              ],

              if (isDirectWalking && subSourceId == 5) ...[
                CustomTextField(
                  title: "Existing Project Name",
                  hint: "Enter Project Name",
                  textController: _existingProjectName,
                  isRequired: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Existing project name is required";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: "Existing Unit Number",
                  hint: "Enter Unit Number",
                  textController: _existingUnitNumber,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Existing unit number is required";
                    }
                    return null;
                  },
                ),
              ],

              if (isDirectWalking && subSourceId == 10) ...[
                CustomTextField(
                  title: "Referral Name",
                  isRequired: true,
                  hint: "Enter Referral Name",
                  textController: _referralName,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Referral name is required";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: "Referral Mobile Number",
                  hint: "Enter Referral Mobile Number",
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  textController: _referralMobile,
                  inputFormatterList: InputValidator.digit(10),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Referral mobile number is required";
                    }
                    if (val.trim().length != 10) {
                      return "Mobile number must be 10 digits";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  isRequired: true,
                  title: "Referral Project Name",
                  hint: "Enter Referral Project Name",
                  textController: _referralProjectName,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Referral project name is required";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: "Referral Unit Number",
                  hint: "Enter Referral Unit Number",
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  textController: _referralUnitNumber,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Referral unit number is required";
                    }
                    return null;
                  },
                ),
              ],
            ]);
          },
        );
      },
    );
  }

  // ADDRESS
  Widget _addressCard() {
    return _card("Address", [
      CustomTextField(
        title: "Current Location",
        isRequired: true,
        hint: "Enter Current Location",
        textController: _locationC,
        validator: (val) {
          if (val == null || val.isEmpty) {
            return "Current location is required.";
          }
          return null;
        },
      ),
    ]);
  }

  // PROPERTY PREFERENCE
  Widget _propertyPrefCard() {
    return _card("Property Preferences", [
      const Text("Budget (In Cr)"),
      SizedBox(
        width: double.infinity,
        child: SfSlider(
          min: 0,
          max: (budgetOptions.length - 1).toDouble(),
          value: budgetOptions.indexOf(_budgetInitialVaue).toDouble(),
          interval: 1,
          showTicks: false,
          showLabels: true,
          enableTooltip: false,
          activeColor: AppColor.primary,
          inactiveColor: AppColor.primary.withValues(alpha: 0.25),
          minorTicksPerInterval: 0,
          labelFormatterCallback: (actualValue, formattedText) {
            int index = actualValue.round();
            int val = budgetOptions[index];
            return val == 1
                ? ">1"
                : val == 25
                ? "25+"
                : "$val";
          },
          onChanged: (dynamic value) {
            int index = value.round();
            int val = budgetOptions[index];
            _budgetC.text =
                val == 1
                    ? ">1"
                    : val == 25
                    ? "25+"
                    : val.toString();
          },
        ),
      ),
      verticalSpacing(height: 20),
      CustomDropDownWidget(
        title: "Possession Type",
        initialValue: _selectedPossessionType ?? possessionType.first,
        dataList: possessionType,
        onSelected: (v) => _selectedPossessionType = v,
      ),
      ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: _selectedRequirementNotifier,
        builder: (context, selectedRequirement, child) {
          List<Map<String, dynamic>> dependentList = [];
          if (selectedRequirement != null) {
            final reqVal = selectedRequirement["DisplayName"] ?? "";
            if (reqVal == "Residential") {
              dependentList = residentialType;
            } else if (reqVal == "Commercial" ||
                reqVal == "Commercial Leasing") {
              dependentList = commercialUnitTypeList;
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropDownWidget(
                title: "Requirement",
                initialValue: selectedRequirement ?? requirementType.first,
                dataList: requirementType,
                onSelected: (v) {
                  _selectedRequirementNotifier.value = v;
                  if (v["DisplayName"] == "Residential") {
                    _selectedResidentialTypeNotifier.value =
                        residentialType.first;
                  } else if (v["DisplayName"] == "Commercial") {
                    _selectedCommercialTypeNotifier.value =
                        commercialUnitTypeList.first;
                  } else if (v["DisplayName"] == "Commercial Leasing") {
                    _selectedCommercialLeasingNotifier.value =
                        commercialUnitTypeList.first;
                  }
                },
              ),
              const SizedBox(height: 8),
              if (dependentList.isNotEmpty)
                CustomDropDownWidget(
                  title: "Select Type",
                  initialValue: () {
                    if (selectedRequirement?["DisplayName"] == "Residential") {
                      return _selectedResidentialTypeNotifier.value;
                    } else if (selectedRequirement?["DisplayName"] ==
                        "Commercial") {
                      return _selectedCommercialTypeNotifier.value;
                    } else if (selectedRequirement?["DisplayName"] ==
                        "Commercial Leasing") {
                      return _selectedCommercialLeasingNotifier.value;
                    }
                    return dependentList.first;
                  }(),
                  dataList: dependentList,
                  onSelected: (v) {
                    if (selectedRequirement?["DisplayName"] == "Residential") {
                      _selectedResidentialTypeNotifier.value = v;
                    } else if (selectedRequirement?["DisplayName"] ==
                        "Commercial") {
                      _selectedCommercialTypeNotifier.value = v;
                    } else if (selectedRequirement?["DisplayName"] ==
                        "Commercial Leasing") {
                      _selectedCommercialLeasingNotifier.value = v;
                    }
                  },
                ),
            ],
          );
        },
      ),
      CustomMultipleSelectPopup(
        title: 'Preferred Location',
        isRequired: true,
        isMultiSelect: true,
        initialValue: _selectedLocations,
        dataList: const [],
        dataFetchCallBack: _enquiryCubit.fetchVillages,
        onSelected: (value) => _selectedLocations = value,
      ),
      CustomDropDownWidget(
        title: "Timeline",
        initialValue: _selectedTimeline ?? timelineTypeList.first,
        dataList: timelineTypeList,
        onSelected: (v) => _selectedTimeline = v,
      ),
      CustomTextField(
        title: "Area Preferred (SqFt)",
        hint: "Enter Area Preferred (SqFt)",
        textController: _areaPrefC,
      ),
      CustomDropDownWidget(
        title: "Desired Floor Band",
        initialValue: _selectedFloorBand ?? floorBrand.first,
        dataList: floorBrand,
        onSelected: (v) => _selectedFloorBand = v,
      ),
    ]);
  }

  // CUSTOMER DETAILS
  Widget _customerDetailsCard() {
    return _card("Customer Details", [
      CustomDropDownWidget(
        title: "Source Of Funding",
        initialValue: _selectedFunding ?? fundingSourceList.first,
        dataList: fundingSourceList,
        onSelected: (v) => _selectedFunding = v,
      ),
      CustomDropDownWidget(
        title: "Ethnicity",
        initialValue: _selectedEthnicity ?? ethnicityList.first,
        dataList: ethnicityList,
        onSelected: (v) => _selectedEthnicity = v,
      ),
    ]);
  }

  // ENQUIRY INFO
  Widget _enquiryInfoCard() {
    return _card("Enquiry Information", [
      CustomDropDownWidget(
        title: "Stage",
        initialValue: _selectedFinalStage ?? stageTypeList.first,
        dataList: stageTypeList,
        onSelected: (v) => _selectedFinalStage = v,
      ),
    ]);
  }

  // FOLLOWUP
  Widget _followUpCard() {
    return _card("Follow Up Details", [
      CustomDatePicker(
        title: "Enquiry Date",
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        isRequired: true,
        initialDate: _enquiryDate,
        setValue: (v) => _enquiryDate = v,
      ),
      CustomDatePicker(
        title: "Next Follow-Up Date",
        isRequired: true,
        startDate: DateTime.now(),
        initialDate: _nextFollowUpDate,
        setValue: (v) => _nextFollowUpDate = v,
        validator: (value) {
          if (value == null) return "Next Follow-Up Date is required";
          return null;
        },
      ),
    ]);
  }

  // SALES
  Widget _salesCard() {
    return _card("Sales Details", [
      ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: _selectedSaleAdvisorNotifier,
        builder: (context, selectedSaleAdvisor, child) {
          return CustomMultipleSelectPopup(
            title: 'Sales Advisor',
            isMultiSelect: false,
            initialValue: selectedSaleAdvisor,
            dataList: const [],
            dataFetchCallBack: _enquiryCubit.fetchEmployees,
            onSelected: (value) => _selectedSaleAdvisorNotifier.value = value,
          );
        },
      ),
      CustomMultipleSelectPopup(
        title: 'Sourcing Manager',
        isMultiSelect: false,
        initialValue: _selectedSourcingManager,
        dataList: const [],
        dataFetchCallBack: _enquiryCubit.fetchEmployees,
        onSelected: (value) => _selectedSourcingManager = value,
      ),
      CustomTextField(
        title: "Remarks",
        textController: _remarkC,
        hint: "Enter Remark",
        minLines: 3,
        maxLines: 3,
      ),
    ]);
  }

  // HELPER
  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(),
          ...children,
        ],
      ),
    );
  }

  // ✅ COMPLETE VERIFICATION DIALOG
  static Future<void> showCompleteVerificationDialog(
    BuildContext context, {
    required TextEditingController otpController,
    required VoidCallback onVerifyOTP,
    required VoidCallback onResendOTP,
    String? mobileNumber,
    String? module = "Enquiry",
  }) {
    return DialogHelper.showCustomDialogue(
      context,
      title: "Complete Verification",
      childContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Verify Details To Continue",
            style: AppTextStyle.ts12R(color: AppColor.grey),
          ),
          verticalSpacing(height: 24),

          // ✅ CHECKBOX STEPS
          _buildVerificationStep("Basic Details", true),
          _buildVerificationStep("Source Details", false),
          _buildVerificationStep("Property Preferences", false),
          _buildVerificationStep("Follow-up Details", true),

          verticalSpacing(height: 24),

          // ✅ OTP SECTION
          Text("Verify OTP", style: AppTextStyle.ts14M()),
          verticalSpacing(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  textController: otpController,
                  hint: "Enter OTP",
                  keyboardType: TextInputType.number,
                ),
              ),
              horizontalSpacing(width: 12),
              CustomButton(
                text: "Send OTP",
                onPressed: onResendOTP, // ✅ Uses your EnquiryCubit.sendOTP()
                titleTextStyle: AppTextStyle.ts12M(),
              ),
            ],
          ),
        ],
      ),
      bottomSection: CustomButton(
        text: "Verify & Add Enquiry", // ✅ Clear action
        onPressed: () {
          if (otpController.text.length == 4) {
            // ✅ AUTO TRIGGER ADD ENQUIRY AFTER OTP SUCCESS
            onVerifyOTP(); // Calls _submitEnquiryData()
          } else {
            showErrorMessage(
              context,
              "Error",
              "Please enter valid 6-digit OTP",
            );
          }
        },
      ),
    );
  }

  // ✅ HELPER: Verification Step Widget
  static Widget _buildVerificationStep(String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isCompleted
                        ? AppColor.primary
                        : AppColor.grey.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              // ✅ Light blue background for active step
              color:
                  isCompleted
                      ? AppColor.lightBlue.withValues(alpha: 0.2)
                      : null,
            ),
            child:
                isCompleted
                    ? Icon(Icons.check, size: 14, color: AppColor.primary)
                    : SizedBox.shrink(),
          ),
          horizontalSpacing(width: 12),
          Text(
            title,
            style: AppTextStyle.ts14M(
              color: isCompleted ? AppColor.primary : AppColor.black,
            ),
          ),
        ],
      ),
    );
  }
}
