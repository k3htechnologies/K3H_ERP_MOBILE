// SAME IMPORTS (unchanged)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/data/repository/inventory.repository.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/custom_verification_dialog.dart';
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
  late LoginCubit _loginCubit;

  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
  final InventoryRepository _inventoryRepository =
      serviceLocator<InventoryRepository>();
  final ChannelPartnerRepository _channelPartnerRepository =
      serviceLocator<ChannelPartnerRepository>();

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
  late ValueNotifier<int> _budgetValueNotifier;
  // VALUE NOTIFIERS FOR REACTIVE STATE
  final ValueNotifier<Map<String, dynamic>?> _selectedAccommodationNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedRequirementNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedResidentialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedCommercialTypeNotifier =
      ValueNotifier(null);
  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedEmployeeNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedProjectNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedFlatNotifier;
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
  final ValueNotifier<Map<String, dynamic>?> _selectedFinalStage =
      ValueNotifier(null);
  final ValueNotifier<bool> _hasManualEntryNotifier = ValueNotifier(false);
  // DROPDOWN VARIABLES
  Map<String, dynamic>? _selectedOccupationType;
  Map<String, dynamic>? _selectedPossessionType;
  Map<String, dynamic>? _selectedTimeline;
  Map<String, dynamic>? _selectedFloorBand;
  Map<String, dynamic>? _selectedFunding;
  Map<String, dynamic>? _selectedEthnicity;
  Map<String, dynamic>? _selectedFinalStageDetail;
  List<Map<String, dynamic>> _selectedLocations = [];
  List<Map<String, dynamic>> _selectedSourcingManager = [];
  late UserModel user;

  late TextEditingController _nameC,
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
      _remarkC,
      otpController;
  late ProjectModel _project;

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
    {'zAttributesId': -1, 'DisplayName': 'Select Residential Type'},
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
    {'zAttributesId': -1, 'DisplayName': 'Select Commercial Type'},
    {'zAttributesId': 1, 'DisplayName': 'OFFICE'},
    {'zAttributesId': 2, 'DisplayName': 'SHOP'},
  ];
  final List<Map<String, dynamic>> commercialLeasingTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Commercial Leasing Type'},
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
    {'zAttributesId': 3, 'DisplayName': 'Sale Of Property'},
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
    {'zAttributesId': 1, 'DisplayName': 'Booking Done'},
    {'zAttributesId': 2, 'DisplayName': 'Blocked'},
    {'zAttributesId': 3, 'DisplayName': 'Cancelled'},
    {'zAttributesId': 4, 'DisplayName': 'Negotiation'},
    {'zAttributesId': 5, 'DisplayName': 'Lost'},
    {'zAttributesId': 6, 'DisplayName': 'Retention'},
    {'zAttributesId': 7, 'DisplayName': 'Re - Visit Scheduled'},
    {'zAttributesId': 8, 'DisplayName': 'Re - Visit Proposed'},
    {'zAttributesId': 9, 'DisplayName': 'Site Visit'},
    {'zAttributesId': 10, 'DisplayName': 'Unit Selection / Blocked'},
  ];

  final List<Map<String, dynamic>> finalStageDetailsList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Final Stage Detail'},
    {'zAttributesId': 1, 'DisplayName': 'Purchased with competition'},
    {'zAttributesId': 2, 'DisplayName': 'Purchased somewhere else'},
    {'zAttributesId': 3, 'DisplayName': 'Not connected calls >7'},
    {'zAttributesId': 4, 'DisplayName': 'Low Budget'},
    {'zAttributesId': 5, 'DisplayName': 'Ready Possession'},
    {'zAttributesId': 6, 'DisplayName': 'Location'},
    {'zAttributesId': 7, 'DisplayName': 'Product Issue'},
    {'zAttributesId': 8, 'DisplayName': 'Pricing Issue'},
    {'zAttributesId': 9, 'DisplayName': 'Payment Issue'},
    {'zAttributesId': 10, 'DisplayName': 'Loan Issue'},
    {'zAttributesId': 11, 'DisplayName': 'Inventory Issue'},
    {'zAttributesId': 12, 'DisplayName': 'General Enquiry'},
    {'zAttributesId': 13, 'DisplayName': 'Wrong Number'},
    {'zAttributesId': 14, 'DisplayName': 'Dropped The Idea Of Buying'},
    {'zAttributesId': 15, 'DisplayName': 'Booked Somewhere Else'},
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
  final closedStatuses = ['booking done', 'cancelled', 'lost'];
  @override
  void initState() {
    super.initState();
    _enquiryCubit = context.read<EnquiryCubit>();
    _loginCubit = context.read<LoginCubit>();
    _initControllers();
    _enquiryCubit.clearChannelPartner();
    _budgetValueNotifier = ValueNotifier<int>(1);
    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedProjectNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedFlatNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    getCurrentUser();
    _project = getProject();
    if (_isEditMode) {
      _populateForm(widget.enquiryModel!);
    } else {
      _timeInC = DateTime.now().toIso8601String().split("T")[1].split(".")[0];
      _enquiryDate = DateTime.now();
      _budgetC.text = ">1";
    }
  }

  @override
  void dispose() {
    // TEXT CONTROLLERS
    _nameC.dispose();
    _mobileC.dispose();
    _emailC.dispose();
    _ageC.dispose();
    _locationC.dispose();
    _areaPrefC.dispose();
    _budgetC.dispose();
    _countryOfResidenceC.dispose();
    _cityOfResidenceC.dispose();
    _budgetValueNotifier.dispose();
    // CHANNEL PARTNER CONTROLLERS
    _channelPartnerMobileC.dispose();
    _teamMemberNameC.dispose();
    _teamMemberMobileC.dispose();

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
    _selectedEmployeeNotifier.dispose();

    super.dispose();
  }

  // INITIALIZED TEXT EDITING CONTROLLERS
  void _initControllers() {
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
    _remarkC = TextEditingController();
    otpController = TextEditingController();
  }

  Future getCurrentUser() async {
    var userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? "",
    );
    user = UserModel.fromJson(userJson);
  }

  // PREFILL
  void _populateForm(EnquiryModel model) async {
    // TEXT CONTROLLERS
    _nameC.text = model.name;
    _mobileC.text = model.mobileNumber;
    _emailC.text = model.emailId;
    _locationC.text = model.currentLocation;
    _areaPrefC.text =
        model.areaPreferred == 0 ? "" : model.areaPreferred.toStringAsFixed(0);
    _budgetC.text = model.budget;
    _remarkC.text = model.remark;

    // SOURCE BASED TEXT FIELDS
    _channelPartnerMobileC.text = model.channelPartnerMobileNumber;
    _channelPartnerMobileNotifier.value = model.channelPartnerMobileNumber;

    // TIME
    _timeInC = model.enquiryTimeIn;

    // DATES
    _dateOfBirthNotifier.value = model.dateOfBirth;
    _enquiryDate =
        (model.enquiryDate != null && model.enquiryDate!.year != 1970)
            ? model.enquiryDate
            : null;

    _nextFollowUpDate =
        (model.nextFollowUpDate != null && model.nextFollowUpDate!.year != 1970)
            ? model.nextFollowUpDate
            : null;

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

    // PREFILL PROJECT
    if (model.loyaltyProjectId != 0 &&
        model.loyaltyExistingProjectName.isNotEmpty) {
      _selectedProjectNotifier.value = [
        {
          "zAttributesId": model.loyaltyProjectId,
          "DisplayName": model.loyaltyExistingProjectName,
        },
      ];
    }

    if (model.referelProjectId != 0 && model.referelProjectName.isNotEmpty) {
      _selectedProjectNotifier.value = [
        {
          "zAttributesId": model.referelProjectId,
          "DisplayName": model.referelProjectName,
        },
      ];
    }

    // PREFILL FLAT
    if (model.loyaltyInventoryFlatId != 0 &&
        model.loyaltyExistingUnitNumber.isNotEmpty) {
      _selectedFlatNotifier.value = [
        {
          "zAttributesId": model.loyaltyInventoryFlatId,
          "DisplayName": model.loyaltyExistingUnitNumber,
        },
      ];
    }
    if (model.referelInventoryFlatId != 0 &&
        model.referelUnitNumber.isNotEmpty) {
      _selectedFlatNotifier.value = [
        {
          "zAttributesId": model.referelInventoryFlatId,
          "DisplayName": model.referelUnitNumber,
        },
      ];
    }

    // DROPDOWNS - PLAIN VARIABLES
    _selectedOccupationType = findItem(occupationType, model.occupationType);
    _selectedPossessionType = findItem(possessionType, model.possessionType);
    _selectedFloorBand = findItem(floorBrand, model.desiredFloorBand);
    _selectedFunding = findItem(fundingSourceList, model.sourceOfFunding);
    _selectedEthnicity = findItem(ethnicityList, model.ethnicity);
    _selectedFinalStage.value = findItem(stageTypeList, model.finalStage);
    _selectedFinalStageDetail = findItem(
      finalStageDetailsList,
      model.finalStageDetail,
    );
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
        commercialLeasingTypeList,
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
        final member = await fetchChannelPartnerTeamMembers(
          1,
          value: model.channelPartnerTeamMemberId.toString(),
        );

        if (!mounted) return;

        final items = member["itemList"] as List<Map<String, dynamic>>;

        if (items.isNotEmpty) {
          _selectedTeamMemberNotifier.value = [items.first];
        }

        _hasManualEntryNotifier.value = false;
      } else if (model.channelPartnerTeamMemberMobileNumber.isNotEmpty ||
          model.channelPartnerTeamMemberName.isNotEmpty) {
        // NO ID BUT HAS NAME/MOBILE
        _selectedTeamMemberNotifier.value = [];
        _hasManualEntryNotifier.value = true;
        _teamMemberNameC.text = model.channelPartnerTeamMemberName;
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
    if (model.villageMasterId != null &&
        model.villageMasterId.toString().isNotEmpty) {
      final villageIdsRaw = model.villageMasterId.toString();
      final villageNamesRaw = model.villageName;

      final villageIds =
          villageIdsRaw
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .map((e) => int.parse(e))
              .toList();

      final villageNames =
          villageNamesRaw
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final maxLength =
          villageIds.length < villageNames.length
              ? villageIds.length
              : villageNames.length;

      _selectedLocations = List.generate(maxLength, (index) {
        return {
          "zAttributesId": villageIds[index],
          "DisplayName": villageNames[index],
          "VillageName": villageNames[index],
        };
      });
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
        _budgetValueNotifier.value = value;
      }
    }
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // VERIFY OTP ONLY IN FIRST ONBOARDING STAGE
    if (!_isEditMode) {
      //  SEND OTP FIRST
      _loginCubit.sendOTPModuleBased(
        context: context,
        mobileNumber: _mobileC.text.trim(),
        module: "ENQUIRY",
      );
      bool isEnquiryCompleted =
          _nameC.text.isNotEmpty &&
          _mobileC.text.isNotEmpty &&
          getDisplayOrEmpty(_selectedAccommodationNotifier.value).isNotEmpty &&
          getDisplayOrEmpty(_selectedOccupationType).isNotEmpty;

      bool isSourceCompleted =
          getDisplayOrEmpty(_selectedSourceNotifier.value).isNotEmpty;
      bool isPropertyCompleted =
          _budgetC.text.isNotEmpty &&
          getDisplayOrEmpty(_selectedRequirementNotifier.value).isNotEmpty &&
          getDisplayOrEmpty(_selectedPossessionType).isNotEmpty &&
          getDisplayOrEmpty(_selectedRequirementNotifier.value).isNotEmpty &&
          _areaPrefC.text.isNotEmpty &&
          getDisplayOrEmpty(_selectedFloorBand).isNotEmpty;

      bool isCustomerCompleted =
          getDisplayOrEmpty(_selectedFunding).isNotEmpty &&
          getDisplayOrEmpty(_selectedEthnicity).isNotEmpty;

      bool isFollowUpCompleted = _nextFollowUpDate != null;
      //  THEN SHOW VERIFICATION DIALOG
      showCompleteVerificationDialog(
        context,
        otpController: otpController,
        verificationSteps: {
          "Enquiry Details": isEnquiryCompleted,
          "Source Details": isSourceCompleted,
          "Property Preferences": isPropertyCompleted,
          "Customer Details": isCustomerCompleted,
          "Follow-up Details": isFollowUpCompleted,
        },
        onVerifyOTP: () {
          _submitEnquiryData();
        },
      );
    } else {
      _submitEnquiryData();
    }
  }

  void _submitEnquiryData() async {
    // SOURCE & SUB SUB SOURCE
    final source = _selectedSourceNotifier.value?["DisplayName"] ?? "";
    final subSubSource =
        source.trim().toLowerCase() == "channelpartner"
            ? (_selectedSubSubSourceNotifier.value?["zAttributesId"] ?? "")
            : getDisplayOrEmptySubSub(_selectedSubSubSourceNotifier.value);

    // CUSTOMER CLASSIFICATION LOGIC
    int selectedCount = 0;
    if ((_selectedPossessionType?["DisplayName"] ?? "").trim().isNotEmpty) {
      selectedCount++;
    }
    if ((_selectedRequirementNotifier.value?["DisplayName"] ?? "")
        .trim()
        .isNotEmpty) {
      selectedCount++;
    }
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
      if (_selectedProjectNotifier.value.isNotEmpty)
        "ReferelProjectId":
            _selectedProjectNotifier.value.first["zAttributesId"],
      if (_selectedFlatNotifier.value.isNotEmpty)
        "ReferelInventoryFlatId":
            _selectedFlatNotifier.value.first["zAttributesId"],
      if (_selectedProjectNotifier.value.isNotEmpty)
        "LoyaltyProjectId":
            _selectedProjectNotifier.value.first["zAttributesId"],
      if (_selectedFlatNotifier.value.isNotEmpty)
        "LoyaltyInventoryFlatId":
            _selectedFlatNotifier.value.first["zAttributesId"],
      if (_selectedEmployeeNotifier.value.isNotEmpty)
        "EmployeeReferenceEmployeeId":
            _selectedEmployeeNotifier.value.first["zAttributesId"],
      if (_selectedTeamMemberNotifier.value.isNotEmpty)
        "ChannelPartnerTeamMemberId":
            _selectedTeamMemberNotifier.value.isNotEmpty
                ? _selectedTeamMemberNotifier.value.first["zAttributesId"]
                : 0,
      if (_selectedTeamMemberNotifier.value.isEmpty)
        "ChannelPartnerTeamMemberName": _teamMemberNameC.text.trim(),
      if (_selectedTeamMemberNotifier.value.isEmpty)
        "ChannelPartnerTeamMemberMobileNumber": _teamMemberMobileC.text.trim(),
      "Nationality": _enquiryCubit.state.selectedNationality,
      "CountryOfResidence": _countryOfResidenceC.text.trim(),
      "CityOfResidence": _cityOfResidenceC.text.trim(),
      "CurrentLocation": _locationC.text.trim(),
      "VillageMasterId": selectedVillages,
      "PossessionType": getDisplayOrEmpty(_selectedPossessionType),
      "AreaPreferred": double.tryParse(_areaPrefC.text.trim()) ?? 0,
      "DesiredFloorBand": getDisplayOrEmpty(_selectedFloorBand),
      "Budget": _budgetC.text.trim(),
      "Requirement": getDisplayOrEmpty(_selectedRequirementNotifier.value),
      "RequirementType": requirementTypeValue,
      "CustomerClassification": customerClassification,
      "SourceOfFunding": getDisplayOrEmpty(_selectedFunding),
      "Ethnicity": getDisplayOrEmpty(_selectedEthnicity),
      "FinalStage": getDisplayOrEmpty(_selectedFinalStage.value),
      "FinalStageDetail": getDisplayOrEmpty(_selectedFinalStageDetail),
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

    //  SUBMIT ENQUIRY AFTER OTP VERIFICATION
    await _enquiryCubit.addUpdateEnquiry(
      context: context,
      body: payload,
      projectId: _project.projectId,
      index: _isEditMode ? widget.index : null,
    );
  }

  String getDisplayOrEmpty(Map<String, dynamic>? item) {
    if (item == null) return "";
    if (item["zAttributesId"] == -1) return "";
    return item["DisplayName"] ?? "";
  }

  String getDisplayOrEmptySubSub(Map<String, dynamic>? item) {
    if (item == null) return "";
    if (item["zAttributesId"] == -1) return "";
    return item["zAttributesId"].toString();
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

  // FETCH EMPLOYEE
  Future<Map<String, dynamic>> _fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"EmployeeName": value, "isCheckPermission": false}
              : {"isCheckPermission": false},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees = response['data'] as List<UserModel>;

        return {
          "itemList":
              employees.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
                  "department": employee.department,
                  "designation": employee.designation,
                  "branch": employee.branch,
                  "reportingPerson": employee.reportPersonName,
                  "email": employee.emailId,
                  "personalNumber": employee.personalMobileNumber,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  //  FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"ProjectName": value, "isCheckPermission": false}
              : {"isCheckPermission": false},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project = response['data'] as List<ProjectModel>;

        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.projectId,
                  "DisplayName": pr.projectName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  //  FETCH PROJECTS
  Future<Map<String, dynamic>> fetchChannelPartnerTeamMembers(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _channelPartnerRepository.getChannelPartnerList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {
                "ChannelPartnerId": value,
                "isCheckPermission": false,
                "CompanyName":
                    _isEditMode
                        ? widget.enquiryModel!.channelPartnerCompany
                        : _enquiryCubit.state.channelPartnerModel!.companyName,
              }
              : {
                "isCheckPermission": false,
                "CompanyName":
                    _isEditMode
                        ? widget.enquiryModel!.channelPartnerCompany
                        : _enquiryCubit.state.channelPartnerModel!.companyName,
              },
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final channelPartners = response['data'] as List<ChannelPartnerModel>;

        return {
          "itemList":
              channelPartners.map((cp) {
                return {
                  "zAttributesId": cp.channelPartnerId,
                  "DisplayName": cp.name,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH FlATS BY PROjECT ID
  Future<Map<String, dynamic>> _fetchFlatsByProjectId(
    int pageNumber, {
    required int projectId,
  }) async {
    final result = await _inventoryRepository.getPaginatedFlats(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: projectId,
      queryParams: {"FlatStatus": "booked"},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final flats = response['data'] as List<FlatModel>;

        return {
          "itemList":
              flats.map((flat) {
                return {
                  "zAttributesId": flat.inventoryFlatId,
                  "DisplayName": flat.flat,
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
        screenTitle: "Enquiry",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Enquiry" : "Add Enquiry",
                style: AppTextStyle.ts14M(),
              ),
              _basicCard(),
              _sourceCard(),
              _addressCard(),
              if (user.designation.toLowerCase() != 'GRE'.toLowerCase())
                _propertyPrefCard(),
              if (user.designation.toLowerCase() != 'GRE'.toLowerCase())
                _customerDetailsCard(),
              if (user.designation.toLowerCase() != 'GRE'.toLowerCase())
                _enquiryInfoCard(),
              _followUpCard(),
              if (user.designation.toLowerCase() != 'GRE'.toLowerCase())
                _salesCard(),
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
        return _card("Enquiry Details", [
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
            keyboardType: TextInputType.phone,
            isRequired: true,
            readOnly: _isEditMode,
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
                initialDate: dateOfBirth,
                validator: (value) {
                  if (value == null) return null;
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
    return BlocBuilder<EnquiryCubit, EnquiryState>(
      builder: (context, state) {
        return ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: _selectedSourceNotifier,
          builder: (context, selectedSource, child) {
            final bool isChannelPartner = selectedSource?['zAttributesId'] == 1;
            final bool isDirectWalking = selectedSource?['zAttributesId'] == 2;

            return ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: _selectedSubSourceNotifier,
              builder: (context, selectedSubSource, child) {
                final int subSourceId =
                    selectedSubSource?['zAttributesId'] ?? -1;

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
                      _selectedSubSubSourceNotifier.value =
                          subSubSourceList.first;
                      _channelPartnerMobileC.clear();
                      _channelPartnerMobileNotifier.value = '';
                      _selectedTeamMemberNotifier.value = [];
                      _hasManualEntryNotifier.value = false;
                      _teamMemberNameC.clear();
                      _teamMemberMobileC.clear();
                      _enquiryCubit.clearChannelPartner();
                      _selectedProjectNotifier.value = [];
                      _selectedFlatNotifier.value = [];
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
                        _selectedProjectNotifier.value.clear();
                        _selectedProjectNotifier.value.clear();
                        _selectedFlatNotifier.value.clear();
                        _selectedEmployeeNotifier.value.clear();
                        if (isChannelPartner) {
                          _channelPartnerMobileC.clear();
                          _channelPartnerMobileNotifier.value = '';
                          _selectedTeamMemberNotifier.value = [];
                          _hasManualEntryNotifier.value = false;
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

                  if (isChannelPartner) ...[
                    CustomTextField(
                      title: "Channel Partner",
                      hint: "Search by Channel Partner Mobile No.",
                      textController: _channelPartnerMobileC,
                      keyboardType: TextInputType.phone,
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
                          _hasManualEntryNotifier.value = false;
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
                    ValueListenableBuilder<String>(
                      valueListenable: _channelPartnerMobileNotifier,
                      builder: (context, mobile, _) {
                        return BlocBuilder<EnquiryCubit, EnquiryState>(
                          builder: (context, state) {
                            final partner = state.channelPartnerModel;

                            final bool hasEnteredMobile = mobile.length == 10;

                            //  NO PARTNER FOUND
                            if (hasEnteredMobile &&
                                partner == null &&
                                state.isFetchingChannelPartners == false) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColor.lightRed,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    width: 0.5,
                                    color: AppColor.red,
                                  ),
                                ),
                                child: Text(
                                  "No Channel Partner found for this mobile number",
                                  style: AppTextStyle.ts14R(
                                    color: AppColor.red,
                                  ),
                                ),
                              );
                            }

                            //  PARTNER FOUND
                            if (partner != null) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColor.lightBlue,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    width: 0.5,
                                    color: AppColor.primary,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                            }

                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  ],

                  (state.channelPartnerModel == null)
                      ? SizedBox.shrink()
                      : ValueListenableBuilder<String>(
                        valueListenable: _channelPartnerMobileNotifier,
                        builder: (context, mobileValue, child) {
                          if (!isChannelPartner ||
                              subSourceId == -1 ||
                              mobileValue.length != 10) {
                            return const SizedBox.shrink();
                          }
                          return ValueListenableBuilder<
                            List<Map<String, dynamic>>
                          >(
                            valueListenable: _selectedTeamMemberNotifier,
                            builder: (context, selectedTeamMember, child) {
                              final bool hasTeamMemberSelected =
                                  selectedTeamMember.isNotEmpty;

                              return Column(
                                children: [
                                  ValueListenableBuilder(
                                    valueListenable: _hasManualEntryNotifier,
                                    builder: (context, value, child) {
                                      return Visibility(
                                        visible: !value,
                                        child: CustomMultipleSelectPopup(
                                          title: 'Team Member',
                                          isRequired: false,
                                          isMultiSelect: false,
                                          initialValue: selectedTeamMember,
                                          dataList: const [],
                                          dataFetchCallBack:
                                              fetchChannelPartnerTeamMembers,
                                          onSelected: (value) {
                                            _teamMemberNameC.clear();
                                            _teamMemberMobileC.clear();
                                            _selectedTeamMemberNotifier.value =
                                                value;
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                  /// TEXTFIELDS (hide if dropdown selected)
                                  if (!hasTeamMemberSelected) ...[
                                    CustomTextField(
                                      title: "Team Member Name",
                                      hint: "Enter Team Member Name",
                                      textController: _teamMemberNameC,
                                      isRequired: true,
                                      onChangeFunction: (_) {
                                        _selectedTeamMemberNotifier.value = [];
                                        _hasManualEntryNotifier.value =
                                            _teamMemberNameC.text
                                                .trim()
                                                .isNotEmpty ||
                                            _teamMemberMobileC.text
                                                .trim()
                                                .isNotEmpty;
                                      },
                                      validator: (val) {
                                        if (_teamMemberMobileC.text.isEmpty &&
                                            (val == null ||
                                                val.trim().isEmpty)) {
                                          return "Team Member name is required";
                                        }
                                        return null;
                                      },
                                    ),

                                    CustomTextField(
                                      title: "Team Member Mobile Number",
                                      hint: "Enter Mobile Number",
                                      textController: _teamMemberMobileC,
                                      keyboardType: TextInputType.phone,
                                      isRequired: true,
                                      inputFormatterList: InputValidator.digit(
                                        10,
                                      ),
                                      onChangeFunction: (_) {
                                        _selectedTeamMemberNotifier.value = [];
                                        _hasManualEntryNotifier.value =
                                            _teamMemberNameC.text
                                                .trim()
                                                .isNotEmpty ||
                                            _teamMemberMobileC.text
                                                .trim()
                                                .isNotEmpty;
                                      },
                                      validator: (val) {
                                        if (_teamMemberNameC.text.isEmpty &&
                                            (val == null ||
                                                val.trim().isEmpty)) {
                                          return "Team Member mobile number is required";
                                        }
                                        if (val != null &&
                                            val.isNotEmpty &&
                                            val.length != 10) {
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
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedEmployeeNotifier,
                      builder: (context, selectedEmployee, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: 'Employee Reference Name',
                              isRequired: true,
                              hintText: "Select Employee Reference Name",
                              isMultiSelect: false,
                              initialValue: selectedEmployee,
                              dataList: const [],
                              onSelected: (value) {
                                _selectedEmployeeNotifier.value = value;
                              },
                              dataFetchCallBack: _fetchEmployees,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Employee Reference Name is required";
                                }
                                return null;
                              },
                            ),
                            if (selectedEmployee.isNotEmpty) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColor.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColor.primary.withValues(
                                      alpha: .2,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Department",
                                          value:
                                              selectedEmployee
                                                  .first["department"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Designation",
                                          value:
                                              selectedEmployee
                                                  .first["designation"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Branch",
                                          value:
                                              selectedEmployee
                                                  .first["branch"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Reporting Person",
                                          value:
                                              selectedEmployee
                                                  .first["reportingPerson"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Email Id",
                                          value:
                                              selectedEmployee.first["email"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Personal Mobile Number",
                                          value:
                                              selectedEmployee
                                                  .first["personalNumber"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],

                  if (isDirectWalking && subSourceId == 5) ...[
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedProjectNotifier,
                      builder: (context, selectedProject, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: 'Project',
                              isRequired: true,
                              isMultiSelect: false,
                              hintText: "Select Project",
                              initialValue: selectedProject,
                              dataList: const [],
                              onSelected: (value) {
                                _selectedProjectNotifier.value = value;
                                _selectedFlatNotifier.value = [];
                              },
                              dataFetchCallBack: _fetchProjects,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Project is required";
                                }
                                return null;
                              },
                            ),
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: _selectedFlatNotifier,
                              builder: (context, selectedFlat, _) {
                                return CustomMultipleSelectPopup(
                                  title: 'Unit Number',
                                  hintText: "Select Unit Number",
                                  isRequired: true,
                                  isMultiSelect: false,
                                  initialValue: selectedFlat,
                                  dataList: const [],
                                  onSelected: (value) {
                                    _selectedFlatNotifier.value = value;
                                  },
                                  dataFetchCallBack: (page, {value}) {
                                    if (_selectedProjectNotifier
                                        .value
                                        .isEmpty) {
                                      return Future.value({
                                        "itemList": [],
                                        "totalNumberOfRecord": 0,
                                      });
                                    }

                                    final projectId =
                                        _selectedProjectNotifier
                                            .value
                                            .first["zAttributesId"];

                                    return _fetchFlatsByProjectId(
                                      page,
                                      projectId: projectId,
                                    );
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Unit Number is required";
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],

                  if (isDirectWalking && subSourceId == 10) ...[
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedProjectNotifier,
                      builder: (context, selectedProject, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: 'Project',
                              isRequired: true,
                              isMultiSelect: false,
                              initialValue: selectedProject,
                              dataList: const [],
                              onSelected: (value) {
                                _selectedProjectNotifier.value = value;
                                _selectedFlatNotifier.value = [];
                              },
                              dataFetchCallBack: _fetchProjects,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Project is required";
                                }
                                return null;
                              },
                            ),
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: _selectedFlatNotifier,
                              builder: (context, selectedFlat, _) {
                                return CustomMultipleSelectPopup(
                                  title: 'Unit Number',
                                  isRequired: true,
                                  isMultiSelect: false,
                                  initialValue: selectedFlat,
                                  dataList: const [],
                                  onSelected: (value) {
                                    _selectedFlatNotifier.value = value;
                                  },
                                  dataFetchCallBack: (page, {value}) {
                                    if (_selectedProjectNotifier
                                        .value
                                        .isEmpty) {
                                      return Future.value({
                                        "itemList": [],
                                        "totalNumberOfRecord": 0,
                                      });
                                    }

                                    final projectId =
                                        _selectedProjectNotifier
                                            .value
                                            .first["zAttributesId"];

                                    return _fetchFlatsByProjectId(
                                      page,
                                      projectId: projectId,
                                    );
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Unit Number is required";
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ]);
              },
            );
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
        minLines: 3,
        maxLines: 3,
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
      Text("Budget (In Cr)", style: AppTextStyle.ts14R()),

      SizedBox(
        width: double.infinity,
        child: ValueListenableBuilder<int>(
          valueListenable: _budgetValueNotifier,
          builder: (context, selectedValue, child) {
            return SfSlider(
              min: 0,
              max: (budgetOptions.length - 1).toDouble(),
              value: budgetOptions.indexOf(selectedValue).toDouble(),
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

                _budgetValueNotifier.value = val;
                _budgetC.text =
                    val == 1
                        ? ">1"
                        : val == 25
                        ? "25+"
                        : val.toString();
              },
            );
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
            } else if (reqVal == "Commercial") {
              dependentList = commercialUnitTypeList;
            } else if (reqVal == "Commercial Leasing") {
              dependentList = commercialLeasingTypeList;
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
                        commercialLeasingTypeList.first;
                  }
                },
              ),
              const SizedBox(height: 8),
              if (dependentList.isNotEmpty)
                CustomDropDownWidget(
                  title: "${selectedRequirement?["DisplayName"]} Type",
                  hintText: "Select ${selectedRequirement?["DisplayName"]}",
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
                  validator: (value) {
                    if (value == null ||
                        value.toString().trim().isEmpty ||
                        value['zAttributesId'] == -1) {
                      return "${selectedRequirement?["DisplayName"]} Type is required";
                    }
                    return null;
                  },
                ),
            ],
          );
        },
      ),
      CustomMultipleSelectPopup(
        title: 'Location',
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
        inputFormatterList: InputValidator.digit(6),
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
        isDisabled: _isEditMode,
        initialValue: _selectedFinalStage.value ?? stageTypeList.first,
        dataList: stageTypeList,
        onSelected: (v) {
          _selectedFinalStage.value = v;
          _selectedFinalStageDetail = finalStageDetailsList.first;
        },
      ),
      ValueListenableBuilder(
        valueListenable: _selectedFinalStage,
        builder: (context, finalStage, child) {
          return finalStage?["zAttributesId"] == 5
              ? CustomDropDownWidget(
                title: "Final Stage Detail",
                isDisabled: _isEditMode,
                initialValue:
                    _selectedFinalStageDetail ?? finalStageDetailsList.first,
                dataList: finalStageDetailsList,
                onSelected: (v) => _selectedFinalStageDetail = v,
              )
              : SizedBox.shrink();
        },
      ),
    ]);
  }

  // FOLLOWUP
  Widget _followUpCard() {
    return _card("Follow Up Details", [
      CustomDatePicker(
        title: "Enquiry Date",
        readOnly: _isEditMode,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        isRequired: true,
        initialDate: _enquiryDate,
        setValue: (v) => _enquiryDate = v,
      ),

      if (user.designation.toLowerCase() != 'GRE'.toLowerCase())
        CustomDatePicker(
          title: "Next Follow-Up Date",
          isRequired: true,
          readOnly: _isEditMode,
          startDate: DateTime.now(),
          initialDate: _nextFollowUpDate,
          setValue: (v) => _nextFollowUpDate = v,
          validator: (value) {
            if (value == null) {
              return "Next Follow-Up Date is required";
            }
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
}
