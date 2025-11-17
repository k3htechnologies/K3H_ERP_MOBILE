import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_paginated_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class EmployeeMasterFormScreen extends StatefulWidget {
  final UserModel? employee;
  final int index;

  const EmployeeMasterFormScreen({
    super.key,
    this.employee,
    required this.index,
  });

  @override
  State<EmployeeMasterFormScreen> createState() =>
      _EmployeeMasterFormScreenState();
}

class _EmployeeMasterFormScreenState extends State<EmployeeMasterFormScreen> {
  // CUBIT
  late EmployeeMasterCubit _employeeMasterCubit;

  // PAGE CONTROLLER
  late PageController _pageController;

  // CURRENT PAGE
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

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

  // LISTS
  // BASIC EMPLOYEE DETAILS
  List<Map<String, dynamic>> genderList = [
    {"zAttributesId": -1, "DisplayName": "Select Gender"},
    {"zAttributesId": 1, "DisplayName": "Male"},
    {"zAttributesId": 2, "DisplayName": "Female"},
    {"zAttributesId": 3, "DisplayName": "Other"},
  ];
  List<Map<String, dynamic>> maritalStatusList = [
    {"zAttributesId": -1, "DisplayName": "Select Marital Status"},
    {"zAttributesId": 1, "DisplayName": "Single"},
    {"zAttributesId": 2, "DisplayName": "Married"},
    {"zAttributesId": 3, "DisplayName": "Divorce"},
    {"zAttributesId": 4, "DisplayName": "Widow"},
  ];
  List<Map<String, dynamic>> bloodGroupList = [
    {"zAttributesId": -1, "DisplayName": "Select Blood Group"},
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
    {"zAttributesId": -1, "DisplayName": "Select Employment Type"},
    {"zAttributesId": 1, "DisplayName": "Permanent"},
    {"zAttributesId": 2, "DisplayName": "Contract"},
  ];

  List<Map<String, dynamic>> relationToEmployeeList = [
    {"zAttributesId": -1, "DisplayName": "Select Relation"},
    {"zAttributesId": 1, "DisplayName": "Father"},
    {"zAttributesId": 2, "DisplayName": "Mother"},
    {"zAttributesId": 3, "DisplayName": "Spouse"},
    {"zAttributesId": 4, "DisplayName": "Sibling"},
    {"zAttributesId": 5, "DisplayName": "Child"},
  ];

  // SELECTED VALUES
  // BASIC EMPLOYEE DETAILS
  Map<String, dynamic>? selectedGender;
  Map<String, dynamic>? selectedMaritalStatus;
  Map<String, dynamic>? selectedBloodGroup;
  Map<String, dynamic>? selectedEmploymentType;
  Map<String, dynamic>? selectedRelationToEmployee;

  // EMPLOYEE INFO SHEET
  Map<String, dynamic>? selectedCompany;
  Map<String, dynamic>? selectedBranch;
  Map<String, dynamic>? selectedDepartment;
  Map<String, dynamic>? selectedDesignation;
  Map<String, dynamic>? selectedReportingPerson;
  Map<String, dynamic>? selectedState;
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedCity;

  // BANK DETAILS
  Map<String, dynamic>? selectedBank;

  // DATES
  // BASIC EMPLOYEE DETAILS
  DateTime? dateOfBirth;

  // EMPLOYEE INFO SHEET
  DateTime? joiningDate;

  Future<void> _prefillDialogToAddUpdateEmployeeMaster(
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
    selectedGender = genderList.firstWhere(
      (item) => item['DisplayName'] == employee.gender,
      orElse: () => genderList.first,
    );
    selectedMaritalStatus = maritalStatusList.firstWhere(
      (item) => item['DisplayName'] == employee.maritalStatus,
      orElse: () => maritalStatusList.first,
    );
    selectedBloodGroup = bloodGroupList.firstWhere(
      (item) => item['DisplayName'] == employee.bloodGroup,
      orElse: () => bloodGroupList.first,
    );
    selectedCompany = {
      'zAttributesId': employee.companyId,
      'DisplayName': employee.companyName,
    };
    selectedBranch = {
      'zAttributesId': employee.branchMasterId,
      'DisplayName': employee.branch,
    };
    selectedDepartment = {
      'zAttributesId': employee.departmentMasterId,
      'DisplayName': employee.department,
    };
    selectedDesignation = {
      'zAttributesId': employee.designationMasterId,
      'DisplayName': employee.designation,
    };
    selectedReportingPerson = {
      'zAttributesId': employee.reportPersonId,
      'DisplayName': employee.reportPersonName,
    };
    selectedEmploymentType = employmentTypeList.firstWhere(
      (item) => item['DisplayName'] == employee.employeeType,
      orElse: () => employmentTypeList.first,
    );
    selectedRelationToEmployee = relationToEmployeeList.firstWhere(
      (item) =>
          item['DisplayName'] == employee.emergencyContactPersonRelationship,
      orElse: () => relationToEmployeeList.first,
    );
    // Bank Details
    selectedBank = {
      'zAttributesId': employee.bankListMasterId,
      'DisplayName': employee.bankName,
    };
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

    // Dates
    dateOfBirth = employee.dateOfBirth;
    joiningDate = employee.joiningDate;
  }

  @override
  void initState() {
    super.initState();
    _employeeMasterCubit = BlocProvider.of<EmployeeMasterCubit>(context);
    _pageController = PageController();
    _initializeTextEditingController();
    _initializeDropdowns();
    if (widget.employee != null) {
      _prefillDialogToAddUpdateEmployeeMaster(widget.employee!);
    }
  }

  @override
  void dispose() {
    super.dispose();
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

    _pageController.dispose();
    for (var key in _formKeys) {
      key.currentState?.dispose();
    }
  }

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

  void _initializeDropdowns() {
    // BASIC EMPLOYEE DETAILS
    selectedGender = genderList.first;
    selectedMaritalStatus = maritalStatusList.first;
    selectedBloodGroup = bloodGroupList.first;
    selectedEmploymentType = employmentTypeList.first;
  }

  // <---- ADD UPDATE EMPLOYEE ---->
  Future<void> _addUpdateEmployee(UserModel? employee, {int index = 0}) async {
    if (!mounted) {
      return;
    }
    if (employee != null) {
      await _employeeMasterCubit.updateEmployeeMaster(
        index: index,
        employeeMasterId: employee.employeeId,
        uniqueKey: employee.uniqueKey,
        context: context,
        firstName: _firstNameC.text.trim(),
        middleName: _middleNameC.text.trim(),
        lastName: _lastNameC.text.trim(),
        selectedGender: selectedGender!["DisplayName"],
        selectedMaritalStatus: selectedMaritalStatus!["DisplayName"],
        selectedBloodGroup: selectedBloodGroup!["DisplayName"],
        selectedBranchId: selectedBranch!["zAttributesId"],
        dateOfBirth: dateOfBirth!,
        joiningDate: joiningDate!,
        officeEmailId: _officeEmailIdC.text.trim(),
        personalEmailId: _personalEmailC.text.trim(),
        personalMobileNumber: _personalMobileNumberC.text,
        officeMobileNumber: _officeMobileNumberC.text,
        communicationAddress: _communicationAddressC.text.trim(),
        permanentAddress: _permanentAddressC.text.trim(),
        bankNameMasterId: selectedBank!['zAttributesId'],
        bankBranchName: _bankBranchNameC.text.trim(),
        accountNumber: _accountNumberC.text,
        ifscCode: _ifscC.text,
        selectedCompanyNameId: selectedCompany!["zAttributesId"],
        selectedDepartmentId: selectedDepartment!["zAttributesId"],
        selectedDesignationId: selectedDesignation!["zAttributesId"],
        selectedReportingPersonId: selectedReportingPerson!["zAttributesId"],
        selectedCountryNameId: 1,
        selectedStateId: selectedState!["zAttributesId"],
        selectedDistrictId: selectedDistrict!["zAttributesId"],
        selectedCityId: selectedCity!["zAttributesId"],
        employeeType: selectedEmploymentType!['DisplayName'],
        emergencyContactPersonRelationship:
            selectedRelationToEmployee!['DisplayName'],
        emergencyMobileNumber: _emergencyContactNumberC.text,
      );
    } else {
      await _employeeMasterCubit.addEmployeeMaster(
        context: context,
        firstName: _firstNameC.text.trim(),
        middleName: _middleNameC.text.trim(),
        lastName: _lastNameC.text.trim(),
        selectedGender: selectedGender!["DisplayName"],
        selectedMaritalStatus: selectedMaritalStatus!["DisplayName"],
        selectedBloodGroup: selectedBloodGroup!["DisplayName"],
        selectedBranchId: selectedBranch!["zAttributesId"],
        dateOfBirth: dateOfBirth!,
        joiningDate: joiningDate!,
        officeEmailId: _officeEmailIdC.text.trim(),
        personalEmailId: _personalEmailC.text.trim(),
        personalMobileNumber: _personalMobileNumberC.text,
        officeMobileNumber: _officeMobileNumberC.text,
        communicationAddress: _communicationAddressC.text.trim(),
        permanentAddress: _permanentAddressC.text.trim(),
        bankNameMasterId: selectedBank!['zAttributesId'],
        bankBranchName: _bankBranchNameC.text.trim(),
        accountNumber: _accountNumberC.text,
        ifscCode: _ifscC.text,
        selectedCompanyNameId: selectedCompany!["zAttributesId"],
        selectedDepartmentId: selectedDepartment!["zAttributesId"],
        selectedDesignationId: selectedDesignation!["zAttributesId"],
        selectedReportingPersonId: selectedReportingPerson!["zAttributesId"],
        selectedCountryNameId: 1,
        selectedStateId: selectedState!["zAttributesId"],
        selectedDistrictId: selectedDistrict!["zAttributesId"],
        selectedCityId: selectedCity!["zAttributesId"],
        employeeType: selectedEmploymentType!['DisplayName'],
        emergencyContactPersonRelationship:
            selectedRelationToEmployee!['DisplayName'],
        emergencyMobileNumber: _emergencyContactNumberC.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColor.black, size: 20),
          onPressed: () {
            goRouter.pop();
          },
        ),
        centerTitle: true,
        title: Text(
          'Add Details',
          style: AppTextStyle.ts16R(),
          textAlign: TextAlign.center,
        ),
      ),

      body: ColoredBox(
        color: AppColor.greyBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: AppColor.white,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 2.0,
                  bottom: 16.0,
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPage,
                  builder: (context, value, child) {
                    int remainingPage = 4 - (value + 1);
                    return Row(
                      children: [
                        Expanded(
                          flex: (value + 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xffdddddd),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3.0),
                                bottomLeft: Radius.circular(3.0),
                                topRight:
                                    (value + 1) == 4
                                        ? Radius.circular(3.0)
                                        : Radius.circular(0.0),
                                bottomRight:
                                    (value + 1) == 4
                                        ? Radius.circular(3.0)
                                        : Radius.circular(0.0),
                              ),
                            ),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColor.info,
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: remainingPage,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Color(0xffdddddd),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(3.0),
                                bottomRight: Radius.circular(3.0),
                              ),
                            ),
                          ),
                        ),
                        horizontalSpacing(width: 8),
                        Text('${value + 1}/4', style: AppTextStyle.ts12M()),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(height: 1, color: AppColor.grey30),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  _currentPage.value = index;
                },
                children: [
                  KeepAlivePage(
                    child: SingleChildScrollView(
                      child: ColoredBox(
                        color: AppColor.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            key: _formKeys[0],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(
                                    'Basic Employee Details',
                                    style: AppTextStyle.ts16R(
                                      color: AppColor.black,
                                    ),
                                  ),
                                ),
                                Row(
                                  spacing: 20,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'First Name*',
                                        inputFormatterList:
                                            InputValidator.textOnly(50),
                                        textController: _firstNameC,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'First name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Middle Name*',
                                        textController: _middleNameC,
                                        inputFormatterList:
                                            InputValidator.textOnly(50),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Middle name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 20,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Last Name*',
                                        inputFormatterList:
                                            InputValidator.textOnly(50),
                                        textController: _lastNameC,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Last name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomDropDownWidget(
                                        title: 'Gender*',
                                        initialValue: selectedGender,
                                        dataList: genderList,
                                        onSelected:
                                            (value) => selectedGender = value,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Gender is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 20.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomDropDownWidget(
                                        title: 'Marital Status*',
                                        initialValue: selectedMaritalStatus,
                                        dataList: maritalStatusList,
                                        onSelected:
                                            (value) =>
                                                selectedMaritalStatus = value,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Marital Status is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomDropDownWidget(
                                        title: 'Blood Group*',
                                        initialValue: selectedBloodGroup,
                                        dataList: bloodGroupList,
                                        onSelected:
                                            (value) =>
                                                selectedBloodGroup = value,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Blood Group is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 20.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomDatePicker(
                                        title: 'DOB*',
                                        initialDate: dateOfBirth,

                                        validator: (value) {
                                          if (value == null) {
                                            return 'DOB is required';
                                          }

                                          if (!InputValidator.isValidAge(
                                            value,
                                          )) {
                                            return 'Age should be greater than or equal to 18.';
                                          }
                                          return null;
                                        },
                                        setValue:
                                            (value) => dateOfBirth = value,
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Office Email Id',
                                        textController: _officeEmailIdC,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value != null &&
                                              value.trim().isNotEmpty &&
                                              !InputValidator.isValidEmail(
                                                value,
                                              )) {
                                            return 'Email Id is not valid';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 20,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Email Id*',
                                        textController: _personalEmailC,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Email Id is required';
                                          }
                                          if (!InputValidator.isValidEmail(
                                            value,
                                          )) {
                                            return 'Email Id is not valid';
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Personal Mobile Number*',
                                        textController: _personalMobileNumberC,
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Personal Mobile Number is required';
                                          }
                                          if (!InputValidator.isValidMobileNumber(
                                            value,
                                          )) {
                                            return 'Mobile number is not valid';
                                          }

                                          return null;
                                        },
                                        inputFormatterList:
                                            InputValidator.digit(10),
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
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 20.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Office Mobile Number',
                                        textController: _officeMobileNumberC,
                                        keyboardType: TextInputType.phone,
                                        inputFormatterList:
                                            InputValidator.digit(10),
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomDropDownWidget(
                                        title: 'Employment Type*',
                                        initialValue: selectedEmploymentType,
                                        dataList: employmentTypeList,
                                        onSelected:
                                            (value) =>
                                                selectedEmploymentType = value,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Employment Type is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 20.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomDropDownWidget(
                                        title: 'Relation to Emergency Contact*',
                                        initialValue:
                                            selectedRelationToEmployee,
                                        dataList: relationToEmployeeList,
                                        onSelected:
                                            (value) =>
                                                selectedRelationToEmployee =
                                                    value,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Relation to Emergency Contact is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Emergency Contact Number*',
                                        textController:
                                            _emergencyContactNumberC,
                                        keyboardType: TextInputType.phone,
                                        inputFormatterList:
                                            InputValidator.digit(10),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Emergency Contact Number is required';
                                          }
                                          if (!InputValidator.isValidMobileNumber(
                                            value,
                                          )) {
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
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  KeepAlivePage(
                    child: SingleChildScrollView(
                      child: ColoredBox(
                        color: AppColor.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            key: _formKeys[1],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(
                                    'Employee Info Sheet',
                                    style: AppTextStyle.ts16R(
                                      color: AppColor.black,
                                    ),
                                  ),
                                ),
                                Row(
                                  spacing: 20,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomPaginationDropDownWidget(
                                        title: "Company Name*",
                                        dataList: [],
                                        initialValue: selectedCompany,
                                        onSelected:
                                            (value) => selectedCompany = value,
                                        dataFetchCallBack:
                                            _employeeMasterCubit.getCompanies,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Company is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomPaginationDropDownWidget(
                                        title: 'Branch*',
                                        initialValue: selectedBranch,
                                        dataFetchCallBack:
                                            _employeeMasterCubit.getBranch,
                                        onSelected:
                                            (value) => selectedBranch = value,
                                        dataList: [],
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Branch is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 20,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomPaginationDropDownWidget(
                                        title: "Department*",
                                        dataList: [],
                                        initialValue: selectedDepartment,
                                        onSelected:
                                            (value) =>
                                                selectedDepartment = value,
                                        dataFetchCallBack:
                                            _employeeMasterCubit.getDepartments,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Department is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomPaginationDropDownWidget(
                                        title: "Designation*",
                                        dataList: [],
                                        initialValue: selectedDesignation,
                                        onSelected:
                                            (value) =>
                                                selectedDesignation = value,
                                        dataFetchCallBack:
                                            _employeeMasterCubit
                                                .getDesignations,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Designation is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 20,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomDatePicker(
                                        title: 'Joining Date*',
                                        initialDate: joiningDate,

                                        setValue:
                                            (value) => joiningDate = value,
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Joining Date is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomPaginationDropDownWidget(
                                        title: 'Reporting Person*',
                                        initialValue: selectedReportingPerson,
                                        dataFetchCallBack:
                                            _employeeMasterCubit.getEmployee,
                                        dataList: [],
                                        onSelected:
                                            (value) =>
                                                selectedReportingPerson = value,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Reporting Person is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  KeepAlivePage(
                    child: SingleChildScrollView(
                      child: ColoredBox(
                        color: AppColor.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            key: _formKeys[2],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(
                                    'Address',
                                    style: AppTextStyle.ts16R(),
                                  ),
                                ),
                                Row(
                                  spacing: 20.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Communication Addres*',
                                        textController: _communicationAddressC,
                                        inputFormatterList: [
                                          LengthLimitingTextInputFormatter(500),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Communication Address is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Permanent Address*',
                                        textController: _permanentAddressC,
                                        inputFormatterList: [
                                          LengthLimitingTextInputFormatter(500),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Permanent Address is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                AddressWidget(
                                  formKey: _formKeys[2],
                                  incomingStateId:
                                      widget.employee?.stateMasterId,
                                  incomingDistrictId:
                                      widget.employee?.districtMasterId,
                                  incomingCityId: widget.employee?.cityMasterId,
                                  stateChange: (selectedState) {
                                    this.selectedState = selectedState;
                                  },
                                  districtChange: (selectedDistrict) {
                                    this.selectedDistrict = selectedDistrict;
                                  },
                                  cityChange: (selectedCity) {
                                    this.selectedCity = selectedCity;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  KeepAlivePage(
                    child: SingleChildScrollView(
                      child: ColoredBox(
                        color: AppColor.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            key: _formKeys[3],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(
                                    'Bank Details',
                                    style: AppTextStyle.ts16R(),
                                  ),
                                ),
                                Row(
                                  spacing: 20.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomPaginationDropDownWidget(
                                        dataList: [],
                                        onSelected:
                                            (value) => selectedBank = value,
                                        initialValue: selectedBank,
                                        title: 'Bank Name*',
                                        dataFetchCallBack:
                                            _employeeMasterCubit.getBankList,
                                        validator: (value) {
                                          if (value == null ||
                                              value["zAttributesId"] == -1) {
                                            return 'Bank Name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Bank Branch Name*',
                                        textController: _bankBranchNameC,
                                        inputFormatterList:
                                            InputValidator.textDigit(50),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Bank Branch Name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 20.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'Account Number*',
                                        textController: _accountNumberC,
                                        inputFormatterList:
                                            InputValidator.accountNumberInputFormatters(),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Account Number is required';
                                          }
                                          if (!InputValidator.isValidAccountNumber(
                                            value,
                                          )) {
                                            return 'Valid Account Number is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomTextField(
                                        title: 'IFSC Code*',
                                        textController: _ifscC,
                                        inputFormatterList:
                                            InputValidator.ifscInputFormatters(),

                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'IFSC Code is required';
                                          }
                                          if (!InputValidator.isValidIFSC(
                                            value,
                                          )) {
                                            return 'Valid IFSC Code is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ColoredBox(
              color: AppColor.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPage,
                  builder: (context, value, child) {
                    return Row(
                      spacing: 20,
                      children: [
                        Expanded(
                          child:
                              value > 0
                                  ? CustomButton(
                                    onPressed: () {
                                      _pageController.jumpToPage(
                                        _currentPage.value - 1,
                                      );
                                    },
                                    text: 'Previous',
                                    textColor: AppColor.green,
                                    backgroundColor: AppColor.white,
                                    borderColor: AppColor.green,
                                  )
                                  : SizedBox(),
                        ),

                        Expanded(
                          child:
                              value == 3
                                  ? CustomButton.save(
                                    onPressed: () async {
                                      await _addUpdateEmployee(
                                        widget.employee,
                                        index: widget.index,
                                      );
                                    },
                                  )
                                  : CustomButton(
                                    onPressed: () {
                                      if (_formKeys[_currentPage.value]
                                          .currentState!
                                          .validate()) {
                                        _pageController.jumpToPage(
                                          _currentPage.value + 1,
                                        );
                                      }
                                    },
                                    text: 'Next',
                                    backgroundColor: AppColor.green,
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  int counter = 0;

  @override
  bool get wantKeepAlive => true; // Tells Flutter to keep the widget alive

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important when using AutomaticKeepAliveClientMixin

    return widget.child;
  }
}
