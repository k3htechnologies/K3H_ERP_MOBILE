// SAME IMPORTS (unchanged)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/modules_workflow_approval.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
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
  final UtilsRepository _utilsRepository = serviceLocator<UtilsRepository>();

  // EDIT MODE
  bool get _isEditMode => widget.enquiryModel != null;
  // VARIABLE FOR VALIDATION
  final _formKey = GlobalKey<FormState>();
  // TIME VARIABLE
  String? _timeInC;
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
  final ValueNotifier<String> _channelPartnerMobileNotifier = ValueNotifier('');
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
      _channelPartnerMobileC,
      _teamMemberNameC,
      _teamMemberMobileC,
      _remarkC,
      otpController;
  late ProjectModel _project;

  // STATIC DROPDOWN LISTS
  final List<Map<String, dynamic>> currentAccommodation = [
    {'zAttributesId': 1, 'DisplayName': 'Rented'},
    {'zAttributesId': 2, 'DisplayName': 'Self-Owned'},
  ];

  final List<Map<String, dynamic>> occupationType = [
    {'zAttributesId': 1, 'DisplayName': 'Business'},
    {'zAttributesId': 2, 'DisplayName': 'Homemaker'},
    {'zAttributesId': 3, 'DisplayName': 'Professional'},
    {'zAttributesId': 4, 'DisplayName': 'Salaried'},
    {'zAttributesId': 5, 'DisplayName': 'Retired'},
  ];

  final List<Map<String, dynamic>> sourceTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'Channel Partner'},
    {'zAttributesId': 2, 'DisplayName': 'Direct Walking'},
  ];

  final List<Map<String, dynamic>> residentialType = [
    {'zAttributesId': 1, 'DisplayName': '1 RK'},
    {'zAttributesId': 2, 'DisplayName': '1 BHK'},
    {'zAttributesId': 3, 'DisplayName': '2 BHK'},
    {'zAttributesId': 4, 'DisplayName': '3 BHK'},
    {'zAttributesId': 5, 'DisplayName': '4 BHK'},
    {'zAttributesId': 6, 'DisplayName': '5 BHK'},
    {'zAttributesId': 7, 'DisplayName': '6 BHK'},
    {'zAttributesId': 8, 'DisplayName': '7 BHK'},
    {'zAttributesId': 9, 'DisplayName': '8 BHK'},
    {'zAttributesId': 10, 'DisplayName': '9 BHK'},
    {'zAttributesId': 11, 'DisplayName': '10 BHK'},
    {'zAttributesId': 12, 'DisplayName': '1 + 1 JODI'},
    {'zAttributesId': 13, 'DisplayName': '2 + 1 JODI'},
    {'zAttributesId': 14, 'DisplayName': '2 + 2 JODI'},
    {'zAttributesId': 15, 'DisplayName': '2 + 3 JODI'},
    {'zAttributesId': 16, 'DisplayName': 'Duplex'},
    {'zAttributesId': 17, 'DisplayName': 'PENTHOUSE'},
  ];

  final List<Map<String, dynamic>> floorBrand = [
    {'zAttributesId': 1, 'DisplayName': 'Higher'},
    {'zAttributesId': 2, 'DisplayName': 'Middle'},
    {'zAttributesId': 3, 'DisplayName': 'Lower'},
  ];

  final List<Map<String, dynamic>> budgetInCrList = [
    {'zAttributesId': 1, 'DisplayName': '<1'},
    {'zAttributesId': 2, 'DisplayName': '1.5'},
    {'zAttributesId': 3, 'DisplayName': '2'},
    {'zAttributesId': 4, 'DisplayName': '2.5'},
    {'zAttributesId': 5, 'DisplayName': '3'},
    {'zAttributesId': 6, 'DisplayName': '3.5'},
    {'zAttributesId': 7, 'DisplayName': '4'},
    {'zAttributesId': 8, 'DisplayName': '4.5'},
    {'zAttributesId': 9, 'DisplayName': '5'},
    {'zAttributesId': 10, 'DisplayName': '5.5'},
    {'zAttributesId': 11, 'DisplayName': '6'},
    {'zAttributesId': 12, 'DisplayName': '6.5'},
    {'zAttributesId': 13, 'DisplayName': '7'},
    {'zAttributesId': 14, 'DisplayName': '7.5'},
    {'zAttributesId': 15, 'DisplayName': '8'},
    {'zAttributesId': 16, 'DisplayName': '8.5'},
    {'zAttributesId': 17, 'DisplayName': '9'},
    {'zAttributesId': 18, 'DisplayName': '9.5'},
    {'zAttributesId': 19, 'DisplayName': '10'},
    {'zAttributesId': 20, 'DisplayName': '10.5'},
    {'zAttributesId': 21, 'DisplayName': '11'},
    {'zAttributesId': 22, 'DisplayName': '11.5'},
    {'zAttributesId': 23, 'DisplayName': '12'},
    {'zAttributesId': 24, 'DisplayName': '12.5'},
    {'zAttributesId': 25, 'DisplayName': '15'},
    {'zAttributesId': 26, 'DisplayName': '15.5'},
    {'zAttributesId': 27, 'DisplayName': '20'},
    {'zAttributesId': 28, 'DisplayName': '20.5'},
    {'zAttributesId': 29, 'DisplayName': '25+'},
  ];

  final List<Map<String, dynamic>> possessionType = [
    {'zAttributesId': 1, 'DisplayName': 'RTMI'},
    {'zAttributesId': 2, 'DisplayName': 'Under 1 Year'},
    {'zAttributesId': 3, 'DisplayName': '1 Years To 2 Years'},
    {'zAttributesId': 4, 'DisplayName': '2 Years To 3 Years'},
    {'zAttributesId': 5, 'DisplayName': '3 Years & Above'},
  ];

  final List<Map<String, dynamic>> requirementType = [
    {'zAttributesId': 1, 'DisplayName': 'Commercial'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial Leasing'},
    {'zAttributesId': 3, 'DisplayName': 'Residential'},
  ];

  final List<Map<String, dynamic>> commercialUnitTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'OFFICE'},
    {'zAttributesId': 2, 'DisplayName': 'SHOP'},
  ];
  final List<Map<String, dynamic>> commercialLeasingTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'OFFICE'},
    {'zAttributesId': 2, 'DisplayName': 'SHOP'},
  ];

  final List<Map<String, dynamic>> timelineTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'Within 1 Month'},
    {'zAttributesId': 2, 'DisplayName': 'Beyond 1 Month'},
  ];

  final List<Map<String, dynamic>> fundingSourceList = [
    {'zAttributesId': 1, 'DisplayName': 'Loan'},
    {'zAttributesId': 2, 'DisplayName': 'Self-funded'},
    {'zAttributesId': 3, 'DisplayName': 'Sale Of Property'},
  ];

  final List<Map<String, dynamic>> ethnicityList = [
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
    {'zAttributesId': 1, 'DisplayName': 'Site Visit'},
    {'zAttributesId': 2, 'DisplayName': 'Re - Visit Proposed'},
    {'zAttributesId': 3, 'DisplayName': 'Re - Visit Scheduled'},
    {'zAttributesId': 4, 'DisplayName': 'Negotiation'},
    {'zAttributesId': 5, 'DisplayName': 'Unit Selection / Blocked'},
    {'zAttributesId': 6, 'DisplayName': 'Booking Done'},
    {'zAttributesId': 7, 'DisplayName': 'Blocked'},
    {'zAttributesId': 8, 'DisplayName': 'Cancelled'},
    {'zAttributesId': 9, 'DisplayName': 'Retention'},
    {'zAttributesId': 10, 'DisplayName': 'Lost'},
  ];

  final List<Map<String, dynamic>> finalStageDetailsList = [
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
    {'zAttributesId': 1, 'DisplayName': 'Channel Partner Data Calling'},
    {'zAttributesId': 2, 'DisplayName': 'Channel Partner Walked IN'},
    {'zAttributesId': 3, 'DisplayName': 'Digital Activity'},
  ];

  final List<Map<String, dynamic>> directWalkingSubSourceList = [
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
    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedProjectNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedFlatNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _flatDetailsNotifier = ValueNotifier(null);
    user = getCurrentUser();
    _project = getProject();
    if (_isEditMode) {
      _populateForm(widget.enquiryModel!);
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
    _countryOfResidenceC = TextEditingController();
    _cityOfResidenceC = TextEditingController();
    _channelPartnerMobileC = TextEditingController();
    _teamMemberNameC = TextEditingController();
    _teamMemberMobileC = TextEditingController();
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
  void _populateForm(EnquiryModel model) async {
    // TEXT CONTROLLERS
    _nameC.text = model.name;
    _mobileC.text = model.mobileNumber;
    _emailC.text = model.emailId;
    _locationC.text = model.currentLocation;
    _areaPrefC.text =
        model.areaPreferred == 0 ? "" : model.areaPreferred.toStringAsFixed(0);
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
    Map<String, dynamic>? findItem(
      List<Map<String, dynamic>> list,
      String value,
    ) {
      if (value.isEmpty) {
        return null;
      }
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

    final payload = {
      "EnquiryId": _isEditMode ? widget.enquiryModel!.enquiryId : 0,
      if (_isEditMode) "Uniquekey": widget.enquiryModel!.uniquekey,
      "ProjectId": getProject().projectId,
      "EnquiryTimeIn": _timeInC,
      "EnquiryTimeOut": null,
      "Name": _nameC.text.trim(),
      "MobileNumber": _mobileC.text.trim(),
      "EmailId": _emailC.text.trim(),
      "DateOfBirth": _dateOfBirthNotifier.value?.toIso8601String(),
      "Accommodation": getDisplayOrEmpty(_selectedAccommodationNotifier.value),
      "OccupationType": getDisplayOrEmpty(_selectedOccupationType.value),
      "Source": source,
      "SubSource": getDisplayOrEmpty(_selectedSubSourceNotifier.value),
      "SubSubSource": subSubSource,
      if (_selectedProjectNotifier.value.isNotEmpty &&
          subSource.toLowerCase().contains('Reference'.toLowerCase()))
        "ReferralProjectId":
            _selectedProjectNotifier.value.first["zAttributesId"],
      if (_selectedProjectNotifier.value.isNotEmpty &&
          subSource.toLowerCase().contains('Reference'.toLowerCase()))
        "ReferralInventoryFlatId":
            _selectedFlatNotifier.value.first["zAttributesId"],
      if (_selectedProjectNotifier.value.isNotEmpty &&
          subSource.toLowerCase().contains('Loyalty'.toLowerCase()))
        "LoyaltyProjectId":
            _selectedProjectNotifier.value.first["zAttributesId"],
      if (_selectedFlatNotifier.value.isNotEmpty &&
          subSource.toLowerCase().contains('Loyalty'.toLowerCase()))
        "LoyaltyInventoryFlatId":
            _selectedFlatNotifier.value.first["zAttributesId"],
      if (_selectedEmployeeNotifier.value.isNotEmpty &&
          subSource.toLowerCase().contains('Employee Reference'.toLowerCase()))
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
      "PossessionType": getDisplayOrEmpty(_selectedPossessionType.value),
      "AreaPreferred": double.tryParse(_areaPrefC.text.trim()) ?? 0,
      "DesiredFloorBand": getDisplayOrEmpty(_selectedFloorBand.value),
      "Budget": _selectedBudgetInCr.value?["DisplayName"] ?? "",
      "Requirement": getDisplayOrEmpty(_selectedRequirementNotifier.value),
      "RequirementType": requirementTypeValue,
      "CustomerClassification": customerClassification,
      "SourceOfFunding": getDisplayOrEmpty(_selectedFunding.value),
      "Ethnicity": getDisplayOrEmpty(_selectedEthnicity.value),
      "FinalStage": getDisplayOrEmpty(_selectedFinalStage.value),
      "FinalStageDetail": getDisplayOrEmpty(_selectedFinalStageDetail.value),
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
      queryParams["EmployeeName"] = value;
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
                      "${employee.fullName} - ${employee.department} - ${employee.designation}",
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
                    hintText: "Select Source",
                    isRequired: true,
                    initialValue: selectedSource,
                    dataList: sourceTypeList,
                    onSelected: (v) {
                      _selectedSourceNotifier.value = v;
                      _selectedSubSourceNotifier.value = null;
                      _selectedSubSubSourceNotifier.value = null;
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
                      title: "Sub Source",
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
                          if (!isChannelPartner || mobileValue.length != 10) {
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

                                    CustomTextField(
                                      title: "Team Member Mobile Number",
                                      hint: "Enter Mobile Number",
                                      textController: _teamMemberMobileC,
                                      keyboardType: TextInputType.phone,
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
                                        if (_teamMemberNameC.text.isNotEmpty &&
                                            _teamMemberMobileC.text.isEmpty) {
                                          return "Team member mobile number is required";
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
              _selectedFinalStageDetail.value = finalStageDetailsList.first;
            },
            onValueClear: () => _selectedFinalStage.value = null,
          );
        },
      ),
      ValueListenableBuilder(
        valueListenable: _selectedFinalStageDetail,
        builder: (context, value, child) {
          return ValueListenableBuilder(
            valueListenable: _selectedFinalStage,
            builder: (context, finalStage, child) {
              return finalStage?["zAttributesId"] == 5
                  ? CustomDropDownWidget(
                    title: "Final Stage Detail",
                    hintText: "Select Final Stage Details",
                    isDisabled: _isEditMode,
                    initialValue: _selectedFinalStageDetail.value,
                    dataList: finalStageDetailsList,
                    onSelected: (v) => _selectedFinalStageDetail.value = v,
                    onValueClear: () => _selectedFinalStageDetail.value = null,
                  )
                  : SizedBox.shrink();
            },
          );
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
