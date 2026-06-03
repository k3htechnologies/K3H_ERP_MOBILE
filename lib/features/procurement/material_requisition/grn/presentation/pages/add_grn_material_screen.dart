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
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddGrnMaterialScreen extends StatefulWidget {
  final MaterialRequisitionDetailGrnDatum? materialDetails;
  final int? index;
  final bool isParentEditMode;

  const AddGrnMaterialScreen({
    super.key,
    required this.materialDetails,
    required this.index,
    this.isParentEditMode = false,
  });

  @override
  State<AddGrnMaterialScreen> createState() => _AddGrnMaterialScreenState();
}

class _AddGrnMaterialScreenState extends State<AddGrnMaterialScreen> {
  // CUBIT
  late GrnCubit _grnCubit;

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

  late MaterialRequisitionCubit _materialRequisitionCubit;

  late TextEditingController _uomC,
      _pendingQuantityC,
      _remarkC,
      _receivedQuantity;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ProjectModel _selectedProject;
  late UserModel user;
  final ValueNotifier<double> _totalQuantity = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    initializeTextEditingController();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _selectedProject = getProject();
    loadData();
    _grnCubit = context.read<GrnCubit>();
  }

  void loadData() async {
    user = getCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getMaterialSubMaterialUOMMaster();
    });
  }

  final UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();

  void initializeTextEditingController() {
    _uomC = TextEditingController();
    _pendingQuantityC = TextEditingController();
    _remarkC = TextEditingController();
    _receivedQuantity = TextEditingController();
  }

  void _prefill() {
    if (!_isEditMode) return;

    final material = materialList.cast<Map<String, dynamic>?>().firstWhere(
      (e) => e?['DisplayName'] == widget.materialDetails?.materialName,
      orElse: () => null,
    );

    _selectedMaterial.value = material;

    final subMaterial = subMaterialList
        .cast<Map<String, dynamic>?>()
        .firstWhere(
          (e) => e?['DisplayName'] == widget.materialDetails?.subMaterialName,
          orElse: () => null,
        );

    _selectedSubMaterial.value = subMaterial;

    _uomC.text = widget.materialDetails?.uomCode ?? '';
    _requiredDate.value = widget.materialDetails?.requiredDate;

    _pendingQuantityC.text =
        widget.materialDetails?.materialQuantity.toString() ?? '';

    _receivedQuantity.text =
        widget.materialDetails?.totalReceivedMaterialQuantity.toString() ?? '';

    _remarkC.text = widget.materialDetails?.qualityAnalysisRemarks ?? '';

    _totalQuantity.value = widget.materialDetails?.materialQuantity ?? 0;
  }

  List<Map<String, dynamic>> get materialList {
    final quotationList =
        _materialRequisitionCubit
            .state
            .materialRequisitionOverview
            ?.materialRequisitionDetailData ??
        [];

    final allowedMaterialIds =
        quotationList.map((e) => e.materialMasterId).toSet();

    final seen = <int>{};

    return rawMaterialList.value
        .where((e) => allowedMaterialIds.contains(e.materialMasterId))
        .where((e) => seen.add(e.materialMasterId))
        .map(
          (e) => {
            "zAttributesId": e.materialMasterId,
            "DisplayName": e.materialName,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> get subMaterialList {
    final selectedId = _selectedMaterial.value?['zAttributesId'];
    if (selectedId == null) return [];

    final quotationList =
        _materialRequisitionCubit
            .state
            .materialRequisitionOverview
            ?.materialRequisitionDetailData ??
        [];

    final allowedSubIds =
        quotationList
            .where((e) => e.materialMasterId == selectedId)
            .map((e) => e.subMaterialMasterId)
            .toSet();

    return rawMaterialList.value
        .where(
          (e) =>
              e.materialMasterId == selectedId &&
              allowedSubIds.contains(e.subMaterialMasterId),
        )
        .map(
          (e) => {
            "zAttributesId": e.subMaterialMasterId,
            "DisplayName": e.subMaterialName,
            "IsTolerant": e.isTolerant,
            "MaterialTolerant": e.materialTolerant,
          },
        )
        .toList();
  }

  double getPendingQuantity({
    required int materialId,
    required int subMaterialId,
  }) {
    final requisitionList =
        _materialRequisitionCubit
            .state
            .materialRequisitionOverview
            ?.materialRequisitionDetailData ??
        [];

    final detail = requisitionList.firstWhere(
      (e) =>
          e.materialMasterId == materialId &&
          e.subMaterialMasterId == subMaterialId,
      orElse: () => throw Exception("Detail not found"),
    );

    final requestedQty = detail.materialQuantity;
    _totalQuantity.value = detail.materialQuantity;

    final grnReceivedQty = _grnCubit.state.allGRNList
        .expand((grn) => grn.materialRequisitionDetailGrnData)
        .where(
          (e) =>
              e.materialName == detail.materialName &&
              e.subMaterialName == detail.subMaterialName,
        )
        .fold<double>(0, (s, e) => s + e.totalReceivedMaterialQuantity);

    final currentQty = _grnCubit.state.materialList
        .where(
          (e) =>
              e.materialName == detail.materialName &&
              e.subMaterialName == detail.subMaterialName,
        )
        .fold<double>(0, (s, e) => s + e.totalReceivedMaterialQuantity);

    return (requestedQty -
            grnReceivedQty -
            ((!widget.isParentEditMode) ? 0 : currentQty))
        .clamp(0.0, double.infinity);
  }

  void updateUOM() {
    final materialId = _selectedMaterial.value?['zAttributesId'];
    final subMaterialId = _selectedSubMaterial.value?['zAttributesId'];

    if (materialId == null || subMaterialId == null) return;

    final item = rawMaterialList.value.firstWhere(
      (e) =>
          e.materialMasterId == materialId &&
          e.subMaterialMasterId == subMaterialId,
    );

    _uomC.text = item.uomCode;
    final remainingQty = getPendingQuantity(
      materialId: materialId,
      subMaterialId: subMaterialId,
    );

    _pendingQuantityC.text = remainingQty.toString();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final material = MaterialRequisitionDetailGrnDatum(
      materialRequisitionDetailId: getMaterialRequisitionDetailId(
        materialName: _selectedMaterial.value?['DisplayName'],
      ),
      uniquekey: _isEditMode ? widget.materialDetails!.uniquekey : '',
      materialRequisitionGrnId:
          _isEditMode ? widget.materialDetails!.materialRequisitionGrnId : 0,
      materialRequisitionDetailGrnId:
          _isEditMode
              ? widget.materialDetails!.materialRequisitionDetailGrnId
              : 0,
      materialName: _selectedMaterial.value?['DisplayName'] ?? '',
      subMaterialName: _selectedSubMaterial.value?['DisplayName'] ?? '',
      materialQuantity: _totalQuantity.value,
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
      totalReceivedMaterialQuantity: double.parse(_receivedQuantity.text),
    );
    if (_isEditMode) {
      _grnCubit.updateMaterialList(material, widget.index);
    } else {
      _grnCubit.addMaterial(material);
    }
    goRouter.pop();
  }

  Future<void> getMaterialSubMaterialUOMMaster() async {
    DialogHelper.showProcessingOverlay(context);
    var result = await utilsRepository
        .getMaterialMasterSubMaterialMasterUOMMaster(
          projectId: _selectedProject.projectId,
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
          if (_isEditMode) {
            _prefill();
          }
        },
      );
    } finally {
      if (mounted) {
        goRouter.pop();
      }
    }
  }

  int getMaterialRequisitionDetailId({required String materialName}) {
    final requisitionList =
        _materialRequisitionCubit
            .state
            .materialRequisitionOverview
            ?.materialRequisitionDetailData ??
        [];

    final detail = requisitionList.where((e) => e.materialName == materialName);
    return detail.first.materialRequisitionDetailId;
  }

  @override
  void dispose() {
    _uomC.dispose();
    _pendingQuantityC.dispose();
    _receivedQuantity.dispose();
    _remarkC.dispose();
    _totalQuantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Goods Receipt Note",
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
                              isDisabled: _isEditMode,
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
                                if ((value == null || value.isEmpty) &&
                                    _selectedMaterial.value == null) {
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
                                  isDisabled: _isEditMode,
                                  onValueClear: () {
                                    _selectedSubMaterial.value = null;
                                    _uomC.clear();
                                  },
                                  onSelected: (value) {
                                    _selectedSubMaterial.value = value;
                                    updateUOM();
                                  },
                                  validator: (value) {
                                    if ((value == null || value.isEmpty) &&
                                        _selectedSubMaterial.value == null) {
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
                          title: "Pending Quantity",
                          isRequired: true,
                          readOnly: true,
                          textController: _pendingQuantityC,
                          hint: "0",
                        ),
                        CustomTextField(
                          title: "Received Quantity",
                          hint: "Enter Received Quantity",
                          isRequired: true,
                          inputFormatterList: InputValidator.decimal(2),

                          keyboardType: TextInputType.numberWithOptions(),
                          textController: _receivedQuantity,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Received Quantity is required";
                            }

                            final receivedQty = double.tryParse(value) ?? 0;
                            final pendingQty =
                                double.tryParse(_pendingQuantityC.text) ?? 0;

                            final isTolerant =
                                _selectedSubMaterial.value?['IsTolerant'] ??
                                false;

                            final materialTolerant =
                                (_selectedSubMaterial
                                            .value?['MaterialTolerant'] ??
                                        0)
                                    .toDouble();

                            if (isTolerant) {
                              final maxAllowedQty =
                                  pendingQty +
                                  ((pendingQty * materialTolerant) / 100);

                              if (receivedQty > maxAllowedQty) {
                                return "Received Quantity cannot be greater than allowed quantity ${maxAllowedQty.toStringAsFixed(2)}";
                              }
                            } else {
                              if (receivedQty > pendingQty) {
                                return "Received Quantity cannot be greater than pending quantity ${pendingQty.toStringAsFixed(2)}";
                              }
                            }

                            return null;
                          },
                        ),

                        CustomTextField(
                          title: "Quality Analyst Remark",
                          hint: "Enter Quality Analyst Remark",
                          isRequired: true,
                          maxLines: 3,
                          minLines: 3,
                          textController: _remarkC,
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? "Quality Analyst Remark is required"
                                      : null,
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
