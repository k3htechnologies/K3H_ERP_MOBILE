import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/data/model/sub_material.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
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

class AddGrnMaterialScreen extends StatefulWidget {
  final MaterialRequisitionDetailGrnDatum? materialDetails;
  final int? index;

  const AddGrnMaterialScreen({
    super.key,
    required this.materialDetails,
    required this.index,
  });

  @override
  State<AddGrnMaterialScreen> createState() => _AddGrnMaterialScreenState();
}

class _AddGrnMaterialScreenState extends State<AddGrnMaterialScreen> {
  // CUBIT
  late GrnCubit _grnCubit;

  late ProjectModel _project;
  final ValueNotifier<List<MaterialRequisitionQuotationDatum>> rawMaterialList =
      ValueNotifier([]);
  final ValueNotifier<Map<String, dynamic>?> _selectedMaterial = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedSubMaterial =
      ValueNotifier(null);
  final ValueNotifier<DateTime?> _requiredDate = ValueNotifier(null);

  //EDIT MODE
  bool get _isEditMode => widget.materialDetails != null;

  late MaterialRequisitionCubit _materialRequisitionCubit;

  late TextEditingController _uomC,
      _totalQuantityC,
      _remarkC,
      _receivedQuantity;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _project = getProject();
    initializeTextEditingController();
    _grnCubit = context.read<GrnCubit>();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _prefill();
    rawMaterialList.value =
        _materialRequisitionCubit
            .state
            .finalizedVendor!
            .materialRequisitionQuotationTermsData
            .first
            .materialRequisitionQuotationData;
  }

  final UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();

  void initializeTextEditingController() {
    _uomC = TextEditingController();
    _totalQuantityC = TextEditingController();
    _remarkC = TextEditingController();
    _receivedQuantity = TextEditingController();
  }

  void _prefill() {
    if (!_isEditMode) return;

    _selectedMaterial.value = materialList.firstWhere(
      (element) =>
          element['DisplayName'] == widget.materialDetails!.materialName,
      orElse: () => {},
    );
    _selectedSubMaterial.value = subMaterialList.firstWhere(
      (element) =>
          element['DisplayName'] == widget.materialDetails!.subMaterialName,
      orElse: () => {},
    );
    _uomC.text = widget.materialDetails!.uomCode;
    _requiredDate.value = widget.materialDetails!.requiredDate;
    _totalQuantityC.text = widget.materialDetails!.materialQuantity.toString();
    _remarkC.text = widget.materialDetails!.qualityAnalysisRemarks ?? "";
  }

  List<Map<String, dynamic>> get materialList {
    final seen = <int>{};

    return rawMaterialList.value
        .where(
          (e) =>
              (seen.add(e.materialRequisitionDetailId) &&
                  e.materialRequisitionDetailId != 0),
        )
        .map((e) {
          return {
            "zAttributesId": e.materialRequisitionDetailId,
            "DisplayName": e.materialName,
          };
        })
        .toList();
  }

  List<Map<String, dynamic>> get subMaterialList {
    final selectedId = _selectedMaterial.value?['zAttributesId'];

    if (selectedId == null) return [];

    return rawMaterialList.value
        .where((e) => e.materialRequisitionDetailId == selectedId)
        .map((e) {
          return {
            "zAttributesId": e.materialRequisitionDetailId,
            "DisplayName": e.subMaterialName,
          };
        })
        .toList();
  }

  void updateUOM() {
    final selectedId = _selectedSubMaterial.value?['zAttributesId'];
    if (selectedId == null) return;

    final selectedItem = rawMaterialList.value.where(
      (e) => e.materialRequisitionDetailId == selectedId,
    );

    _uomC.text = selectedItem.first.uom;
    _totalQuantityC.text = addCommasToInteger(
      selectedItem.first.materialQuantity,
      withoutSign: true,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final material = MaterialRequisitionDetailGrnDatum(
      materialRequisitionDetailId: _selectedMaterial.value?['zAttributesId'],
      uniquekey: _isEditMode ? widget.materialDetails!.uniquekey : '',
      materialRequisitionGrnId:
          _isEditMode ? widget.materialDetails!.materialRequisitionGrnId : 0,
      materialRequisitionDetailGrnId:
          _isEditMode
              ? widget.materialDetails!.materialRequisitionDetailGrnId
              : 0,
      materialName: _selectedMaterial.value?['DisplayName'] ?? '',
      subMaterialName: _selectedSubMaterial.value?['DisplayName'] ?? '',
      materialQuantity: double.tryParse(_totalQuantityC.text) ?? 0,
      uomCode: _uomC.text,
      uom: _uomC.text,
      requiredDate: _requiredDate.value ?? DateTime.now(),
      qualityAnalysisRemarks: _remarkC.text.trim(),
      createdById: _isEditMode ? widget.materialDetails!.createdById : 0,
      createdBy: _isEditMode ? widget.materialDetails!.createdBy : '',
      createdDate:
          _isEditMode ? widget.materialDetails!.createdDate : DateTime.now(),
      modifiedById: _isEditMode ? widget.materialDetails!.modifiedById : 0,
      modifiedBy: _isEditMode ? widget.materialDetails!.modifiedBy : "",
      modifiedDate: _isEditMode ? widget.materialDetails!.modifiedDate : null,
      totalReceivedMaterialQuantity: double.parse(_receivedQuantity.text) ?? 0,
    );
    if (_isEditMode) {
      _grnCubit.updateMaterialList(material, widget.index);
    } else {
      _grnCubit.addMaterial(material);
    }
    goRouter.pop();
  }

  @override
  void dispose() {
    _uomC.dispose();
    _totalQuantityC.dispose();
    _receivedQuantity.dispose();
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
                          _isEditMode
                              ? "Update GRN Material"
                              : "Add GRN Material",
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

                        CustomTextField(
                          title: "Total Quantity",
                          isRequired: true,
                          readOnly: true,
                          textController: _totalQuantityC,
                        ),
                        CustomTextField(
                          title: "Received Quantity",
                          hint: "Enter Received Quantity",
                          isRequired: true,
                          inputFormatterList: InputValidator.decimal(2),
                          keyboardType: TextInputType.numberWithOptions(),
                          textController: _receivedQuantity,
                          validator: (value) {
                            if (value == null || value == "") {
                              return "Received Quantity is required";
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
