import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddEmployeeScreen extends StatefulWidget {
  final UserModel? employee;
  final int index;

  const AddEmployeeScreen({super.key, this.employee, required this.index});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  // CUBIT
  late EmployeeMasterCubit _employeeMasterCubit;

  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // FORM KEYS
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // TEXT EDITING CONTROLLER
  late final TextEditingController
      // BASIC EMPLOYEE DETAILS
      _firstNameC,
      _middleNameC,
      _lastNameC,
      _officeEmailIdC,
      _personalEmailC,
      _personalMobileNumberC,
      _officeMobileNumberC,
      _emergencyContactNumberC,
      // ADDRESS
      _communicationAddressC,
      _permanentAddressC,
      // BANK DETAILS
      _bankBranchNameC,
      _accountNumberC,
      _ifscC;

  //EDIT MODE
  bool get _isEditMode => widget.employee != null;

  // LISTS
  List<Map<String, dynamic>> genderList = [
    {"zAttributesId": 1, "DisplayName": "Male"},
    {"zAttributesId": 2, "DisplayName": "Female"},
    {"zAttributesId": 3, "DisplayName": "Other"},
  ];
  List<Map<String, dynamic>> maritalStatusList = [
    {"zAttributesId": 1, "DisplayName": "Single"},
    {"zAttributesId": 2, "DisplayName": "Married"},
    {"zAttributesId": 3, "DisplayName": "Divorced"},
    {"zAttributesId": 4, "DisplayName": "Widowed"},
    {"zAttributesId": 5, "DisplayName": "Separated"},
  ];
  List<Map<String, dynamic>> bloodGroupList = [
    {"zAttributesId": 1, "DisplayName": "A+"},
    {"zAttributesId": 2, "DisplayName": "A-"},
    {"zAttributesId": 3, "DisplayName": "O+"},
    {"zAttributesId": 4, "DisplayName": "O-"},
    {"zAttributesId": 5, "DisplayName": "AB+"},
    {"zAttributesId": 6, "DisplayName": "AB-"},
    {"zAttributesId": 7, "DisplayName": "B+"},
    {"zAttributesId": 8, "DisplayName": "B-"},
  ];

  List<Map<String, dynamic>> employmentTypeList = [
    {"zAttributesId": 1, "DisplayName": "Permanent"},
    {"zAttributesId": 2, "DisplayName": "Contract"},
    {"zAttributesId": 3, "DisplayName": "Intern"},
    {"zAttributesId": 4, "DisplayName": "Part Time"},
    {"zAttributesId": 5, "DisplayName": "Temporary"},
  ];

  List<Map<String, dynamic>> relationToEmployeeList = [
    {"zAttributesId": 1, "DisplayName": "Father"},
    {"zAttributesId": 2, "DisplayName": "Mother"},
    {"zAttributesId": 3, "DisplayName": "Spouse"},
    {"zAttributesId": 4, "DisplayName": "Sibling"},
    {"zAttributesId": 5, "DisplayName": "Child"},
    {"zAttributesId": 6, "DisplayName": "Son"},
    {"zAttributesId": 7, "DisplayName": "Daughter"},
    {"zAttributesId": 8, "DisplayName": "Grandfather"},
    {"zAttributesId": 9, "DisplayName": "Grandmother"},
    {"zAttributesId": 10, "DisplayName": "Uncle"},
    {"zAttributesId": 11, "DisplayName": "Aunty"},
    {"zAttributesId": 12, "DisplayName": "Cousin"},
    {"zAttributesId": 13, "DisplayName": "Friend"},
    {"zAttributesId": 14, "DisplayName": "Other"},
  ];

  // EMPLOYEE INFO SHEET
  Map<String, dynamic>? selectedState;
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedVillage;

  // DROPDOWN NOTIFIERS
  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedReportingPersonNotifier;

  late final ValueNotifier<Map<String, dynamic>?> _selectedGenderNotifier;
  late final ValueNotifier<Map<String, dynamic>?>
  _selectedMaritalStatusNotifier;
  late final ValueNotifier<Map<String, dynamic>?> _selectedBloodGroupNotifier;
  late final ValueNotifier<Map<String, dynamic>?>
  _selectedEmploymentTypeNotifier;
  late final ValueNotifier<Map<String, dynamic>?> _selectedRelationNotifier;

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedCompany = [];
  List<Map<String, dynamic>> _selectedDepartment = [];
  List<Map<String, dynamic>> _selectedBranch = [];
  List<Map<String, dynamic>> _selectedDesignation = [];
  List<Map<String, dynamic>> _selectedBank = [];

  // DATES
  // BASIC EMPLOYEE DETAILS
  DateTime? dateOfBirth;

  // EMPLOYEE INFO SHEET
  DateTime? joiningDate;
  DateTime? idCardIssueDateDate;

  @override
  void initState() {
    super.initState();
    _employeeMasterCubit = BlocProvider.of<EmployeeMasterCubit>(context);
    _initializeTextEditingController();

    _selectedReportingPersonNotifier =
        ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedGenderNotifier = ValueNotifier<Map<String, dynamic>?>(null);
    _selectedMaritalStatusNotifier = ValueNotifier(null);
    _selectedBloodGroupNotifier = ValueNotifier(null);
    _selectedEmploymentTypeNotifier = ValueNotifier(null);
    _selectedRelationNotifier = ValueNotifier(null);

    if (widget.employee != null) {
      _prefillDetailsToAddUpdateEmployeeMaster(widget.employee!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _selectedReportingPersonNotifier.dispose();
    // BASIC EMPLOYEE DETAILS
    _firstNameC.dispose();
    _middleNameC.dispose();
    _lastNameC.dispose();
    _officeEmailIdC.dispose();
    _personalEmailC.dispose();
    _personalMobileNumberC.dispose();
    _officeMobileNumberC.dispose();
    _emergencyContactNumberC.dispose();
    // ADDRESS
    _communicationAddressC.dispose();
    _permanentAddressC.dispose();
    _bankBranchNameC.dispose();
    _accountNumberC.dispose();
    _ifscC.dispose();
    _selectedGenderNotifier.dispose();
    _selectedMaritalStatusNotifier.dispose();
    _selectedBloodGroupNotifier.dispose();
    _selectedEmploymentTypeNotifier.dispose();
    _selectedRelationNotifier.dispose();

    for (var key in _formKeys) {
      key.currentState?.dispose();
    }
  }

  // PREFILL DETAILS TO EDIT MODE
  Future<void> _prefillDetailsToAddUpdateEmployeeMaster(
    UserModel employee,
  ) async {
    // BASIC EMPLOYEE DETAILS
    _firstNameC.text = employee.firstName;
    _middleNameC.text = employee.middleName;
    _lastNameC.text = employee.lastName;
    _officeEmailIdC.text = employee.officeEmailId;
    _personalEmailC.text = employee.emailId;
    _personalMobileNumberC.text = employee.personalMobileNumber;
    _officeMobileNumberC.text = employee.officeMobileNumber;
    _emergencyContactNumberC.text = employee.emergencyMobileNumber;
    // ADDRESS
    _communicationAddressC.text = employee.communicationAddress;
    _permanentAddressC.text = employee.permanentAddress;
    // BANK DETAILS
    _bankBranchNameC.text = employee.bankBranchName;
    _accountNumberC.text = employee.accountNo;
    _ifscC.text = employee.ifscCode;

    // DROPDOWNS
    _selectedGenderNotifier.value = genderList.firstWhere(
      (item) => item['DisplayName'] == employee.gender,
      orElse: () => genderList.first,
    );
    _selectedMaritalStatusNotifier.value = maritalStatusList.firstWhere(
      (item) => item['DisplayName'] == employee.maritalStatus,
      orElse: () => maritalStatusList.first,
    );

    _selectedBloodGroupNotifier.value = bloodGroupList.firstWhere(
      (item) => item['DisplayName'] == employee.bloodGroup,
      orElse: () => bloodGroupList.first,
    );

    _selectedEmploymentTypeNotifier.value = employmentTypeList.firstWhere(
      (item) => item['DisplayName'] == employee.employeeType,
    );

    _selectedRelationNotifier.value = relationToEmployeeList.firstWhere(
      (item) =>
          item['DisplayName'] == employee.emergencyContactPersonRelationship,
      orElse: () => relationToEmployeeList.first,
    );

    selectedState = {
      'zAttributesId': employee.stateMasterId,
      'DisplayName': employee.stateName,
    };
    selectedDistrict = {
      'zAttributesId': employee.districtMasterId,
      'DisplayName': employee.districtName,
    };

    selectedCity = {
      'zAttributesId': employee.cityMasterId,
      'DisplayName': employee.cityName,
    };
    selectedVillage = {
      'zAttributesId': employee.villageMasterId,
      'DisplayName': employee.villageName,
    };
    // DATES
    dateOfBirth = employee.dateOfBirth;
    joiningDate = employee.joiningDate;
    idCardIssueDateDate = employee.idCardIssuedDate;
    if (employee.companyId > 0) {
      _selectedCompany = [
        {
          "zAttributesId": employee.companyId,
          "DisplayName": employee.companyName,
        },
      ];
    }
    if (employee.departmentMasterId > 0) {
      _selectedDepartment = [
        {
          "zAttributesId": employee.departmentMasterId,
          "DisplayName": employee.department,
        },
      ];
    }
    if (employee.branchMasterId > 0) {
      _selectedBranch = [
        {
          "zAttributesId": employee.branchMasterId,
          "DisplayName": employee.branch,
        },
      ];
    }
    if (employee.designationMasterId > 0) {
      _selectedDesignation = [
        {
          "zAttributesId": employee.designationMasterId,
          "DisplayName": employee.designation,
        },
      ];
    }
    _selectedReportingPersonNotifier.value = [
      {
        'zAttributesId': widget.employee!.reportPersonId,
        'DisplayName': widget.employee!.reportPersonName,
      },
    ];
    if (employee.bankListMasterId > 0) {
      _selectedBank = [
        {
          "zAttributesId": employee.bankListMasterId,
          "DisplayName": employee.bankName,
        },
      ];
    }
    _fetchEmployeeDetailsForEdit(widget.employee!.reportPersonId);
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    // BASIC EMPLOYEE DETAILS
    _firstNameC = TextEditingController();
    _middleNameC = TextEditingController();
    _lastNameC = TextEditingController();
    _officeEmailIdC = TextEditingController();
    _personalEmailC = TextEditingController();
    _personalMobileNumberC = TextEditingController();
    _officeMobileNumberC = TextEditingController();
    _emergencyContactNumberC = TextEditingController();
    // ADDRESS
    _communicationAddressC = TextEditingController();
    _permanentAddressC = TextEditingController();
    // BANK DETAILS
    _bankBranchNameC = TextEditingController();
    _accountNumberC = TextEditingController();
    _ifscC = TextEditingController();
  }

  // FETCH DEPARTMENTS
  Future<Map<String, dynamic>> _fetchDepartment(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 15;

    //  SEARCH MODE
    if (value != null) {
      await _employeeMasterCubit.getDepartmentList(
        context,
        pageNumber,
        pageSize,
        searchQuery: value,
      );

      final departmentList = _employeeMasterCubit.state.departmentList;

      final totalCount = _employeeMasterCubit.state.departmentTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final dept in departmentList) {
        uniqueFiltered[dept.departmentMasterId] = {
          "zAttributesId": dept.departmentMasterId,
          "DisplayName": dept.departmentName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _employeeMasterCubit.state.departmentTotalCount;

    final currentLoadedCount = _employeeMasterCubit.state.departmentList.length;

    if (currentLoadedCount < totalCount) {
      await _employeeMasterCubit.getDepartmentList(
        context,
        pageNumber,
        pageSize,
      );
    }

    final updatedList = _employeeMasterCubit.state.departmentList;

    final Map<int, Map<String, dynamic>> uniqueDepartments = {};

    for (final dept in updatedList) {
      uniqueDepartments[dept.departmentMasterId] = {
        "zAttributesId": dept.departmentMasterId,
        "DisplayName": dept.departmentName,
      };
    }

    return {
      "itemList": uniqueDepartments.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueDepartments.length,
    };
  }

  // FETCH EMPLOYEE
  Future<void> _fetchEmployeeDetailsForEdit(int employeeId) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: 1,
      pageSize: 1,
      queryParams: {'EmployeeId': employeeId},
    );
    result.fold((_) {}, (response) {
      // Repository already returns List<UserModel> in response['data']
      final employees = response['data'] as List<UserModel>? ?? [];
      if (employees.isEmpty) return;
      final employee = employees.first;
      if (!mounted) return;
      _selectedReportingPersonNotifier.value = [
        {
          'zAttributesId': employee.employeeId,
          'DisplayName': employee.fullName,
          'employeeCode': employee.employeeCode,
          'department': employee.department,
          'designation': employee.designation,
          'branch': employee.branch,
          'email': employee.emailId,
          'personalNumber': employee.personalMobileNumber,
          'reportingPerson': employee.reportPersonName,
        },
      ];
    });
  }

  // FETCH COMPANIES
  Future<Map<String, dynamic>> _fetchCompany(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 15;

    //  SEARCH MODE
    if (value != null) {
      await _employeeMasterCubit.getCompanies(
        context,
        pageNumber,
        pageSize,
        searchQuery: value,
      );

      final companyList = _employeeMasterCubit.state.companyNameList;
      final totalCount = _employeeMasterCubit.state.companyNameTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final comp in companyList) {
        uniqueFiltered[comp.companyId] = {
          "zAttributesId": comp.companyId,
          "DisplayName": comp.companyName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _employeeMasterCubit.state.companyNameTotalCount;
    final currentLoadedCount =
        _employeeMasterCubit.state.companyNameList.length;

    // LOAD NEXT PAGE
    if (currentLoadedCount < totalCount) {
      await _employeeMasterCubit.getCompanies(context, pageNumber, pageSize);
    }

    final updatedList = _employeeMasterCubit.state.companyNameList;

    final Map<int, Map<String, dynamic>> uniqueCompanies = {};

    for (final comp in updatedList) {
      uniqueCompanies[comp.companyId] = {
        "zAttributesId": comp.companyId,
        "DisplayName": comp.companyName,
      };
    }

    return {
      "itemList": uniqueCompanies.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueCompanies.length,
    };
  }

  // FETCH DESIGNATIONS
  Future<Map<String, dynamic>> _fetchDesignations(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 15;

    //  SEARCH MODE
    if (value != null) {
      await _employeeMasterCubit.getDesignationList(
        context,
        pageNumber,
        pageSize,
        searchQuery: value,
      );

      final designationList = _employeeMasterCubit.state.designationList;
      final totalCount = _employeeMasterCubit.state.designationTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final dept in designationList) {
        uniqueFiltered[dept.designationMasterId] = {
          "zAttributesId": dept.designationMasterId,
          "DisplayName": dept.designationName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _employeeMasterCubit.state.designationTotalCount;

    final currentLoadedCount =
        _employeeMasterCubit.state.designationList.length;

    if (currentLoadedCount < totalCount) {
      await _employeeMasterCubit.getDesignationList(
        context,
        pageNumber,
        pageSize,
      );
    }

    final updatedList = _employeeMasterCubit.state.designationList;

    final Map<int, Map<String, dynamic>> uniqueDesignations = {};

    for (final dept in updatedList) {
      uniqueDesignations[dept.designationMasterId] = {
        "zAttributesId": dept.designationMasterId,
        "DisplayName": dept.designationName,
      };
    }

    return {
      "itemList": uniqueDesignations.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueDesignations.length,
    };
  }

  // FETCH BRANCH
  Future<Map<String, dynamic>> _fetchBranch(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 15;

    //  SEARCH MODE
    if (value != null) {
      await _employeeMasterCubit.getBranch(
        context,
        pageNumber,
        pageSize,
        searchQuery: value,
      );

      final branchList = _employeeMasterCubit.state.branchList;
      final totalCount = _employeeMasterCubit.state.branchTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final branch in branchList) {
        uniqueFiltered[branch.branchMasterId] = {
          "zAttributesId": branch.branchMasterId,
          "DisplayName": branch.branchName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _employeeMasterCubit.state.branchTotalCount;
    final currentLoadedCount = _employeeMasterCubit.state.branchList.length;

    if (currentLoadedCount < totalCount) {
      await _employeeMasterCubit.getBranch(context, pageNumber, pageSize);
    }

    final updatedList = _employeeMasterCubit.state.branchList;

    final Map<int, Map<String, dynamic>> uniqueBranches = {};

    for (final branch in updatedList) {
      uniqueBranches[branch.branchMasterId] = {
        "zAttributesId": branch.branchMasterId,
        "DisplayName": branch.branchName,
      };
    }

    return {
      "itemList": uniqueBranches.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueBranches.length,
    };
  }

  // FETCH REPORTING PERSON
  Future<Map<String, dynamic>> _fetchReportingPerson(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 15;

    //  SEARCH MODE
    if (value != null) {
      await _employeeMasterCubit.getEmployee(
        context,
        pageNumber,
        pageSize,
        searchQuery: value,
      );

      final reportingPersonList =
          _employeeMasterCubit.state.reportingPersonList;
      final totalCount = _employeeMasterCubit.state.reportingPersonTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final rp in reportingPersonList) {
        uniqueFiltered[rp.employeeId] = {
          "zAttributesId": rp.employeeId,
          "DisplayName": rp.fullName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _employeeMasterCubit.state.reportingPersonTotalCount;
    final currentLoadedCount =
        _employeeMasterCubit.state.reportingPersonList.length;

    if (currentLoadedCount < totalCount) {
      await _employeeMasterCubit.getEmployee(context, pageNumber, pageSize);
    }

    final updatedList = _employeeMasterCubit.state.reportingPersonList;

    final Map<int, Map<String, dynamic>> uniqueReportingPersons = {};

    for (final rp in updatedList) {
      uniqueReportingPersons[rp.employeeId] = {
        "zAttributesId": rp.employeeId,
        "DisplayName": rp.fullName,
      };
    }

    return {
      "itemList": uniqueReportingPersons.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueReportingPersons.length,
    };
  }

  Future<Map<String, dynamic>> _fetchBank(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 15;

    //  SEARCH MODE
    if (value != null) {
      await _employeeMasterCubit.getBankList(
        context,
        pageNumber,
        pageSize,
        searchQuery: value,
      );

      final bankList = _employeeMasterCubit.state.bankList;
      final totalCount = _employeeMasterCubit.state.bankTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final bank in bankList) {
        uniqueFiltered[bank.bankListMasterId] = {
          "zAttributesId": bank.bankListMasterId,
          "DisplayName": bank.bankNameWithCode,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _employeeMasterCubit.state.bankTotalCount;
    final currentLoadedCount = _employeeMasterCubit.state.bankList.length;

    if (currentLoadedCount < totalCount) {
      await _employeeMasterCubit.getBankList(context, pageNumber, pageSize);
    }

    final updatedList = _employeeMasterCubit.state.bankList;

    final Map<int, Map<String, dynamic>> uniqueBanks = {};

    for (final bank in updatedList) {
      uniqueBanks[bank.bankListMasterId] = {
        "zAttributesId": bank.bankListMasterId,
        "DisplayName": bank.bankNameWithCode,
      };
    }

    return {
      "itemList": uniqueBanks.values.toList(),
      "totalNumberOfRecord": totalCount > 0 ? totalCount : uniqueBanks.length,
    };
  }

  // <---- ADD UPDATE EMPLOYEE ---->
  Future<void> _handleSubmit() async {
    if (!mounted) {
      return;
    }

    // VALIDATE ALL FORMS
    bool allValid = true;
    for (var formKey in _formKeys) {
      if (!formKey.currentState!.validate()) {
        allValid = false;
      }
    }

    if (!allValid) {
      return;
    }

    await _addUpdateEmployee(widget.employee, index: widget.index);
  }

  // ADD UPDATE EMPLOYEE
  Future<void> _addUpdateEmployee(UserModel? employee, {int index = 0}) async {
    if (!mounted) {
      return;
    }
    final selectedReportingPerson = _selectedReportingPersonNotifier.value;
    if (employee != null) {
      await _employeeMasterCubit.updateEmployeeMaster(
        index: widget.index,
        employeeMasterId: employee.employeeId,
        uniqueKey: employee.uniqueKey,
        context: context,
        firstName: _firstNameC.text.trim(),
        middleName: _middleNameC.text.trim(),
        lastName: _lastNameC.text.trim(),
        selectedGender: _selectedGenderNotifier.value!["DisplayName"],
        selectedMaritalStatus:
            _selectedMaritalStatusNotifier.value!["DisplayName"],
        selectedBloodGroup: _selectedBloodGroupNotifier.value!["DisplayName"],
        selectedBranchId: int.parse(
          _selectedBranch[0]["zAttributesId"].toString(),
        ),
        dateOfBirth: dateOfBirth!,
        joiningDate: joiningDate!,
        idCardIssueDate: idCardIssueDateDate,
        officeEmailId: _officeEmailIdC.text.trim(),
        personalEmailId: _personalEmailC.text.trim(),
        personalMobileNumber: _personalMobileNumberC.text,
        officeMobileNumber: _officeMobileNumberC.text,
        communicationAddress: _communicationAddressC.text.trim(),
        permanentAddress: _permanentAddressC.text.trim(),
        bankNameMasterId: int.parse(
          _selectedBank[0]['zAttributesId'].toString(),
        ),
        bankBranchName: _bankBranchNameC.text.trim(),
        accountNumber: _accountNumberC.text,
        ifscCode: _ifscC.text,
        selectedCompanyNameId: int.parse(
          _selectedCompany[0]["zAttributesId"].toString(),
        ),
        selectedDepartmentId: int.parse(
          _selectedDepartment[0]["zAttributesId"].toString(),
        ),
        selectedDesignationId: int.parse(
          _selectedDesignation[0]["zAttributesId"].toString(),
        ),
        selectedReportingPersonId:
            selectedReportingPerson.first['zAttributesId'] as int,
        selectedCountryNameId: 1,
        selectedStateId: selectedState!["zAttributesId"],
        selectedDistrictId: selectedDistrict!["zAttributesId"],
        selectedCityId: selectedCity!["zAttributesId"],
        selectedVillageId: selectedVillage!["zAttributesId"],
        employeeType: _selectedEmploymentTypeNotifier.value!['DisplayName'],
        emergencyContactPersonRelationship:
            _selectedRelationNotifier.value!['DisplayName'],
        emergencyMobileNumber: _emergencyContactNumberC.text,
      );
    } else {
      await _employeeMasterCubit.addEmployeeMaster(
        context: context,
        firstName: _firstNameC.text.trim(),
        middleName: _middleNameC.text.trim(),
        lastName: _lastNameC.text.trim(),
        selectedGender: _selectedGenderNotifier.value!["DisplayName"],
        selectedMaritalStatus:
            _selectedMaritalStatusNotifier.value!["DisplayName"],
        selectedBloodGroup: _selectedBloodGroupNotifier.value!["DisplayName"],
        selectedBranchId: int.parse(
          _selectedBranch[0]["zAttributesId"].toString(),
        ),
        dateOfBirth: dateOfBirth!,
        joiningDate: joiningDate!,
        idCardIssueDate: idCardIssueDateDate,
        officeEmailId: _officeEmailIdC.text.trim(),
        personalEmailId: _personalEmailC.text.trim(),
        personalMobileNumber: _personalMobileNumberC.text,
        officeMobileNumber: _officeMobileNumberC.text,
        communicationAddress: _communicationAddressC.text.trim(),
        permanentAddress: _permanentAddressC.text.trim(),
        bankNameMasterId: int.parse(
          _selectedBank[0]['zAttributesId'].toString(),
        ),
        bankBranchName: _bankBranchNameC.text.trim(),
        accountNumber: _accountNumberC.text,
        ifscCode: _ifscC.text,
        selectedCompanyNameId: int.parse(
          _selectedCompany[0]["zAttributesId"].toString(),
        ),
        selectedDepartmentId: int.parse(
          _selectedDepartment[0]["zAttributesId"].toString(),
        ),
        selectedDesignationId: int.parse(
          _selectedDesignation[0]["zAttributesId"].toString(),
        ),
        selectedReportingPersonId:
            selectedReportingPerson.first['zAttributesId'] as int,
        selectedCountryNameId: 1,
        selectedStateId: selectedState!["zAttributesId"],
        selectedDistrictId: selectedDistrict!["zAttributesId"],
        selectedCityId: selectedCity!["zAttributesId"],
        selectedVillageId: selectedVillage!["zAttributesId"],
        employeeType: _selectedEmploymentTypeNotifier.value!['DisplayName'],
        emergencyContactPersonRelationship:
            _selectedRelationNotifier.value!['DisplayName'],
        emergencyMobileNumber: _emergencyContactNumberC.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Employee Master",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    !_isEditMode ? "Add Employee" : "Update Employee",
                    style: AppTextStyle.ts16SB(),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildBasicDetailsSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildEmployeeInfoSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildAddressSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildBankDetailsSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
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
            onPressed: _handleSubmit,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }

  // ------------------------- UI SECTION BUILDERS ------------------------- //

  Widget _buildSectionContainer(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: commonCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  // BUILD HEADER SECTION
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppTextStyle.ts16M(color: AppColor.black.withValues(alpha: .5)),
      ),
    );
  }

  // <---- BASIC DETAILS SECTION ---->
  Widget _buildBasicDetailsSection() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Employee Details'),
          CustomTextField(
            title: 'First Name',
            hint: "Enter First Name",
            isRequired: true,
            inputFormatterList: InputValidator.textOnly(50),
            textController: _firstNameC,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First name is required';
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'Middle Name',
            hint: "Enter Middle Name",
            isRequired: true,
            textController: _middleNameC,
            inputFormatterList: InputValidator.textOnly(50),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Middle name is required';
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'Last Name',
            hint: "Enter Last Name",
            isRequired: true,
            inputFormatterList: InputValidator.textOnly(50),
            textController: _lastNameC,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
          ),
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedGenderNotifier,
            builder: (context, gender, _) {
              return CustomDropDownWidget(
                title: 'Gender',
                isRequired: true,
                initialValue: gender,
                hintText: "Select Gender",
                dataList: genderList,
                onSelected: (value) {
                  _selectedGenderNotifier.value = value;
                },
                validator: (value) {
                  if (value == null || value["zAttributesId"] == -1) {
                    return 'Gender is required';
                  }
                  return null;
                },
                onValueClear: () {
                  _selectedGenderNotifier.value = null;
                },
              );
            },
          ),
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedMaritalStatusNotifier,
            builder: (context, value, _) {
              return CustomDropDownWidget(
                title: 'Marital Status',
                isRequired: true,
                hintText: "Select Marital Status",
                initialValue: value,
                dataList: maritalStatusList,
                onSelected: (val) {
                  _selectedMaritalStatusNotifier.value = val;
                },
                onValueClear: () {
                  _selectedMaritalStatusNotifier.value = null;
                },
                validator: (val) {
                  if (val == null || val["zAttributesId"] == -1) {
                    return 'Marital Status is required';
                  }
                  return null;
                },
              );
            },
          ),
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedBloodGroupNotifier,
            builder: (context, value, _) {
              return CustomDropDownWidget(
                title: 'Blood Group',
                hintText: "Select Blood Group",
                isRequired: true,
                initialValue: value,
                dataList: bloodGroupList,
                onSelected: (val) {
                  _selectedBloodGroupNotifier.value = val;
                },
                onValueClear: () {
                  _selectedBloodGroupNotifier.value = null;
                },
                validator: (val) {
                  if (val == null || val["zAttributesId"] == -1) {
                    return 'Blood Group is required';
                  }
                  return null;
                },
              );
            },
          ),
          CustomDatePicker(
            title: 'DOB',
            isRequired: true,
            initialDate: dateOfBirth,
            validator: (value) {
              if (value == null) {
                return 'DOB is required';
              }
              if (!InputValidator.isValidAge(value)) {
                return 'Age should be greater than or equal to 18.';
              }
              return null;
            },
            setValue: (value) => dateOfBirth = value,
          ),
          CustomTextField(
            title: 'Email Id',
            hint: "Enter Email Id",
            isRequired: true,
            textController: _personalEmailC,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email Id is required';
              }
              if (!InputValidator.isValidEmail(value)) {
                return 'Email Id is not valid';
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'Office Email Id',
            hint: "Enter Office Email Id",
            textController: _officeEmailIdC,
            keyboardType: TextInputType.emailAddress,
          ),
          CustomTextField(
            title: 'Personal Mobile Number',
            hint: "Enter Personal Mobile Number",
            isRequired: true,
            textController: _personalMobileNumberC,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Personal Mobile Number is required';
              }
              if (!InputValidator.isValidMobileNumber(value)) {
                return 'Mobile number is not valid';
              }
              return null;
            },
            inputFormatterList: InputValidator.digit(10),
            prefixWidget: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 10),
                  Text("+91"),
                  VerticalDivider(
                    color: AppColor.black,
                    thickness: 0.5,
                    width: 15,
                    indent: 5,
                    endIndent: 5,
                  ),
                ],
              ),
            ),
          ),
          CustomTextField(
            title: 'Office Mobile Number',
            hint: "Enter Office Mobile Number",
            textController: _officeMobileNumberC,
            keyboardType: TextInputType.phone,
            inputFormatterList: InputValidator.digit(10),
          ),
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedEmploymentTypeNotifier,
            builder: (context, value, _) {
              return CustomDropDownWidget(
                title: 'Employee Type',
                hintText: "Select Employment Type",
                isRequired: true,
                initialValue: value,
                dataList: employmentTypeList,
                onSelected: (val) {
                  _selectedEmploymentTypeNotifier.value = val;
                },
                onValueClear: () {
                  _selectedEmploymentTypeNotifier.value = null;
                },
                validator: (val) {
                  if (val == null || val["zAttributesId"] == -1) {
                    return 'Employment Type is required';
                  }
                  return null;
                },
              );
            },
          ),
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedRelationNotifier,
            builder: (context, value, _) {
              return CustomDropDownWidget(
                title: 'Relation to Emergency Contact',
                isRequired: true,
                hintText: "Select Relation",
                initialValue: value,
                dataList: relationToEmployeeList,
                onSelected: (val) {
                  _selectedRelationNotifier.value = val;
                },
                onValueClear: () {
                  _selectedRelationNotifier.value = null;
                },
                validator: (val) {
                  if (val == null || val["zAttributesId"] == -1) {
                    return 'Relation to Emergency Contact is required';
                  }
                  return null;
                },
              );
            },
          ),
          CustomTextField(
            title: 'Emergency Contact Number',
            hint: "Enter Emergency Contact Number",
            isRequired: true,
            textController: _emergencyContactNumberC,
            keyboardType: TextInputType.phone,
            inputFormatterList: InputValidator.digit(10),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Emergency Contact Number is required';
              }
              if (!InputValidator.isValidMobileNumber(value)) {
                return 'Mobile number is not valid';
              }
              return null;
            },
            prefixWidget: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 10),
                  Text("+91"),
                  VerticalDivider(
                    color: AppColor.black,
                    thickness: 0.5,
                    width: 15,
                    indent: 5,
                    endIndent: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // <---- EMPLOYEE INFO SECTION ---->
  Widget _buildEmployeeInfoSection() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Employee Info Sheet'),
          CustomMultipleSelectPopup(
            title: "Company Name",
            isRequired: true,
            isMultiSelect: false,
            hintText: "Select Company",
            initialValue: _selectedCompany,
            dataFetchCallBack: _fetchCompany,
            dataList: [],
            onSelected: (value) {
              _selectedCompany = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Company is required';
              }
              return null;
            },
          ),
          CustomMultipleSelectPopup(
            title: "Department",
            hintText: "Select Department",
            isRequired: true,
            isMultiSelect: false,
            initialValue: _selectedDepartment,
            dataList: [],
            dataFetchCallBack: _fetchDepartment,
            onSelected: (value) {
              _selectedDepartment = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Department is required';
              }
              return null;
            },
          ),
          CustomMultipleSelectPopup(
            title: "Branch",
            hintText: "Select Branch",
            isRequired: true,
            isMultiSelect: false,
            initialValue: _selectedBranch,
            dataFetchCallBack: _fetchBranch,
            dataList: [],
            onSelected: (value) {
              _selectedBranch = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Branch is required';
              }
              return null;
            },
          ),
          CustomMultipleSelectPopup(
            title: "Designation",
            hintText: "Select Designation",
            isRequired: true,
            isMultiSelect: false,
            initialValue: _selectedDesignation,
            dataList: [],
            dataFetchCallBack: _fetchDesignations,
            onSelected: (value) {
              _selectedDesignation = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Designation is required';
              }
              return null;
            },
          ),
          CustomDatePicker(
            title: 'Joining Date',
            isRequired: true,
            initialDate: joiningDate,
            setValue: (value) => joiningDate = value,
            validator: (value) {
              if (value == null) {
                return 'Joining Date is required';
              }
              return null;
            },
          ),
          CustomDatePicker(
            title: 'Id Card Issued Date',
            initialDate: idCardIssueDateDate,
            setValue: (value) => idCardIssueDateDate = value,
          ),
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _selectedReportingPersonNotifier,
            builder: (context, selectedEmployee, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomMultipleSelectPopup(
                    title: "Reporting Person",
                    hintText: "Select Reporting Person",
                    isRequired: true,
                    isMultiSelect: false,
                    initialValue: selectedEmployee,
                    dataList: [],
                    dataFetchCallBack: _fetchReportingPerson,
                    onSelected: (value) async {
                      if (value.isEmpty) return;

                      final id = value.first['zAttributesId'] as int;

                      await _fetchEmployeeDetailsForEdit(id);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Reporting Person is required';
                      }
                      return null;
                    },
                    onClear: () {
                      _selectedReportingPersonNotifier.value = [];
                    },
                  ),
                  if (selectedEmployee.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColor.lightBlue),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Department",
                                value:
                                    selectedEmployee.first["department"] ?? '',
                              ),
                              buildColumnTitleValue(
                                title: "Designation",
                                value:
                                    selectedEmployee.first["designation"] ?? '',
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Branch",
                                value: selectedEmployee.first["branch"] ?? '',
                              ),
                              buildColumnTitleValue(
                                title: "Reporting Person",
                                value:
                                    selectedEmployee.first["reportingPerson"] ??
                                    '',
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Email Id",
                                value: selectedEmployee.first["email"] ?? '',
                              ),
                              buildColumnTitleValue(
                                title: "Personal Mobile Number",
                                value:
                                    selectedEmployee.first["personalNumber"] ??
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
      ),
    );
  }

  // <---- ADDRESS SECTION ---->
  Widget _buildAddressSection() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Address'),
          CustomTextField(
            title: 'Communication Address',
            hint: "Enter Communication Address",
            minLines: 3,
            maxLines: 3,
            isRequired: true,
            textController: _communicationAddressC,
            inputFormatterList: [LengthLimitingTextInputFormatter(500)],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Communication Address is required';
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'Permanent Address',
            hint: "Enter Permanent Address",
            minLines: 3,
            maxLines: 3,
            isRequired: true,
            textController: _permanentAddressC,
            inputFormatterList: [LengthLimitingTextInputFormatter(500)],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Permanent Address is required';
              }
              return null;
            },
          ),
          AddressWidget(
            formKey: _formKeys[2],
            incomingStateId: widget.employee?.stateMasterId,
            incomingDistrictId: widget.employee?.districtMasterId,
            incomingCityId: widget.employee?.cityMasterId,
            incomingVillageId: widget.employee?.villageMasterId,
            stateChange: (selectedState) {
              this.selectedState = selectedState;
            },
            districtChange: (selectedDistrict) {
              this.selectedDistrict = selectedDistrict;
            },
            cityChange: (selectedCity) {
              this.selectedCity = selectedCity;
            },
            villageChange: (selectedVillage) {
              this.selectedVillage = selectedVillage;
            },
          ),
        ],
      ),
    );
  }

  // <---- BANK DETAILS SECTION ---->
  Widget _buildBankDetailsSection() {
    return Form(
      key: _formKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Bank Details'),
          CustomMultipleSelectPopup(
            title: "Bank",
            isRequired: true,
            isMultiSelect: false,
            initialValue: _selectedBank,
            dataList: [],
            dataFetchCallBack: _fetchBank,
            onSelected: (value) {
              _selectedBank = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bank Name is required';
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'Bank Branch Name',
            hint: "Enter Bank Branch Name",
            isRequired: true,
            textController: _bankBranchNameC,
            inputFormatterList: InputValidator.textDigit(50),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bank Branch Name is required';
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'Account Number',
            hint: "Enter Account Number",
            isRequired: true,
            textController: _accountNumberC,
            inputFormatterList: InputValidator.accountNumberInputFormatters(),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Account Number is required';
              }
              if (!InputValidator.isValidAccountNumber(value)) {
                return 'Valid Account Number is required';
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'IFSC Code',
            hint: "Enter IFSC Code",
            isRequired: true,
            textController: _ifscC,
            inputFormatterList: InputValidator.ifscInputFormatters(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'IFSC Code is required';
              }
              if (!InputValidator.isValidIFSC(value)) {
                return 'Valid IFSC Code is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
