import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/data/model/sub_material.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddMaterialScreen extends StatefulWidget {
  final MaterialRequisitionDetailModel? materialDetails;
  final int? index;

  const AddMaterialScreen({
    super.key,
    required this.materialDetails,
    required this.index,
  });

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  // CUBIT
  late MaterialRequisitionCubit _materialRequisitionCubit;

  late ProjectModel _project;
  late UserModel user;
  final ValueNotifier<List<SubMaterialModel>> rawMaterialList = ValueNotifier(
    [],
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedMaterial = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedSubMaterial =
      ValueNotifier(null);
  final ValueNotifier<DateTime?> _requiredDate = ValueNotifier(null);

  //EDIT MODE
  bool get _isEditMode => widget.materialDetails != null;

  late TextEditingController _uomC, _quantityC, _remarkC;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _project = getProject();
    initializeTextEditingController();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    user = getCurrentUser();
    _prefill();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMaterialSubMaterialUOMMaster();
    });
  }

  final UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();

  void initializeTextEditingController() {
    _uomC = TextEditingController();
    _quantityC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _prefill() {
    if (!_isEditMode) return;

    _selectedMaterial.value = {
      "DisplayName": widget.materialDetails!.materialName,
      "zAttributesId": widget.materialDetails!.materialMasterId,
    };
    _selectedSubMaterial.value = {
      "DisplayName": widget.materialDetails!.subMaterialName,
      "zAttributesId": widget.materialDetails!.subMaterialMasterId,
    };
    _uomC.text = widget.materialDetails!.uomCode;
    _requiredDate.value = widget.materialDetails!.requiredDate;
    _quantityC.text = widget.materialDetails!.materialQuantity.toString();
    _remarkC.text = widget.materialDetails!.remark;
  }

  // <---- DROPDOWN FUNCTIONS ---->
  Future<void> getMaterialSubMaterialUOMMaster() async {
    DialogHelper.showProcessingOverlay(context);
    var result = await utilsRepository
        .getMaterialMasterSubMaterialMasterUOMMaster(
          projectId: _project.projectId,
          queryParams: {"ClientRegistrationId": user.clientRegistrationId},
        );

    try {
      return await result.fold(
        (failure) async {
          showErrorMessage(context, 'Error', failure.message);
          rawMaterialList.value = [];
        },
        (response) async {
          final data = response["MaterialMasterSubMaterialMasterData"];

          if (data == null) {
            rawMaterialList.value = [];
          }

          final parsedList = await compute(
            (m) =>
                (m as List<dynamic>)
                    .map((e) => SubMaterialModel.fromJson(e))
                    .toList(),
            data,
          );

          rawMaterialList.value = List<SubMaterialModel>.from(parsedList);
        },
      );
    } finally {
      if (mounted) {
        goRouter.pop();
      }
    }
  }

  List<Map<String, dynamic>> get materialList {
    final seen = <dynamic>{};

    return rawMaterialList.value
        .where((e) {
          return seen.add(e.materialMasterId);
        })
        .map((e) {
          return {
            "zAttributesId": e.materialMasterId,
            "DisplayName": e.materialName,
          };
        })
        .toList();
  }

  List<Map<String, dynamic>> get subMaterialList {
    final selectedId = _selectedMaterial.value?['zAttributesId'];

    if (selectedId == null) return [];

    return rawMaterialList.value
        .where((e) => e.materialMasterId == selectedId)
        .map((e) {
          return {
            "zAttributesId": e.subMaterialMasterId,
            "DisplayName": e.subMaterialName,
          };
        })
        .toList();
  }

  void updateUOM() {
    final selectedId = _selectedSubMaterial.value?['zAttributesId'];
    if (selectedId == null) return;
    final selectedItem = rawMaterialList.value.firstWhere(
      (e) => e.subMaterialMasterId == selectedId,
    );

    _uomC.text = selectedItem.uomCode;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final selectedId = _selectedSubMaterial.value?['zAttributesId'];
    final selectedItem = rawMaterialList.value.firstWhere(
      (e) => e.subMaterialMasterId == selectedId,
    );
    final material = MaterialRequisitionDetailModel(
      materialRequisitionDetailId:
          _isEditMode ? widget.materialDetails!.materialRequisitionDetailId : 0,
      uniquekey: _isEditMode ? widget.materialDetails!.uniquekey : '',
      materialMasterId: _selectedMaterial.value?['zAttributesId'] ?? -1,
      materialName: _selectedMaterial.value?['DisplayName'] ?? '',
      subMaterialName: _selectedSubMaterial.value?['DisplayName'] ?? '',
      subMaterialMasterId: _selectedSubMaterial.value?['zAttributesId'] ?? -1,
      materialQuantity: double.tryParse(_quantityC.text) ?? 0,
      uomMasterId: selectedItem.uomMasterId,
      uomCode: _uomC.text,
      uom: _uomC.text,
      requiredDate: _requiredDate.value ?? DateTime.now(),
      remark: _remarkC.text.trim(),
      materialReceivedQuantityTillDate:
          _isEditMode
              ? widget.materialDetails!.materialReceivedQuantityTillDate
              : 0,
      createdById: _isEditMode ? widget.materialDetails!.createdById : 0,
      createdBy: _isEditMode ? widget.materialDetails!.createdBy : '',
      createdDate:
          _isEditMode ? widget.materialDetails!.createdDate : DateTime.now(),
      modifiedById: _isEditMode ? widget.materialDetails!.modifiedById : 0,
      modifiedBy: _isEditMode ? widget.materialDetails!.modifiedBy : "",
    );
    if (_isEditMode) {
      _materialRequisitionCubit.updateMaterialList(material, widget.index);
    } else {
      _materialRequisitionCubit.addMaterial(material);
    }
    goRouter.pop();
  }

  @override
  void dispose() {
    _uomC.dispose();
    _quantityC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Material Requisition",
        authorization: AuthorizationModel(),
      ),
      body: ValueListenableBuilder(
        valueListenable: rawMaterialList,
        builder: (context, value, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    decoration: commonCardDecoration(),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode ? "Update Material" : "Add Material",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        verticalSpacing(),
                        ValueListenableBuilder(
                          valueListenable: _selectedMaterial,
                          builder: (context, value, child) {
                            return CustomDropDownWidget(
                              title: "Material",
                              isRequired: true,
                              hintText: "Select Material",
                              initialValue: value,
                              dataList: materialList,
                              onValueClear: () {
                                _selectedMaterial.value = null;
                                _selectedSubMaterial.value = null;
                                _uomC.clear();
                              },
                              onSelected: (value) {
                                _selectedMaterial.value = value;
                                _selectedSubMaterial.value = null;
                                _uomC.clear();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Material is required";
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: _selectedMaterial,
                          builder: (context, value, child) {
                            return ValueListenableBuilder(
                              valueListenable: _selectedSubMaterial,
                              builder: (context, value, child) {
                                return CustomDropDownWidget(
                                  title: "Sub Material",
                                  isRequired: true,
                                  hintText: "Select Sub Material",
                                  initialValue: value,
                                  dataList: subMaterialList,
                                  onValueClear: () {
                                    _selectedSubMaterial.value = null;
                                    _uomC.clear();
                                  },
                                  onSelected: (value) {
                                    _selectedSubMaterial.value = value;
                                    updateUOM();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Sub material is required";
                                    }
                                    return null;
                                  },
                                );
                              },
                            );
                          },
                        ),

                        CustomTextField(
                          title: "UOM",
                          isRequired: true,
                          readOnly: true,
                          textController: _uomC,
                        ),
                        ValueListenableBuilder(
                          valueListenable: _requiredDate,
                          builder: (context, value, child) {
                            return CustomDatePicker(
                              title: "Required Date",
                              initialDate: value,
                              isRequired: true,
                              startDate: DateTime.now(),
                              setValue: (value) {
                                _requiredDate.value = value;
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Date is required';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        CustomTextField(
                          title: "Quantity",
                          hint: "Enter Received Quantity",
                          isRequired: true,
                          inputFormatterList: InputValidator.decimal(2),
                          keyboardType: TextInputType.numberWithOptions(),
                          textController: _quantityC,
                          validator: (value) {
                            if (value == null || value == "") {
                              return "Quantity is required";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: "Remark",
                          hint: "Enter Remark",
                          maxLines: 3,
                          minLines: 3,
                          textController: _remarkC,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(
            leading: Icon(Icons.add, size: 18, color: AppColor.white),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
