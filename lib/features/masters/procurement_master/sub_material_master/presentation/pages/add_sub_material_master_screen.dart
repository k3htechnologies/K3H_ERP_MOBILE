import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/repository/material_master.repository.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/cubit/sub_material_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/uom_master/data/model/uom_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/uom_master/data/repository/uom_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddSubMaterialMasterScreen extends StatefulWidget {
  final SubMaterialMasterModel? subMaterial;
  final int index;
  const AddSubMaterialMasterScreen({
    super.key,
    this.subMaterial,
    this.index = 0,
  });
  @override
  State<AddSubMaterialMasterScreen> createState() =>
      _AddSubMaterialMasterScreenState();
}

class _AddSubMaterialMasterScreenState
    extends State<AddSubMaterialMasterScreen> {
  // CUBIT
  late SubMaterialMasterCubit _subMaterialMasterCubit;
  final MaterialMasterRepository _materialMasterRepository =
      serviceLocator<MaterialMasterRepository>();
  final UOMMasterRepository _uomMasterRepository =
      serviceLocator<UOMMasterRepository>();
  // TEXT EDITING CONTROLLERS
  late TextEditingController _subMaterialNameC, _leadTimeInDaysC;
  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //EDIT MODE
  bool get _isEditMode => widget.subMaterial != null;
  // SELECTED VALUES
  final ValueNotifier<List<Map<String, dynamic>>?> _selectedMaterial =
      ValueNotifier(null);
  final ValueNotifier<List<Map<String, dynamic>>?> _selectedUOM = ValueNotifier(
    null,
  );
  final ValueNotifier<bool> _isTolerant = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    _subMaterialMasterCubit = context.read<SubMaterialMasterCubit>();
    _initializeTextEditingControllers();
    if (widget.subMaterial != null) {
      _prefillForm(widget.subMaterial!);
    }
  }

  @override
  void dispose() {
    _subMaterialNameC.dispose();
    _leadTimeInDaysC.dispose();
    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _subMaterialNameC = TextEditingController();
    _leadTimeInDaysC = TextEditingController();
  }

  void _prefillForm(SubMaterialMasterModel subMaterial) {
    _subMaterialNameC.text = subMaterial.subMaterialName;
    _selectedMaterial.value = [
      {
        "zAttributesId": subMaterial.materialMasterId,
        "DisplayName": subMaterial.materialName,
      },
    ];
    _selectedUOM.value = [
      {
        "zAttributesId": subMaterial.uomMasterId,
        "DisplayName": "${subMaterial.uom} (${subMaterial.uomCode})",
      },
    ];
    _leadTimeInDaysC.text = subMaterial.leadTimeInDays.toString();
    _isTolerant.value = subMaterial.isTolerant;
  }

  Future<Map<String, dynamic>> _fetchMaterialList(
    int pageNumber, {
    String? value,
  }) async {
    var result = await _materialMasterRepository.getMaterialList(
      pageNumber: pageNumber,
      pageSize: 20,
      queryParams:
          value != null && value.isNotEmpty ? {"MaterialName": value} : null,
    );
    return result.fold(
      (failure) => {"itemList": [], "totalNumberOfRecord": 0},
      (response) {
        List<Map<String, dynamic>> materialList =
            (response['data'] as List)
                .map(
                  (material) => {
                    "zAttributesId": material.materialMasterId,
                    "DisplayName": material.materialName,
                  },
                )
                .toList();
        return {
          "itemList": materialList,
          "totalNumberOfRecord": response['totalNumberOfRecord'],
        };
      },
    );
  }

  Future<Map<String, dynamic>> _fetchUOMList(
    int pageNumber, {
    String? value,
  }) async {
    var result = await _uomMasterRepository.getUOMList(
      pageNumber: pageNumber,
      pageSize: 20,
      queryParams: value != null && value.isNotEmpty ? {"Uom": value} : null,
    );
    return result.fold(
      (failure) => {"itemList": [], "totalNumberOfRecord": 0},
      (response) {
        List<Map<String, dynamic>> uomList =
            (response['data'] as List)
                .map((uom) => UOMModel.fromJson(uom))
                .map(
                  (uom) => {
                    "zAttributesId": uom.uomMasterId,
                    "DisplayName": "${uom.uom} (${uom.uomCode})",
                  },
                )
                .toList();
        return {
          "itemList": uomList,
          "totalNumberOfRecord": response['totalNumberOfRecord'],
        };
      },
    );
  }

  Future<void> _addUpdateSubMaterial() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMaterial.value == null || _selectedMaterial.value!.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select Material')));
        return;
      }
      if (_selectedUOM.value == null || _selectedUOM.value!.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select UOM')));
        return;
      }
      if (_isEditMode) {
        await _subMaterialMasterCubit.updateSubMaterialMaster(
          context: context,
          subMaterialMasterId: widget.subMaterial!.subMaterialMasterId,
          uniqueKey: widget.subMaterial!.uniquekey,
          subMaterialName: _subMaterialNameC.text.trim(),
          materialMasterId: _selectedMaterial.value!.first['zAttributesId'],
          uomMasterId: _selectedUOM.value!.first['zAttributesId'],
          leadTimeInDays: int.parse(_leadTimeInDaysC.text),
          isTolerant: _isTolerant.value,
          index: widget.index,
        );
      } else {
        await _subMaterialMasterCubit.addSubMaterialMaster(
          context: context,
          subMaterialName: _subMaterialNameC.text.trim(),
          materialMasterId: _selectedMaterial.value!.first['zAttributesId'],
          uomMasterId: _selectedUOM.value!.first['zAttributesId'],
          leadTimeInDays: int.parse(_leadTimeInDaysC.text),
          isTolerant: _isTolerant.value,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Sub Material",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Sub Material" : "Add Sub Material",
                style: AppTextStyle.ts14M(),
              ),
              verticalSpacing(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      title: 'Sub Material Name',
                      isRequired: true,
                      hint: "Enter Sub Material Name",
                      textController: _subMaterialNameC,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Sub Material Name is required.';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedMaterial,
                      builder: (context, value, child) {
                        return CustomMultipleSelectPopup(
                          title: "Material",
                          hintText: "Select Material",
                          isRequired: true,
                          isMultiSelect: false,
                          dataFetchCallBack: _fetchMaterialList,
                          initialValue: value,
                          onSelected: (selected) {
                            _selectedMaterial.value = selected;
                          },
                          onClear: () => _selectedMaterial.value = null,
                          validator: (selected) {
                            if (selected == null || selected.isEmpty) {
                              return 'Material is required.';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedUOM,
                      builder: (context, value, child) {
                        return CustomMultipleSelectPopup(
                          title: "UOM",
                          hintText: "Select UOM",
                          isRequired: true,
                          isMultiSelect: false,
                          dataFetchCallBack: _fetchUOMList,
                          initialValue: value,
                          onSelected: (selected) {
                            _selectedUOM.value = selected;
                          },
                          onClear: () => _selectedUOM.value = null,
                          validator: (selected) {
                            if (selected == null || selected.isEmpty) {
                              return 'UOM is required.';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      textController: _leadTimeInDaysC,
                      title: "Lead Time (Days)",
                      hint: "Enter Lead Time (Days)",
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      inputFormatterList: InputValidator.digit(5),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.parse(value) == 0) {
                          return 'Lead Time is required.';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _isTolerant,
                      builder: (context, isTolerant, child) {
                        return CustomCheckBox(
                          isSelected: isTolerant,
                          title: "Is Tolerant?",
                          onChanged: (value) {
                            _isTolerant.value = value;
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
      bottomNavigationBar: SafeArea(
        child: Container(
          color: AppColor.white,
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading:
                _isEditMode
                    ? const Icon(Icons.edit, size: 18, color: AppColor.white)
                    : const Icon(Icons.add, size: 18, color: AppColor.white),
            text: _isEditMode ? 'Update' : 'Add',
            backgroundColor: AppColor.primary,
            onPressed: _addUpdateSubMaterial,
          ),
        ),
      ),
    );
  }
}
