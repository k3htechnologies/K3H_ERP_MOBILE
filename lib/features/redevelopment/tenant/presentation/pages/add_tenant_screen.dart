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
  List<TenantApplicantData> _applicants = [];

  // TEXT EDITING CONTROLLERS
  late TextEditingController _unitNumberC,
      _flatCarpetAreaC,
      _freeAreaOfferedPercentageC,
      _extraAreaPurchasedSqFtC,
      _totalAreaSqFtC;

  List<Map<String, dynamic>> flatTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Type'},
    {'zAttributesId': 1, 'DisplayName': 'Residential'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial'},
    {'zAttributesId': 3, 'DisplayName': 'Void'},
    {'zAttributesId': 4, 'DisplayName': 'Gym'},
  ];

  List<Map<String, dynamic>> commercialFlatList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Configuration'},
    {'zAttributesId': 1, 'DisplayName': 'Shop'},
    {'zAttributesId': 2, 'DisplayName': 'Office'},
  ];

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

  late ValueNotifier<Map<String, dynamic>> selectedFlatType;

  // SELECTED DROPDOWN VALUES
  Map<String, dynamic>? selectedFlatFacing, selectedFlatConfiguration;

  bool _isApplicantType(String type) =>
      type.toLowerCase().trim() == 'applicant';

  bool get _hasPrimaryApplicant =>
      _applicants.any((e) => _isApplicantType(e.applicantType));

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
    selectedFlatFacing = flatFacingList.first;
    selectedFlatType = ValueNotifier(flatTypeList.first);
    selectedFlatConfiguration = commercialFlatList.first;
  }

  void _prefillTenantDetails(TenantModel? tenant) {
    if (tenant == null) return;

    _unitNumberC.text = tenant.flatNumber;
    _flatCarpetAreaC.text = tenant.flatCarpetAreaSqFt.toString();
    _freeAreaOfferedPercentageC.text =
        tenant.freeAreaOfferedPercentage.toString();
    _extraAreaPurchasedSqFtC.text = tenant.extraAreaPurchasedSqFt.toString();
    _totalAreaSqFtC.text = tenant.totalAreaSqFt.toString();

    selectedFlatFacing = flatFacingList.firstWhere(
      (e) => e['DisplayName'] == tenant.facing,
      orElse: () => flatFacingList.first,
    );

    final flatTypeMatch = flatTypeList.firstWhere(
      (e) => e['DisplayName'] == tenant.flatType,
      orElse: () => flatTypeList.first,
    );
    selectedFlatType.value = flatTypeMatch;

    final isResidential = tenant.flatType.toLowerCase() == 'residential';
    final configList = isResidential ? residentialFlatList : commercialFlatList;

    selectedFlatConfiguration = configList.firstWhere(
      (e) => e['DisplayName'] == tenant.flatConfiguration,
      orElse: () => configList.first,
    );
  }

  void _initApplicants() {
    final incomingApplicants = widget.tenant?.tenantApplicantData ?? [];
    _applicants =
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
              hasPrimaryApplicant: _hasPrimaryApplicant,
            ),
      ),
    );

    if (result == null || result['applicant'] == null) return;

    final TenantApplicantData updatedApplicant = result['applicant'];
    final int? updatedIndex = result['index'] as int?;

    // Check for existing primary applicant when saving
    final existingApplicantIndex = _applicants.indexWhere(
      (e) => _isApplicantType(e.applicantType),
    );
    final bool isUpdatingExisting =
        updatedIndex != null && updatedIndex < _applicants.length;
    if (_isApplicantType(updatedApplicant.applicantType) &&
        existingApplicantIndex != -1 &&
        (!isUpdatingExisting || existingApplicantIndex != updatedIndex)) {
      await showErrorMessage(
        context,
        'Error',
        'Only one Applicant type is allowed.',
      );
      return;
    }

    setState(() {
      if (isUpdatingExisting) {
        final int targetIndex = updatedIndex;
        _applicants[targetIndex] = updatedApplicant;
      } else {
        _applicants.add(updatedApplicant);
      }
    });
  }

  void _deleteApplicant(int index) {
    if (index < 0 || index >= _applicants.length) return;
    setState(() {
      _applicants.removeAt(index);
    });
  }

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

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_applicants.isEmpty) {
      showErrorMessage(
        context,
        'Error',
        'Please add at least one Applicant before saving.',
      );
      return;
    }

    if (!_hasPrimaryApplicant) {
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
        selectedFlatConfiguration?['DisplayName']?.toString() ?? '';
    final facing = selectedFlatFacing?['DisplayName']?.toString() ?? '';

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
        addUpdateTenantApplicant: _applicants,
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
        addUpdateTenantApplicant: _applicants,
      );
    }
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
                    if (_applicants.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'No applicants added yet',
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              _applicants
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
                      title: 'Unit Number',
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
                    CustomDropDownWidget(
                      title: 'Unit Type',
                      dataList: flatTypeList,
                      isRequired: true,
                      initialValue: selectedFlatType.value,
                      onSelected: (value) {
                        selectedFlatConfiguration = null;
                        selectedFlatType.value = value;
                      },
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'Unit Type is required';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedFlatType,
                      builder: (context, value, child) {
                        if (value['zAttributesId'] == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: CustomDropDownWidget(
                              title: 'Flat Configuration*',
                              dataList: residentialFlatList,
                              initialValue: selectedFlatConfiguration,
                              onSelected: (value) {
                                selectedFlatConfiguration = value;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value["zAttributesId"] == -1) {
                                  return 'Flat Configuration is required';
                                }
                                return null;
                              },
                            ),
                          );
                        }
                        if (value['zAttributesId'] == 2) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: CustomDropDownWidget(
                              title: 'Flat Configuration*',
                              dataList: commercialFlatList,
                              initialValue: selectedFlatConfiguration,
                              onSelected: (value) {
                                selectedFlatConfiguration = value;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value["zAttributesId"] == -1) {
                                  return 'Flat Configuration is required';
                                }
                                return null;
                              },
                            ),
                          );
                        }
                        return SizedBox();
                      },
                    ),
                    CustomDropDownWidget(
                      title: 'Facing',
                      isRequired: true,
                      dataList: flatFacingList,
                      initialValue: selectedFlatFacing,
                      onSelected: (value) {
                        selectedFlatFacing = value;
                      },
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'Facing is required';
                        }
                        return null;
                      },
                    ),
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
                      title: 'Extra Area Purchased SqFt ',
                      hint: "Enter Extra Area Purchased SqFt",
                      inputFormatterList: InputValidator.digit(10),
                      textController: _extraAreaPurchasedSqFtC,
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 77,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? 'Update' : 'Save',
            onPressed: _handleSubmit,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }
}
