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
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
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
  final ValueNotifier<List<Map<String, dynamic>>?> _selectedProjectSubScheme =
      ValueNotifier(null);
  final ValueNotifier<bool> _isFederation = ValueNotifier(false);

  late final ValueNotifier<Map<String, dynamic>?>
  _selectedProjectStatusNotifier;

  // ADDRESS VARIABLES
  int? _countryMasterId;
  int? _stateMasterId;
  int? _districtMasterId;
  int? _cityMasterId;
  int? _villageMasterId;

  final ValueNotifier<Map<String, dynamic>?> projectSchemeNotifier =
      ValueNotifier(null);

  // DATE PICKER VARIABLE
  DateTime? reraPossessionDate;
  DateTime? reraCertificateDate;
  DateTime? surveyDate;
  DateTime? expectedStartDate;
  DateTime? executionStartDate;
  final ValueNotifier<DateTime?> purchaseStartDate = ValueNotifier(null);
  final ValueNotifier<DateTime?> purchaseEndDate = ValueNotifier(null);
  final ValueNotifier<DateTime?> submissionDate = ValueNotifier(null);

  // TEXT EDITING CONTROLLER
  late TextEditingController _projectNameC,
      _projectLocationC,
      _projectScopeC,
      _ctsNumberC,
      _fileNumberC,
      _tenderAmountC,
      _tendorEmdAmountC,
      _tenantAmountTransactionNumberC,
      _tenantEmdTransactionNumberC,
      _tenderEmdPayOrderRemarkC,
      _liasoningNameC,
      _liasoningMobileNumberC,
      _designingNameC,
      _designingMobileNumberC,
      _rccConsultantNameC,
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
      _siteContact1NameC,
      _siteContact1MobileNumberC,
      _siteContact1DesignationC,
      _siteContact2NameC,
      _siteContact2MobileNumberC,
      _siteContact2DesignationC,
      _siteContact3NameC,
      _siteContact3MobileNumberC,
      _siteContact3DesignationC,
      _tenderAmountPayOrderRemarkC,
      _federationAmountC;

  final ValueNotifier<Map<String, dynamic>?>
  _selectedTenantAmountPaymentModeNotifier = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?>
  _selectedTenantEmdPaymentModeNotifier = ValueNotifier(null);
  // CHECKBOX FOR REDEVELOPMENT
  final ValueNotifier<bool> isRedevelopmentNotifier = ValueNotifier(false);
  late ValueNotifier<Map<String, dynamic>?> selectedCategoryType;

  // ProjectPhotoURL IMAGE SELECTION
  MultiFilePickerModel projectPhotoImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel tenderAmountTransactionFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel tenderEmdTransactionFile = MultiFilePickerModel(
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
    {"zAttributesId": 4, "DisplayName": "33 (7) B"},
    {"zAttributesId": 5, "DisplayName": "33 (7) A"},
    {"zAttributesId": 6, "DisplayName": "33 (9)"},
    {"zAttributesId": 7, "DisplayName": "33 (12) B"},
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
      _populateFormFields(widget.project!);
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
    _siteContact1NameC.dispose();
    _siteContact1MobileNumberC.dispose();
    _siteContact1DesignationC.dispose();
    _siteContact2NameC.dispose();
    _siteContact2MobileNumberC.dispose();
    _siteContact2DesignationC.dispose();
    _siteContact3NameC.dispose();
    _siteContact3MobileNumberC.dispose();
    _siteContact3DesignationC.dispose();
    isRedevelopmentNotifier.dispose();
    projectSchemeNotifier.dispose();
    _selectedProjectStatusNotifier.dispose();
    selectedCategoryType.dispose();
    _tenderAmountC.dispose();
    _tendorEmdAmountC.dispose();
    _tenantAmountTransactionNumberC.dispose();
    _tenderEmdPayOrderRemarkC.dispose();
    _liasoningNameC.dispose();
    _liasoningMobileNumberC.dispose();
    _designingNameC.dispose();
    _designingMobileNumberC.dispose();
    _rccConsultantNameC.dispose();
    _rccConsultantMobileNumberC.dispose();
    _apfNumberC.dispose();
    _selectedTenantAmountPaymentModeNotifier.dispose();
    _selectedTenantEmdPaymentModeNotifier.dispose();
    _tenderAmountPayOrderRemarkC.dispose();
    _tenantEmdTransactionNumberC.dispose();
    _federationAmountC.dispose();
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
    _siteContact1NameC = TextEditingController();
    _siteContact1MobileNumberC = TextEditingController();
    _siteContact1DesignationC = TextEditingController();
    _siteContact2NameC = TextEditingController();
    _siteContact2MobileNumberC = TextEditingController();
    _siteContact2DesignationC = TextEditingController();
    _siteContact3NameC = TextEditingController();
    _siteContact3MobileNumberC = TextEditingController();
    _siteContact3DesignationC = TextEditingController();
    _tenderAmountC = TextEditingController();
    _tendorEmdAmountC = TextEditingController();
    _tenantAmountTransactionNumberC = TextEditingController();
    _tenderEmdPayOrderRemarkC = TextEditingController();
    _liasoningNameC = TextEditingController();
    _liasoningMobileNumberC = TextEditingController();
    _designingNameC = TextEditingController();
    _designingMobileNumberC = TextEditingController();
    _rccConsultantNameC = TextEditingController();
    _rccConsultantMobileNumberC = TextEditingController();
    _apfNumberC = TextEditingController();
    _tenderAmountPayOrderRemarkC = TextEditingController();
    _tenderEmdPayOrderRemarkC = TextEditingController();
    _tenantEmdTransactionNumberC = TextEditingController();
    _federationAmountC = TextEditingController();
  }

  // PREFILL DIALOGUE TO ADD/UPDATE PROJECT MASTER
  void _populateFormFields(ProjectModel projectModel) {
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
    _rccConsultantNameC.text = widget.project!.rccConsultantName;
    _rccConsultantMobileNumberC.text =
        widget.project!.rccConsultantMobileNumber;
    selectedCategoryType.value = projectCategoryList.firstWhere(
      (item) => item["DisplayName"] == widget.project!.category,
      orElse: () => projectCategoryList.first,
    );
    final isTender = selectedCategoryType.value?["zAttributesId"] == 2;
    if (isTender) {
      _tenderAmountC.text = widget.project!.tenderAmount.toString();
      _tendorEmdAmountC.text = widget.project!.tenderEmdAmount.toString();
      purchaseStartDate.value = widget.project!.tenderPurchaseStartDate;
      purchaseEndDate.value = widget.project!.tenderPurchaseEndDate;
      _tenantAmountTransactionNumberC.text =
          widget.project!.tenderAmountChequeNumber;
      tenderAmountTransactionFile.fileNameList =
          widget.project!.tenderAmountChequeNumberUrl.isEmpty
              ? []
              : widget.project!.tenderAmountChequeNumberUrl
                  .split(",")
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
      tenderEmdTransactionFile.fileNameList =
          widget.project!.tenderEmdChequeNumberUrl.isEmpty
              ? []
              : widget.project!.tenderEmdChequeNumberUrl
                  .split(",")
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
      submissionDate.value = widget.project!.tenderSubmissionDate;
      _tenderEmdPayOrderRemarkC.text =
          widget.project!.tenderPayorderRemark ?? "";
      _selectedTenantEmdPaymentModeNotifier
          .value = tenurePaymentModeList.firstWhereOrNull(
        (item) => item["DisplayName"] == widget.project!.tenderEmdPaymentMode,
      );
      _selectedTenantAmountPaymentModeNotifier.value = tenurePaymentModeList
          .firstWhereOrNull(
            (item) =>
                item["DisplayName"] == widget.project!.tenderAmountPaymentMode,
          );
      _tenantEmdTransactionNumberC.text = widget.project!.tenderEmdChequeNumber;
      _tenderAmountPayOrderRemarkC.text =
          widget.project!.tenderAmountPayorderRemark;
      _tenderEmdPayOrderRemarkC.text = widget.project!.tenderEmdPayorderRemark;
    } else {
      _tenderAmountC.text = '';
      _tendorEmdAmountC.text = '';
      purchaseStartDate.value = null;
      purchaseEndDate.value = null;
      _tenantAmountTransactionNumberC.text = '';
      tenderAmountTransactionFile.fileNameList = [];
      tenderEmdTransactionFile.fileNameList = [];
      submissionDate.value = null;
      _tenderEmdPayOrderRemarkC.text = '';
      _selectedTenantEmdPaymentModeNotifier.value = null;
      _selectedTenantAmountPaymentModeNotifier.value = null;
      _tenantAmountTransactionNumberC.text = '';
      _tenantEmdTransactionNumberC.text = '';
      _tenderAmountPayOrderRemarkC.text = '';
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
    _siteContact1NameC.text = widget.project!.siteContactName;
    _siteContact1MobileNumberC.text = widget.project!.siteContactMobileNumber;
    _siteContact1DesignationC.text = widget.project!.siteContactDesignation;

    _siteContact2NameC.text = widget.project!.siteContact2Name;
    _siteContact2MobileNumberC.text = widget.project!.siteContact2MobileNumber;
    _siteContact2DesignationC.text = widget.project!.siteContact2Designation;
    _siteContact3NameC.text = widget.project!.siteContact3Name;
    _siteContact3MobileNumberC.text = widget.project!.siteContact3MobileNumber;
    _siteContact3DesignationC.text = widget.project!.siteContact3Designation;
    surveyDate = widget.project!.surveyDate;
    expectedStartDate = widget.project!.expectedStartDate;
    executionStartDate = widget.project!.executionStartDate;
    reraCertificateDate = widget.project!.reraCertificateDate;
    reraPossessionDate = widget.project!.reraPossessionDate;

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
      _selectedProjectSubScheme.value =
          subList
              .where(
                (item) => widget.project!.projectSubScheme
                    .split(",")
                    .contains(item["DisplayName"]),
              )
              .toList();
    } else {
      projectSchemeNotifier.value = null;
      _selectedProjectSubScheme.value = null;
    }

    projectPhotoImage.fileNameList =
        widget.project!.projectPhotoUrl
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    isRedevelopmentNotifier.value = widget.project!.isRedevelopment;
    _isFederation.value = widget.project!.isFederation;
    _federationAmountC.text = widget.project!.federationAmount.toString();
    _countryMasterId = projectModel.countryMasterId;
    _stateMasterId = projectModel.stateMasterId;
    _districtMasterId = projectModel.districtMasterId;
    _cityMasterId = projectModel.cityMasterId;
    _villageMasterId = projectModel.villageMasterId;
  }

  String get selectedProjectSubScheme =>
      _selectedProjectSubScheme.value != null
          ? _selectedProjectSubScheme.value!
              .map((v) => v["DisplayName"].toString())
              .toSet()
              .join(",")
          : "";

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
            businessCategory: selectedBusinessCategory?["DisplayName"] ?? "",
            fileNumber: _fileNumberC.text,
            liasoningArchitectName: _liasoningNameC.text,
            liasoningArchitectMobileNumber: _liasoningMobileNumberC.text,
            designingArchitectName: _designingNameC.text,
            designingArchitectMobileNumber: _designingMobileNumberC.text,
            rccMobileNumber: _rccConsultantMobileNumberC.text,
            rccConsulantName: _rccConsultantNameC.text,
            category:
                selectedCategoryType.value != null
                    ? selectedCategoryType.value!["DisplayName"].toString()
                    : "",
            tenderAmount:
                _tenderAmountC.text.trim().isNotEmpty
                    ? _tenderAmountC.text
                    : "0.0",
            tenderEMDAmount:
                _tendorEmdAmountC.text.trim().isNotEmpty
                    ? _tendorEmdAmountC.text
                    : "0.0",
            tenderPurchaseStartDate:
                purchaseStartDate.value?.toIso8601String() ?? '',
            tenderPurchaseEndDate:
                purchaseEndDate.value?.toIso8601String() ?? "",
            tenderChequeNumber: _tenantAmountTransactionNumberC.text,
            tenderChequeNumberFile: tenderAmountTransactionFile,
            tenderEmdChequeNumberFile: tenderEmdTransactionFile,
            tenderSubmissionDate: submissionDate.value?.toIso8601String() ?? "",
            tenderPayorderRemark: _tenderAmountPayOrderRemarkC.text,
            isRedevelopment: isRedevelopmentNotifier.value,
            countryMasterId: _countryMasterId?.toString() ?? "1",
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
            projectSubScheme: selectedProjectSubScheme,
            apfNumber: _apfNumberC.text,
            reraNumber: _reraNumberC.text,
            reraCertificateDate: reraCertificateDate?.toIso8601String() ?? "",
            reraPossessionDate: reraPossessionDate?.toIso8601String() ?? "",
            siteContact1MobileNumber: _siteContact1MobileNumberC.text.trim(),
            siteContact1Name: _siteContact1NameC.text.trim(),
            siteContact1Designation: _siteContact1DesignationC.text.trim(),
            siteContact2MobileNumber: _siteContact2MobileNumberC.text.trim(),
            siteContact2Name: _siteContact2NameC.text.trim(),
            siteContact2Designation: _siteContact2DesignationC.text.trim(),
            siteContact3MobileNumber: _siteContact3MobileNumberC.text.trim(),
            siteContact3Name: _siteContact3NameC.text.trim(),
            siteContact3Designation: _siteContact3DesignationC.text.trim(),
            surveyDate: surveyDate?.toIso8601String() ?? '',
            tenderAmountPaymentMode:
                _selectedTenantAmountPaymentModeNotifier
                    .value?["DisplayName"] ??
                '',
            tenderAmountChequeNumber:
                _tenantAmountTransactionNumberC.text.trim(),
            tenderAmountPayorderRemark:
                _tenderAmountPayOrderRemarkC.text.trim(),
            tenderEmdPaymentMode:
                _selectedTenantEmdPaymentModeNotifier.value?["DisplayName"] ??
                '',
            tenderEmdChequeNumber: _tenantEmdTransactionNumberC.text.trim(),
            tenderEmdPayorderRemark: _tenderEmdPayOrderRemarkC.text.trim(),
            projectShortName:
                _projectNameC.text.trim().isNotEmpty
                    ? _projectNameC.text.trim().substring(0, 3).toUpperCase()
                    : "",
            isFederation: _isFederation.value,
            federationAmount:
                _federationAmountC.text.trim().isNotEmpty
                    ? _federationAmountC.text
                    : "0.0",
          )
          : _projectMasterCubit.addProject(
            context: context,
            projectName: _projectNameC.text,
            location: _projectLocationC.text,
            ctsNumber:
                isRedevelopmentNotifier.value == false ? _ctsNumberC.text : "",
            projectPhotoMap: projectPhotoImage,
            businessCategory: selectedBusinessCategory?["DisplayName"] ?? "-",
            fileNumber: _fileNumberC.text,
            liasoningArchitectName: _liasoningNameC.text,
            liasoningArchitectMobileNumber: _liasoningMobileNumberC.text,
            designingArchitectName: _designingNameC.text,
            designingArchitectMobileNumber: _designingMobileNumberC.text,
            rccConsulantName: _rccConsultantNameC.text,
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
                _tendorEmdAmountC.text.trim().isNotEmpty
                    ? _tendorEmdAmountC.text
                    : "0.0",
            tenderPurchaseStartDate:
                purchaseStartDate.value?.toIso8601String() ?? '',
            tenderPurchaseEndDate:
                purchaseEndDate.value?.toIso8601String() ?? "",
            tenderChequeNumber: _tenantAmountTransactionNumberC.text,
            tenderChequeNumberFile: tenderAmountTransactionFile,
            tenderEmdChequeNumberFile: tenderEmdTransactionFile,
            tenderSubmissionDate: submissionDate.value?.toIso8601String() ?? "",
            tenderPayorderRemark: _tenderAmountPayOrderRemarkC.text,
            isRedevelopment: isRedevelopmentNotifier.value,
            countryMasterId: _countryMasterId?.toString() ?? "1",
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
            projectSubScheme: selectedProjectSubScheme,
            projectAreaInSqmt:
                _projectAreaSqMtC.text.trim().isNotEmpty
                    ? _projectAreaSqMtC.text
                    : "0.0",
            apfNumber: _apfNumberC.text,
            reraNumber: _reraNumberC.text,
            reraCertificateDate: reraCertificateDate?.toIso8601String() ?? "",
            reraPossessionDate: reraPossessionDate?.toIso8601String() ?? "",
            siteContact1MobileNumber: _siteContact1MobileNumberC.text.trim(),
            siteContact1Name: _siteContact1NameC.text.trim(),
            siteContact1Designation: _siteContact1DesignationC.text.trim(),
            siteContact2MobileNumber: _siteContact2MobileNumberC.text.trim(),
            siteContact2Name: _siteContact2NameC.text.trim(),
            siteContact2Designation: _siteContact2DesignationC.text.trim(),
            siteContact3MobileNumber: _siteContact3MobileNumberC.text.trim(),
            siteContact3Name: _siteContact3NameC.text.trim(),
            siteContact3Designation: _siteContact3DesignationC.text.trim(),
            surveyDate: surveyDate?.toIso8601String() ?? '',
            tenderAmountPaymentMode:
                _selectedTenantAmountPaymentModeNotifier
                    .value?["DisplayName"] ??
                '',
            tenderAmountChequeNumber:
                _tenantAmountTransactionNumberC.text.trim(),
            tenderAmountPayorderRemark:
                _tenderAmountPayOrderRemarkC.text.trim(),
            tenderEmdPaymentMode:
                _selectedTenantEmdPaymentModeNotifier.value?["DisplayName"] ??
                '',
            tenderEmdChequeNumber: _tenantEmdTransactionNumberC.text.trim(),
            tenderEmdPayorderRemark: _tenderEmdPayOrderRemarkC.text.trim(),
            projectShortName:
                _projectNameC.text.trim().isNotEmpty
                    ? _projectNameC.text.trim().substring(0, 3).toUpperCase()
                    : "",
            isFederation: _isFederation.value,
            federationAmount:
                _federationAmountC.text.trim().isNotEmpty
                    ? _federationAmountC.text
                    : "0.0",
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
                                CustomCheckBox(
                                  isSelected: isRedevelopment,
                                  onChanged: (check) {
                                    isRedevelopmentNotifier.value = check;
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
                            dataList: projectCategoryList,
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
                                  purchaseStartDate.value = null;
                                  purchaseEndDate.value = null;
                                  _selectedTenantAmountPaymentModeNotifier
                                      .value = null;
                                  _tenantAmountTransactionNumberC.clear();
                                  tenderAmountTransactionFile =
                                      MultiFilePickerModel(
                                        fileBytesList: [],
                                        fileNameList: [],
                                        deletedFileList: "",
                                      );
                                  _tenderAmountPayOrderRemarkC.clear();
                                  _tenderEmdPayOrderRemarkC.clear();
                                  _tendorEmdAmountC.clear();
                                  submissionDate.value = null;
                                  _selectedTenantEmdPaymentModeNotifier.value =
                                      null;
                                  _tenantEmdTransactionNumberC.clear();
                                  tenderEmdTransactionFile =
                                      MultiFilePickerModel(
                                        fileBytesList: [],
                                        fileNameList: [],
                                        deletedFileList: "",
                                      );
                                  _tenderEmdPayOrderRemarkC.clear();
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
                    ],
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: selectedCategoryType,
                  builder: (context, value, child) {
                    if (selectedCategoryType.value == null ||
                        selectedCategoryType.value?['DisplayName'] ==
                            'Direct') {
                      return SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.0),
                          margin: EdgeInsets.only(bottom: 10.0),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tender Amount Details",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.black.withValues(alpha: 0.5),
                                ),
                              ),
                              verticalSpacing(),
                              ValueListenableBuilder(
                                valueListenable: selectedCategoryType,
                                builder: (context, value, child) {
                                  final isTender =
                                      value?["DisplayName"]
                                          ?.toString()
                                          .toLowerCase() ==
                                      "tender";

                                  if (!isTender) return SizedBox.shrink();

                                  return Column(
                                    children: [
                                      CustomTextField(
                                        title: 'Amount (₹)',
                                        textController: _tenderAmountC,
                                        hint: "Enter Amount",
                                        isRequired: true,
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        inputFormatterList:
                                            InputValidator.decimal(2),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Amount is required.";
                                          }
                                          return null;
                                        },
                                      ),

                                      ValueListenableBuilder(
                                        valueListenable: purchaseStartDate,
                                        builder: (
                                          context,
                                          purchaseStartDt,
                                          child,
                                        ) {
                                          return CustomDatePicker(
                                            title: "Purchase Start Date",
                                            isRequired: true,
                                            initialDate: purchaseStartDt,
                                            setValue:
                                                (value) =>
                                                    purchaseStartDate.value =
                                                        value,
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Purchase Start Date is required.';
                                              }

                                              return null;
                                            },
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: purchaseEndDate,
                                        builder: (
                                          context,
                                          purchaseEndDt,
                                          child,
                                        ) {
                                          return CustomDatePicker(
                                            title: "Purchase End Date",
                                            initialDate: purchaseEndDt,
                                            isRequired: true,
                                            setValue:
                                                (value) =>
                                                    purchaseEndDate.value =
                                                        value,
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Purchase End Date is required.';
                                              }

                                              return null;
                                            },
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable:
                                            _selectedTenantAmountPaymentModeNotifier,
                                        builder: (
                                          context,
                                          selectedPaymentMode,
                                          _,
                                        ) {
                                          return CustomDropDownWidget(
                                            title: "Payment Mode",
                                            hintText: "Select Payment Mode",
                                            initialValue: selectedPaymentMode,
                                            dataList: tenurePaymentModeList,
                                            onSelected: (value) {
                                              _selectedTenantAmountPaymentModeNotifier
                                                  .value = value;
                                            },

                                            onValueClear: () {
                                              _selectedTenantAmountPaymentModeNotifier
                                                  .value = null;
                                            },
                                          );
                                        },
                                      ),

                                      CustomTextField(
                                        title:
                                            'Transaction / Cheque / Demand Draft No',
                                        textController:
                                            _tenantAmountTransactionNumberC,
                                        hint:
                                            "Enter Transaction / Cheque / Demand Draft No",
                                        inputFormatterList:
                                            InputValidator.digitAndCharacterOnly(
                                              15,
                                            ),
                                      ),
                                      CustomMultiFilePicker(
                                        title:
                                            "Transaction / Cheque / Demand Draft Image",
                                        filePickType: FilePickType.image,
                                        initialFileList:
                                            tenderAmountTransactionFile
                                                .fileNameList,
                                        initialFileBytes:
                                            tenderAmountTransactionFile
                                                .fileBytesList,
                                        onFilePickedCallback: (
                                          bytesList,
                                          fileNameList,
                                        ) {
                                          tenderAmountTransactionFile
                                              .fileNameList = fileNameList;
                                          tenderAmountTransactionFile
                                              .fileBytesList = bytesList;
                                        },
                                        onFileDeleteCallback: (
                                          fileBytesList,
                                          fileNameList,
                                          deleted,
                                        ) {
                                          tenderAmountTransactionFile
                                              .fileBytesList = fileBytesList;
                                          tenderAmountTransactionFile
                                              .fileNameList = fileNameList;
                                          tenderAmountTransactionFile
                                              .deletedFileList = deleted;
                                        },
                                      ),
                                      CustomTextField(
                                        title: 'Payorder Remark',
                                        textController:
                                            _tenderAmountPayOrderRemarkC,
                                        hint: "Enter Payorder Remark",
                                        minLines: 3,
                                        maxLines: 3,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(12.0),
                          margin: EdgeInsets.only(bottom: 10.0),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tender EMD Details",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.black.withValues(alpha: 0.5),
                                ),
                              ),
                              verticalSpacing(),
                              ValueListenableBuilder(
                                valueListenable: selectedCategoryType,
                                builder: (context, value, child) {
                                  final isTender =
                                      value?["DisplayName"]
                                          ?.toString()
                                          .toLowerCase() ==
                                      "tender";

                                  if (!isTender) return SizedBox.shrink();

                                  return Column(
                                    children: [
                                      CustomTextField(
                                        title: 'EMD Amount (₹)',
                                        textController: _tendorEmdAmountC,
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        hint: "Enter EMD Amount",
                                        inputFormatterList:
                                            InputValidator.decimal(2),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: submissionDate,
                                        builder: (
                                          context,
                                          submissionDt,
                                          child,
                                        ) {
                                          return CustomDatePicker(
                                            title: "Submission Date",
                                            initialDate: submissionDt,
                                            setValue:
                                                (value) =>
                                                    submissionDate.value =
                                                        value,
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable:
                                            _selectedTenantEmdPaymentModeNotifier,
                                        builder: (
                                          context,
                                          selectedPaymentMode,
                                          _,
                                        ) {
                                          return CustomDropDownWidget(
                                            title: "Payment Mode",
                                            hintText: "Select Payment Mode",
                                            initialValue: selectedPaymentMode,
                                            dataList: tenurePaymentModeList,
                                            onSelected: (value) {
                                              _selectedTenantEmdPaymentModeNotifier
                                                  .value = value;
                                            },

                                            onValueClear: () {
                                              _selectedTenantEmdPaymentModeNotifier
                                                  .value = null;
                                            },
                                          );
                                        },
                                      ),

                                      CustomTextField(
                                        title:
                                            'Transaction / Cheque / Demand Draft No',
                                        textController:
                                            _tenantEmdTransactionNumberC,
                                        hint:
                                            "Enter Transaction / Cheque / Demand Draft No",
                                        inputFormatterList:
                                            InputValidator.digitAndCharacterOnly(
                                              15,
                                            ),
                                      ),
                                      CustomMultiFilePicker(
                                        title:
                                            "Transaction / Cheque / Demand Draft Image",
                                        filePickType: FilePickType.image,
                                        initialFileList:
                                            tenderEmdTransactionFile
                                                .fileNameList,
                                        initialFileBytes:
                                            tenderEmdTransactionFile
                                                .fileBytesList,
                                        onFilePickedCallback: (
                                          bytesList,
                                          fileNameList,
                                        ) {
                                          tenderEmdTransactionFile
                                              .fileNameList = fileNameList;
                                          tenderEmdTransactionFile
                                              .fileBytesList = bytesList;
                                        },
                                        onFileDeleteCallback: (
                                          fileBytesList,
                                          fileNameList,
                                          deleted,
                                        ) {
                                          tenderEmdTransactionFile
                                              .fileBytesList = fileBytesList;
                                          tenderEmdTransactionFile
                                              .fileNameList = fileNameList;
                                          tenderEmdTransactionFile
                                              .deletedFileList = deleted;
                                        },
                                      ),

                                      CustomTextField(
                                        title: 'Payorder Remark',
                                        textController:
                                            _tenderEmdPayOrderRemarkC,
                                        hint: "Enter Payorder Remark",
                                        minLines: 3,
                                        maxLines: 3,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
                        keyboardType: TextInputType.number,
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
                        keyboardType: TextInputType.number,
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
                        textController: _rccConsultantNameC,
                        hint: "Enter Name",
                      ),
                      CustomTextField(
                        title: 'Mobile Number',
                        textController: _rccConsultantMobileNumberC,
                        hint: "Enter Mobile Number",
                        keyboardType: TextInputType.number,
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
                        incomingCountryId: _countryMasterId ?? 1,
                        incomingStateId: _stateMasterId,
                        incomingDistrictId: _districtMasterId,
                        incomingCityId: widget.project?.cityMasterId,
                        incomingVillageId: _villageMasterId,
                        countryChange: (selectedCountry) {
                          _countryMasterId = selectedCountry['zAttributesId'];
                        },
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
                              _selectedProjectSubScheme.value = null;
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: projectSchemeNotifier,
                        builder: (context, selectedProjectScheme, _) {
                          return ValueListenableBuilder(
                            valueListenable: _selectedProjectSubScheme,
                            builder: (context, value, child) {
                              return CustomMultipleSelectPopup(
                                title: 'Project Sub Scheme',
                                hintText: "Select Project Sub Scheme",
                                initialValue: value,

                                dataList: _currentSubSchemeList,
                                isReadOnly: projectSchemeNotifier.value == null,
                                onSelected: (value) {
                                  _selectedProjectSubScheme.value = value;
                                },
                                onClear: () {
                                  _selectedProjectSubScheme.value = null;
                                },
                                dataFetchCallBack:
                                    (pageNumber, {value}) => filterDropdownList(
                                      pageNumber,
                                      value: value,
                                      list: _currentSubSchemeList,
                                    ),
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
                        title: 'RERA Possession Date',
                        initialDate: reraPossessionDate,
                        setValue: (value) {
                          reraPossessionDate = value;
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
                      ValueListenableBuilder(
                        valueListenable: _isFederation,
                        builder: (context, isPayTAA, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              CustomCheckBox(
                                isSelected: isPayTAA,
                                onChanged: (val) {
                                  _isFederation.value = val;
                                },
                                title: "Is This Project a Federation?",
                              ),
                              CustomTextField(
                                title: 'Project Project Federation Amount',
                                isRequired: isPayTAA,
                                readOnly: !isPayTAA,
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
                                hint:
                                    isPayTAA
                                        ? "Enter Project Federation Amount"
                                        : "0",
                                textController: _federationAmountC,
                                inputFormatterList: InputValidator.decimal(2),
                              ),
                            ],
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
                        "Site Contact Information",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      verticalSpacing(),
                      CustomTextField(
                        title: 'Name',
                        hint: "Enter Site Contact Name",
                        textController: _siteContact1NameC,
                        inputFormatterList: InputValidator.textOnly(100),
                      ),
                      CustomTextField(
                        title: 'Mobile Number',
                        hint: "Enter Mobile Number",
                        textController: _siteContact1MobileNumberC,
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
                        title: 'Designation',
                        hint: "Enter Designation",
                        textController: _siteContact1DesignationC,
                        inputFormatterList: InputValidator.textOnly(100),
                      ),
                      CustomTextField(
                        title: 'Name 2',
                        hint: "Enter Site Contact2 Name",
                        textController: _siteContact2NameC,
                        inputFormatterList: InputValidator.textOnly(100),
                      ),
                      CustomTextField(
                        title: 'Mobile Number 2',
                        hint: "Enter Mobile Number",
                        textController: _siteContact2MobileNumberC,
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
                        title: 'Designation 2',
                        hint: "Enter Designation",
                        textController: _siteContact2DesignationC,
                        inputFormatterList: InputValidator.textOnly(100),
                      ),
                      CustomTextField(
                        title: 'Name 3',
                        hint: "Enter Site Contact3 Name",
                        textController: _siteContact3NameC,
                        inputFormatterList: InputValidator.textOnly(100),
                      ),
                      CustomTextField(
                        title: 'Mobile Number 3',
                        hint: "Enter Mobile Number",
                        textController: _siteContact3MobileNumberC,
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
                        title: 'Designation 3',
                        hint: "Enter Designation",
                        textController: _siteContact3DesignationC,
                        inputFormatterList: InputValidator.textOnly(100),
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
