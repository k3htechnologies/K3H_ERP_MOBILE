import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBuildingScreen extends StatefulWidget {
  final BusinessDevelopmentBuildingModel? building;
  final int index;
  final int? projectId;
  const AddBuildingScreen({
    super.key,
    this.building,
    this.index = 0,
    this.projectId,
  });
  @override
  State<AddBuildingScreen> createState() => _AddBuildingScreenState();
}

class _AddBuildingScreenState extends State<AddBuildingScreen> {
  late BuildingCubit _buildingCubit;
  late AuthorizationModel _routhAuthorizationModel;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _buildingNameC,
      _ctsNumberC,
      _totalPlotAreaSqMtC,
      _totalPlotAreaSqFtC,
      _totalNumberOfUnitsC,
      _tenderAmountC,
      _tenantAmountTransactionNumberC,
      _tenderAmountPayOrderRemarkC,
      _tendorEmdAmountC,
      _tenantEmdTransactionNumberC,
      _tenderEmdPayOrderRemarkC,
      _totalUnitsAreaUtilizedC,
      _totalGardenAreaC,
      _totalReligiousStructureAreaC,
      _propertyAgeYearsC,
      _numberOfFloorsC,
      _numberOfWingsC,
      _fsiTdrUtilizationC,
      _litigationRemarksC,
      _googleLocationC,
      _searchC;
  int? _countryMasterId;
  int? _stateMasterId;
  int? _districtMasterId;
  int? _cityMasterId;
  int? _villageMasterId;
  int? _wardMasterId;
  final ValueNotifier<bool> _isGarden = ValueNotifier(false);
  final ValueNotifier<bool> _isReligiousStructure = ValueNotifier(false);
  final ValueNotifier<bool> _isLitigation = ValueNotifier(false);
  final ValueNotifier<Map<String, dynamic>?> _selectedLandOwnershipType =
      ValueNotifier<Map<String, dynamic>?>(null);
  final List<Map<String, dynamic>> _ownershipTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'Landlord'},
    {'zAttributesId': 2, 'DisplayName': 'Society'},
    {'zAttributesId': 3, 'DisplayName': 'Government'},
  ];
  final ValueNotifier<Map<String, dynamic>?> _selectedRoadWidth =
      ValueNotifier<Map<String, dynamic>?>(null);
  final List<Map<String, dynamic>> _roadWidthList = [
    {'zAttributesId': 1, 'DisplayName': '6.10 M'},
    {'zAttributesId': 2, 'DisplayName': '9.15 M'},
    {'zAttributesId': 3, 'DisplayName': '12.20 M'},
    {'zAttributesId': 4, 'DisplayName': '13.40 M'},
    {'zAttributesId': 5, 'DisplayName': '18.3 M'},
    {'zAttributesId': 6, 'DisplayName': '27.45 M'},
    {'zAttributesId': 7, 'DisplayName': '36.6 M'},
  ];
  late int _projectId;
  bool get _isEditMode => widget.building != null;
  final ValueNotifier<Map<String, dynamic>?> selectedCategoryType =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?>
  _selectedTenantAmountPaymentModeNotifier = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?>
  _selectedTenantEmdPaymentModeNotifier = ValueNotifier(null);
  MultiFilePickerModel _tenderAmountTransactionFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel _tenderEmdTransactionFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  final ValueNotifier<DateTime?> _purchaseStartDate = ValueNotifier(null);
  final ValueNotifier<DateTime?> _purchaseEndDate = ValueNotifier(null);
  final ValueNotifier<DateTime?> _submissionDate = ValueNotifier(null);
  @override
  void initState() {
    super.initState();
    initializeTextEditingController();
    _buildingCubit = context.read<BuildingCubit>();
    _projectId = widget.projectId ?? getProject().projectId;
    _routhAuthorizationModel = AuthorizationModel();
    if (_isEditMode) {
      _populateFormFields(widget.building!);
    }
  }

  @override
  void dispose() {
    _selectedLandOwnershipType.dispose();
    _selectedRoadWidth.dispose();
    _buildingNameC.dispose();
    _ctsNumberC.dispose();
    _googleLocationC.dispose();
    _totalPlotAreaSqFtC.dispose();
    _totalNumberOfUnitsC.dispose();
    _numberOfWingsC.dispose();
    _totalUnitsAreaUtilizedC.dispose();
    _totalGardenAreaC.dispose();
    _totalReligiousStructureAreaC.dispose();
    _propertyAgeYearsC.dispose();
    _numberOfFloorsC.dispose();
    _fsiTdrUtilizationC.dispose();
    _litigationRemarksC.dispose();
    _searchC.dispose();
    _totalPlotAreaSqMtC.dispose();
    _tenderAmountC.dispose();
    _tenantAmountTransactionNumberC.dispose();
    _tenderAmountPayOrderRemarkC.dispose();
    _tendorEmdAmountC.dispose();
    _tenantEmdTransactionNumberC.dispose();
    _tenderEmdPayOrderRemarkC.dispose();
    super.dispose();
  }

  void initializeTextEditingController() {
    _buildingNameC = TextEditingController();
    _ctsNumberC = TextEditingController();
    _googleLocationC = TextEditingController();
    _totalPlotAreaSqFtC = TextEditingController();
    _totalNumberOfUnitsC = TextEditingController();
    _numberOfWingsC = TextEditingController();
    _totalUnitsAreaUtilizedC = TextEditingController();
    _totalGardenAreaC = TextEditingController();
    _totalReligiousStructureAreaC = TextEditingController();
    _propertyAgeYearsC = TextEditingController();
    _numberOfFloorsC = TextEditingController();
    _fsiTdrUtilizationC = TextEditingController();
    _litigationRemarksC = TextEditingController();
    _searchC = TextEditingController();
    _totalPlotAreaSqMtC = TextEditingController();
    _tenderAmountC = TextEditingController();
    _tenantAmountTransactionNumberC = TextEditingController();
    _tenderAmountPayOrderRemarkC = TextEditingController();
    _tendorEmdAmountC = TextEditingController();
    _tenantEmdTransactionNumberC = TextEditingController();
    _tenderEmdPayOrderRemarkC = TextEditingController();
  }

  void _populateFormFields(BusinessDevelopmentBuildingModel buildingModel) {
    _buildingNameC.text = buildingModel.buildingName;
    _ctsNumberC.text = buildingModel.cTSNumber;
    _googleLocationC.text = buildingModel.googleLocation;
    selectedCategoryType.value = projectCategoryList.firstWhere(
      (item) => item["DisplayName"] == buildingModel.category,
      orElse: () => projectCategoryList.first,
    );
    final isTender = selectedCategoryType.value?["zAttributesId"] == 2;
    if (isTender) {
      _tenderAmountC.text = buildingModel.tenderAmount.toString();
      _tendorEmdAmountC.text = buildingModel.tenderEMDAmount.toString();
      _purchaseStartDate.value = buildingModel.tenderPurchaseStartDate;
      _purchaseEndDate.value = buildingModel.tenderPurchaseEndDate;
      _tenantAmountTransactionNumberC.text =
          buildingModel.tenderAmountChequeNumber;
      _tenderAmountTransactionFile.fileNameList =
          buildingModel.tenderAmountChequeNumberURL.isEmpty
              ? []
              : buildingModel.tenderAmountChequeNumberURL
                  .split(",")
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
      _tenderEmdTransactionFile.fileNameList =
          buildingModel.tenderEMDChequeNumberURL.isEmpty
              ? []
              : buildingModel.tenderEMDChequeNumberURL
                  .split(",")
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
      _submissionDate.value = buildingModel.tenderSubmissionDate;
      _tenderEmdPayOrderRemarkC.text = buildingModel.tenderAmountPayorderRemark;
      _selectedTenantEmdPaymentModeNotifier.value =
          buildingModel.tenderEMDPaymentMode.isEmpty
              ? null
              : tenurePaymentModeList.firstWhere(
                (item) =>
                    item["DisplayName"] == buildingModel.tenderEMDPaymentMode,
              );
      _selectedTenantAmountPaymentModeNotifier.value =
          buildingModel.tenderAmountPaymentMode.isEmpty
              ? null
              : tenurePaymentModeList.firstWhere(
                (item) =>
                    item["DisplayName"] ==
                    buildingModel.tenderAmountPaymentMode,
              );
      _tenantEmdTransactionNumberC.text = buildingModel.tenderEMDChequeNumber;
      _tenderAmountPayOrderRemarkC.text =
          buildingModel.tenderAmountPayorderRemark;
      _tenderEmdPayOrderRemarkC.text = buildingModel.tenderEMDPayorderRemark;
    } else {
      _tenderAmountC.text = '';
      _tendorEmdAmountC.text = '';
      _purchaseStartDate.value = null;
      _purchaseEndDate.value = null;
      _tenantAmountTransactionNumberC.text = '';
      _tenderAmountTransactionFile.fileNameList = [];
      _tenderEmdTransactionFile.fileNameList = [];
      _submissionDate.value = null;
      _tenderEmdPayOrderRemarkC.text = '';
      _selectedTenantEmdPaymentModeNotifier.value = null;
      _selectedTenantAmountPaymentModeNotifier.value = null;
      _tenantAmountTransactionNumberC.text = '';
      _tenantEmdTransactionNumberC.text = '';
      _tenderAmountPayOrderRemarkC.text = '';
    }
    _totalPlotAreaSqFtC.text = buildingModel.totalPlotAreaSqFt.toString();
    _totalPlotAreaSqMtC.text = buildingModel.totalPlotAreaSqMt.toString();
    _totalNumberOfUnitsC.text = buildingModel.totalNumberOfUnits.toString();
    _totalUnitsAreaUtilizedC.text =
        buildingModel.totalUnitsAreaUtilizedSqFt.toString();
    _totalGardenAreaC.text = buildingModel.totalGardenAreaSqFt.toString();
    _totalReligiousStructureAreaC.text =
        buildingModel.totalReligiousStructureAreaSqFt.toString();
    _propertyAgeYearsC.text = buildingModel.propertyAgeYears.toString();
    _numberOfFloorsC.text = buildingModel.numberOfFloors.toString();
    _fsiTdrUtilizationC.text = buildingModel.fSITDRUtilizationSqFt.toString();
    _litigationRemarksC.text = buildingModel.litigationRemarks;
    _numberOfWingsC.text = buildingModel.numberOfWings.toString();
    _countryMasterId = buildingModel.countryMasterId;
    _stateMasterId = buildingModel.stateMasterId;
    _districtMasterId = buildingModel.districtMasterId;
    _cityMasterId = buildingModel.cityMasterId;
    _villageMasterId = buildingModel.villageMasterId;
    _wardMasterId = buildingModel.wardMasterId;
    _isGarden.value = buildingModel.isGarden;
    _isReligiousStructure.value = buildingModel.isReligiousStructure;
    _isLitigation.value = buildingModel.isLitigation;
    _selectedLandOwnershipType.value =
        buildingModel.landOwnershipType == ""
            ? null
            : _ownershipTypeList.firstWhere(
              (element) =>
                  element['DisplayName'] == buildingModel.landOwnershipType,
              orElse: () => _ownershipTypeList.first,
            );
    _selectedRoadWidth.value =
        (buildingModel.roadWidth.isNotEmpty)
            ? _roadWidthList.firstWhere(
              (element) => element['DisplayName'] == buildingModel.roadWidth,
              orElse: () => _roadWidthList.first,
            )
            : _roadWidthList.first;
  }

  Future<void> _addUpdateBuilding(
    BuildContext context,
    BusinessDevelopmentBuildingModel? buildingModel,
    BuildingState state,
  ) async {
    if (_formKey.currentState!.validate()) {
      _isEditMode
          ? _buildingCubit.updateBuilding(
            context: context,
            projectId: _projectId,
            index: widget.index,
            buildingId: buildingModel!.buildingId,
            uniqueKey: buildingModel.uniquekey,
            buildingName: _buildingNameC.text.trim(),
            ctsNumber: _ctsNumberC.text.trim(),
            googleLocation: _googleLocationC.text.trim(),
            totalPlotAreaSqFt: double.tryParse(_totalPlotAreaSqFtC.text) ?? 0.0,
            totalPlotAreaSqMt: double.tryParse(_totalPlotAreaSqMtC.text) ?? 0.0,
            roadWidth: _selectedRoadWidth.value?['DisplayName'] ?? '',
            countryMasterId: _countryMasterId ?? 1,
            districtMasterId: _districtMasterId,
            stateMasterId: _stateMasterId,
            cityMasterId: _cityMasterId,
            villageMasterId: _villageMasterId,
            wardMasterId: _wardMasterId,
            totalNumberOfUnits: int.tryParse(_totalNumberOfUnitsC.text) ?? 0,
            totalUnitsAreaUtilizedSqFt:
                double.tryParse(_totalUnitsAreaUtilizedC.text) ?? 0.0,
            isGarden: _isGarden.value,
            totalGardenAreaSqFt: double.tryParse(_totalGardenAreaC.text) ?? 0.0,
            isReligiousStructure: _isReligiousStructure.value,
            totalReligiousStructureAreaSqFt:
                double.tryParse(_totalReligiousStructureAreaC.text) ?? 0.0,
            propertyAgeYears: int.tryParse(_propertyAgeYearsC.text) ?? 0,
            numberOfFloors: int.tryParse(_numberOfFloorsC.text) ?? 0,
            numberOfWings: int.tryParse(_numberOfWingsC.text) ?? 0,
            fsiTdrUtilizationSqFt:
                double.tryParse(_fsiTdrUtilizationC.text) ?? 0.0,
            landOwnershipType:
                _selectedLandOwnershipType.value?['DisplayName'] ?? '',
            isLitigation: _isLitigation.value,
            litigationRemarks: _litigationRemarksC.text.trim(),
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
                _purchaseStartDate.value?.toIso8601String() ?? '',
            tenderPurchaseEndDate:
                _purchaseEndDate.value?.toIso8601String() ?? "",
            tenderChequeNumber: _tenantAmountTransactionNumberC.text,
            tenderChequeNumberFile: _tenderAmountTransactionFile,
            tenderEmdChequeNumberFile: _tenderEmdTransactionFile,
            tenderSubmissionDate:
                _submissionDate.value?.toIso8601String() ?? "",
            tenderPayorderRemark: _tenderAmountPayOrderRemarkC.text,
            tenderAmountPaymentMode:
                _selectedTenantAmountPaymentModeNotifier
                    .value?["DisplayName"] ??
                '',
            tenderEmdPaymentMode:
                _selectedTenantEmdPaymentModeNotifier.value?["DisplayName"] ??
                '',
            tenderEmdChequeNumber: _tenantEmdTransactionNumberC.text.trim(),
            tenderEmdPayorderRemark: _tenderEmdPayOrderRemarkC.text.trim(),
          )
          : _buildingCubit.addBuilding(
            context: context,
            projectId: _projectId,
            buildingName: _buildingNameC.text.trim(),
            ctsNumber: _ctsNumberC.text.trim(),
            googleLocation: _googleLocationC.text.trim(),
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
                _purchaseStartDate.value?.toIso8601String() ?? '',
            tenderPurchaseEndDate:
                _purchaseEndDate.value?.toIso8601String() ?? "",
            tenderChequeNumber: _tenantAmountTransactionNumberC.text,
            tenderChequeNumberFile: _tenderAmountTransactionFile,
            tenderEmdChequeNumberFile: _tenderEmdTransactionFile,
            tenderSubmissionDate:
                _submissionDate.value?.toIso8601String() ?? "",
            tenderPayorderRemark: _tenderAmountPayOrderRemarkC.text,
            tenderAmountPaymentMode:
                _selectedTenantAmountPaymentModeNotifier
                    .value?["DisplayName"] ??
                '',
            tenderEmdPaymentMode:
                _selectedTenantEmdPaymentModeNotifier.value?["DisplayName"] ??
                '',
            tenderEmdChequeNumber: _tenantEmdTransactionNumberC.text.trim(),
            tenderEmdPayorderRemark: _tenderEmdPayOrderRemarkC.text.trim(),
            totalPlotAreaSqFt: double.tryParse(_totalPlotAreaSqFtC.text) ?? 0.0,
            totalPlotAreaSqMt: double.tryParse(_totalPlotAreaSqMtC.text) ?? 0.0,
            roadWidth: _selectedRoadWidth.value?['DisplayName'] ?? '',
            countryMasterId: _countryMasterId ?? 1,
            districtMasterId: _districtMasterId,
            stateMasterId: _stateMasterId,
            cityMasterId: _cityMasterId,
            villageMasterId: _villageMasterId,
            wardMasterId: _wardMasterId,
            totalNumberOfUnits: int.tryParse(_totalNumberOfUnitsC.text) ?? 0,
            totalUnitsAreaUtilizedSqFt:
                double.tryParse(_totalUnitsAreaUtilizedC.text) ?? 0.0,
            isGarden: _isGarden.value,
            totalGardenAreaSqFt: double.tryParse(_totalGardenAreaC.text) ?? 0.0,
            isReligiousStructure: _isReligiousStructure.value,
            totalReligiousStructureAreaSqFt:
                double.tryParse(_totalReligiousStructureAreaC.text) ?? 0.0,
            propertyAgeYears: int.tryParse(_propertyAgeYearsC.text) ?? 0,
            numberOfFloors: int.tryParse(_numberOfFloorsC.text) ?? 0,
            numberOfWings: int.tryParse(_numberOfWingsC.text) ?? 0,
            fsiTdrUtilizationSqFt:
                double.tryParse(_fsiTdrUtilizationC.text) ?? 0.0,
            landOwnershipType:
                _selectedLandOwnershipType.value?['DisplayName'] ?? '',
            isLitigation: _isLitigation.value,
            litigationRemarks: _litigationRemarksC.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Building",
        authorization: _routhAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                _isEditMode ? "Update Building" : "Add Building",
                style: AppTextStyle.ts14M(),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Building Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      textController: _buildingNameC,
                      title: 'Building Name',
                      hint: 'Enter Building Name',
                      isRequired: true,
                      inputFormatterList: InputValidator.textOnly(100),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Building name is required.';
                        }
                        if (value.trim().length < 2) {
                          return 'Building name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _ctsNumberC,
                      title: 'CTS Number',
                      hint: 'Enter CTS Number',
                      isRequired: true,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'CTS number is required.';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedRoadWidth,
                      builder: (context, selectedValue, child) {
                        return CustomDropDownWidget(
                          title: 'Road Width',
                          hintText: 'Select Road Width',
                          isRequired: true,
                          dataList: _roadWidthList,
                          initialValue: selectedValue,
                          onSelected: (selected) {
                            _selectedRoadWidth.value = selected;
                          },
                          validator: (value) {
                            if (value == null || value['zAttributesId'] == -1) {
                              return 'Road width is required.';
                            }
                            return null;
                          },
                          onValueClear: () => _selectedRoadWidth.value = null,
                        );
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedLandOwnershipType,
                      builder: (context, selectedValue, child) {
                        return CustomDropDownWidget(
                          title: 'Land Ownership Type',
                          hintText: 'Select Land Ownership Type',
                          dataList: _ownershipTypeList,
                          initialValue: selectedValue,
                          onSelected: (selected) {
                            _selectedLandOwnershipType.value = selected;
                          },
                          onValueClear:
                              () => _selectedLandOwnershipType.value = null,
                        );
                      },
                    ),
                    CustomTextField(
                      textController: _googleLocationC,
                      title: "Google Location",
                      isRequired: true,
                      hint: "Enter Google Location",
                      prefixType: CustomTextFieldPrefix.location,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Google Location is required.";
                        }
                        final googleMapRegex = RegExp(
                          r'^(https?:\/\/)?(www\.)?(google\.[a-z.]+\/maps(\?|\/)|maps\.google\.[a-z.]+|maps\.app\.goo\.gl|goo\.gl\/maps|share\.google)\/?.*$',
                          caseSensitive: false,
                        );
                        if (!googleMapRegex.hasMatch(value.trim())) {
                          return "Please enter a valid Google Maps location link";
                        }
                        return null;
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
                            if (selectedCategoryType.value?['zAttributesId'] !=
                                val['zAttributesId']) {
                              selectedCategoryType.value = val;
                              final isDirect =
                                  val["DisplayName"]
                                      ?.toString()
                                      .toLowerCase() ==
                                  "direct";
                              if (isDirect) {
                                _tenderAmountC.clear();
                                _purchaseStartDate.value = null;
                                _purchaseEndDate.value = null;
                                _selectedTenantAmountPaymentModeNotifier.value =
                                    null;
                                _tenantAmountTransactionNumberC.clear();
                                _tenderAmountTransactionFile =
                                    MultiFilePickerModel(
                                      fileBytesList: [],
                                      fileNameList: [],
                                      deletedFileList: "",
                                    );
                                _tenderAmountPayOrderRemarkC.clear();
                                _tenderEmdPayOrderRemarkC.clear();
                                _tendorEmdAmountC.clear();
                                _submissionDate.value = null;
                                _selectedTenantEmdPaymentModeNotifier.value =
                                    null;
                                _tenantEmdTransactionNumberC.clear();
                                _tenderEmdTransactionFile =
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
                              return "Category is required.";
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
                      selectedCategoryType.value?['DisplayName'] == 'Direct') {
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Amount is required.";
                                        }
                                        return null;
                                      },
                                    ),
                                    AnimatedBuilder(
                                      animation: Listenable.merge([
                                        _purchaseStartDate,
                                        _purchaseEndDate,
                                      ]),
                                      builder: (context, _) {
                                        return CustomFromToDatePicker(
                                          fromDateTitle: "Purchase Start Date",
                                          toDateTitle: "Purchase End Date",
                                          alignVertical: true,
                                          initialFromDate:
                                              _purchaseStartDate.value,
                                          initialToDate: _purchaseEndDate.value,
                                          onToDateChanged: (start, end) {
                                            _purchaseStartDate.value = start;
                                            _purchaseEndDate.value = end;
                                          },
                                          fromDateValidator: (value) {
                                            if (value == null) {
                                              return 'Purchase Start Date is required.';
                                            }
                                            return null;
                                          },
                                          toDateValidator: (value) {
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
                                          _tenderAmountTransactionFile
                                              .fileNameList,
                                      initialFileBytes:
                                          _tenderAmountTransactionFile
                                              .fileBytesList,
                                      onFilePickedCallback: (
                                        bytesList,
                                        fileNameList,
                                      ) {
                                        _tenderAmountTransactionFile
                                            .fileNameList = fileNameList;
                                        _tenderAmountTransactionFile
                                            .fileBytesList = bytesList;
                                      },
                                      onFileDeleteCallback: (
                                        fileBytesList,
                                        fileNameList,
                                        deleted,
                                      ) {
                                        _tenderAmountTransactionFile
                                            .fileBytesList = fileBytesList;
                                        _tenderAmountTransactionFile
                                            .fileNameList = fileNameList;
                                        _tenderAmountTransactionFile
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
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: _submissionDate,
                                      builder: (context, submissionDt, child) {
                                        return CustomDatePicker(
                                          title: "Submission Date",
                                          initialDate: submissionDt,
                                          setValue:
                                              (value) =>
                                                  _submissionDate.value = value,
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
                                          _tenderEmdTransactionFile
                                              .fileNameList,
                                      initialFileBytes:
                                          _tenderEmdTransactionFile
                                              .fileBytesList,
                                      onFilePickedCallback: (
                                        bytesList,
                                        fileNameList,
                                      ) {
                                        _tenderEmdTransactionFile.fileNameList =
                                            fileNameList;
                                        _tenderEmdTransactionFile
                                            .fileBytesList = bytesList;
                                      },
                                      onFileDeleteCallback: (
                                        fileBytesList,
                                        fileNameList,
                                        deleted,
                                      ) {
                                        _tenderEmdTransactionFile
                                            .fileBytesList = fileBytesList;
                                        _tenderEmdTransactionFile.fileNameList =
                                            fileNameList;
                                        _tenderEmdTransactionFile
                                            .deletedFileList = deleted;
                                      },
                                    ),
                                    CustomTextField(
                                      title: 'Payorder Remark',
                                      textController: _tenderEmdPayOrderRemarkC,
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
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Property Information",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      textController: _totalPlotAreaSqMtC,
                      title: 'Total Plot Area (SqMt)',
                      hint: 'Enter Total Plot Area',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Total plot area is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _totalPlotAreaSqFtC,
                      title: 'Total Plot Area (SqFt)',
                      hint: 'Enter Total Plot Area',
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                    ),
                    CustomTextField(
                      textController: _totalUnitsAreaUtilizedC,
                      title: "Utilized Units Area (SqFt)",
                      hint: 'Enter Utilized Units Area',
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                    ),
                    CustomTextField(
                      textController: _totalNumberOfUnitsC,
                      title: 'Total Units',
                      hint: 'Enter Total Units',
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7),
                      ],
                    ),
                    CustomTextField(
                      textController: _numberOfFloorsC,
                      title: 'Number of Floors',
                      hint: 'Enter Number of Floors',
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                    CustomTextField(
                      textController: _numberOfWingsC,
                      title: 'Number of Wings',
                      hint: 'Enter Number of Wings',
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FSI / TDR Information",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      textController: _propertyAgeYearsC,
                      title: 'Property Age (Years)',
                      hint: 'Enter Property Age',
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.decimal(5),
                    ),
                    CustomTextField(
                      textController: _fsiTdrUtilizationC,
                      title: 'FSI / TDR Utilization (SqFt)',
                      hint: 'Enter FSI / TDR Utilization',
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.decimal(10),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Additional Information",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _isGarden,
                      builder: (context, isGarden, _) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CustomCheckBox(
                                  isSelected: isGarden,
                                  onChanged: (value) {
                                    _isGarden.value = value;
                                  },
                                ),
                                horizontalSpacing(width: 10.0),
                                Text('Garden', style: AppTextStyle.ts14R()),
                              ],
                            ),
                            verticalSpacing(),
                            CustomTextField(
                              textController: _totalGardenAreaC,
                              isRequired: isGarden,
                              readOnly: !isGarden,
                              title: 'Garden Area (SqFt)',
                              hint: 'Enter Garden Area (SqFt)',
                              keyboardType: TextInputType.number,
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    7,
                                  ),
                              validator: (value) {
                                if ((value == null || value.trim().isEmpty) &&
                                    isGarden) {
                                  return 'Garden Area is required.';
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _isReligiousStructure,
                      builder: (context, isReligiousStructure, _) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CustomCheckBox(
                                  isSelected: isReligiousStructure,
                                  onChanged: (value) {
                                    _isReligiousStructure.value = value;
                                  },
                                ),
                                horizontalSpacing(width: 10.0),
                                Text(
                                  'Religious Structure',
                                  style: AppTextStyle.ts14R(),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            CustomTextField(
                              isRequired: isReligiousStructure,
                              readOnly: !isReligiousStructure,
                              textController: _totalReligiousStructureAreaC,
                              title: 'Religious Structure Area (SqFt)',
                              hint: 'Enter Religious Structure Area (SqFt)',
                              keyboardType: TextInputType.number,
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    7,
                                  ),
                              validator: (value) {
                                if ((value == null || value.trim().isEmpty) &&
                                    isReligiousStructure) {
                                  return 'Religious Structure Area is required.';
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _isLitigation,
                      builder: (context, isLitigation, _) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CustomCheckBox(
                                  isSelected: isLitigation,
                                  onChanged: (value) {
                                    _isLitigation.value = value;
                                  },
                                ),
                                horizontalSpacing(width: 10.0),
                                Text('Litigation', style: AppTextStyle.ts14R()),
                              ],
                            ),
                            verticalSpacing(),
                            CustomTextField(
                              isRequired: isLitigation,
                              textController: _litigationRemarksC,
                              title: 'Litigation Remarks',
                              readOnly: !isLitigation,
                              hint: 'Enter Litigation Remarks',
                              inputFormatterList: InputValidator.textDigit(500),
                              validator: (value) {
                                if (isLitigation) {
                                  if ((value == null || value.trim().isEmpty)) {
                                    return 'Litigation remark is required.';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Location",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    AddressWidget(
                      formKey: _formKey,
                      incomingCountryId: _countryMasterId ?? 1,
                      incomingStateId: _stateMasterId,
                      incomingDistrictId: _districtMasterId,
                      incomingCityId: _cityMasterId,
                      incomingVillageId: _villageMasterId,
                      incomingWardId: _wardMasterId,
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
                      wardChange: (selectedWard) {
                        _wardMasterId = selectedWard['zAttributesId'];
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update" : "Add",
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            onPressed: () {
              _addUpdateBuilding(
                context,
                widget.building,
                _buildingCubit.state,
              );
            },
          ),
        ),
      ),
    );
  }
}
