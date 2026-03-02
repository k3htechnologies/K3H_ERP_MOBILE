import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/cubit/project_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddProjectScreen extends StatefulWidget {
  final ProjectModel? project;
  final int index;
  const AddProjectScreen({super.key, this.project, this.index = 0});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  // CUBIT
  late ProjectMasterCubit _projectMasterCubit;

  // FORM KEY
  final GlobalKey<FormState> _projectMasterAddUpdateKey =
      GlobalKey<FormState>();

  // DROPDOWN VALUES
  Map<String, dynamic>? selectedState;
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedProjectStatus;
  Map<String, dynamic>? selectedProjectScheme;
  Map<String, dynamic>? selectedProjectSubScheme;

  // DATE PICKER VARIABLE
  DateTime? reraCompletionDate;
  DateTime? reraCertificateDate;
  DateTime? surveyDate;
  DateTime? expectedStartDate;
  DateTime? executionStartDate;

  // TEXT EDITING CONTROLLER
  late TextEditingController _projectNameC,
      _projectLocationC,
      _projectScopeC,
      _ctsNumberC,
      _businessCategoryC,
      _projectSubSchemeC,
      _pinCodeC,
      _projectEstimateCostC,
      _onGoingBudgetCostC,
      _projectAreaSqftC,
      _googleLocationC,
      _reraNumberC,
      _siteContactNameC,
      _siteContactMobileNumberC;

  // CHECKBOX FOR REDEVELOPMENT
  bool isRedevelopment = false;

  // ProjectPhotoURL IMAGE SELECTION
  MultiFilePickerModel projectPhotoImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // STATIC LISTS
  List<Map<String, dynamic>> projectSchemeList = [
    {"zAttributesId": -1, "DisplayName": "Select Project Status"},
    {"zAttributesId": 1, "DisplayName": "BMC"},
    {"zAttributesId": 2, "DisplayName": "MHADA"},
    {"zAttributesId": 3, "DisplayName": "SRA"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSubSchemeList = [
    {"zAttributesId": -1, "DisplayName": "Select Project Status"},
    {"zAttributesId": 1, "DisplayName": "33 (20) B"},
    {"zAttributesId": 2, "DisplayName": "33 (19)"},
    {"zAttributesId": 3, "DisplayName": "33 (7) B"},
    {"zAttributesId": 4, "DisplayName": "33 (7) A"},
    {"zAttributesId": 5, "DisplayName": "33 (9)"},
    {"zAttributesId": 6, "DisplayName": "33 (12) B"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSubSchemeList1 = [
    {"zAttributesId": -1, "DisplayName": "Select Project Status"},
    {"zAttributesId": 1, "DisplayName": "33 (5)"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSubSchemeList2 = [
    {"zAttributesId": -1, "DisplayName": "Select Project Status"},
    {"zAttributesId": 1, "DisplayName": "33 (10)"},
    {"zAttributesId": 2, "DisplayName": "33 (11)"},
  ];

  List<Map<String, dynamic>> get _currentSubSchemeList {
    if (selectedProjectScheme == null) return projectSubSchemeList;
    final id = selectedProjectScheme!["zAttributesId"] as int?;
    if (id == null || id == -1) return projectSubSchemeList;
    switch (id) {
      case 1:
        return projectSubSchemeList; // BMC
      case 2:
        return projectSubSchemeList1; // MHADA
      case 3:
        return projectSubSchemeList2; // SRA
      default:
        return projectSubSchemeList;
    }
  }

  // STATIC LISTS
  List<Map<String, dynamic>> projectStatusList = [
    {"zAttributesId": -1, "DisplayName": "Select Project Scheme"},
    {"zAttributesId": 1, "DisplayName": "On-Going"},
    {"zAttributesId": 2, "DisplayName": "Completed"},
    {"zAttributesId": 3, "DisplayName": "On-Hold"},
    {"zAttributesId": 4, "DisplayName": "Cancelled"},
    {"zAttributesId": 5, "DisplayName": "Planning"},
  ];

  @override
  void initState() {
    super.initState();
    _projectMasterCubit = context.read<ProjectMasterCubit>();
    selectedProjectStatus = projectStatusList.first;
    selectedProjectScheme = projectSchemeList.first;
    selectedProjectSubScheme =
        _currentSubSchemeList.isNotEmpty ? _currentSubSchemeList.first : null;
    _initializeTextEditingController();
    if (widget.project != null) {
      _prefillDialogueToAddUpdateProjectMaster(widget.project!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _projectNameC.dispose();
    _projectLocationC.dispose();
    _projectScopeC.dispose();
    _ctsNumberC.dispose();
    _businessCategoryC.dispose();
    _projectSubSchemeC.dispose();
    _pinCodeC.dispose();
    _projectEstimateCostC.dispose();
    _onGoingBudgetCostC.dispose();
    _projectAreaSqftC.dispose();
    _googleLocationC.dispose();
    _reraNumberC.dispose();
    _siteContactNameC.dispose();
    _siteContactMobileNumberC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _projectNameC = TextEditingController();
    _projectLocationC = TextEditingController();
    _projectScopeC = TextEditingController();
    _ctsNumberC = TextEditingController();
    _businessCategoryC = TextEditingController();
    _projectSubSchemeC = TextEditingController();
    _pinCodeC = TextEditingController();
    _projectEstimateCostC = TextEditingController();
    _onGoingBudgetCostC = TextEditingController();
    _projectAreaSqftC = TextEditingController();
    _googleLocationC = TextEditingController();
    _reraNumberC = TextEditingController();
    _siteContactNameC = TextEditingController();
    _siteContactMobileNumberC = TextEditingController();
  }

  // PREFILL DIALOGUE TO ADD/UPDATE PROJECT MASTER
  void _prefillDialogueToAddUpdateProjectMaster(ProjectModel projectModel) {
    _projectNameC.text = widget.project!.projectName;
    _projectLocationC.text = widget.project!.projectLocation;
    _ctsNumberC.text = widget.project!.ctsNumber;
    _businessCategoryC.text = widget.project!.bussinessCategory;
    _projectScopeC.text = widget.project!.projectScope;
    // Project sub scheme is set via selectedProjectSubScheme below when scheme is set
    _pinCodeC.text = widget.project!.zipCode;
    _googleLocationC.text = widget.project!.googleLocation;
    _projectEstimateCostC.text = widget.project!.projectEstimateCost.toString();
    _onGoingBudgetCostC.text = widget.project!.onGoingBudgetCost.toString();
    _projectAreaSqftC.text = widget.project!.projectAreaInSqft.toString();
    _reraNumberC.text = widget.project!.reraNumber;
    _siteContactNameC.text = widget.project!.siteContactName;
    _siteContactMobileNumberC.text = widget.project!.siteContactMobileNumber;

    // Prefill date fields
    surveyDate = widget.project!.surveyDate;
    expectedStartDate = widget.project!.expectedStartDate;
    executionStartDate = widget.project!.executionStartDate;
    reraCertificateDate = widget.project!.reraCertificateDate;
    reraCompletionDate = widget.project!.reraComplitionDate;

    // Prefill project status dropdown
    if (widget.project!.projectStatus.isNotEmpty) {
      selectedProjectStatus = projectStatusList.firstWhere(
        (status) => status["DisplayName"] == widget.project!.projectStatus,
        orElse: () => projectStatusList.first,
      );
    } else {
      selectedProjectStatus = projectStatusList.first;
    }

    if (widget.project!.projectScheme.isNotEmpty) {
      selectedProjectScheme = projectSchemeList.firstWhere(
        (item) => item["DisplayName"] == widget.project!.projectScheme,
        orElse: () => projectSchemeList.first,
      );
      final subList = _currentSubSchemeList;
      selectedProjectSubScheme = subList.firstWhere(
        (item) => item["DisplayName"] == widget.project!.projectSubScheme,
        orElse: () => subList.first,
      );
    } else {
      selectedProjectScheme = projectSchemeList.first;
      selectedProjectSubScheme =
          _currentSubSchemeList.isNotEmpty ? _currentSubSchemeList.first : null;
    }

    // Prefill project photo
    projectPhotoImage.fileNameList =
        widget.project!.projectPhotoUrl
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    // Prefill location data
    isRedevelopment = widget.project!.isRedevelopment;
    selectedDistrict = {
      "DisplayName": widget.project!.districtName,
      "zAttributesId": widget.project!.districtMasterId,
    };
    selectedCity = {
      "DisplayName": widget.project!.cityName,
      "zAttributesId": widget.project!.cityMasterId,
    };
    selectedState = {
      "DisplayName": widget.project!.stateName,
      "zAttributesId": widget.project!.stateMasterId,
    };
  }

  // API CALL TO ADD/UPDATE PROJECT MASTER
  Future<void> _addUpdateProject(ProjectModel? project) async {
    if (_projectMasterAddUpdateKey.currentState!.validate()) {
      project != null
          ? _projectMasterCubit.updateProject(
            context: context,
            index: widget.index,
            projectId: project.projectId,
            uniqueKey: project.uniquekey,
            projectName: _projectNameC.text,
            location: _projectLocationC.text,
            ctsNumber: _ctsNumberC.text,
            projectPhotoMap: projectPhotoImage,
            businessCategory: _businessCategoryC.text,
            isRedevelopment: isRedevelopment,
            districtMasterId: selectedDistrict!["zAttributesId"].toString(),
            stateMasterId: selectedState!["zAttributesId"].toString(),
            cityMasterId: selectedCity!["zAttributesId"].toString(),
            executionStartDate: executionStartDate?.toIso8601String() ?? "",
            expectedStartDate: expectedStartDate?.toIso8601String() ?? "",
            googleLocation: _googleLocationC.text,
            pinCode: _pinCodeC.text,
            onGoingBudgetCost:
                _onGoingBudgetCostC.text.trim().isNotEmpty
                    ? _onGoingBudgetCostC.text
                    : "0.0 ",
            projectAreaInSqft:
                _projectAreaSqftC.text.trim().isNotEmpty
                    ? _projectAreaSqftC.text
                    : "0.0",
            projectEstimateCost:
                _projectEstimateCostC.text.trim().isNotEmpty
                    ? _projectEstimateCostC.text
                    : "0.0",
            projectScheme:
                selectedProjectScheme != null &&
                        selectedProjectScheme!["zAttributesId"] != -1
                    ? selectedProjectScheme!["DisplayName"].toString()
                    : "",
            projectScope: _projectScopeC.text,
            projectStatus:
                selectedProjectStatus!["zAttributesId"] == -1
                    ? ""
                    : selectedProjectStatus!["DisplayName"].toString(),
            projectSubScheme:
                selectedProjectSubScheme != null &&
                        selectedProjectSubScheme!["zAttributesId"] != -1
                    ? selectedProjectSubScheme!["DisplayName"].toString()
                    : "",
            reraNumber: _reraNumberC.text,
            reraCertificateDate: reraCertificateDate?.toIso8601String() ?? "",
            reraComplitionDate: reraCompletionDate?.toIso8601String() ?? "",
            siteContactMobileNumber: _siteContactMobileNumberC.text,
            siteContactName: _siteContactNameC.text,
            surveyDate: surveyDate?.toIso8601String() ?? '',
          )
          : _projectMasterCubit.addProject(
            context: context,
            projectName: _projectNameC.text,
            location: _projectLocationC.text,
            ctsNumber: _ctsNumberC.text,
            projectPhotoMap: projectPhotoImage,
            businessCategory: _businessCategoryC.text,
            isRedevelopment: isRedevelopment,
            districtMasterId: selectedDistrict!["zAttributesId"].toString(),
            stateMasterId: selectedState!["zAttributesId"].toString(),
            cityMasterId: selectedCity!["zAttributesId"].toString(),
            executionStartDate: executionStartDate?.toIso8601String() ?? "",
            expectedStartDate: expectedStartDate?.toIso8601String() ?? "",
            googleLocation: _googleLocationC.text,
            pinCode: _pinCodeC.text,
            onGoingBudgetCost:
                _onGoingBudgetCostC.text.trim().isNotEmpty
                    ? _onGoingBudgetCostC.text
                    : "0.0 ",
            projectAreaInSqft:
                _projectAreaSqftC.text.trim().isNotEmpty
                    ? _projectAreaSqftC.text
                    : "0.0",
            projectEstimateCost:
                _projectEstimateCostC.text.trim().isNotEmpty
                    ? _projectEstimateCostC.text
                    : "0.0",
            projectScheme:
                selectedProjectScheme != null &&
                        selectedProjectScheme!["zAttributesId"] != -1
                    ? selectedProjectScheme!["DisplayName"].toString()
                    : "",
            projectScope: _projectScopeC.text,
            projectStatus:
                selectedProjectStatus!["zAttributesId"] == -1
                    ? ""
                    : selectedProjectStatus!["DisplayName"].toString(),
            projectSubScheme:
                selectedProjectSubScheme != null &&
                        selectedProjectSubScheme!["zAttributesId"] != -1
                    ? selectedProjectSubScheme!["DisplayName"].toString()
                    : "",
            reraNumber: _reraNumberC.text,
            reraCertificateDate: reraCertificateDate?.toIso8601String() ?? "",
            reraComplitionDate: reraCompletionDate?.toIso8601String() ?? "",
            siteContactMobileNumber: _siteContactMobileNumberC.text,
            siteContactName: _siteContactNameC.text,
            surveyDate: surveyDate?.toIso8601String() ?? '',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Project Details",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _projectMasterAddUpdateKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project == null ? "Add Project" : "Update Project",
                  style: AppTextStyle.ts16SB(),
                ),
                verticalSpacing(),
                StatefulBuilder(
                  builder: (context, innerState) {
                    return Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: commonCardDecoration(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCheckBox(
                            isSelected: isRedevelopment,
                            onChanged: (value) {
                              innerState(() {
                                isRedevelopment = value;
                              });
                            },
                          ),
                          horizontalSpacing(),
                          Flexible(
                            child: Text(
                              'Is this project a Redevelopment Project?',
                              style: AppTextStyle.ts16SB(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Basic Details",
                        style: AppTextStyle.ts16SB(color: AppColor.grey),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'Project Name',
                        hint: "Enter Project Name",
                        textController: _projectNameC,
                        isRequired: true,
                        inputFormatterList: InputValidator.textDigit(50),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Project Name is required';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        title: 'CTS Number',
                        hint: "Enter CTS Number",
                        isRequired: true,
                        textController: _ctsNumberC,
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'CTS number is required';
                          }
                          return null;
                        },
                      ),
                      CustomMultiFilePicker(
                        initialFileList: projectPhotoImage.fileNameList,
                        title: "Project Photo",
                        filePickType: FilePickType.kycDocument,
                        isRequired: true,
                        onFilePickedCallback: (bytes, fileName) {
                          projectPhotoImage.fileBytesList = bytes;
                          projectPhotoImage.fileNameList = fileName;
                        },
                        onFileDeleteCallback: (bytes, fileName, deletedFiles) {
                          projectPhotoImage.fileBytesList = bytes;
                          projectPhotoImage.fileNameList = fileName;
                          projectPhotoImage.deletedFileList = deletedFiles;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Project Photo is required";
                          }
                          return null;
                        },
                      ),
                      AddressWidget(
                        formKey: _projectMasterAddUpdateKey,
                        incomingStateId: widget.project?.stateMasterId,
                        incomingDistrictId: widget.project?.districtMasterId,
                        incomingCityId: widget.project?.cityMasterId,
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
                      CustomTextField(
                        title: 'PIN Code',
                        textController: _pinCodeC,
                        hint: "Enter PIN Code",
                        inputFormatterList: InputValidator.digit(10),
                      ),
                      CustomTextField(
                        title: 'Business Category',
                        textController: _businessCategoryC,
                        hint: "Enter Business Category",
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                      ),
                      CustomTextField(
                        title: 'Project Location',
                        hint: "Enter Project Location",
                        isRequired: true,
                        textController: _projectLocationC,
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Project Location is required";
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        title: 'Google Location',
                        textController: _googleLocationC,
                        hint: "Enter Google Location",
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Scheme & Scope Details",
                        style: AppTextStyle.ts16SB(color: AppColor.grey),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'Project Scope',
                        textController: _projectScopeC,
                        hint: "Enter Project Scope",
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                      ),
                      CustomDropDownWidget(
                        title: 'Project Scheme',
                        initialValue: selectedProjectScheme,
                        dataList: projectSchemeList,
                        onSelected: (value) {
                          setState(() {
                            selectedProjectScheme = value;
                            selectedProjectSubScheme =
                                _currentSubSchemeList.isNotEmpty
                                    ? _currentSubSchemeList.first
                                    : null;
                          });
                        },
                      ),
                      CustomDropDownWidget(
                        title: 'Project Sub Scheme',
                        initialValue: selectedProjectSubScheme,
                        dataList: _currentSubSchemeList,
                        onSelected: (value) {
                          setState(() {
                            selectedProjectSubScheme = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Documentation",
                        style: AppTextStyle.ts16SB(color: AppColor.grey),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'RERA Number',
                        hint: "Enter RERA Number",
                        textController: _reraNumberC,
                        inputFormatterList:
                            InputValidator.reraInputFormatters(),
                      ),
                      CustomDatePicker(
                        title: 'RERA Certificate Date',
                        initialDate: reraCertificateDate,
                        setValue: (value) {
                          reraCertificateDate = value;
                        },
                      ),
                      CustomDatePicker(
                        title: 'RERA Completion Date',
                        initialDate: reraCompletionDate,
                        setValue: (value) {
                          reraCompletionDate = value;
                        },
                        validator: (value) {
                          if (value != null &&
                              reraCertificateDate != null &&
                              reraCertificateDate!.isAfter(value)) {
                            return 'RERA Completion Date should be after RERA Certificate Date';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Financials",
                        style: AppTextStyle.ts16SB(color: AppColor.grey),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'Project Estimate Cost',
                        hint: "Enter Project Estimate Cost",
                        textController: _projectEstimateCostC,
                        inputFormatterList: InputValidator.decimal(2),
                      ),
                      CustomTextField(
                        title: 'On Going Budget Cost',
                        hint: "Enter On Going Budget Cost",
                        textController: _onGoingBudgetCostC,
                        inputFormatterList: InputValidator.decimal(2),
                      ),
                      CustomTextField(
                        title: 'Project Area in Sqft',
                        hint: "Enter Project Area in Sqft",
                        textController: _projectAreaSqftC,
                        inputFormatterList: InputValidator.decimal(2),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Timeline",
                        style: AppTextStyle.ts16SB(color: AppColor.grey),
                      ),
                      verticalSpacing(),
                      CustomDatePicker(
                        title: 'Survey Date',
                        initialDate: surveyDate,
                        setValue: (value) {
                          surveyDate = value;
                        },
                      ),
                      CustomDatePicker(
                        title: 'Expected Start Date',
                        initialDate: expectedStartDate,
                        setValue: (value) {
                          expectedStartDate = value;
                        },
                      ),
                      CustomDatePicker(
                        title: 'Execution Start Date',
                        initialDate: executionStartDate,
                        setValue: (value) {
                          executionStartDate = value;
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contact Information",
                        style: AppTextStyle.ts16SB(color: AppColor.grey),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'Site Contact Name',
                        hint: "Enter Site Contact Name",
                        textController: _siteContactNameC,
                        inputFormatterList: InputValidator.textOnly(100),
                      ),
                      CustomTextField(
                        title: 'Site Contact Mobile Number',
                        hint: "Enter Site Contact Mobile Number",
                        textController: _siteContactMobileNumberC,
                        inputFormatterList: InputValidator.digit(10),
                      ),
                      CustomDropDownWidget(
                        title: 'Project Status',
                        initialValue: selectedProjectStatus,
                        dataList: projectStatusList,
                        onSelected: (value) => selectedProjectStatus = value,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading:
                widget.project != null
                    ? Icon(Icons.edit, size: 18, color: AppColor.white)
                    : Icon(Icons.add, size: 18, color: AppColor.white),
            text: widget.project != null ? 'Update Project' : 'Add Project',
            backgroundColor: AppColor.primary,
            onPressed: () {
              _addUpdateProject(widget.project);
            },
          ),
        ),
      ),
    );
  }
}
