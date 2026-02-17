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
  late EnquiryCubit _enquiryCubit;
  bool get _isEditMode => widget.enquiryModel != null;

  final _formKey = GlobalKey<FormState>();
  String? _timeInC;
  String? _timeOutC;
  final List<int> budgetOptions = [1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 25];

  // ValueNotifiers for reactive state
  final ValueNotifier<int> _budgetValueNotifier = ValueNotifier<int>(1);
  final ValueNotifier<Map<String, dynamic>?> _selectedAccommodationNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedOccupationTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedPossessionTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedTimelineNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedFloorBandNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedRequirementNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedResidentialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedCommercialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?>
  _selectedCommercialLeasingNotifier = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedFundingNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedEthnicityNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSourceNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSubSourceNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSubSubSourceNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedFinalStageNotifier =
      ValueNotifier(null);
  final ValueNotifier<List<Map<String, dynamic>>>
  _selectedChannelPartnerNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> _selectedLocationsNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> _selectedSaleAdvisorNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>>
  _selectedSourcingManagerNotifier = ValueNotifier([]);
  final ValueNotifier<DateTime?> _dateOfBirthNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _enquiryDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _nextFollowUpDateNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<List<Map<String, dynamic>>> _selectedTeamMemberNotifier =
      ValueNotifier([]);
  final ValueNotifier<String> _channelPartnerMobileNotifier = ValueNotifier('');
  late TextEditingController _uniqueKey,
      _nameC,
      _mobileC,
      _emailC,
      _ageC,
      _locationC,
      _areaPrefC,
      _budgetC,
      // NRI Fields
      _countryOfResidenceC, // ADD THIS
      _cityOfResidenceC, // ADD THIS
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
      _remarkC;
  // Static dropdown lists
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
    // _initializeDefaultValues();

    if (_isEditMode) {
      _populateForm(widget.enquiryModel!);
    } else {
      _timeInC = DateTime.now().toIso8601String().split("T")[1];
      _enquiryDateNotifier.value = DateTime.now();
    }
  }

  void _initControllers() {
    _uniqueKey = TextEditingController();
    _nameC = TextEditingController();
    _mobileC = TextEditingController();
    _emailC = TextEditingController();
    _ageC = TextEditingController();
    _locationC = TextEditingController();
    _areaPrefC = TextEditingController();
    _budgetC = TextEditingController();

    // NRI Fields
    _countryOfResidenceC = TextEditingController(); // ADD THIS
    _cityOfResidenceC = TextEditingController(); // ADD THIS

    // Channel Partner
    _channelPartnerMobileC = TextEditingController();
    _teamMemberNameC = TextEditingController();
    _teamMemberMobileC = TextEditingController();

    // Employee Reference
    _employeeName = TextEditingController();
    _employeeMobileNumber = TextEditingController();

    // Loyalty
    _existingProjectName = TextEditingController();
    _existingUnitNumber = TextEditingController();

    // Referral
    _referralName = TextEditingController();
    _referralMobile = TextEditingController();
    _referralProjectName = TextEditingController();
    _referralUnitNumber = TextEditingController();

    _remarkC = TextEditingController();
  }

  void _populateForm(EnquiryModel model) {
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
    _timeOutC = model.enquiryTimeOut;

    // DATES
    _dateOfBirthNotifier.value = model.dateOfBirth;
    _enquiryDateNotifier.value = model.enquiryDate;
    _nextFollowUpDateNotifier.value = model.nextFollowUpDate;

    // NRI FIELDS
    _countryOfResidenceC.text = model.countryOfResidence ?? '';
    _cityOfResidenceC.text = model.cityOfResidence ?? '';

    // TEAM MEMBER SELECTION
    if (model.source == "Channel Partner" &&
        model.channelPartnerName.isNotEmpty) {
      _selectedTeamMemberNotifier.value = [
        {
          "zAttributesId": model.channelPartnerTeamMemberId,
          "DisplayName": model.channelPartnerName,
          "Mobile": model.channelPartnerTeamMemberMobileNumber,
        },
      ];
    }

    _updateAge();

    /// HELPER: Find item in list by DisplayName
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

    // DROPDOWNS
    _selectedAccommodationNotifier.value = findItem(
      currentAccommodation,
      model.accommodation,
    );
    _selectedOccupationTypeNotifier.value = findItem(
      occupationType,
      model.occupationType,
    );
    _selectedPossessionTypeNotifier.value = findItem(
      possessionType,
      model.possessionType,
    );
    _selectedFloorBandNotifier.value = findItem(
      floorBrand,
      model.desiredFloorBand,
    );
    _selectedRequirementNotifier.value = findItem(
      requirementType,
      model.requirement,
    );

    // Populate dependent requirement type dropdowns
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

    _selectedFundingNotifier.value = findItem(
      fundingSourceList,
      model.sourceOfFunding,
    );
    _selectedEthnicityNotifier.value = findItem(ethnicityList, model.ethnicity);
    _selectedSourceNotifier.value = findItem(sourceTypeList, model.source);
    _selectedFinalStageNotifier.value = findItem(
      stageTypeList,
      model.finalStage,
    );
    _selectedTimelineNotifier.value = findItem(
      timelineTypeList,
      model.timeline,
    );

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
      _selectedLocationsNotifier.value =
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
      _selectedSourcingManagerNotifier.value = [
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
        _budgetValueNotifier.value = value;
      }
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Source & SubSubSource
    final source = _selectedSourceNotifier.value?["DisplayName"] ?? "";
    final subSubSource =
        _selectedSubSubSourceNotifier.value?["DisplayName"] ?? "";

    // Count selected fields (Possession, Requirement, Location, Budget)
    int selectedCount = 0;
    if ((_selectedPossessionTypeNotifier.value?["DisplayName"] ?? "")
        .trim()
        .isNotEmpty) {
      selectedCount++;
    }
    if ((_selectedRequirementNotifier.value?["DisplayName"] ?? "")
        .trim()
        .isNotEmpty) {
      selectedCount++;
    }
    if (_locationC.text.trim().isNotEmpty) selectedCount++;
    if (_budgetC.text.trim().isNotEmpty) selectedCount++;

    final timeline = _selectedTimelineNotifier.value?["DisplayName"] ?? "";

    // CustomerClassification logic including Budget
    String customerClassification;
    if (selectedCount >= 3 && timeline.contains("Within 1 Month")) {
      customerClassification = "Hot";
    } else if (selectedCount >= 2 && timeline.contains("Beyond 1 Month")) {
      customerClassification = "Warm";
    } else {
      customerClassification = "Cold";
    }

    // RequirementType from cascading dropdown
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
    // Build payload
    final payload = {
      "EnquiryId": _isEditMode ? widget.enquiryModel!.enquiryId : 0,
      if (_isEditMode) "Uniquekey": widget.enquiryModel!.uniquekey,
      "ProjectId": getProject().projectId,
      "EnquiryTimeIn": _timeInC,
      "EnquiryTimeOut": _timeOutC,
      "Name": _nameC.text.trim(),
      "MobileNumber": _mobileC.text.trim(),
      "EmailId": _emailC.text.trim(),
      "DateOfBirth": _dateOfBirthNotifier.value?.toIso8601String(),
      "Accommodation":
          _selectedAccommodationNotifier.value?["DisplayName"] ?? "",
      "OccupationType":
          _selectedOccupationTypeNotifier.value?["DisplayName"] ?? "",
      "Source": source,
      "SubSource": _selectedSubSourceNotifier.value?["DisplayName"] ?? "",
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
      "Nationality": _enquiryCubit.state.selectedNationality ?? "",
      "CountryOfResidence": _countryOfResidenceC.text.trim(),
      "CityOfResidence": _cityOfResidenceC.text.trim(),
      "CurrentLocation": _locationC.text.trim(),
      "VillageMasterId": selectedVillages,
      "PossessionType":
          _selectedPossessionTypeNotifier.value?["DisplayName"] ?? "",
      "AreaPreferred": int.tryParse(_areaPrefC.text.trim()) ?? 0,
      "DesiredFloorBand":
          _selectedFloorBandNotifier.value?["DisplayName"] ?? "",
      "Budget": _budgetC.text.trim(),
      "Requirement": _selectedRequirementNotifier.value?["DisplayName"] ?? "",
      "RequirementType": requirementTypeValue,
      "CustomerClassification": customerClassification,
      "SourceOfFunding": _selectedFundingNotifier.value?["DisplayName"] ?? "",
      "Ethnicity": _selectedEthnicityNotifier.value?["DisplayName"] ?? "",
      "FinalStage": _selectedFinalStageNotifier.value?["DisplayName"] ?? "",
      "FinalStageDetail": "",
      "EnquiryDate": _enquiryDateNotifier.value?.toIso8601String(),
      "NextFollowUpDate": _nextFollowUpDateNotifier.value?.toIso8601String(),
      "SalesAdvisorId":
          _selectedSaleAdvisorNotifier.value.isNotEmpty
              ? _selectedSaleAdvisorNotifier.value.first["zAttributesId"]
              : 0,
      "SourcingManagerId":
          _selectedSourcingManagerNotifier.value.isNotEmpty
              ? _selectedSourcingManagerNotifier.value.first["zAttributesId"]
              : 0,
      "Remark": _remarkC.text.trim(),
      "Timeline": timeline,
    };

    // Submit
    _enquiryCubit.addUpdateEnquiry(
      context: context,
      body: payload,
      index: _isEditMode ? widget.index : null,
    );
  }

  String get selectedVillages => _selectedLocationsNotifier.value
      .map((village) => village["zAttributesId"])
      .join(",");

  void _updateAge() {
    if (_dateOfBirthNotifier.value != null) {
      final today = DateTime.now();
      int age = today.year - _dateOfBirthNotifier.value!.year;
      if (today.month < _dateOfBirthNotifier.value!.month ||
          (today.month == _dateOfBirthNotifier.value!.month &&
              today.day < _dateOfBirthNotifier.value!.day)) {
        age--;
      }
      _ageC.text = age.toString();
    }
  }

  @override
  void dispose() {
    // Text Controllers
    _uniqueKey.dispose();
    _nameC.dispose();
    _mobileC.dispose();
    _emailC.dispose();
    _ageC.dispose();
    _locationC.dispose();
    _areaPrefC.dispose();
    _budgetC.dispose();

    // Channel Partner Controllers
    _channelPartnerMobileC.dispose();
    _teamMemberNameC.dispose();
    _teamMemberMobileC.dispose();

    // Employee Reference Controllers
    _employeeName.dispose();
    _employeeMobileNumber.dispose();

    // Loyalty Controllers
    _existingProjectName.dispose();
    _existingUnitNumber.dispose();

    // Referral Controllers
    _referralName.dispose();
    _referralMobile.dispose();
    _referralProjectName.dispose();
    _referralUnitNumber.dispose();

    // Other Controllers
    _remarkC.dispose();

    // Value Notifiers - Budget & Dates
    _budgetValueNotifier.dispose();
    _dateOfBirthNotifier.dispose();
    _enquiryDateNotifier.dispose();
    _nextFollowUpDateNotifier.dispose();

    // Value Notifiers - Dropdowns
    _selectedAccommodationNotifier.dispose();
    _selectedOccupationTypeNotifier.dispose();
    _selectedPossessionTypeNotifier.dispose();
    _selectedTimelineNotifier.dispose();
    _selectedFloorBandNotifier.dispose();
    _selectedRequirementNotifier.dispose();
    _selectedResidentialTypeNotifier.dispose();
    _selectedCommercialTypeNotifier.dispose();
    _selectedCommercialLeasingNotifier.dispose();
    _selectedFundingNotifier.dispose();
    _selectedEthnicityNotifier.dispose();
    _selectedFinalStageNotifier.dispose();

    // NRI Fields
    _countryOfResidenceC.dispose();
    _cityOfResidenceC.dispose();

    // Value Notifiers - Source Related
    _selectedSourceNotifier.dispose();
    _selectedSubSourceNotifier.dispose();
    _selectedSubSubSourceNotifier.dispose();
    _selectedTeamMemberNotifier.dispose();
    _channelPartnerMobileNotifier.dispose();

    // Value Notifiers - Multi-Select
    _selectedLocationsNotifier.dispose();
    _selectedSaleAdvisorNotifier.dispose();
    _selectedSourcingManagerNotifier.dispose();

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
          padding: EdgeInsets.all(16),
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
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedOccupationTypeNotifier,
            builder: (context, selectedOccupationType, child) {
              return CustomDropDownWidget(
                title: "Occupation Type",
                isRequired: true,
                initialValue: selectedOccupationType ?? occupationType.first,
                dataList: occupationType,
                onSelected: (v) => _selectedOccupationTypeNotifier.value = v,
                validator: (val) {
                  if (val?['zAttributesId'] == -1) {
                    return "Please select occupation type";
                  }
                  return null;
                },
              );
            },
          ),
          Text("Nationality", style: AppTextStyle.ts14R()),
          Row(
            children: [
              Radio<String>(
                value: state.options[0],
                groupValue: state.selectedNationality,
                onChanged: (value) {
                  _enquiryCubit.onSelectedOptionChanged(value!);
                  // Clear NRI fields when switching to Indian
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
                groupValue: state.selectedNationality,
                onChanged: (value) {
                  _enquiryCubit.onSelectedOptionChanged(value!);
                },
              ),
              Text("NRI", style: AppTextStyle.ts14R()),
            ],
          ),

          // NRI-specific fields
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

  Widget _sourceCard() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: _selectedSourceNotifier,
      builder: (context, selectedSource, child) {
        final bool isChannelPartner =
            selectedSource?['zAttributesId'] ==
            sourceTypeList[1]['zAttributesId'];
        final bool isDirectWalking =
            selectedSource?['zAttributesId'] ==
            sourceTypeList[2]['zAttributesId'];

        return ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: _selectedSubSourceNotifier,
          builder: (context, selectedSubSource, child) {
            final int subSourceId = selectedSubSource?['zAttributesId'] ?? -1;

            return _card("Source", [
              // Source Dropdown
              CustomDropDownWidget(
                title: "Source",
                isRequired: true,
                initialValue: selectedSource ?? sourceTypeList.first,
                dataList: sourceTypeList,
                onSelected: (v) {
                  _selectedSourceNotifier.value = v;
                  // Reset SubSource when Source changes
                  _selectedSubSourceNotifier.value =
                      v['zAttributesId'] == sourceTypeList[1]['zAttributesId']
                          ? channelPartnerActivityList.first
                          : directWalkingSubSourceList.first;
                  _selectedSubSubSourceNotifier.value = subSubSourceList.first;
                  // Clear channel partner fields
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

              // Sub Source Dropdown (shown when Source is selected)
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
                    // Clear channel partner fields when sub source changes
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

              // Channel Partner Mobile Number Search Field
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

                    if (partner == null) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 10),
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
              // Show Team Member fields only when valid 10-digit mobile is entered
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
                          // Team Member Dropdown
                          CustomMultipleSelectPopup(
                            title: 'Team Member',
                            isRequired: false,
                            isMultiSelect: false,
                            initialValue: selectedTeamMember,
                            dataList: const [],
                            dataFetchCallBack: _enquiryCubit.fetchEmployees,
                            onSelected: (value) {
                              // Clear text fields when dropdown changes
                              _teamMemberNameC.clear();
                              _teamMemberMobileC.clear();

                              _selectedTeamMemberNotifier.value = value;

                              // Auto-populate name and mobile if available in the selected data
                              if (value.isNotEmpty) {
                                final member = value.first;
                                _teamMemberNameC.text =
                                    member['DisplayName'] ?? '';
                                _teamMemberMobileC.text =
                                    member['MobileNo'] ?? '';
                              }
                            },
                          ),

                          // Show text fields only if NO team member is selected from dropdown
                          if (!hasTeamMemberSelected) ...[
                            // Team Member Name
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

                            // Team Member Mobile Number
                            CustomTextField(
                              title: "Team Member Mobile Number",
                              hint: "Enter Mobile Number",
                              textController: _teamMemberMobileC,
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

              // ========== DIRECT WALKING SUB-SOURCE SPECIFIC FIELDS ==========

              // Advertisement (subSourceId == 1) → show SubSubSource dropdown
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
                      onSelected: (v) {
                        _selectedSubSubSourceNotifier.value = v;
                      },
                      validator: (value) {
                        if (value?['zAttributesId'] == -1) {
                          return "Sub Sub Source is required";
                        }
                        return null;
                      },
                    );
                  },
                ),

              // Employee Reference (subSourceId == 3) → 2 fields
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

              // Loyalty (subSourceId == 5) → 2 fields
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
                  isRequired: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Existing unit number is required";
                    }
                    return null;
                  },
                ),
              ],

              // Reference (subSourceId == 10) → 4 fields
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

  Widget _propertyPrefCard() {
    return ValueListenableBuilder<int>(
      valueListenable: _budgetValueNotifier,
      builder: (context, budgetValue, child) {
        return _card("Property Preferences", [
          const Text("Budget (In Cr)"),
          SizedBox(
            width: double.infinity,
            child: SfSlider(
              min: 0,
              max: (budgetOptions.length - 1).toDouble(),
              value: budgetOptions.indexOf(budgetValue).toDouble(),
              interval: 1,
              showTicks: false,
              showLabels: true,
              enableTooltip: false,
              activeColor: AppColor.primary,
              inactiveColor: AppColor.primary.withOpacity(0.25),
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
                _budgetValueNotifier.value = val;
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
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedPossessionTypeNotifier,
            builder: (context, selectedPossessionType, child) {
              return CustomDropDownWidget(
                title: "Possession Type",
                initialValue: selectedPossessionType ?? possessionType.first,
                dataList: possessionType,
                onSelected: (v) => _selectedPossessionTypeNotifier.value = v,
              );
            },
          ),
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedRequirementNotifier,
            builder: (context, selectedRequirement, child) {
              // Determine which secondary dropdown to show based on requirement selection
              List<Map<String, dynamic>> dependentList = [];

              if (selectedRequirement != null) {
                String requirementValue =
                    selectedRequirement["DisplayName"] ?? "";

                if (requirementValue == "Residential") {
                  dependentList = residentialType;
                } else if (requirementValue == "Commercial") {
                  dependentList = commercialUnitTypeList;
                } else if (requirementValue == "Commercial Leasing") {
                  dependentList = commercialUnitTypeList;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Requirement Dropdown
                  CustomDropDownWidget(
                    title: "Requirement",
                    initialValue: selectedRequirement ?? requirementType.first,
                    dataList: requirementType,
                    onSelected: (v) {
                      _selectedRequirementNotifier.value = v;

                      // Reset dependent selection when main requirement changes
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

                  // Dependent Dropdown (only shows if a dependent list exists)
                  if (dependentList.isNotEmpty)
                    CustomDropDownWidget(
                      title: "Select Type",
                      initialValue: () {
                        if (selectedRequirement?["DisplayName"] ==
                            "Residential") {
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
                        if (selectedRequirement?["DisplayName"] ==
                            "Residential") {
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
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _selectedLocationsNotifier,
            builder: (context, selectedLocations, child) {
              return CustomMultipleSelectPopup(
                title: 'Preferred Location',
                isRequired: true,
                isMultiSelect: true,
                initialValue: selectedLocations,
                dataList: const [],
                dataFetchCallBack: _enquiryCubit.fetchVillages,
                onSelected: (value) {
                  _selectedLocationsNotifier.value = value;
                },
              );
            },
          ),
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedTimelineNotifier,
            builder: (context, selectedTimeline, child) {
              return CustomDropDownWidget(
                title: "Timeline",
                initialValue: selectedTimeline ?? timelineTypeList.first,
                dataList: timelineTypeList,
                onSelected: (v) => _selectedTimelineNotifier.value = v,
              );
            },
          ),
          CustomTextField(
            title: "Area Preferred (SqFt)",
            hint: "Enter Area Preferred (SqFt)",
            textController: _areaPrefC,
          ),
        ]);
      },
    );
  }

  Widget _customerDetailsCard() {
    return _card("Customer Details", [
      ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: _selectedFundingNotifier,
        builder: (context, selectedFunding, child) {
          return CustomDropDownWidget(
            title: "Source Of Funding",
            initialValue: selectedFunding ?? fundingSourceList.first,
            dataList: fundingSourceList,
            onSelected: (v) => _selectedFundingNotifier.value = v,
          );
        },
      ),
      ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: _selectedEthnicityNotifier,
        builder: (context, selectedEthnicity, child) {
          return CustomDropDownWidget(
            title: "Ethnicity",
            initialValue: selectedEthnicity ?? ethnicityList.first,
            dataList: ethnicityList,
            onSelected: (v) => _selectedEthnicityNotifier.value = v,
          );
        },
      ),
    ]);
  }

  Widget _enquiryInfoCard() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: _selectedFinalStageNotifier,
      builder: (context, selectedFinalStage, child) {
        return _card("Enquiry Information", [
          CustomDropDownWidget(
            title: "Stage",
            initialValue: selectedFinalStage ?? stageTypeList.first,
            dataList: stageTypeList,
            onSelected: (v) => _selectedFinalStageNotifier.value = v,
          ),
        ]);
      },
    );
  }

  Widget _followUpCard() {
    return _card("Follow Up Details", [
      ValueListenableBuilder<DateTime?>(
        valueListenable: _enquiryDateNotifier,
        builder: (context, enquiryDate, child) {
          return CustomDatePicker(
            title: "Enquiry Date",
            isRequired: true,
            initialDate: enquiryDate,
            setValue: (v) => _enquiryDateNotifier.value = v,
          );
        },
      ),
      ValueListenableBuilder<DateTime?>(
        valueListenable: _nextFollowUpDateNotifier,
        builder: (context, nextFollowUpDate, child) {
          return CustomDatePicker(
            title: "Next Follow-Up Date",
            isRequired: true,
            initialDate: nextFollowUpDate,
            setValue: (v) => _nextFollowUpDateNotifier.value = v,
            validator: (value) {
              if (value == null) return "Next Follow-Up Date is required";
              return null;
            },
          );
        },
      ),
    ]);
  }

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
            onSelected: (value) {
              _selectedSaleAdvisorNotifier.value = value;
            },
          );
        },
      ),
      ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: _selectedSourcingManagerNotifier,
        builder: (context, selectedSourcingManager, child) {
          return CustomMultipleSelectPopup(
            title: 'Sourcing Manager',
            isMultiSelect: false,
            initialValue: selectedSourcingManager,
            dataList: const [],
            dataFetchCallBack: _enquiryCubit.fetchEmployees,
            onSelected: (value) {
              _selectedSourcingManagerNotifier.value = value;
            },
          );
        },
      ),
      CustomTimePicker(
        title: "Customer Time Out",
        initialTime: parseTimeOfDayFromHHmm(_timeOutC),
        setValue: (val) => _timeOutC = formatTimeOfDayHHmm(val),
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
}
