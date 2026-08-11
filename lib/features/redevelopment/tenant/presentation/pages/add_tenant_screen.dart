import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/pages/add_tenant_applicant_screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTenantScreen extends StatefulWidget {
  final TenantModel? tenant;
  final int index;
  final int projectId;
  final int buildingId;
  const AddTenantScreen({
    super.key,
    this.tenant,
    this.index = 0,
    required this.projectId,
    required this.buildingId,
  });
  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  late TenantCubit _cubit;
  late AuthorizationModel _routeAuthorizationModel;
  final ValueNotifier<List<TenantApplicantData>> _applicants =
      ValueNotifier<List<TenantApplicantData>>([]);
  late TextEditingController _unitNumberC,
      _flatCarpetAreaC,
      _extraFreeCarpetAreaOffered,
      _freeMofaCarpetArea,
      _existingTerraceArea,
      _newEligibilityMofaCarpetArea,
      _newEligibilityReraCarpetArea,
      _areaAgainstTerrace,
      _mofaCarpetAreaPurchased,
      _reraCarpetAreaPurchased,
      _deckArea,
      _totalNewMofaCarpetArea,
      _totalNewReraCarpetArea,
      _totalAreaAgainstTerraceDeckRera,
      _remarkController;
  ValueNotifier<Map<String, dynamic>?> selectedFlatType = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedUnitFacing = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedFlatConfiguration =
      ValueNotifier(null);
  bool _isApplicantType(String type) =>
      type.toLowerCase().trim() == 'applicant';
  bool _hasPrimaryApplicant(List<TenantApplicantData> applicants) =>
      applicants.any((e) => _isApplicantType(e.applicantType));
  bool get _isEditMode => widget.tenant != null;
  @override
  void initState() {
    super.initState();
    _cubit = context.read<TenantCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    _initialisedTextController();
    _initApplicants();
    _prefillTenantDetails(widget.tenant);
    _areaAgainstTerrace.addListener(_calculateTotalArea);
    _deckArea.addListener(_calculateTotalArea);
    _totalNewReraCarpetArea.addListener(_calculateTotalArea);
  }

  void _initialisedTextController() {
    _unitNumberC = TextEditingController();
    _flatCarpetAreaC = TextEditingController();
    _extraFreeCarpetAreaOffered = TextEditingController();
    _freeMofaCarpetArea = TextEditingController();
    _existingTerraceArea = TextEditingController();
    _newEligibilityMofaCarpetArea = TextEditingController();
    _newEligibilityReraCarpetArea = TextEditingController();
    _areaAgainstTerrace = TextEditingController();
    _mofaCarpetAreaPurchased = TextEditingController();
    _reraCarpetAreaPurchased = TextEditingController();
    _deckArea = TextEditingController();
    _totalNewMofaCarpetArea = TextEditingController();
    _totalNewReraCarpetArea = TextEditingController();
    _totalAreaAgainstTerraceDeckRera = TextEditingController();
    _remarkController = TextEditingController();
  }

  void _prefillTenantDetails(TenantModel? tenant) {
    if (tenant == null) return;
    _unitNumberC.text = tenant.unitAnnexureSurveyNumber;
    _flatCarpetAreaC.text = tenant.unitCarpetAreaSqFt.toString();
    _extraFreeCarpetAreaOffered.text =
        tenant.freeMOFACarpetAreaSqFt == 0
            ? ""
            : tenant.freeMOFACarpetAreaSqFt.toString();
    selectedUnitFacing.value = flatFacingList.firstWhereOrNull(
      (e) =>
          e['DisplayName'].toString().toLowerCase() ==
          tenant.unitFacing.toLowerCase(),
    );
    final flatTypeMatch = propertyTypeList.firstWhereOrNull(
      (e) => e['DisplayName'] == tenant.unitType,
    );
    final isResidential =
        tenant.inventoryFlatType.toLowerCase() == 'residential';
    final configList = isResidential ? residentialFlatList : commercialFlatList;
    final configMatch = configList.firstWhere(
      (e) =>
          e['DisplayName'].toString().toLowerCase() ==
          tenant.unitConfiguration.toLowerCase(),
      orElse: () => configList.first,
    );
    selectedFlatType.value = flatTypeMatch;
    Future.microtask(() {
      if (mounted) {
        selectedFlatConfiguration.value = configMatch;
      }
    });
    _extraFreeCarpetAreaOffered.text =
        tenant.extraFreeCarpetAreaOfferedPercent.toString();
    _freeMofaCarpetArea.text = tenant.freeMOFACarpetAreaSqFt.toString();
    _existingTerraceArea.text = tenant.existingTerraceAreaSqFt.toString();
    _newEligibilityMofaCarpetArea.text =
        tenant.newEligibilityMOFACarpetAreaSqFt.toString();
    _newEligibilityReraCarpetArea.text =
        tenant.newEligibilityRERACarpetAreaSqFt.toString();
    _areaAgainstTerrace.text = tenant.areaAgainstTerraceSqFt.toString();
    _mofaCarpetAreaPurchased.text =
        tenant.mofaCarpetAreaPurchasedSqFt.toString();
    _reraCarpetAreaPurchased.text =
        tenant.reraCarpetAreaPurchasedSqFt.toString();
    _deckArea.text = tenant.deckAreaSqFt.toString();
    _totalNewMofaCarpetArea.text = tenant.totalNewMOFACarpetAreaSqFt.toString();
    _totalNewReraCarpetArea.text = tenant.totalNewRERACarpetAreaSqFt.toString();
    _remarkController.text = tenant.remark;
    _calculateTotalArea();
  }

  void _initApplicants() {
    final incomingApplicants = widget.tenant?.tenantApplicantData ?? [];
    _applicants.value =
        incomingApplicants
            .map((e) => TenantApplicantData.fromJson(e.toJson()))
            .toList();
  }

  Future<void> _openApplicantForm({
    TenantApplicantData? applicant,
    int? index,
  }) async {
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTenantApplicantScreen(
              applicant: applicant,
              index: index,
              hasPrimaryApplicant: _hasPrimaryApplicant(_applicants.value),
            ),
      ),
    );
    if (result == null || result['applicant'] == null) return;
    final TenantApplicantData updatedApplicant = result['applicant'];
    final int? updatedIndex = result['index'] as int?;
    final currentApplicants = List<TenantApplicantData>.from(_applicants.value);
    final bool isUpdatingExisting =
        updatedIndex != null && updatedIndex < currentApplicants.length;
    TenantApplicantData finalApplicant = updatedApplicant;
    if (isUpdatingExisting) {
      final old = currentApplicants[updatedIndex];
      finalApplicant.profilePhotoImage = mergeFile(
        updatedApplicant.profilePhotoImage,
        old.profilePhotoImage,
      );
      finalApplicant.aadhaarImage = mergeFile(
        updatedApplicant.aadhaarImage,
        old.aadhaarImage,
      );
      finalApplicant.panImage = mergeFile(
        updatedApplicant.panImage,
        old.panImage,
      );
      finalApplicant.passportImage = mergeFile(
        updatedApplicant.passportImage,
        old.passportImage,
      );
      finalApplicant.drivingLicenseImage = mergeFile(
        updatedApplicant.drivingLicenseImage,
        old.drivingLicenseImage,
      );
      finalApplicant.votingIdImage = mergeFile(
        updatedApplicant.votingIdImage,
        old.votingIdImage,
      );
      finalApplicant.gstImage = mergeFile(
        updatedApplicant.gstImage,
        old.gstImage,
      );
      finalApplicant.chequeImage = mergeFile(
        updatedApplicant.chequeImage,
        old.chequeImage,
      );
    }
    if (isUpdatingExisting) {
      currentApplicants[updatedIndex] = finalApplicant;
    } else {
      currentApplicants.add(finalApplicant);
    }
    _applicants.value = currentApplicants;
  }

  Future<void> _showPopupToDeleteApplicant(
    BuildContext context,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a applicant ?',
      'Deleting this applicant will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _deleteApplicant(index);
    }
  }

  void _deleteApplicant(int index) {
    final currentApplicants = List<TenantApplicantData>.from(_applicants.value);
    if (index < 0 || index >= currentApplicants.length) return;
    currentApplicants.removeAt(index);
    _applicants.value = currentApplicants;
  }

  void _calculateTotalArea() {
    final a = double.tryParse(_areaAgainstTerrace.text) ?? 0;
    final b = double.tryParse(_deckArea.text) ?? 0;
    final c = double.tryParse(_totalNewReraCarpetArea.text) ?? 0;
    _totalAreaAgainstTerraceDeckRera.text = (a + b + c).toStringAsFixed(2);
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final currentApplicants = _applicants.value;
    if (currentApplicants.isEmpty) {
      showErrorMessage(context, 'Error', 'Atleast one applicant is required');
      return;
    }
    if (!_hasPrimaryApplicant(currentApplicants)) {
      showErrorMessage(
        context,
        'Error',
        'In Applicant List - One Applicant is required',
      );
      return;
    }
    final flatType = selectedFlatType.value!['DisplayName'].toString();
    final flatConfiguration =
        selectedFlatConfiguration.value?['DisplayName']?.toString() ?? '';
    final facing = selectedUnitFacing.value?['DisplayName']?.toString() ?? '';

    if (_isEditMode && widget.tenant != null) {
      final tenant = widget.tenant!;
      _cubit.updateTenant(
        context: context,
        projectId: tenant.projectId.toString(),
        index: widget.index,
        tenantId: tenant.tenantId.toString(),
        uniqueKey: tenant.uniquekey,
        buildingId: tenant.buildingId.toString(),
        unitAnnexureSurveyNumber: _unitNumberC.text.trim(),
        unitCarpetAreaSqFt: _flatCarpetAreaC.text.trim(),
        unitFacing: facing,
        unitType: flatType,
        unitConfiguration: flatConfiguration,
        addUpdateTenantApplicant: currentApplicants,
        extraFreeCarpetAreaOfferedPercent:
            double.tryParse(_extraFreeCarpetAreaOffered.text) ?? 0,
        freeMOFACarpetAreaSqFt: double.tryParse(_freeMofaCarpetArea.text) ?? 0,
        newEligibilityMOFACarpetAreaSqFt:
            double.tryParse(_newEligibilityMofaCarpetArea.text) ?? 0,
        newEligibilityRERACarpetAreaSqFt:
            double.tryParse(_newEligibilityReraCarpetArea.text) ?? 0,
        mofaCarpetAreaPurchasedSqFt:
            double.tryParse(_mofaCarpetAreaPurchased.text) ?? 0,
        reraCarpetAreaPurchasedSqFt:
            double.tryParse(_reraCarpetAreaPurchased.text) ?? 0,
        totalNewMOFACarpetAreaSqFt:
            double.tryParse(_totalNewMofaCarpetArea.text) ?? 0,
        totalNewRERACarpetAreaSqFt:
            double.tryParse(_totalNewReraCarpetArea.text) ?? 0,
        deckAreaSqFt: double.tryParse(_deckArea.text) ?? 0,
        existingTerraceAreaSqFt:
            double.tryParse(_existingTerraceArea.text) ?? 0,
        areaAgainstTerraceSqFt: double.tryParse(_areaAgainstTerrace.text) ?? 0,
        totalNewRERACarpetAreaWithDeckSqFt:
            double.tryParse(_areaAgainstTerrace.text) ?? 0,
        remark: _remarkController.text.trim(),
      );
    } else {
      _cubit.addTenant(
        context: context,
        projectId: widget.projectId,
        buildingId: widget.buildingId,
        unitAnnexureSurveyNumber: _unitNumberC.text.trim(),
        unitCarpetAreaSqFt: _flatCarpetAreaC.text.trim(),
        unitFacing: facing,
        unitType: flatType,
        unitConfiguration: flatConfiguration,
        addUpdateTenantApplicant: currentApplicants,
        extraFreeCarpetAreaOfferedPercent:
            double.tryParse(_extraFreeCarpetAreaOffered.text) ?? 0,
        freeMOFACarpetAreaSqFt: double.tryParse(_freeMofaCarpetArea.text) ?? 0,
        newEligibilityMOFACarpetAreaSqFt:
            double.tryParse(_newEligibilityMofaCarpetArea.text) ?? 0,
        newEligibilityRERACarpetAreaSqFt:
            double.tryParse(_newEligibilityReraCarpetArea.text) ?? 0,
        mofaCarpetAreaPurchasedSqFt:
            double.tryParse(_mofaCarpetAreaPurchased.text) ?? 0,
        reraCarpetAreaPurchasedSqFt:
            double.tryParse(_reraCarpetAreaPurchased.text) ?? 0,
        totalNewMOFACarpetAreaSqFt:
            double.tryParse(_totalNewMofaCarpetArea.text) ?? 0,
        totalNewRERACarpetAreaSqFt:
            double.tryParse(_totalNewReraCarpetArea.text) ?? 0,
        deckAreaSqFt: double.tryParse(_deckArea.text) ?? 0,
        existingTerraceAreaSqFt:
            double.tryParse(_existingTerraceArea.text) ?? 0,
        areaAgainstTerraceSqFt: double.tryParse(_areaAgainstTerrace.text) ?? 0,
        totalNewRERACarpetAreaWithDeckSqFt:
            double.tryParse(_areaAgainstTerrace.text) ?? 0,
        remark: _remarkController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _applicants.dispose();
    selectedFlatType.dispose();
    selectedUnitFacing.dispose();
    selectedFlatConfiguration.dispose();
    _unitNumberC.dispose();
    _flatCarpetAreaC.dispose();
    _extraFreeCarpetAreaOffered.dispose();
    _freeMofaCarpetArea.dispose();
    _existingTerraceArea.dispose();
    _newEligibilityMofaCarpetArea.dispose();
    _newEligibilityReraCarpetArea.dispose();
    _areaAgainstTerrace.dispose();
    _mofaCarpetAreaPurchased.dispose();
    _reraCarpetAreaPurchased.dispose();
    _deckArea.dispose();
    _totalNewMofaCarpetArea.dispose();
    _totalNewReraCarpetArea.dispose();
    _totalAreaAgainstTerraceDeckRera.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Tenant",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Tenant" : "Add Tenant",
                style: AppTextStyle.ts14M(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Applicant Details",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        CustomButton(
                          leading: Icon(
                            Icons.add,
                            size: 18,
                            color: AppColor.white,
                          ),
                          text: "Add Applicant",
                          onPressed: () async => _openApplicantForm(),
                          backgroundColor: AppColor.primary,
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<List<TenantApplicantData>>(
                      valueListenable: _applicants,
                      builder: (context, applicants, child) {
                        if (applicants.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Text(
                                'No applicants added yet',
                                style: AppTextStyle.ts14R(color: AppColor.grey),
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 450,
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: applicants.length,
                            itemBuilder: (context, index) {
                              final applicant = applicants[index];
                              return _buildApplicantCard(applicant, index);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Unit Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: 'Unit / Annexure / Survey Number',
                      hint: "Enter Unit Number",
                      isRequired: true,
                      inputFormatterList: InputValidator.digitAndCharacterOnly(
                        15,
                      ),
                      textController: _unitNumberC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Unit Number is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: selectedFlatType,
                      builder: (context, flatTypeValue, child) {
                        return CustomDropDownWidget(
                          key: ValueKey(
                            'flatType_${flatTypeValue?['zAttributesId']}',
                          ),
                          title: 'Unit Type',
                          hintText: "Select Unit Type",
                          dataList: propertyTypeList,
                          isRequired: true,
                          initialValue: flatTypeValue,
                          onSelected: (value) {
                            if (selectedFlatType.value?['zAttributesId'] !=
                                value['zAttributesId']) {
                              selectedFlatConfiguration.value = null;
                            }
                            selectedFlatType.value = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Unit Type is required';
                            }
                            return null;
                          },
                          onValueClear: () => selectedFlatType.value = null,
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedFlatType,
                      builder: (context, value, child) {
                        if (value?['zAttributesId'] == 1) {
                          return ValueListenableBuilder<Map<String, dynamic>?>(
                            valueListenable: selectedFlatConfiguration,
                            builder: (context, configValue, child) {
                              return CustomDropDownWidget(
                                key: ValueKey(
                                  'residential_config_${value?['zAttributesId']}_${configValue?['zAttributesId'] ?? 'null'}',
                                ),
                                title: 'Flat Configuration',
                                hintText: "Select Flat Configuration",
                                isRequired: true,
                                dataList: residentialFlatList,
                                initialValue: configValue,
                                onSelected: (selectedValue) {
                                  selectedFlatConfiguration.value =
                                      selectedValue;
                                },
                                validator: (val) {
                                  if (selectedFlatConfiguration.value == null) {
                                    return 'Flat Configuration is required';
                                  }
                                  return null;
                                },
                                onValueClear:
                                    () =>
                                        selectedFlatConfiguration.value = null,
                              );
                            },
                          );
                        }
                        if (value?['zAttributesId'] == 2) {
                          return ValueListenableBuilder<Map<String, dynamic>?>(
                            valueListenable: selectedFlatConfiguration,
                            builder: (context, configValue, child) {
                              return CustomDropDownWidget(
                                key: ValueKey(
                                  'commercial_config_${value?['zAttributesId']}_${configValue?['zAttributesId'] ?? 'null'}',
                                ),
                                title: 'Flat Configuration',
                                hintText: "Select Flat Configuration",
                                isRequired: true,
                                dataList: commercialFlatList,
                                initialValue: configValue,
                                onSelected: (selectedValue) {
                                  selectedFlatConfiguration.value =
                                      selectedValue;
                                },
                                validator: (val) {
                                  if (val == null) {
                                    return 'Flat Configuration is required';
                                  }
                                  return null;
                                },
                                onValueClear:
                                    () =>
                                        selectedFlatConfiguration.value = null,
                              );
                            },
                          );
                        }
                        return SizedBox();
                      },
                    ),
                    CustomTextField(
                      title: 'Carpet Area SqFt',
                      hint: "Enter Carpet Area",
                      isRequired: true,
                      textController: _flatCarpetAreaC,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Carpet Area is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: selectedUnitFacing,
                      builder: (context, facingValue, child) {
                        return CustomDropDownWidget(
                          key: ValueKey(
                            'facing_${facingValue?['zAttributesId'] ?? 'null'}',
                          ),
                          title: 'Unit Facing',
                          hintText: "Select Unit Facing",
                          isRequired: true,
                          dataList: flatFacingList,
                          initialValue: facingValue,
                          onSelected: (value) {
                            selectedUnitFacing.value = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Unit Facing is required';
                            }
                            return null;
                          },
                          onValueClear: () => selectedUnitFacing.value = null,
                        );
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Details',
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: 'Extra Free Carpet Area Offered (%)',
                      hint: 'Enter Extra Free Carpet Area Offered',
                      inputFormatterList: InputValidator.percentage(),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _extraFreeCarpetAreaOffered,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Free MOFA Carpet Area (SqFt)',
                      hint: 'Enter Free MOFA CA',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _freeMofaCarpetArea,
                    ),
                    CustomTextField(
                      title: 'Existing Terrace Area (SqFt)',
                      hint: 'Enter Existing Terrace Area',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _existingTerraceArea,
                    ),
                    CustomTextField(
                      title: 'New Eligibility MOFA Carpet Area (SqFt)',
                      hint: 'Enter New Eligibility MOFA CA',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _newEligibilityMofaCarpetArea,
                    ),
                    CustomTextField(
                      title: 'New Eligibility RERA Carpet Area (SqFt)',
                      hint: 'Enter New Eligibility RERA CA',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _newEligibilityReraCarpetArea,
                    ),
                    CustomTextField(
                      title: '(A) Area Against Terrace (SqFt)',
                      hint: 'Enter Area Against Terrace',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _areaAgainstTerrace,
                    ),
                    CustomTextField(
                      title: 'MOFA Carpet Area Purchased (SqFt)',
                      hint: 'Enter MOFA CA Purchased',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _mofaCarpetAreaPurchased,
                    ),
                    CustomTextField(
                      title: 'RERA Carpet Area Purchased (SqFt)',
                      hint: 'Enter RERA CA Purchased',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _reraCarpetAreaPurchased,
                    ),
                    CustomTextField(
                      title: '(B) Deck Area (SqFt)',
                      hint: 'Enter Deck Area',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _deckArea,
                    ),
                    CustomTextField(
                      title: 'Total New MOFA Carpet Area (SqFt)',
                      hint: 'Enter Total New MOFA CA',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _totalNewMofaCarpetArea,
                    ),
                    CustomTextField(
                      title: '(C) Total New RERA Carpet Area (SqFt)',
                      hint: 'Enter Total New RERA CA',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _totalNewReraCarpetArea,
                    ),
                    CustomTextField(
                      title:
                          'Area Against Terrace + Deck Area + Total New RERA Carpet Area (SqFt) (A + B + C)',
                      hint: '0.00',
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      textController: _totalAreaAgainstTerraceDeckRera,
                      readOnly: true,
                    ),
                    CustomTextField(
                      title: 'Remark',
                      hint: 'Enter Remark',
                      textController: _remarkController,
                      maxLines: 4,
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
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: _isEditMode ? 'Update' : 'Add',
            onPressed: _handleSubmit,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildApplicantCard(TenantApplicantData applicant, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.primary, width: .3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.h,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.applicantName,
                      style: AppTextStyle.ts14M(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      applicant.applicantType,
                      style: AppTextStyle.ts12M(color: AppColor.grey),
                    ),
                  ],
                ),
              ),
              horizontalSpacing(width: 5),
              Row(
                children: [
                  CustomIconButton.edit(
                    onPressed:
                        () => _openApplicantForm(
                          applicant: applicant,
                          index: index,
                        ),
                  ),
                  horizontalSpacing(width: 8),
                  CustomIconButton.delete(
                    onPressed:
                        () => _showPopupToDeleteApplicant(context, index),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Mobile Number",
                value:
                    applicant.applicantMobileNumber.isEmpty
                        ? "-"
                        : applicant.applicantMobileNumber,
                customValueWidget: CustomClickToContactText(
                  countryCode: applicant.applicantMobileNumberCountryCode,
                  value: applicant.applicantMobileNumber,
                ),
              ),
              buildColumnTitleValue(
                title: "Email ID",
                value:
                    applicant.applicantEmailId.isEmpty
                        ? "-"
                        : applicant.applicantEmailId,
                customValueWidget: CustomClickToContactText(
                  value: applicant.applicantEmailId,
                  type: ContactType.email,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Aadhaar Card No.",
                value:
                    applicant.aadharCardNumber.isEmpty
                        ? "-"
                        : applicant.aadharCardNumber,
              ),
              buildColumnTitleValue(
                title: "Aadhaar Card",
                value:
                    applicant.aadharCardURL.isEmpty
                        ? "-"
                        : applicant.aadharCardURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.aadharCardURL.isNotEmpty) {
                      showFilePreviewDialog(
                        title: "Aadhaar Card",
                        context,
                        applicant.aadharCardURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.aadharCardURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "PAN Card No.",
                value: applicant.panNumber.isEmpty ? "-" : applicant.panNumber,
              ),
              buildColumnTitleValue(
                title: "PAN Card",
                value:
                    applicant.panCardURL.isEmpty ? "-" : applicant.panCardURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.panCardURL.isNotEmpty) {
                      showFilePreviewDialog(
                        title: "PAN Card",
                        context,
                        applicant.panCardURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.panCardURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Driving License",
                value:
                    applicant.drivingLicenseNumber.isEmpty
                        ? "-"
                        : applicant.drivingLicenseNumber,
              ),
              buildColumnTitleValue(
                title: "Driving License",
                value:
                    applicant.drivingLicenseURL.isEmpty
                        ? "-"
                        : applicant.drivingLicenseURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.drivingLicenseURL.isNotEmpty) {
                      showFilePreviewDialog(
                        title: "Driving License",
                        context,
                        applicant.drivingLicenseURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.drivingLicenseURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Voting ID No.",
                value:
                    applicant.votingIdNumber.isEmpty
                        ? "-"
                        : applicant.votingIdNumber,
              ),
              buildColumnTitleValue(
                title: "Voting ID",
                value:
                    applicant.votingIdURL.isEmpty ? "-" : applicant.votingIdURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.votingIdURL.isNotEmpty) {
                      showFilePreviewDialog(
                        title: "Voting ID",
                        context,
                        applicant.votingIdURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.votingIdURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Passport No.",
                value:
                    applicant.passportNumber.isEmpty
                        ? "-"
                        : applicant.passportNumber,
              ),
              buildColumnTitleValue(
                title: "Passport",
                value:
                    applicant.passportURL.isEmpty ? "-" : applicant.passportURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.passportURL.isNotEmpty) {
                      showFilePreviewDialog(
                        title: "Passport",
                        context,
                        applicant.passportURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.passportURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "GST No.",
                value: applicant.gstNumber.isEmpty ? "-" : applicant.gstNumber,
              ),
              buildColumnTitleValue(
                title: "GST Certificate",
                value:
                    applicant.gstNumberURL.isEmpty
                        ? "-"
                        : applicant.gstNumberURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.gstNumberURL.isNotEmpty) {
                      showFilePreviewDialog(
                        title: "GST Certificate",
                        context,
                        applicant.gstNumberURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.gstNumberURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Profile Photo",
                value: applicant.photoURL.isEmpty ? "-" : applicant.photoURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.photoURL.isNotEmpty) {
                      showFilePreviewDialog(
                        title: "Profile Photo",
                        context,
                        applicant.photoURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.photoURL.isEmpty,
                ),
              ),
              buildColumnTitleValue(
                title: "Cheque / Cancelled Cheque",
                value: applicant.chequeURL.isEmpty ? "-" : applicant.chequeURL,
                customValueWidget: CustomButton.documentOutline(
                  onPressed: () {
                    if (applicant.chequeURL.isNotEmpty) {
                      showFilePreviewDialog(
                        title: "Cheque / Cancelled Cheque",
                        context,
                        applicant.chequeURL.split(","),
                      );
                    }
                  },
                  isDisable: applicant.chequeURL.isEmpty,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(title: "Bank", value: applicant.bankName),
              buildColumnTitleValue(
                title: "Account Number",
                value: applicant.accountNumber,
              ),
            ],
          ),
          buildRowWrapper(
            child: buildColumnTitleValue(
              title: "IFSC",
              value: applicant.ifscCode,
            ),
          ),
        ],
      ),
    );
  }
}
