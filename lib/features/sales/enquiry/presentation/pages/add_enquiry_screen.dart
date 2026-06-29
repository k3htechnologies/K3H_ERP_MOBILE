// SAME IMPORTS (unchanged)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/country_code.dart';
import 'package:k3h_erp_app/core/models/modules_workflow_approval.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/data/repository/inventory.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/custom_verification_dialog.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
  late UtilsCubit _utilsCubit;

  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
  final InventoryRepository _inventoryRepository =
      serviceLocator<InventoryRepository>();
  final ChannelPartnerRepository _channelPartnerRepository =
      serviceLocator<ChannelPartnerRepository>();
  final UtilsRepository _utilsRepository = serviceLocator<UtilsRepository>();

  // EDIT MODE
  bool get _isEditMode => widget.enquiryModel != null;
  // VARIABLE FOR VALIDATION
  final _formKey = GlobalKey<FormState>();
  final _channelPartnerCodeKey = GlobalKey<FormState>();
  // TIME VARIABLE
  String? _timeInC;
  String? _timeOutC;
  // DATE VARIABLE
  DateTime? _enquiryDate;
  DateTime? _nextFollowUpDate;

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
  final ValueNotifier<String> _channelPartnerCodeNotifier = ValueNotifier('');
  final ValueNotifier<Map<String, dynamic>?> _selectedFinalStage =
      ValueNotifier(null);
  final ValueNotifier<bool> _hasManualEntryNotifier = ValueNotifier(false);
  late final ValueNotifier<FlatModel?> _flatDetailsNotifier;
  // DROPDOWN VARIABLES
  final ValueNotifier<Map<String, dynamic>?> _selectedOccupationType =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedBudgetInCr =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedPossessionType =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedTimeline = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedFloorBand = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedFunding = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedEthnicity = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedFinalStageDetail =
      ValueNotifier(null);
  List<Map<String, dynamic>> _selectedLocations = [];
  List<Map<String, dynamic>> _selectedSourcingManager = [];
  late UserModel user;

  late TextEditingController _nameC,
      _mobileC,
      _emailC,
      _ageC,
      _locationC,
      _areaPrefC,
      // NRI Fields
      _countryOfResidenceC,
      _cityOfResidenceC,
      // Channel Partner
      _channelPartnerCodeC,
      _teamMemberNameC,
      _teamMemberMobileC,
      _teamMemberEmailC,
      _remarkC,
      otpController;
  late ProjectModel _project;

  final closedStatuses = ['booking done', 'cancelled', 'lost'];
  ValueNotifier<CountryCode> selectedMobileNoCountry = ValueNotifier(
    countryList.firstWhere((e) => e.code == "+91"),
  );
  ValueNotifier<CountryCode> selectedTeamMemberMobileNoCountry = ValueNotifier(
    countryList.firstWhere((e) => e.code == "+91"),
  );
  final ValueNotifier<bool> _isMobileNoAlreadyExist = ValueNotifier(false);
  final ValueNotifier<bool> _isTeamMemberAlreadyExist = ValueNotifier(false);
  final ValueNotifier<bool> _isChannelPartnerAlreadyExist = ValueNotifier(
    false,
  );

  @override
  void initState() {
    super.initState();
    _enquiryCubit = context.read<EnquiryCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _initControllers();
    _enquiryCubit.clearChannelPartner();
    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedProjectNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedFlatNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _flatDetailsNotifier = ValueNotifier(null);
    user = getCurrentUser();
    _project = getProject();
    if (_isEditMode) {
      _populateFormFields(widget.enquiryModel!);
    } else {
      _timeInC = DateTime.now().toIso8601String().split("T")[1].split(".")[0];
      _enquiryDate = DateTime.now();
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
    _countryOfResidenceC.dispose();
    _cityOfResidenceC.dispose();
    _selectedBudgetInCr.dispose();
    // CHANNEL PARTNER CONTROLLERS
    _channelPartnerCodeC.dispose();
    _teamMemberNameC.dispose();
    _teamMemberMobileC.dispose();
    _teamMemberEmailC.dispose();
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
    _channelPartnerCodeNotifier.dispose();
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
    _countryOfResidenceC = TextEditingController();
    _cityOfResidenceC = TextEditingController();
    _channelPartnerCodeC = TextEditingController();
    _teamMemberNameC = TextEditingController();
    _teamMemberMobileC = TextEditingController();
    _teamMemberEmailC = TextEditingController();
    _remarkC = TextEditingController();
    otpController = TextEditingController();
  }

  Future<void> _fetchFlatDetailsById(int flatId, int projectId) async {
    final result = await _inventoryRepository.getPaginatedFlats(
      pageNumber: 1,
      pageSize: 1,
      projectId: projectId,
      queryParams: {"InventoryFlatId": flatId},
    );

    result.fold(
      (failure) {
        _flatDetailsNotifier.value = null;
      },
      (response) {
        final flats = response['data'] as List<FlatModel>;

        if (flats.isNotEmpty) {
          _flatDetailsNotifier.value = flats.first;
        }
      },
    );
  }

  Future<void> _fetchEmployeeDetailsById(int employeeId) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: 1,
      pageSize: 1,
      queryParams: {"EmployeeId": employeeId, "isCheckPermission": false},
    );

    result.fold((failure) {}, (response) {
      final employees = response['data'] as List<UserModel>;

      if (employees.isEmpty) return;

      final emp = employees.first;

      if (!mounted) return;

      _selectedEmployeeNotifier.value = [
        {
          "zAttributesId": emp.employeeId,
          "DisplayName": emp.fullName,
          "department": emp.department,
          "designation": emp.designation,
          "branch": emp.branch,
          "reportingPerson": emp.reportPersonName,
          "email": emp.emailId,
          "personalNumber": emp.personalMobileNumber,
        },
      ];
    });
  }

  // PREFILL
  void _populateFormFields(EnquiryModel model) async {
    // TEXT CONTROLLERS
    _nameC.text = model.name;
    _mobileC.text = model.mobileNumber;
    if (model.mobileNumberCountryCode.isNotEmpty) {
      selectedMobileNoCountry.value = countryList.firstWhere(
        (e) => e.code == model.mobileNumberCountryCode,
        orElse:
            () => CountryCode(
              name: "India",
              code: "+91",
              countryCode: "IN",
              mobileLength: 10,
              regex: RegExp(r'^[6-9]\d{9}$'),
            ),
      );
    }
    _teamMemberEmailC.text = model.channelPartnerTeamMemberEmailId;
    _emailC.text = model.emailId;
    _locationC.text = model.currentLocation;
    _areaPrefC.text =
        model.areaPreferred == 0 ? "" : model.areaPreferred.toStringAsFixed(0);
    _remarkC.text = model.remark;

    // SOURCE BASED TEXT FIELDS
    _channelPartnerCodeC.text = model.channelPartnerCode;
    _channelPartnerCodeNotifier.value = model.channelPartnerCode;

    // TIME
    _timeInC = model.enquiryTimeIn;
    _timeOutC = model.enquiryTimeOut;

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
    _enquiryCubit.onSelectedOptionChanged(model.nationality);
    _countryOfResidenceC.text = model.countryOfResidence;
    _cityOfResidenceC.text = model.cityOfResidence;

    _updateAge();

    // DROPDOWNS - NOTIFIER
    _selectedAccommodationNotifier.value = findItem(
      currentAccommodation,
      model.accommodation,
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

    if (model.referralProjectId != 0 && model.referralProjectName.isNotEmpty) {
      _selectedProjectNotifier.value = [
        {
          "zAttributesId": model.referralProjectId,
          "DisplayName": model.referralProjectName,
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
      _fetchFlatDetailsById(
        model.loyaltyInventoryFlatId,
        model.loyaltyProjectId,
      );
    }

    if (model.referralInventoryFlatId != 0 &&
        model.referralUnitNumber.isNotEmpty) {
      _selectedFlatNotifier.value = [
        {
          "zAttributesId": model.referralInventoryFlatId,
          "DisplayName": model.referralUnitNumber,
        },
      ];
      _fetchFlatDetailsById(
        model.referralInventoryFlatId,
        model.referralProjectId,
      );
    }

    if (model.employeeReferenceEmployeeId != 0 &&
        model.employeeReferenceName.isNotEmpty) {
      _selectedEmployeeNotifier.value = [
        {
          "zAttributesId": model.employeeReferenceEmployeeId,
          "DisplayName": model.employeeReferenceName,
        },
      ];

      _fetchEmployeeDetailsById(model.employeeReferenceEmployeeId);
    }

    // DROPDOWNS - PLAIN VARIABLES
    _selectedOccupationType.value = findItem(
      occupationType,
      model.occupationType,
    );
    _selectedPossessionType.value = findItem(
      possessionType,
      model.possessionType,
    );
    _selectedFloorBand.value = findItem(floorBrand, model.desiredFloorBand);
    _selectedFunding.value = findItem(fundingSourceList, model.sourceOfFunding);
    _selectedEthnicity.value = findItem(ethnicityList, model.ethnicity);
    _selectedFinalStage.value = findItem(stageTypeList, model.finalStage);
    _selectedFinalStageDetail.value = findItem(
      finalStageDetailsList,
      model.finalStageDetail,
    );
    _selectedTimeline.value = findItem(timelineTypeList, model.timeline);

    // DEPENDENT REQUIREMENT TYPE DROPDOWNS
    final reqDisplay = model.requirement;
    if (reqDisplay.isNotEmpty) {
      _selectedRequirementNotifier.value = findItem(
        requirementType,
        model.requirement,
      );
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
        _enquiryCubit.fetchChannelPartners(1, value: model.channelPartnerCode);
      }

      // AUTO-FETCH TEAM MEMBER BY ID IN EDIT MODE
      if (model.channelPartnerTeamMemberId != 0) {
        final member = await fetchChannelPartnerTeamMembers(1);

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

    if (model.budget.isNotEmpty) {
      final raw = model.budget.trim();

      final match = budgetInCrList.firstWhere(
        (e) => e["DisplayName"].toString() == raw,
        orElse:
            () => budgetInCrList.firstWhere(
              (e) => e["DisplayName"] == "<1",
              orElse: () => budgetInCrList.first,
            ),
      );

      _selectedBudgetInCr.value = match;
    }
  }

  // SUBMIT FORM
  void _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // VERIFY OTP ONLY IN FIRST ONBOARDING STAGE AND USER IS INDIAN
    if (!_isEditMode && selectedMobileNoCountry.value.countryCode == "IN") {
      //  SEND OTP FIRST
      _utilsCubit.sendOTPModuleBased(
        context: context,
        mobileNumber: _mobileC.text.trim(),
        module: "ENQUIRY",
        name: _nameC.text.trim(),
        projectName: _project.projectName,
        source: getDisplayOrEmpty(_selectedSourceNotifier.value),
      );
      bool isEnquiryCompleted =
          _nameC.text.isNotEmpty &&
          _mobileC.text.isNotEmpty &&
          getDisplayOrEmpty(_selectedAccommodationNotifier.value).isNotEmpty &&
          getDisplayOrEmpty(_selectedOccupationType.value).isNotEmpty;

      bool isSourceCompleted =
          getDisplayOrEmpty(_selectedSourceNotifier.value).isNotEmpty;
      bool isPropertyCompleted =
          (_selectedBudgetInCr.value != null &&
              _selectedBudgetInCr.value!.isNotEmpty) &&
          getDisplayOrEmpty(_selectedRequirementNotifier.value).isNotEmpty &&
          getDisplayOrEmpty(_selectedPossessionType.value).isNotEmpty &&
          getDisplayOrEmpty(_selectedRequirementNotifier.value).isNotEmpty &&
          _areaPrefC.text.isNotEmpty &&
          getDisplayOrEmpty(_selectedFloorBand.value).isNotEmpty;

      bool isCustomerCompleted =
          getDisplayOrEmpty(_selectedFunding.value).isNotEmpty &&
          getDisplayOrEmpty(_selectedEthnicity.value).isNotEmpty;

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
    final subSource = _selectedSubSourceNotifier.value?["DisplayName"] ?? "";
    final subSubSource =
        source.trim().toLowerCase() == "channel partner"
            ? (_selectedSubSubSourceNotifier.value?["zAttributesId"]).toString()
            : getDisplayOrEmptySubSub(_selectedSubSubSourceNotifier.value);
    // CUSTOMER CLASSIFICATION LOGIC
    int selectedCount = 0;
    if ((_selectedPossessionType.value?["DisplayName"] ?? "")
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
    if ((_selectedBudgetInCr.value?["DisplayName"] ?? "").isNotEmpty) {
      selectedCount++;
    }

    final timeline = getDisplayOrEmpty(_selectedTimeline.value);
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

    if (_isEditMode) {
      await _enquiryCubit.updateEnquiry(
        context: context,
        index: widget.index,
        enquiryId: widget.enquiryModel!.enquiryId,
        uniqueKey: widget.enquiryModel!.uniquekey,
        projectId: getProject().projectId,
        enquiryTimeIn: _timeInC,
        enquiryTimeOut: _timeOutC,
        name: _nameC.text.trim(),
        mobileNumberCountryCode: selectedMobileNoCountry.value.code,
        mobileNumber: _mobileC.text.trim(),
        emailId: _emailC.text.trim(),
        dateOfBirth: _dateOfBirthNotifier.value,
        accommodation: getDisplayOrEmpty(_selectedAccommodationNotifier.value),
        occupationType: getDisplayOrEmpty(_selectedOccupationType.value),
        source: source,
        subSource: getDisplayOrEmpty(_selectedSubSourceNotifier.value),
        subSubSource: subSubSource,

        referralProjectId:
            _selectedProjectNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('reference')
                ? _selectedProjectNotifier.value.first["zAttributesId"]
                : null,

        referralInventoryFlatId:
            _selectedFlatNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('reference')
                ? _selectedFlatNotifier.value.first["zAttributesId"]
                : null,

        loyaltyProjectId:
            _selectedProjectNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('loyalty')
                ? _selectedProjectNotifier.value.first["zAttributesId"]
                : null,

        loyaltyInventoryFlatId:
            _selectedFlatNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('loyalty')
                ? _selectedFlatNotifier.value.first["zAttributesId"]
                : null,

        employeeReferenceEmployeeId:
            _selectedEmployeeNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('employee reference')
                ? _selectedEmployeeNotifier.value.first["zAttributesId"]
                : null,

        channelPartnerTeamMemberId:
            _selectedTeamMemberNotifier.value.isNotEmpty
                ? _selectedTeamMemberNotifier.value.first["zAttributesId"]
                : null,

        channelPartnerTeamMemberName: _teamMemberNameC.text.trim(),

        channelPartnerTeamMemberMobileNumber: _teamMemberMobileC.text.trim(),

        channelPartnerTeamMemberMobileNumberCountryCode:
            selectedTeamMemberMobileNoCountry.value.code,

        channelPartnerTeamMemberEmailId: _teamMemberEmailC.text.trim(),

        nationality: _enquiryCubit.state.selectedNationality,

        countryOfResidence: _countryOfResidenceC.text.trim(),

        cityOfResidence: _cityOfResidenceC.text.trim(),

        currentLocation: _locationC.text.trim(),

        villageMasterId: selectedVillages,

        possessionType: getDisplayOrEmpty(_selectedPossessionType.value),

        areaPreferred: double.tryParse(_areaPrefC.text.trim()) ?? 0,

        desiredFloorBand: getDisplayOrEmpty(_selectedFloorBand.value),

        budget: _selectedBudgetInCr.value?["DisplayName"] ?? "",

        requirement: getDisplayOrEmpty(_selectedRequirementNotifier.value),

        requirementType: requirementTypeValue,

        customerClassification: customerClassification,

        sourceOfFunding: getDisplayOrEmpty(_selectedFunding.value),

        ethnicity: getDisplayOrEmpty(_selectedEthnicity.value),

        finalStage: getDisplayOrEmpty(_selectedFinalStage.value),

        finalStageDetail: getDisplayOrEmpty(_selectedFinalStageDetail.value),

        enquiryDate: _enquiryDate,
        nextFollowUpDate: _nextFollowUpDate,

        salesAdvisorId:
            _selectedSaleAdvisorNotifier.value.isNotEmpty
                ? _selectedSaleAdvisorNotifier.value.first["zAttributesId"]
                : 0,

        sourcingManagerId:
            _selectedSourcingManager.isNotEmpty
                ? _selectedSourcingManager.first["zAttributesId"]
                : 0,

        remark: _remarkC.text.trim(),
        timeline: timeline,
        otp: otpController.text.trim(),
      );
    } else {
      await _enquiryCubit.addEnquiry(
        context: context,
        projectId: getProject().projectId,
        enquiryTimeIn: _timeInC,
        enquiryTimeOut: _timeOutC,
        name: _nameC.text.trim(),
        mobileNumberCountryCode: selectedMobileNoCountry.value.code,
        mobileNumber: _mobileC.text.trim(),
        emailId: _emailC.text.trim(),
        dateOfBirth: _dateOfBirthNotifier.value,
        accommodation: getDisplayOrEmpty(_selectedAccommodationNotifier.value),
        occupationType: getDisplayOrEmpty(_selectedOccupationType.value),
        source: source,
        subSource: getDisplayOrEmpty(_selectedSubSourceNotifier.value),
        subSubSource: subSubSource,

        referralProjectId:
            _selectedProjectNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('reference')
                ? _selectedProjectNotifier.value.first["zAttributesId"]
                : null,

        referralInventoryFlatId:
            _selectedFlatNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('reference')
                ? _selectedFlatNotifier.value.first["zAttributesId"]
                : null,

        loyaltyProjectId:
            _selectedProjectNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('loyalty')
                ? _selectedProjectNotifier.value.first["zAttributesId"]
                : null,

        loyaltyInventoryFlatId:
            _selectedFlatNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('loyalty')
                ? _selectedFlatNotifier.value.first["zAttributesId"]
                : null,

        employeeReferenceEmployeeId:
            _selectedEmployeeNotifier.value.isNotEmpty &&
                    subSource.toLowerCase().contains('employee reference')
                ? _selectedEmployeeNotifier.value.first["zAttributesId"]
                : null,

        channelPartnerTeamMemberId:
            _selectedTeamMemberNotifier.value.isNotEmpty
                ? _selectedTeamMemberNotifier.value.first["zAttributesId"]
                : null,

        channelPartnerTeamMemberName: _teamMemberNameC.text.trim(),

        channelPartnerTeamMemberMobileNumber: _teamMemberMobileC.text.trim(),

        channelPartnerTeamMemberMobileNumberCountryCode:
            selectedTeamMemberMobileNoCountry.value.code,

        channelPartnerTeamMemberEmailId: _teamMemberEmailC.text.trim(),

        nationality: _enquiryCubit.state.selectedNationality,

        countryOfResidence: _countryOfResidenceC.text.trim(),

        cityOfResidence: _cityOfResidenceC.text.trim(),

        currentLocation: _locationC.text.trim(),

        villageMasterId: selectedVillages,

        possessionType: getDisplayOrEmpty(_selectedPossessionType.value),

        areaPreferred: double.tryParse(_areaPrefC.text.trim()) ?? 0,

        desiredFloorBand: getDisplayOrEmpty(_selectedFloorBand.value),

        budget: _selectedBudgetInCr.value?["DisplayName"] ?? "",

        requirement: getDisplayOrEmpty(_selectedRequirementNotifier.value),

        requirementType: requirementTypeValue,

        customerClassification: customerClassification,

        sourceOfFunding: getDisplayOrEmpty(_selectedFunding.value),

        ethnicity: getDisplayOrEmpty(_selectedEthnicity.value),

        finalStage: getDisplayOrEmpty(_selectedFinalStage.value),

        finalStageDetail: getDisplayOrEmpty(_selectedFinalStageDetail.value),

        enquiryDate: _enquiryDate,
        nextFollowUpDate: _nextFollowUpDate,

        salesAdvisorId:
            _selectedSaleAdvisorNotifier.value.isNotEmpty
                ? _selectedSaleAdvisorNotifier.value.first["zAttributesId"]
                : 0,

        sourcingManagerId:
            _selectedSourcingManager.isNotEmpty
                ? _selectedSourcingManager.first["zAttributesId"]
                : 0,

        remark: _remarkC.text.trim(),
        timeline: timeline,
        otp: otpController.text.trim(),

        isIndian: selectedMobileNoCountry.value.countryCode == "IN",
      );
    }
  }

  String getDisplayOrEmpty(Map<String, dynamic>? item) {
    if (item == null) return "";
    return item["DisplayName"] ?? "";
  }

  String getDisplayOrEmptySubSub(Map<String, dynamic>? item) {
    if (item == null) return "";
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
      queryParams: {
        "ChannelPartnerId":
            (_isEditMode &&
                    widget.enquiryModel!.channelPartnerTeamMemberId != 0)
                ? widget.enquiryModel!.channelPartnerTeamMemberId.toString()
                : null,
        "isCheckPermission": false,
        "ChannelPartnerName": value,
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
    String? value,
    required int projectId,
    required int? inventoryFlatId,
  }) async {
    final result = await _inventoryRepository.getPaginatedFlats(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: projectId,
      queryParams: {
        if (value != null && value.isNotEmpty) "Flat": value,
        "FlatStatus": "Booked,Alloted",
      },
    );
    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final flats = response['data'] as List<FlatModel>;

        if (inventoryFlatId != null && flats.isNotEmpty) {
          _flatDetailsNotifier.value = flats.first;
        }
        return {
          "itemList":
              flats.map((flat) {
                return {
                  "zAttributesId": flat.inventoryFlatId,
                  "DisplayName": flat.flat,
                  "flatModel": flat,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH EMPLOYEES LIST FOR DROPDOWN
  Future<Map<String, dynamic>> _fetchSalesEmployees(
    int pageNumber, {
    String? value,
    int? employeeId,
  }) async {
    final Map<String, dynamic> queryParams = {"IsCheckPermission": "false"};

    queryParams["DepartmentName"] = "Sales";

    if (employeeId != null && employeeId != 0) {
      queryParams["EmployeeId"] = employeeId;
    } else if (value != null && value.isNotEmpty) {
      queryParams["FullName"] = value;
    }

    final result = await _utilsRepository.pullPaginationProjectWithEmployee(
      pageNumber: pageNumber,
      projectId: _project.projectId,
      pageSize: 15,
      queryParams: queryParams,
    );

    return result.fold(
      (failure) => {
        "itemList": <ModulesApprovalEmployeeDataModel>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees =
            response['data'] as List<ModulesApprovalEmployeeDataModel>;
        return {
          "itemList":
              employees.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName":
                      "${employee.fullName} - ${employee.designation}",
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
            onPressed: () => _submitForm(context),
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
          ValueListenableBuilder(
            valueListenable: selectedMobileNoCountry,
            builder: (context, value, child) {
              return CustomTextField(
                title: "Mobile Number",
                textController: _mobileC,
                readOnly: _isEditMode,
                hint: "Enter Mobile Number",
                keyboardType: TextInputType.phone,
                isRequired: true,
                showCountryDropdown: true,
                selectedCountry: value,
                onCountryChanged: (country) async {
                  if (country == null) return;

                  selectedMobileNoCountry.value = country;
                  if (_mobileC.text.isNotEmpty &&
                      country.mobileLength == _mobileC.text.length) {
                    _isMobileNoAlreadyExist.value =
                        (await _enquiryCubit.fetchEnquiryByMobileNo(
                          value: _mobileC.text.trim(),
                          mobileNumberCountryCode:
                              selectedMobileNoCountry.value.code,
                          projectId: _project.projectId,
                        )).isNotEmpty;
                  } else {
                    _isMobileNoAlreadyExist.value = false;
                  }
                },
                onChangeFunction: (value) async {
                  final country = selectedMobileNoCountry.value;

                  if (value.isNotEmpty &&
                      country.mobileLength == value.length) {
                    _isMobileNoAlreadyExist.value =
                        (await _enquiryCubit.fetchEnquiryByMobileNo(
                          value: _mobileC.text.trim(),
                          mobileNumberCountryCode:
                              selectedMobileNoCountry.value.code,
                          projectId: _project.projectId,
                        )).isNotEmpty;
                  } else {
                    _isMobileNoAlreadyExist.value = false;
                  }
                },
                inputFormatterList: [
                  LengthLimitingTextInputFormatter(value.mobileLength),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  final mobile = value?.trim() ?? "";
                  final country = selectedMobileNoCountry.value;
                  if (value == null || value.isEmpty) {
                    return "Mobile Number is required";
                  }
                  if (mobile.isNotEmpty) {
                    // LENGTH AND REGEX VALIDATION
                    if ((mobile.length != country.mobileLength) ||
                        country.regex != null &&
                            !country.regex!.hasMatch(mobile)) {
                      return "Invalid Mobile Number";
                    }
                  }
                  if (_isMobileNoAlreadyExist.value && !_isEditMode) {
                    return "Mobile number already exists";
                  }

                  return null;
                },
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: selectedMobileNoCountry,
            builder: (context, selectedMobNovalue, child) {
              return CustomTextField(
                title: "E-mail ID",
                isRequired: selectedMobNovalue.countryCode != "IN",
                textController: _emailC,
                keyboardType: TextInputType.emailAddress,
                hint: "Enter Email",
                validator:
                    (value) =>
                        (selectedMobNovalue.countryCode != "IN" &&
                                (value == null || value.isEmpty))
                            ? "E-mail ID is required"
                            : null,
              );
            },
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
                hintText: "Select Current Accommodation",
                initialValue: selectedAccommodation,
                isRequired: true,
                dataList: currentAccommodation,
                onSelected: (v) => _selectedAccommodationNotifier.value = v,
                validator: (val) {
                  if (val == null) {
                    return "Please select accommodation";
                  }
                  return null;
                },
                onValueClear: () {
                  _selectedAccommodationNotifier.value = null;
                },
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: _selectedOccupationType,
            builder: (context, value, child) {
              return CustomDropDownWidget(
                title: "Occupation Type",
                hintText: "Select Occupation Type",
                isRequired: true,
                initialValue: _selectedOccupationType.value,
                dataList: occupationType,
                onSelected: (v) => _selectedOccupationType.value = v,
                validator: (val) {
                  if (val == null) {
                    return "Please select occupation type";
                  }
                  return null;
                },
                onValueClear: () => _selectedOccupationType.value = null,
              );
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
                enabled: !_isEditMode,
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
                enabled: !_isEditMode,
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
                    hintText: "Select Source",
                    isDisabled: _isEditMode,
                    isRequired: true,
                    initialValue: selectedSource,
                    dataList: sourceTypeList,
                    onSelected: (v) {
                      _selectedSourceNotifier.value = v;
                      _selectedSubSourceNotifier.value = null;
                      _selectedSubSubSourceNotifier.value = null;
                      _channelPartnerCodeC.clear();
                      _channelPartnerCodeNotifier.value = '';
                      _selectedTeamMemberNotifier.value = [];
                      _hasManualEntryNotifier.value = false;
                      _teamMemberNameC.clear();
                      _teamMemberMobileC.clear();
                      _enquiryCubit.clearChannelPartner();
                      _selectedProjectNotifier.value = [];
                      _selectedFlatNotifier.value = [];
                      _isChannelPartnerAlreadyExist.value = false;
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Source is required";
                      }
                      return null;
                    },
                    onValueClear: () {
                      _selectedSourceNotifier.value = null;
                    },
                  ),

                  if (selectedSource != null)
                    CustomDropDownWidget(
                      key: ValueKey(selectedSource['zAttributesId']),
                      title: "Sub Source",
                      isDisabled: _isEditMode,
                      hintText: "Select Sub Source",
                      isRequired: true,
                      initialValue: selectedSubSource,
                      dataList:
                          isChannelPartner
                              ? channelPartnerActivityList
                              : directWalkingSubSourceList,
                      onSelected: (v) {
                        _selectedSubSourceNotifier.value = v;
                        _selectedProjectNotifier.value = [];
                        _selectedFlatNotifier.value = [];
                        _selectedEmployeeNotifier.value = [];
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Sub source is required";
                        }
                        return null;
                      },
                      onValueClear: () {
                        _selectedSubSourceNotifier.value = null;
                      },
                    ),

                  if (isChannelPartner) ...[
                    CustomTextField(
                      title: "Channel Partner Code",
                      hint: "Search by Channel Partner Code",
                      textController: _channelPartnerCodeC,
                      readOnly: _isEditMode,
                      key: _channelPartnerCodeKey,
                      isRequired: true,
                      inputFormatterList: [
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(18),
                      ],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Channel Partner code is required";
                        }
                        if (!_isChannelPartnerAlreadyExist.value &&
                            !_isEditMode) {
                          return "No Channel Partner found for this Channel Partner Code";
                        }

                        return null;
                      },
                      onChangeFunction: (value) async {
                        _channelPartnerCodeNotifier.value = value;
                        if (value.length != 18) {
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
                          _isChannelPartnerAlreadyExist.value = true;
                          _channelPartnerCodeKey.currentState?.validate();
                        } else {
                          _isChannelPartnerAlreadyExist.value = false;
                          _channelPartnerCodeKey.currentState?.validate();
                        }
                      },
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: _channelPartnerCodeNotifier,
                      builder: (context, mobile, _) {
                        return BlocBuilder<EnquiryCubit, EnquiryState>(
                          builder: (context, state) {
                            final partner = state.channelPartnerModel;

                            //  PARTNER FOUND
                            if (partner != null) {
                              return infoCard([
                                {
                                  "title": "CP Code",
                                  "value": partner.systemGeneratedCode,
                                },
                                {"title": "Full Name", "value": partner.name},
                                {
                                  "title": "Company Name",
                                  "value": partner.companyName,
                                },
                                {
                                  "title": "Firms Type",
                                  "value": partner.firmsType,
                                },
                                {
                                  "title": "Mobile",
                                  "value": partner.mobileNumber,
                                  "widget": CustomClickToContactText(
                                    countryCode:
                                        partner.mobileNumberCountryCode,
                                    value: partner.mobileNumber,
                                    type: ContactType.phone,
                                  ),
                                },
                                {
                                  "title": "Designation",
                                  "value": partner.designation,
                                },
                                {"title": "Type", "value": partner.type},
                              ]);
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
                        valueListenable: _channelPartnerCodeNotifier,
                        builder: (context, mobileValue, child) {
                          if (!isChannelPartner || mobileValue.length != 18) {
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
                                          isReadOnly: _isEditMode,
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
                                      readOnly: _isEditMode,
                                      textController: _teamMemberNameC,
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
                                        if (_teamMemberMobileC
                                                .text
                                                .isNotEmpty &&
                                            (val == null ||
                                                val.trim().isEmpty)) {
                                          return "Team member name is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable:
                                          selectedTeamMemberMobileNoCountry,
                                      builder: (context, value, child) {
                                        return CustomTextField(
                                          title: "Team Member Mobile Number",
                                          hint: "Enter Mobile Number",
                                          readOnly: _isEditMode,
                                          textController: _teamMemberMobileC,
                                          keyboardType: TextInputType.phone,
                                          showCountryDropdown: true,
                                          selectedCountry: value,
                                          onChangeFunction: (value) async {
                                            final country =
                                                selectedTeamMemberMobileNoCountry
                                                    .value;
                                            _selectedTeamMemberNotifier.value =
                                                [];
                                            _hasManualEntryNotifier.value =
                                                _teamMemberNameC.text
                                                    .trim()
                                                    .isNotEmpty ||
                                                _teamMemberMobileC.text
                                                    .trim()
                                                    .isNotEmpty;
                                            if (value.isNotEmpty &&
                                                country.mobileLength ==
                                                    value.length) {
                                              _isTeamMemberAlreadyExist.value =
                                                  (await _enquiryCubit
                                                      .fetchChannelPartnersByMobile(
                                                        _teamMemberMobileC.text
                                                            .trim(),
                                                      )).isNotEmpty;
                                            } else {
                                              _isTeamMemberAlreadyExist.value =
                                                  false;
                                            }
                                          },
                                          onCountryChanged: (country) {
                                            if (country == null) return;

                                            selectedTeamMemberMobileNoCountry
                                                .value = country;
                                          },
                                          inputFormatterList: [
                                            LengthLimitingTextInputFormatter(
                                              value.mobileLength,
                                            ),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          validator: (value) {
                                            final country =
                                                selectedTeamMemberMobileNoCountry
                                                    .value;
                                            final mobile = value?.trim() ?? "";

                                            if (_teamMemberNameC
                                                    .text
                                                    .isNotEmpty &&
                                                mobile.isEmpty) {
                                              return "Team Member Mobile Number is required";
                                            }

                                            if (mobile.isNotEmpty) {
                                              // LENGTH AND REGEX VALIDATION
                                              if ((mobile.length !=
                                                      country.mobileLength) ||
                                                  country.regex != null &&
                                                      !country.regex!.hasMatch(
                                                        mobile,
                                                      )) {
                                                return "Invalid Team Member Mobile Number";
                                              }
                                            }
                                            if (_isTeamMemberAlreadyExist
                                                    .value &&
                                                !_isEditMode) {
                                              return "Team Member Mobile number already exists";
                                            }
                                            return null;
                                          },
                                        );
                                      },
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable:
                                          selectedTeamMemberMobileNoCountry,
                                      builder: (
                                        context,
                                        selectedMobNovalue,
                                        child,
                                      ) {
                                        return CustomTextField(
                                          title: "Team Member E-mail ID",
                                          isRequired:
                                              selectedMobNovalue.countryCode !=
                                              "IN",
                                          readOnly: _isEditMode,
                                          textController: _teamMemberEmailC,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          hint: "Enter Team Member E-mail ID",
                                          validator:
                                              (value) =>
                                                  (selectedMobNovalue
                                                                  .countryCode !=
                                                              "IN" &&
                                                          (_teamMemberMobileC
                                                                  .text
                                                                  .isNotEmpty ||
                                                              _teamMemberNameC
                                                                  .text
                                                                  .isNotEmpty) &&
                                                          (value == null ||
                                                              value.isEmpty))
                                                      ? "Team Member E-mail ID is required"
                                                      : null,
                                        );
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
                          isDisabled: _isEditMode,
                          isRequired: true,
                          initialValue: selectedSubSubSource,
                          dataList: subSubSourceList,
                          onSelected:
                              (v) => _selectedSubSubSourceNotifier.value = v,
                          validator: (value) {
                            if (value == null) {
                              return "Sub Sub Source is required";
                            }
                            return null;
                          },
                          onValueClear:
                              () => _selectedSubSubSourceNotifier.value = null,
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
                              isReadOnly: _isEditMode,
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
                          key: const ValueKey("loyalty_project_section"),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: 'Project',
                              isReadOnly: _isEditMode,
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
                                  isReadOnly: _isEditMode,
                                  hintText: "Select Unit Number",
                                  isRequired: true,
                                  isMultiSelect: false,
                                  initialValue: selectedFlat,
                                  dataList: const [],
                                  onSelected: (value) {
                                    _selectedFlatNotifier.value = value;
                                    final flatData = value.first['flatModel'];
                                    _flatDetailsNotifier.value = flatData;
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
                                      value: value,
                                      projectId: projectId,
                                      inventoryFlatId: 0,
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
                            ValueListenableBuilder(
                              valueListenable: _selectedFlatNotifier,
                              builder: (context, value, child) {
                                if (value.isEmpty) {
                                  return SizedBox.shrink();
                                }
                                return ValueListenableBuilder(
                                  valueListenable: _flatDetailsNotifier,
                                  builder: (context, value, child) {
                                    return _flatDetails();
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
                          key: const ValueKey("reference_project_section"),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: 'Project',
                              isReadOnly: _isEditMode,
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
                                  return "Referral Project Name is required";
                                }
                                return null;
                              },
                            ),
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: _selectedFlatNotifier,
                              builder: (context, selectedFlat, _) {
                                return CustomMultipleSelectPopup(
                                  title: 'Unit Number',
                                  isReadOnly: _isEditMode,
                                  isRequired: true,
                                  isMultiSelect: false,
                                  initialValue: selectedFlat,
                                  dataList: const [],
                                  onSelected: (value) {
                                    _selectedFlatNotifier.value = value;
                                    final flatData = value.first['flatModel'];

                                    _flatDetailsNotifier.value = flatData;
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
                                      value: value,
                                      projectId: projectId,
                                      inventoryFlatId: 0,
                                    );
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Referral Unit Number is required";
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _selectedFlatNotifier,
                              builder: (context, value, child) {
                                if (value.isEmpty) {
                                  return SizedBox.shrink();
                                }
                                return ValueListenableBuilder(
                                  valueListenable: _flatDetailsNotifier,
                                  builder: (context, value, child) {
                                    return _flatDetails();
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

  Widget _flatDetails() {
    if (_flatDetailsNotifier.value == null) {
      return SizedBox.shrink();
    }
    return infoCard([
      {
        "title": "Building",
        "value": _flatDetailsNotifier.value?.buildingNumber,
      },
      {"title": "Wing", "value": _flatDetailsNotifier.value?.wing},
      {"title": "Floor", "value": _flatDetailsNotifier.value?.floor},
      {"title": "Flat Number", "value": _flatDetailsNotifier.value?.flat},
      {
        "title": "Carpet Area (SqFt)",
        "value": _flatDetailsNotifier.value?.reraCarpetAreaSqFt.toString(),
      },
      {"title": "Flat Type", "value": _flatDetailsNotifier.value?.flatType},
      {
        "title": "Configuration",
        "value": _flatDetailsNotifier.value?.flatConfiguration,
      },
      {"title": "Facing", "value": _flatDetailsNotifier.value?.flatFacing},
      {"title": "Status", "value": _flatDetailsNotifier.value?.flatStatus},
      {"title": "Owner Name", "value": _flatDetailsNotifier.value?.ownerName},
      {
        "title": "Booked By",
        "value": _flatDetailsNotifier.value?.bookingCreatedBy,
      },
      {
        "title": "Booking Date",
        "value":
            _flatDetailsNotifier.value?.bookingCreatedDate == null
                ? "-"
                : formatDateTimeAsDDMMMYYYY(
                  _flatDetailsNotifier.value!.bookingCreatedDate!,
                ),
      },
    ]);
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
      CustomDropDownWidget(
        title: "Budget (In Cr)",
        hintText: "Select Budget(In Cr)",
        initialValue: _selectedBudgetInCr.value,
        dataList: budgetInCrList,
        onSelected: (value) {
          _selectedBudgetInCr.value = value;
        },
      ),
      ValueListenableBuilder(
        valueListenable: _selectedPossessionType,
        builder: (context, value, child) {
          return CustomDropDownWidget(
            title: "Possession Type",
            hintText: "Select Possession Type",
            initialValue: _selectedPossessionType.value,
            dataList: possessionType,
            onSelected: (v) => _selectedPossessionType.value = v,
            onValueClear: () => _selectedPossessionType.value = null,
          );
        },
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
                hintText: "Select Requirement",
                initialValue: selectedRequirement,
                dataList: requirementType,
                onSelected: (v) {
                  _selectedRequirementNotifier.value = v;
                },
                onValueClear: () {
                  _selectedRequirementNotifier.value = null;
                  _selectedResidentialTypeNotifier.value = null;
                  _selectedCommercialTypeNotifier.value = null;
                  _selectedCommercialLeasingNotifier.value = null;
                },
              ),
              if (dependentList.isNotEmpty)
                CustomDropDownWidget(
                  key: ValueKey(selectedRequirement?["DisplayName"]),
                  title: "${selectedRequirement?["DisplayName"]} Type",
                  hintText: "Select ${selectedRequirement?["DisplayName"]}",
                  isRequired: true,
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
                    return null;
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
                    if (value == null || value.toString().trim().isEmpty) {
                      return "${selectedRequirement?["DisplayName"]} Type is required";
                    }
                    return null;
                  },
                  onValueClear: () {
                    if (selectedRequirement?["DisplayName"] == "Residential") {
                      _selectedResidentialTypeNotifier.value = null;
                    } else if (selectedRequirement?["DisplayName"] ==
                        "Commercial") {
                      _selectedCommercialTypeNotifier.value = null;
                    } else if (selectedRequirement?["DisplayName"] ==
                        "Commercial Leasing") {
                      _selectedCommercialLeasingNotifier.value = null;
                    }
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
      ValueListenableBuilder(
        valueListenable: _selectedTimeline,
        builder: (context, value, child) {
          return CustomDropDownWidget(
            title: "Timeline of Purchase",
            hintText: "Select Timeline of Purchase",
            initialValue: _selectedTimeline.value,
            dataList: timelineTypeList,
            onSelected: (v) => _selectedTimeline.value = v,
            onValueClear: () {
              _selectedTimeline.value = null;
            },
          );
        },
      ),
      CustomTextField(
        title: "Area Preferred (SqFt)",
        hint: "Enter Area Preferred (SqFt)",
        textController: _areaPrefC,
        inputFormatterList: InputValidator.digit(6),
      ),
      ValueListenableBuilder(
        valueListenable: _selectedFloorBand,
        builder: (context, value, child) {
          return CustomDropDownWidget(
            title: "Desired Floor Band",
            hintText: "Select Desired Floor Band",
            initialValue: _selectedFloorBand.value,
            dataList: floorBrand,
            onSelected: (v) => _selectedFloorBand.value = v,
            onValueClear: () {
              _selectedFloorBand.value = null;
            },
          );
        },
      ),
    ]);
  }

  // CUSTOMER DETAILS
  Widget _customerDetailsCard() {
    return _card("Customer Details", [
      ValueListenableBuilder(
        valueListenable: _selectedFunding,
        builder: (context, value, child) {
          return CustomDropDownWidget(
            title: "Source Of Funding",
            hintText: "Select Source Of Funding",
            initialValue: _selectedFunding.value,
            dataList: fundingSourceList,
            onSelected: (v) => _selectedFunding.value = v,
            onValueClear: () {
              _selectedFunding.value = null;
            },
          );
        },
      ),
      ValueListenableBuilder(
        valueListenable: _selectedEthnicity,
        builder: (context, value, child) {
          return CustomDropDownWidget(
            title: "Ethnicity",
            hintText: "Select Ethnicity",
            initialValue: _selectedEthnicity.value,
            dataList: ethnicityList,
            onSelected: (v) => _selectedEthnicity.value = v,
            onValueClear: () {
              _selectedEthnicity.value = null;
            },
          );
        },
      ),
    ]);
  }

  // ENQUIRY INFO
  Widget _enquiryInfoCard() {
    return _card("Enquiry Information", [
      ValueListenableBuilder(
        valueListenable: _selectedFinalStage,
        builder: (context, value, child) {
          return CustomDropDownWidget(
            title: "Stage",
            hintText: "Select Stage",
            isDisabled: _isEditMode,
            initialValue: _selectedFinalStage.value,
            dataList: stageTypeList,
            onSelected: (v) {
              _selectedFinalStage.value = v;
              _selectedFinalStageDetail.value = null;
            },
            onValueClear: () {
              _selectedFinalStage.value = null;
              _selectedFinalStageDetail.value = null;
            },
          );
        },
      ),
      AnimatedBuilder(
        animation: Listenable.merge([
          _selectedFinalStageDetail,
          _selectedFinalStage,
        ]),
        builder: (context, child) {
          return _selectedFinalStage.value?["DisplayName"]
                      .toString()
                      .toLowerCase() ==
                  'lost'
              ? CustomDropDownWidget(
                title: "Final Stage Detail",
                hintText: "Select Final Stage Detail",
                isRequired: true,
                isDisabled: _isEditMode,
                initialValue: _selectedFinalStageDetail.value,
                dataList: finalStageDetailsList,
                onSelected: (v) => _selectedFinalStageDetail.value = v,
                onValueClear: () => _selectedFinalStageDetail.value = null,
                validator:
                    (v) => v == null ? 'Final Stage Detail is required' : null,
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
          readOnly: _isEditMode,
          startDate: DateTime.now(),
          initialDate: _nextFollowUpDate,
          setValue: (v) => _nextFollowUpDate = v,
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
            dataFetchCallBack: _fetchSalesEmployees,
            onSelected: (value) => _selectedSaleAdvisorNotifier.value = value,
          );
        },
      ),
      CustomMultipleSelectPopup(
        title: 'Sourcing Manager',
        isMultiSelect: false,
        initialValue: _selectedSourcingManager,
        dataList: const [],
        dataFetchCallBack: _fetchSalesEmployees,
        onSelected: (value) => _selectedSourcingManager = value,
      ),
      CustomTimePicker(
        title: 'Customer Time Out',
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
