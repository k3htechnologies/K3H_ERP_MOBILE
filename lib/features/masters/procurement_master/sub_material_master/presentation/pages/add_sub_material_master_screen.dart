import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/model/material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/repository/material_master.repository.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/cubit/sub_material_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/data/model/umo_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/data/repository/umo_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
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
  late TextEditingController _subMaterialNameC;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // SELECTED VALUES
  List<Map<String, dynamic>>? _selectedMaterial;
  List<Map<String, dynamic>>? _selectedUOM;

  @override
  void initState() {
    super.initState();
    _subMaterialMasterCubit = serviceLocator<SubMaterialMasterCubit>();
    _initializeTextEditingControllers();
    if (widget.subMaterial != null) {
      _prefillForm(widget.subMaterial!);
    }
  }

  @override
  void dispose() {
    _subMaterialNameC.dispose();
    super.dispose();
  }

  // <---- INITIALIZE TEXT EDITING CONTROLLERS ---->
  void _initializeTextEditingControllers() {
    _subMaterialNameC = TextEditingController();
  }

  // <---- PREFILL FORM ---->
  void _prefillForm(SubMaterialMasterModel subMaterial) {
    _subMaterialNameC.text = subMaterial.subMaterialName;
    _selectedMaterial = [
      {
        "zAttributesId": subMaterial.materialMasterId,
        "DisplayName": subMaterial.materialName,
      },
    ];
    _selectedUOM = [
      {
        "zAttributesId": subMaterial.uomMasterId,
        "DisplayName": subMaterial.uom,
      },
    ];
  }

  // <---- FETCH MATERIAL LIST FOR DROPDOWN ---->
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
                .map((material) => MaterialMasterModel.fromJson(material))
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

  // <---- FETCH UOM LIST FOR DROPDOWN ---->
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
                    "DisplayName": uom.uom,
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

  // <---- ADD/UPDATE SUB MATERIAL ---->
  Future<void> _addUpdateSubMaterial() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMaterial == null || _selectedMaterial!.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select Material')));
        return;
      }
      if (_selectedUOM == null || _selectedUOM!.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select UOM')));
        return;
      }

      if (widget.subMaterial != null) {
        // UPDATE
        await _subMaterialMasterCubit.updateSubMaterialMaster(
          context: context,
          subMaterialMasterId: widget.subMaterial!.subMaterialMasterId,
          uniqueKey: widget.subMaterial!.uniquekey,
          subMaterialName: _subMaterialNameC.text.trim(),
          materialMasterId: _selectedMaterial!.first['zAttributesId'],
          uomMasterId: _selectedUOM!.first['zAttributesId'],
          index: widget.index,
        );
      } else {
        // ADD
        await _subMaterialMasterCubit.addSubMaterialMaster(
          context: context,
          subMaterialName: _subMaterialNameC.text.trim(),
          materialMasterId: _selectedMaterial!.first['zAttributesId'],
          uomMasterId: _selectedUOM!.first['zAttributesId'],
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subMaterial != null
                    ? "Update Sub Material"
                    : "Add Sub Material",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    CustomTextField(
                      title: 'Sub Material Name',
                      isRequired: true,
                      textController: _subMaterialNameC,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Sub Material Name is required';
                        }
                        return null;
                      },
                    ),
                    verticalSpacing(),
                    CustomMultipleSelectPopup(
                      title: "Material",
                      isRequired: true,
                      isMultiSelect: false,
                      dataFetchCallBack: _fetchMaterialList,
                      initialValue: _selectedMaterial,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMaterial = selected;
                        });
                      },
                      validator: (selected) {
                        if (selected == null || selected.isEmpty) {
                          return 'Material is required';
                        }
                        return null;
                      },
                    ),
                    verticalSpacing(),
                    CustomMultipleSelectPopup(
                      title: "UOM",
                      isRequired: true,
                      isMultiSelect: false,
                      dataFetchCallBack: _fetchUOMList,
                      initialValue: _selectedUOM,
                      onSelected: (selected) {
                        setState(() {
                          _selectedUOM = selected;
                        });
                      },
                      validator: (selected) {
                        if (selected == null || selected.isEmpty) {
                          return 'UOM is required';
                        }
                        return null;
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
          height: 80,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading:
                widget.subMaterial != null
                    ? const Icon(Icons.edit, size: 18, color: AppColor.white)
                    : const Icon(Icons.add, size: 18, color: AppColor.white),
            text: widget.subMaterial != null ? 'Edit' : 'Add',
            backgroundColor: AppColor.primary,
            onPressed: _addUpdateSubMaterial,
          ),
        ),
      ),
    );
  }
}
