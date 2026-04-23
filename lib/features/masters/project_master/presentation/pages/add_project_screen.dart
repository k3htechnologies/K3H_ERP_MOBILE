import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/cubit/project_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
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
  Map<String, dynamic>? selectedBusinessCategory;
  Map<String, dynamic>? selectedCategory;
  ValueNotifier<Map<String, dynamic>?> selectedProjectSubScheme = ValueNotifier(
    null,
  );
  late final ValueNotifier<Map<String, dynamic>?>
  _selectedProjectStatusNotifier;

  // ADDRESS VARIABLES
  int? _stateMasterId;
  int? _districtMasterId;
  int? _cityMasterId;
  int? _villageMasterId;

  final ValueNotifier<Map<String, dynamic>?> projectSchemeNotifier =
      ValueNotifier(null);

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
      _fileNumberC,
      _tenderAmountC,
      _tendorEMDAmountC,
      _chequeNumberC,
      _payOrderTrackC,
      _liasoningNameC,
      _liasoningMobileNumberC,
      _designingNameC,
      _designingMobileNumberC,
      _rccConsultantgNameC,
      _rccConsultantMobileNumberC,
      _projectSubSchemeC,
      _pinCodeC,
      _projectEstimateCostC,
      _onGoingBudgetCostC,
      _projectAreaSqftC,
      _projectAreaSqMtC,
      _googleLocationC,
      _reraNumberC,
      _apfNumberC,
      _siteContactNameC,
      _siteContactMobileNumberC;

  DateTime? purchaseStartDate;
  DateTime? purchaseEndDate;
  DateTime? submissionDate;
  DateTime? issueDate;

  // CHECKBOX FOR REDEVELOPMENT
  final ValueNotifier<bool> isRedevelopmentNotifier = ValueNotifier(false);
  late ValueNotifier<Map<String, dynamic>?> selectedCategoryType;

  // ProjectPhotoURL IMAGE SELECTION
  MultiFilePickerModel projectPhotoImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel chequePhotoFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // BUSINESS CATEGORY
  List<Map<String, dynamic>> businessCategoryList = [
    {"zAttributesId": 1, "DisplayName": "Commercial"},
    {"zAttributesId": 2, "DisplayName": "Mixed Use"},
    {"zAttributesId": 3, "DisplayName": "Residential"},
  ];

  // CATEGORY
  List<Map<String, dynamic>> categoryList = [
    {"zAttributesId": 1, "DisplayName": "Direct"},
    {"zAttributesId": 2, "DisplayName": "Tender"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSchemeList = [
    {"zAttributesId": 1, "DisplayName": "BMC"},
    {"zAttributesId": 2, "DisplayName": "MHADA"},
    {"zAttributesId": 3, "DisplayName": "SRA"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSubSchemeBMCList = [
    {"zAttributesId": 1, "DisplayName": "33 (20) B"},
    {"zAttributesId": 2, "DisplayName": "33 (19)"},
    {"zAttributesId": 3, "DisplayName": "33 (7)"},
    {"zAttributesId": 3, "DisplayName": "33 (7) B"},
    {"zAttributesId": 4, "DisplayName": "33 (7) A"},
    {"zAttributesId": 5, "DisplayName": "33 (9)"},
    {"zAttributesId": 6, "DisplayName": "33 (12) B"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSubSchemeMHADAList = [
    {"zAttributesId": 1, "DisplayName": "33 (5)"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSubSchemeSRAList = [
    {"zAttributesId": 1, "DisplayName": "33 (10)"},
    {"zAttributesId": 2, "DisplayName": "33 (11)"},
  ];

  final List<Map<String, dynamic>> categoryList = [
    {"zAttributesId": 1, "DisplayName": "Direct"},
    {"zAttributesId": 2, "DisplayName": "Tender"},
  ];

  List<Map<String, dynamic>> get _currentSubSchemeList {
    if (projectSchemeNotifier.value == null) return [{}];
    final id = projectSchemeNotifier.value!["zAttributesId"] as int?;
    switch (id) {
      case 1:
        return projectSubSchemeBMCList; // BMC
      case 2:
        return projectSubSchemeMHADAList; // MHADA
      case 3:
        return projectSubSchemeSRAList; // SRA
      default:
        return projectSubSchemeBMCList;
    }
  }

  // STATIC LISTS
  List<Map<String, dynamic>> projectStatusList = [
    {"zAttributesId": 1, "DisplayName": "On-Going"},
    {"zAttributesId": 2, "DisplayName": "Completed"},
    {"zAttributesId": 3, "DisplayName": "On-Hold"},
    {"zAttributesId": 4, "DisplayName": "Cancelled"},
    {"zAttributesId": 5, "DisplayName": "Planning"},
  ];

  // EDIT MODE
  bool get _isEditMode => widget.project != null;

  @override
  void initState() {
    super.initState();
    _projectMasterCubit = context.read<ProjectMasterCubit>();
    _selectedProjectStatusNotifier = ValueNotifier(null);
    selectedCategoryType = ValueNotifier(null);
    _initializeTextEditingController();
    if (_isEditMode) {
      _prefillDialogueToAddUpdateProjectMaster(widget.project!);
      log("the project details are: ${widget.project!.toJson()}");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _projectNameC.dispose();
    _projectLocationC.dispose();
    _projectScopeC.dispose();
    _ctsNumberC.dispose();
    _fileNumberC.dispose();
    _projectSubSchemeC.dispose();
    _pinCodeC.dispose();
    _projectEstimateCostC.dispose();
    _onGoingBudgetCostC.dispose();
    _projectAreaSqftC.dispose();
    _projectAreaSqMtC.dispose();
    _googleLocationC.dispose();
    _reraNumberC.dispose();
    _siteContactNameC.dispose();
    _siteContactMobileNumberC.dispose();
    isRedevelopmentNotifier.dispose();
    projectSchemeNotifier.dispose();
    _selectedProjectStatusNotifier.dispose();
    selectedCategoryType.dispose();
    _tenderAmountC.dispose();
    _tendorEMDAmountC.dispose();
    _chequeNumberC.dispose();
    _payOrderTrackC.dispose();
    _liasoningNameC.dispose();
    _liasoningMobileNumberC.dispose();
    _designingNameC.dispose();
    _designingMobileNumberC.dispose();
    _rccConsultantgNameC.dispose();
    _rccConsultantMobileNumberC.dispose();
    _apfNumberC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _projectNameC = TextEditingController();
    _projectLocationC = TextEditingController();
    _projectScopeC = TextEditingController();
    _ctsNumberC = TextEditingController();
    _fileNumberC = TextEditingController();
    _projectSubSchemeC = TextEditingController();
    _pinCodeC = TextEditingController();
    _projectEstimateCostC = TextEditingController();
    _onGoingBudgetCostC = TextEditingController();
    _projectAreaSqftC = TextEditingController();
    _projectAreaSqMtC = TextEditingController();
    _googleLocationC = TextEditingController();
    _reraNumberC = TextEditingController();
    _siteContactNameC = TextEditingController();
    _siteContactMobileNumberC = TextEditingController();
    _tenderAmountC = TextEditingController();
    _tendorEMDAmountC = TextEditingController();
    _chequeNumberC = TextEditingController();
    _payOrderTrackC = TextEditingController();
    _liasoningNameC = TextEditingController();
    _liasoningMobileNumberC = TextEditingController();
    _designingNameC = TextEditingController();
    _designingMobileNumberC = TextEditingController();
    _rccConsultantgNameC = TextEditingController();
    _rccConsultantMobileNumberC = TextEditingController();
    _apfNumberC = TextEditingController();
  }

  // PREFILL DIALOGUE TO ADD/UPDATE PROJECT MASTER
  void _prefillDialogueToAddUpdateProjectMaster(ProjectModel projectModel) {
    _projectNameC.text = widget.project!.projectName;
    _projectLocationC.text = widget.project!.projectLocation;
    _ctsNumberC.text = widget.project!.ctsNumber;
    _fileNumberC.text = widget.project!.fileNumber;
    _liasoningNameC.text = widget.project!.liasoningArchitectName;
    _liasoningMobileNumberC.text =
        widget.project!.liasoningArchitectMobileNumber;
    _designingNameC.text = widget.project!.designingArchitectName;
    _designingMobileNumberC.text =
        widget.project!.designingArchitectMobileNumber;
    _rccConsultantgNameC.text = widget.project!.rccConsultantName;
    _rccConsultantMobileNumberC.text =
        widget.project!.rccConsultantMobileNumber;
    selectedCategoryType.value = categoryList.firstWhere(
      (item) => item["DisplayName"] == widget.project!.category,
      orElse: () => categoryList.first,
    );
    final isTender = selectedCategoryType.value?["zAttributesId"] == 2;
    if (isTender) {
      _tenderAmountC.text = widget.project!.tenderAmount.toString();
      _tendorEMDAmountC.text = widget.project!.tenderEmdAmount.toString();
      purchaseStartDate = widget.project!.tenderPurchaseStartDate;
      purchaseEndDate = widget.project!.tenderPurchaseEndDate;
      _chequeNumberC.text = widget.project!.tenderChequeNumber ?? "";
      chequePhotoFile.fileNameList =
          widget.project!.tenderChequeNumberUrl!
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
      submissionDate = widget.project!.tenderSubmissionDate;
      issueDate = widget.project!.tenderIssueDate;
      _payOrderTrackC.text = widget.project!.tenderPayorderRemark ?? "";
    }
    _projectScopeC.text = widget.project!.projectScope;

    _pinCodeC.text = widget.project!.zipCode;
    _googleLocationC.text = widget.project!.googleLocation;
    _projectEstimateCostC.text = widget.project!.projectEstimateCost.toString();
    _onGoingBudgetCostC.text = widget.project!.onGoingBudgetCost.toString();
    _projectAreaSqftC.text = widget.project!.projectAreaInSqft.toString();
    _projectAreaSqMtC.text = widget.project!.projectAreaInSqmt.toString();
    _apfNumberC.text = widget.project!.apfNumber ?? "";
    _reraNumberC.text = widget.project!.reraNumber;
    _siteContactNameC.text = widget.project!.siteContactName;
    _siteContactMobileNumberC.text = widget.project!.siteContactMobileNumber;

    surveyDate = widget.project!.surveyDate;
    expectedStartDate = widget.project!.expectedStartDate;
    executionStartDate = widget.project!.executionStartDate;
    reraCertificateDate = widget.project!.reraCertificateDate;
    reraCompletionDate = widget.project!.reraComplitionDate;

    if (widget.project!.category.isNotEmpty) {
      selectedCategory = categoryList.firstWhere(
        (category) =>
            category["DisplayName"].toLowerCase() ==
            widget.project!.category.toLowerCase(),
      );
    }

    if (widget.project!.bussinessCategory.isNotEmpty) {
      selectedBusinessCategory = businessCategoryList.firstWhere(
        (businessCategory) =>
            businessCategory["DisplayName"] ==
            widget.project!.bussinessCategory,
        orElse: () => businessCategoryList.first,
      );
    }

    _selectedProjectStatusNotifier.value = projectStatusList.firstWhereOrNull(
      (status) => status["DisplayName"] == widget.project!.projectStatus,
    );

    if (widget.project!.projectScheme.isNotEmpty) {
      projectSchemeNotifier.value = projectSchemeList.firstWhere(
        (item) => item["DisplayName"] == widget.project!.projectScheme,
        orElse: () => projectSchemeList.first,
      );
      final subList = _currentSubSchemeList;
      selectedProjectSubScheme.value = subList.firstWhere(
        (item) => item["DisplayName"] == widget.project!.projectSubScheme,
        orElse: () => subList.first,
      );
    } else {
      projectSchemeNotifier.value = null;
      selectedProjectSubScheme.value = null;
    }

    projectPhotoImage.fileNameList =
        widget.project!.projectPhotoUrl
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    isRedevelopmentNotifier.value = widget.project!.isRedevelopment;
    _stateMasterId = projectModel.stateMasterId;
    _districtMasterId = projectModel.districtMasterId;
    _cityMasterId = projectModel.cityMasterId;
    _villageMasterId = projectModel.villageMasterId;
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
            ctsNumber:
                isRedevelopmentNotifier.value == false ? _ctsNumberC.text : "",
            projectPhotoMap: projectPhotoImage,
            category: selectedCategory?["DisplayName"] ?? "",
            businessCategory: selectedBusinessCategory?["DisplayName"] ?? "",
            fileNumber: _fileNumberC.text,
            liasoningArchitectName: _liasoningNameC.text,
            liasoningArchitectMobileNumber: _liasoningMobileNumberC.text,
            designingArchitectName: _designingNameC.text,
            designingArchitectMobileNumber: _designingMobileNumberC.text,
            rccMobileNumber: _rccConsultantgNameC.text,
            rccArchitectName: _rccConsultantMobileNumberC.text,
            category:
                selectedCategoryType.value != null
                    ? selectedCategoryType.value!["DisplayName"].toString()
                    : "",
            tenderAmount:
                _tenderAmountC.text.trim().isNotEmpty
                    ? _tenderAmountC.text
                    : "0.0",
            tenderEMDAmount:
                _tendorEMDAmountC.text.trim().isNotEmpty
                    ? _tendorEMDAmountC.text
                    : "0.0",
            tenderPurchaseStartDate: purchaseStartDate?.toIso8601String() ?? '',
            tenderPurchaseEndDate: purchaseEndDate?.toIso8601String() ?? "",
            tenderChequeNumber: _chequeNumberC.text,
            tenderChequeNumberURL: chequePhotoFile,
            tenderSubmissionDate: submissionDate?.toIso8601String() ?? "",
            tenderIssueDate: issueDate?.toIso8601String() ?? "",
            tenderPayorderRemark: _payOrderTrackC.text,
            isRedevelopment: isRedevelopmentNotifier.value,
            districtMasterId: _districtMasterId.toString(),
            stateMasterId: _stateMasterId.toString(),
            cityMasterId: _cityMasterId.toString(),
            villageMasterId: _villageMasterId.toString(),
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
            projectAreaInSqmt:
                _projectAreaSqMtC.text.trim().isNotEmpty
                    ? _projectAreaSqMtC.text
                    : "0.0",
            projectEstimateCost:
                _projectEstimateCostC.text.trim().isNotEmpty
                    ? _projectEstimateCostC.text
                    : "0.0",
            projectScheme:
                projectSchemeNotifier.value != null
                    ? projectSchemeNotifier.value!["DisplayName"].toString()
                    : "",
            projectScope: _projectScopeC.text,
            projectStatus:
                _selectedProjectStatusNotifier.value?["DisplayName"] ?? "",
            projectSubScheme:
                selectedProjectSubScheme.value != null
                    ? selectedProjectSubScheme.value!["DisplayName"].toString()
                    : "",
            apfNumber: _apfNumberC.text,
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
            ctsNumber:
                isRedevelopmentNotifier.value == false ? _ctsNumberC.text : "",
            projectPhotoMap: projectPhotoImage,
            category: selectedCategory?["DisplayName"] ?? "",
            businessCategory: selectedBusinessCategory?["DisplayName"] ?? "-",
            fileNumber: _fileNumberC.text,
            liasoningArchitectName: _liasoningNameC.text,
            liasoningArchitectMobileNumber: _liasoningMobileNumberC.text,
            designingArchitectName: _designingNameC.text,
            designingArchitectMobileNumber: _designingMobileNumberC.text,
            rccArchitectName: _rccConsultantgNameC.text,
            rccMobileNumber: _rccConsultantMobileNumberC.text,
            category:
                selectedCategoryType.value != null
                    ? selectedCategoryType.value!["DisplayName"].toString()
                    : "",
            tenderAmount:
                _tenderAmountC.text.trim().isNotEmpty
                    ? _tenderAmountC.text
                    : "0.0",
            tenderEMDAmount:
                _tendorEMDAmountC.text.trim().isNotEmpty
                    ? _tendorEMDAmountC.text
                    : "0.0",
            tenderPurchaseStartDate: purchaseStartDate?.toIso8601String() ?? '',
            tenderPurchaseEndDate: purchaseEndDate?.toIso8601String() ?? "",
            tenderChequeNumber: _chequeNumberC.text,
            tenderChequeNumberURL: chequePhotoFile,
            tenderSubmissionDate: submissionDate?.toIso8601String() ?? "",
            tenderIssueDate: issueDate?.toIso8601String() ?? "",
            tenderPayorderRemark: _payOrderTrackC.text,
            isRedevelopment: isRedevelopmentNotifier.value,
            districtMasterId: _districtMasterId.toString(),
            stateMasterId: _stateMasterId.toString(),
            cityMasterId: _cityMasterId.toString(),
            villageMasterId: _villageMasterId.toString(),
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
                projectSchemeNotifier.value != null
                    ? projectSchemeNotifier.value!["DisplayName"].toString()
                    : "",
            projectScope: _projectScopeC.text,
            projectStatus:
                _selectedProjectStatusNotifier.value?["DisplayName"] ?? "",
            projectSubScheme:
                selectedProjectSubScheme.value != null
                    ? selectedProjectSubScheme.value!["DisplayName"].toString()
                    : "",
            projectAreaInSqmt: _projectAreaSqMtC.text,
            apfNumber: _apfNumberC.text,
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
                  !_isEditMode ? "Add Project" : "Update Project",
                  style: AppTextStyle.ts16SB(),
                ),
                verticalSpacing(),
                // BASIC DETAILS
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Basic Details",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      verticalSpacing(),
                      ValueListenableBuilder<bool>(
                        valueListenable: isRedevelopmentNotifier,
                        builder: (context, isRedevelopment, _) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomCheckbox(
                                  value: isRedevelopment,
                                  onChanged: (check) {
                                    isRedevelopmentNotifier.value = check!;

                                    if (check) {
                                      _ctsNumberC.clear();
                                    }
                                  },
                                ),
                                horizontalSpacing(),
                                Flexible(
                                  child: Text(
                                    'Is this project a Redevelopment Project?',
                                    style: AppTextStyle.ts14R(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
                      verticalSpacing(),
                      ValueListenableBuilder<bool>(
                        valueListenable: isRedevelopmentNotifier,
                        builder: (context, isRedevelopment, child) {
                          return CustomTextField(
                            title: 'CTS Number',
                            hint: "Enter CTS Number",
                            isRequired: !isRedevelopment,
                            readOnly: isRedevelopment,
                            textController: _ctsNumberC,
                            inputFormatterList: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            validator: (value) {
                              if (!isRedevelopment &&
                                  (value == null || value.isEmpty)) {
                                return 'CTS number is required';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      CustomMultiFilePicker(
                        initialFileList: projectPhotoImage.fileNameList,
                        title: "Project Photo",
                        filePickType: FilePickType.image,
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

                      CustomDropDownWidget(
                        title: 'Category',
                        hintText: "Select Category",
                        initialValue: selectedCategory,
                        dataList: categoryList,
                        onSelected: (value) {
                          selectedCategory = value;
                        },
                        onValueClear: () {
                          selectedCategory = null;
                        },
                      ),

                      CustomDropDownWidget(
                        title: 'Business Category',
                        hintText: "Select Business Category",
                        initialValue: selectedBusinessCategory,
                        dataList: businessCategoryList,
                        onSelected: (value) {
                          selectedBusinessCategory = value;
                        },
                        onValueClear: () {
                          selectedBusinessCategory = null;
                        },
                      ),
                      CustomTextField(
                        title: 'File Number',
                        textController: _fileNumberC,
                        hint: "Enter File Number",
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                      ),
                    ],
                  ),
                ),
                // PROJECT CATEGORY
                Container(
                  padding: EdgeInsets.all(12.0),
                  margin: EdgeInsets.only(bottom: 10.0),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Category",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      verticalSpacing(),
                      ValueListenableBuilder(
                        valueListenable: selectedCategoryType,
                        builder: (context, value, child) {
                          return CustomDropDownWidget(
                            title: 'Category',
                            hintText: "Select Category",
                            isRequired: true,
                            initialValue: value,
                            dataList: categoryList,
                            onSelected: (val) {
                              if (selectedCategoryType
                                      .value?['zAttributesId'] !=
                                  val['zAttributesId']) {
                                selectedCategoryType.value = val;

                                final isDirect =
                                    val["DisplayName"]
                                        ?.toString()
                                        .toLowerCase() ==
                                    "direct";

                                if (isDirect) {
                                  _tenderAmountC.clear();
                                  _tendorEMDAmountC.clear();
                                  purchaseStartDate = null;
                                  purchaseEndDate = null;
                                  _chequeNumberC.clear();
                                  chequePhotoFile = MultiFilePickerModel(
                                    fileBytesList: [],
                                    fileNameList: [],
                                    deletedFileList: "",
                                  );
                                  _payOrderTrackC.clear();
                                  submissionDate = null;
                                  issueDate = null;
                                }
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Category is required";
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: selectedCategoryType,
                        builder: (context, value, child) {
                          final isTender =
                              value?["DisplayName"]?.toString().toLowerCase() ==
                              "tender";

                          if (!isTender) return SizedBox.shrink();

                          return Column(
                            children: [
                              CustomTextField(
                                title: 'Tender Amount (₹)',
                                textController: _tenderAmountC,
                                hint: "Enter Tender Amount",
                                inputFormatterList: InputValidator.decimal(2),
                              ),
                              CustomTextField(
                                title: 'Tender EMD Amount (₹)',
                                textController: _tendorEMDAmountC,
                                hint: "Enter Tender EMD Amount",
                                inputFormatterList: InputValidator.decimal(2),
                              ),
                              CustomDatePicker(
                                title: "Purchase Start Date",
                                initialDate: purchaseStartDate,
                                startDate: DateTime.now(),
                                setValue: (value) => purchaseStartDate = value,
                              ),
                              CustomDatePicker(
                                title: "Purchase End Date",
                                initialDate: purchaseEndDate,
                                startDate: DateTime.now(),
                                setValue: (value) => purchaseEndDate = value,
                              ),
                              CustomTextField(
                                title: 'Cheque Number',
                                textController: _chequeNumberC,
                                hint: "Enter Cheque Number",
                              ),
                              CustomMultiFilePicker(
                                title: "Cheque Photo",
                                filePickType: FilePickType.image,
                                initialFileList: chequePhotoFile.fileNameList,
                                initialFileBytes: chequePhotoFile.fileBytesList,
                                onFilePickedCallback: (
                                  bytesList,
                                  fileNameList,
                                ) {
                                  chequePhotoFile.fileNameList = fileNameList;
                                  chequePhotoFile.fileBytesList = bytesList;
                                },
                                onFileDeleteCallback: (
                                  fileBytesList,
                                  fileNameList,
                                  deleted,
                                ) {
                                  chequePhotoFile.fileBytesList = fileBytesList;
                                  chequePhotoFile.fileNameList = fileNameList;
                                  chequePhotoFile.deletedFileList = deleted;
                                },
                              ),
                              CustomDatePicker(
                                title: "Submission Date",
                                initialDate: submissionDate,
                                startDate: DateTime.now(),
                                setValue: (value) => submissionDate = value,
                              ),
                              CustomDatePicker(
                                title: "Issue Date",
                                initialDate: issueDate,
                                startDate: DateTime.now(),
                                setValue: (value) => issueDate = value,
                              ),
                              CustomTextField(
                                title: 'Payorder Remark',
                                textController: _payOrderTrackC,
                                hint: "Enter Payorder Remark",
                                minLines: 3,
                                maxLines: 10,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // LIASONING ARCHITECT
                Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Liasoning Architect",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'Name',
                        textController: _liasoningNameC,
                        hint: "Enter Name",
                      ),
                      CustomTextField(
                        title: 'Mobile Number',
                        textController: _liasoningMobileNumberC,
                        hint: "Enter Mobile Number",
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
                        inputFormatterList: InputValidator.digit(10),
                      ),
                    ],
                  ),
                ),
                // DESIGNING ARCHITECT
                Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Designing Architect",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'Name',
                        textController: _designingNameC,
                        hint: "Enter Name",
                      ),
                      CustomTextField(
                        title: 'Mobile Number',
                        textController: _designingMobileNumberC,
                        hint: "Enter Mobile Number",
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
                        inputFormatterList: InputValidator.digit(10),
                      ),
                    ],
                  ),
                ),
                // RCC CONSULTANT
                Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "RCC Consultant",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'Name',
                        textController: _rccConsultantgNameC,
                        hint: "Enter Name",
                      ),
                      CustomTextField(
                        title: 'Mobile Number',
                        textController: _rccConsultantMobileNumberC,
                        hint: "Enter Mobile Number",
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
                        inputFormatterList: InputValidator.digit(10),
                      ),
                    ],
                  ),
                ),
                // LOCATION
                Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Location Details",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      verticalSpacing(),
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
                        isRequired: true,
                        prefixWidget: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColor.grey,
                                width: .5,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: AppColor.grey,
                            size: 18,
                          ),
                        ),
                        textController: _googleLocationC,
                        hint: "Enter Google Location",
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Google Location is required";
                          }

                          final googleMapRegex = RegExp(
                            r'^(https?:\/\/)?(www\.)?(google\.com\/maps|goo\.gl\/maps|maps\.app\.goo\.gl)\/.+',
                          );

                          if (!googleMapRegex.hasMatch(value.trim())) {
                            return "Enter a valid Google Maps link";
                          }

                          return null;
                        },
                      ),
                      AddressWidget(
                        formKey: _projectMasterAddUpdateKey,
                        incomingStateId: _stateMasterId,
                        incomingDistrictId: _districtMasterId,
                        incomingCityId: widget.project?.cityMasterId,
                        incomingVillageId: _villageMasterId,
                        stateChange: (selectedState) {
                          _stateMasterId = selectedState['zAttributesId'];
                        },
                        districtChange: (selectedDistrict) {
                          _districtMasterId = selectedDistrict['zAttributesId'];
                        },
                        cityChange: (selectedCity) {
                          _cityMasterId = selectedCity['zAttributesId'];
                        },
                        villageChange: (selectedVillage) {
                          _villageMasterId = selectedVillage['zAttributesId'];
                        },
                      ),
                      CustomTextField(
                        title: 'PIN Code',
                        textController: _pinCodeC,
                        hint: "Enter PIN Code",
                        inputFormatterList: InputValidator.digit(6),
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
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
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
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: projectSchemeNotifier,
                        builder: (context, selectedProjectScheme, _) {
                          return CustomDropDownWidget(
                            title: 'Project Scheme',
                            hintText: 'Select Project Scheme',
                            initialValue: selectedProjectScheme,
                            dataList: projectSchemeList,
                            onSelected: (value) {
                              projectSchemeNotifier.value = value;
                            },
                            onValueClear: () {
                              projectSchemeNotifier.value = null;
                              selectedProjectSubScheme.value = null;
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: projectSchemeNotifier,
                        builder: (context, selectedProjectScheme, _) {
                          return ValueListenableBuilder(
                            valueListenable: selectedProjectSubScheme,
                            builder: (context, value, child) {
                              return CustomDropDownWidget(
                                title: 'Project Sub Scheme',
                                hintText: "Select Project Sub Scheme",
                                initialValue: value,
                                dataList: _currentSubSchemeList,
                                isDisabled: projectSchemeNotifier.value == null,
                                onSelected: (value) {
                                  selectedProjectSubScheme.value = value;
                                },
                                onValueClear: () {
                                  selectedProjectSubScheme.value = null;
                                },
                              );
                            },
                          );
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
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'APF Number',
                        hint: "Enter APF Number",
                        textController: _apfNumberC,
                        inputFormatterList:
                            InputValidator.reraInputFormatters(),
                      ),
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
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'Project Estimate Cost',
                        prefixWidget: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColor.grey,
                                width: .5,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.currency_rupee,
                            color: AppColor.grey,
                            size: 18,
                          ),
                        ),
                        hint: "Enter Estimate Cost",
                        textController: _projectEstimateCostC,
                        inputFormatterList: InputValidator.decimal(2),
                      ),
                      CustomTextField(
                        title: 'On Going Budget Cost',
                        prefixWidget: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColor.grey,
                                width: .5,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.currency_rupee,
                            color: AppColor.grey,
                            size: 18,
                          ),
                        ),
                        hint: "Enter Budget Cost",
                        textController: _onGoingBudgetCostC,
                        inputFormatterList: InputValidator.decimal(2),
                      ),
                      CustomTextField(
                        title: 'Project Area in Sqft',
                        hint: "Enter Area in (Sqft)",
                        textController: _projectAreaSqftC,
                        inputFormatterList: InputValidator.decimal(2),
                      ),
                      CustomTextField(
                        title: 'Project Area in (SqMt)',
                        hint: "Enter Project Area in (SqMt)",
                        textController: _projectAreaSqMtC,
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
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
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
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
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
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: _selectedProjectStatusNotifier,
                        builder: (context, status, _) {
                          return CustomDropDownWidget(
                            title: 'Project Status',
                            initialValue: status,
                            hintText: "Select Project Status",
                            dataList: projectStatusList,
                            onSelected: (value) {
                              _selectedProjectStatusNotifier.value = value;
                            },
                            onValueClear: () {
                              _selectedProjectStatusNotifier.value = null;
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
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading:
                _isEditMode
                    ? Icon(Icons.edit, size: 18, color: AppColor.white)
                    : Icon(Icons.add, size: 18, color: AppColor.white),
            text: _isEditMode ? 'Update' : 'Add',
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
