import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/pages/add_tenant_applicant_screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // APPLICANT LIST
  final ValueNotifier<List<TenantApplicantData>> _applicants =
      ValueNotifier<List<TenantApplicantData>>([]);

  // TEXT EDITING CONTROLLERS
  late TextEditingController _unitNumberC,
      _flatCarpetAreaC,
      _freeAreaOfferedPercentageC,
      _extraAreaPurchasedSqFtC,
      _totalAreaSqFtC;

  // STATIC FLAT TYPE LIST
  List<Map<String, dynamic>> flatTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Type'},
    {'zAttributesId': 1, 'DisplayName': 'Residential'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial'},
    {'zAttributesId': 3, 'DisplayName': 'Void'},
    {'zAttributesId': 4, 'DisplayName': 'Gym'},
  ];

  // STATIC FLAT CONFIGURATION LIST
  List<Map<String, dynamic>> commercialFlatList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Configuration'},
    {'zAttributesId': 1, 'DisplayName': 'Shop'},
    {'zAttributesId': 2, 'DisplayName': 'Office'},
  ];

  // STATIC FLAT CONFIGURATION LIST
  List<Map<String, dynamic>> residentialFlatList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Configuration'},
    {'zAttributesId': 1, 'DisplayName': '1 BHK'},
    {'zAttributesId': 2, 'DisplayName': '2 BHK'},
    {'zAttributesId': 3, 'DisplayName': '3 BHK'},
    {'zAttributesId': 4, 'DisplayName': '4 BHK'},
    {'zAttributesId': 5, 'DisplayName': '5 BHK'},
    {'zAttributesId': 6, 'DisplayName': '1 Rk'},
    {'zAttributesId': 7, 'DisplayName': 'Duplex'},
  ];

  // STATIC FLAT FACING LIST
  List<Map<String, dynamic>> flatFacingList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Facing'},
    {'zAttributesId': 1, 'DisplayName': 'North'},
    {'zAttributesId': 2, 'DisplayName': 'South'},
    {'zAttributesId': 3, 'DisplayName': 'East'},
    {'zAttributesId': 4, 'DisplayName': 'West'},
    {'zAttributesId': 5, 'DisplayName': 'Road'},
    {'zAttributesId': 6, 'DisplayName': 'Garden'},
    {'zAttributesId': 7, 'DisplayName': 'Front'},
    {'zAttributesId': 8, 'DisplayName': 'Park'},
  ];

  // SELECTED FLAT TYPE
  late ValueNotifier<Map<String, dynamic>> selectedFlatType;

  // SELECTED DROPDOWN VALUES (reactive, without setState)
  late ValueNotifier<Map<String, dynamic>?> selectedFlatFacing;
  late ValueNotifier<Map<String, dynamic>?> selectedFlatConfiguration;

  // METHODS TO CHECK IF APPLICANT TYPE IS PRIMARY
  bool _isApplicantType(String type) =>
      type.toLowerCase().trim() == 'applicant';

  bool _hasPrimaryApplicant(List<TenantApplicantData> applicants) =>
      applicants.any((e) => _isApplicantType(e.applicantType));

  bool get _isEditMode => widget.tenant != null;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _initialisedTextController();
    _initApplicants();
    _prefillTenantDetails(widget.tenant);
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initialisedTextController() {
    _unitNumberC = TextEditingController();
    _flatCarpetAreaC = TextEditingController();
    _freeAreaOfferedPercentageC = TextEditingController();
    _extraAreaPurchasedSqFtC = TextEditingController();
    _totalAreaSqFtC = TextEditingController();
    selectedFlatFacing = ValueNotifier<Map<String, dynamic>?>(
      flatFacingList.first,
    );
    selectedFlatType = ValueNotifier(flatTypeList.first);
    selectedFlatConfiguration = ValueNotifier<Map<String, dynamic>?>(
      commercialFlatList.first,
    );
  }

  // PREFILL TENANT DETAILS
  void _prefillTenantDetails(TenantModel? tenant) {
    if (tenant == null) return;

    _unitNumberC.text = tenant.flatNumber;
    _flatCarpetAreaC.text = tenant.flatCarpetAreaSqFt.toString();
    _freeAreaOfferedPercentageC.text =
        tenant.freeAreaOfferedPercentage == 0
            ? ""
            : tenant.freeAreaOfferedPercentage.toString();
    _extraAreaPurchasedSqFtC.text = tenant.extraAreaPurchasedSqFt.toString();
    _totalAreaSqFtC.text = tenant.totalAreaSqFt.toString();

    selectedFlatFacing.value = flatFacingList.firstWhere(
      (e) =>
          e['DisplayName'].toString().toLowerCase() ==
          tenant.facing.toLowerCase(),
      orElse: () => flatFacingList.first,
    );

    final flatTypeMatch = flatTypeList.firstWhere(
      (e) => e['DisplayName'] == tenant.flatType,
      orElse: () => flatTypeList.first,
    );

    final isResidential = tenant.flatType.toLowerCase() == 'residential';
    final configList = isResidential ? residentialFlatList : commercialFlatList;
    final configMatch = configList.firstWhere(
      (e) =>
          e['DisplayName'].toString().toLowerCase() ==
          tenant.flatConfiguration.toLowerCase(),
      orElse: () => configList.first,
    );
    selectedFlatType.value = flatTypeMatch;
    Future.microtask(() {
      if (mounted) {
        selectedFlatConfiguration.value = configMatch;
      }
    });
  }

  // INITIALIZE APPLICANTS
  void _initApplicants() {
    final incomingApplicants = widget.tenant?.tenantApplicantData ?? [];
    _applicants.value =
        incomingApplicants
            .map((e) => TenantApplicantData.fromJson(e.toJson()))
            .toList();
  }

  // OPEN APPLICANT FORM
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
    final existingApplicantIndex = currentApplicants.indexWhere(
      (e) => _isApplicantType(e.applicantType),
    );
    final bool isUpdatingExisting =
        updatedIndex != null && updatedIndex < currentApplicants.length;
    if (_isApplicantType(updatedApplicant.applicantType) &&
        existingApplicantIndex != -1 &&
        (!isUpdatingExisting || existingApplicantIndex != updatedIndex) &&
        mounted) {
      await showErrorMessage(
        context,
        'Error',
        'Only one Applicant type is allowed.',
      );
      return;
    }

    if (isUpdatingExisting) {
      final int targetIndex = updatedIndex;
      currentApplicants[targetIndex] = updatedApplicant;
    } else {
      currentApplicants.add(updatedApplicant);
    }
    _applicants.value = currentApplicants;
  }

  void _deleteApplicant(int index) {
    final currentApplicants = List<TenantApplicantData>.from(_applicants.value);
    if (index < 0 || index >= currentApplicants.length) return;
    currentApplicants.removeAt(index);
    _applicants.value = currentApplicants;
  }

  // HANDLE SUBMIT
  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final currentApplicants = _applicants.value;
    if (currentApplicants.isEmpty) {
      showErrorMessage(
        context,
        'Error',
        'Please add at least one Applicant before saving.',
      );
      return;
    }

    if (!_hasPrimaryApplicant(currentApplicants)) {
      showErrorMessage(
        context,
        'Error',
        'Please ensure one Applicant has type "Applicant".',
      );
      return;
    }

    final cubit = context.read<TenantCubit>();

    final flatType = selectedFlatType.value['DisplayName'].toString();
    final flatConfiguration =
        selectedFlatConfiguration.value?['DisplayName']?.toString() ?? '';
    final facing = selectedFlatFacing.value?['DisplayName']?.toString() ?? '';

    final freeArea =
        _freeAreaOfferedPercentageC.text.trim().isEmpty
            ? '0'
            : _freeAreaOfferedPercentageC.text.trim();
    final extraArea =
        _extraAreaPurchasedSqFtC.text.trim().isEmpty
            ? '0'
            : _extraAreaPurchasedSqFtC.text.trim();
    final totalArea =
        _totalAreaSqFtC.text.trim().isEmpty ? '0' : _totalAreaSqFtC.text.trim();

    if (_isEditMode && widget.tenant != null) {
      final tenant = widget.tenant!;
      cubit.updateTenant(
        context: context,
        projectId: tenant.projectId.toString(),
        index: widget.index,
        tenantId: tenant.tenantId.toString(),
        uniqueKey: tenant.uniquekey,
        buildingId: tenant.buildingId.toString(),
        flatNumber: _unitNumberC.text.trim(),
        flatCarpetAreaSqFt: _flatCarpetAreaC.text.trim(),
        facing: facing,
        flatType: flatType,
        flatConfiguration: flatConfiguration,
        freeAreaOfferedPercentage: freeArea,
        extraAreaPurchasedSqFt: extraArea,
        totalAreaSqFt: totalArea,
        addUpdateTenantApplicant: currentApplicants,
      );
    } else {
      cubit.addTenant(
        context: context,
        projectId: widget.projectId.toString(),
        buildingId: widget.buildingId.toString(),
        flatNumber: _unitNumberC.text.trim(),
        flatCarpetAreaSqFt: _flatCarpetAreaC.text.trim(),
        facing: facing,
        flatType: flatType,
        flatConfiguration: flatConfiguration,
        freeAreaOfferedPercentage: freeArea,
        extraAreaPurchasedSqFt: extraArea,
        totalAreaSqFt: totalArea,
        addUpdateTenantApplicant: currentApplicants,
      );
    }
  }

  @override
  void dispose() {
    _applicants.dispose();
    selectedFlatType.dispose();
    selectedFlatFacing.dispose();
    selectedFlatConfiguration.dispose();
    _unitNumberC.dispose();
    _flatCarpetAreaC.dispose();
    _freeAreaOfferedPercentageC.dispose();
    _extraAreaPurchasedSqFtC.dispose();
    _totalAreaSqFtC.dispose();
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
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Applicant Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Text(
                          "Add Applicant Details",
                          style: AppTextStyle.ts14M(),
                        ),
                        Spacer(),
                        CustomButton(
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
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                applicants
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => SizedBox(
                                        width: 320,
                                        child: _buildApplicantCard(
                                          entry.value,
                                          entry.key,
                                        ),
                                      ),
                                    )
                                    .toList(),
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
                      textController: _unitNumberC,
                      validator: (value) {
                        if (value == null) {
                          return "Unit Number is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Carpet Area SqFt',
                      hint: "Enter Carpet Area",
                      isRequired: true,
                      textController: _flatCarpetAreaC,
                      validator: (value) {
                        if (value == null) {
                          return "Carpet Area is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: selectedFlatType,
                      builder: (context, flatTypeValue, child) {
                        return CustomDropDownWidget(
                          key: ValueKey(
                            'flatType_${flatTypeValue['zAttributesId']}',
                          ),
                          title: 'Unit Type',
                          dataList: flatTypeList,
                          isRequired: true,
                          initialValue: flatTypeValue,
                          onSelected: (value) {
                            // Only clear configuration if flat type actually changed
                            if (selectedFlatType.value['zAttributesId'] !=
                                value['zAttributesId']) {
                              selectedFlatConfiguration.value = null;
                            }
                            selectedFlatType.value = value;
                          },
                          validator: (value) {
                            if (value == null || value["zAttributesId"] == -1) {
                              return 'Unit Type is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedFlatType,
                      builder: (context, value, child) {
                        if (value['zAttributesId'] == 1) {
                          return ValueListenableBuilder<Map<String, dynamic>?>(
                            valueListenable: selectedFlatConfiguration,
                            builder: (context, configValue, child) {
                              return CustomDropDownWidget(
                                key: ValueKey(
                                  'residential_config_${value['zAttributesId']}_${configValue?['zAttributesId'] ?? 'null'}',
                                ),
                                title: 'Flat Configuration',
                                isRequired: true,
                                dataList: residentialFlatList,
                                initialValue: configValue,
                                onSelected: (selectedValue) {
                                  selectedFlatConfiguration.value =
                                      selectedValue;
                                },
                                validator: (val) {
                                  if (val == null ||
                                      val["zAttributesId"] == -1) {
                                    return 'Flat Configuration is required';
                                  }
                                  return null;
                                },
                              );
                            },
                          );
                        }
                        if (value['zAttributesId'] == 2) {
                          return ValueListenableBuilder<Map<String, dynamic>?>(
                            valueListenable: selectedFlatConfiguration,
                            builder: (context, configValue, child) {
                              return CustomDropDownWidget(
                                key: ValueKey(
                                  'commercial_config_${value['zAttributesId']}_${configValue?['zAttributesId'] ?? 'null'}',
                                ),
                                title: 'Flat Configuration',
                                isRequired: true,
                                dataList: commercialFlatList,
                                initialValue: configValue,
                                onSelected: (selectedValue) {
                                  selectedFlatConfiguration.value =
                                      selectedValue;
                                },
                                validator: (val) {
                                  if (val == null ||
                                      val["zAttributesId"] == -1) {
                                    return 'Flat Configuration is required';
                                  }
                                  return null;
                                },
                              );
                            },
                          );
                        }
                        return SizedBox();
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: selectedFlatFacing,
                      builder: (context, facingValue, child) {
                        return CustomDropDownWidget(
                          key: ValueKey(
                            'facing_${facingValue?['zAttributesId'] ?? 'null'}',
                          ),
                          title: 'Facing',
                          isRequired: true,
                          dataList: flatFacingList,
                          initialValue: facingValue,
                          onSelected: (value) {
                            selectedFlatFacing.value = value;
                          },
                          validator: (value) {
                            if (value == null || value["zAttributesId"] == -1) {
                              return 'Facing is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offer',
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: 'Free Area Offered Percentage',
                      hint: "Enter Free Area Offered Percentage",
                      inputFormatterList: InputValidator.percentage(),
                      textController: _freeAreaOfferedPercentageC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        final intVal = int.tryParse(value);
                        if (intVal == null || intVal <= 0 || intVal > 100) {
                          return "Invalid Percentage";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Total Area SqFt ',
                      hint: "Enter Total Area SqFt",
                      inputFormatterList: InputValidator.digit(10),
                      textController: _totalAreaSqFtC,
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extra Area Purchased',
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: 'Extra Area Purchased SqFt ',
                      hint: "Enter Extra Area Purchased SqFt",
                      inputFormatterList: InputValidator.digit(10),
                      textController: _extraAreaPurchasedSqFtC,
                    ),
                  ],
                )
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(_isEditMode?Icons.edit:Icons.add,color: AppColor.white,size: 18,),
            text: _isEditMode ? 'Update Tenant' : 'Add Tenant',
            onPressed: _handleSubmit,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }

  // BUILD APPLICANT CARD
  Widget _buildApplicantCard(TenantApplicantData applicant, int index) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applicant.applicantName, style: AppTextStyle.ts14M()),
                    verticalSpacing(height: 4),
                    Text(
                      applicant.applicantType,
                      style: AppTextStyle.ts12R(color: AppColor.grey),
                    ),
                  ],
                ),
              ),
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
                    onPressed: () => _deleteApplicant(index),
                  ),
                ],
              ),
            ],
          ),
          verticalSpacing(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailField(
                  "Contact No.",
                  applicant.applicantMobileNumber,
                ),
              ),
              Expanded(
                child: _buildDetailField("Email", applicant.applicantEmailId),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildDetailField("Bank", applicant.bankName)),
              Expanded(
                child: _buildDetailField(
                  "Account No.",
                  applicant.accountNumber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BUILD DETAIL FIELD
  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.ts12R(color: AppColor.grey)),
          Text(
            value.isEmpty ? "-" : value,
            style: AppTextStyle.ts14R(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
