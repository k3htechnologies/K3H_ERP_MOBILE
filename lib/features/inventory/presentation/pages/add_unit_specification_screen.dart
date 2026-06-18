import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddUnitSpecificationScreen extends StatefulWidget {
  final FlatSpecificationModel? unitSpecificationModel;
  final Function(FlatSpecificationModel) onSave;
  final int? inventoryFlatId;
  final int? inventoryBuildingId;
  final int? inventoryFlatFloorBasementPodiumWingId;
  final int? inventoryFloorId;

  const AddUnitSpecificationScreen({
    super.key,
    this.unitSpecificationModel,
    required this.onSave,
    this.inventoryFlatId,
    this.inventoryBuildingId,
    this.inventoryFlatFloorBasementPodiumWingId,
    this.inventoryFloorId,
  });

  @override
  State<AddUnitSpecificationScreen> createState() =>
      _AddUnitSpecificationScreenState();
}

class _AddUnitSpecificationScreenState
    extends State<AddUnitSpecificationScreen> {
  // EDIT MODE
  bool get _isEditMode => widget.unitSpecificationModel != null;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _unitLayoutC, _areaC, _lengthC, _widthC, _noteC;

  // UNIT SPECIFICATION LIST VARIABLE
  ValueNotifier<Map<String, dynamic>?> selectedUnitLayout = ValueNotifier(null);

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> unitLayoutTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'Entire Flat'},
  ];

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _initControllers();
    _populateFormFields();
  }

  @override
  void dispose() {
    _unitLayoutC.dispose();
    _areaC.dispose();
    _lengthC.dispose();
    _widthC.dispose();
    _noteC.dispose();
    selectedUnitLayout.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _unitLayoutC = TextEditingController();
    _areaC = TextEditingController();
    _lengthC = TextEditingController();
    _widthC = TextEditingController();
    _noteC = TextEditingController();
  }

  // PREFILL DATA IF IN EDIT MODE
  void _populateFormFields() {
    if (_isEditMode && widget.unitSpecificationModel != null) {
      final spec = widget.unitSpecificationModel!;
      selectedUnitLayout.value = unitLayoutTypeList.firstWhere(
        (e) =>
            e['DisplayName'].toString().trim().toLowerCase() ==
            spec.flatLayout.trim().toLowerCase(),
        orElse: () => unitLayoutTypeList.first,
      );
      _areaC.text = spec.flatLayoutAreaSqFt.toStringAsFixed(2);
      _lengthC.text = spec.flatLayoutLengthSqFt.toStringAsFixed(2);
      _widthC.text = spec.flatLayoutWidthSqFt.toStringAsFixed(2);
      _noteC.text = spec.note;
    }
  }

  // SAVE FUNCTION
  void _saveUnitSpecification() {
    if (_formKey.currentState!.validate()) {
      final area = double.tryParse(_areaC.text.trim()) ?? 0.0;
      final length = double.tryParse(_lengthC.text.trim()) ?? 0.0;
      final width = double.tryParse(_widthC.text.trim()) ?? 0.0;

      final unitSpecification = FlatSpecificationModel(
        inventoryFlatSpecificationId:
            widget.unitSpecificationModel?.inventoryFlatSpecificationId ?? 0,
        uniquekey: widget.unitSpecificationModel?.uniquekey ?? "",
        inventoryBuildingId:
            widget.unitSpecificationModel?.inventoryBuildingId ??
            widget.inventoryBuildingId ??
            0,
        inventoryFlatFloorBasementPodiumWingId:
            widget
                .unitSpecificationModel
                ?.inventoryFlatFloorBasementPodiumWingId ??
            widget.inventoryFlatFloorBasementPodiumWingId ??
            0,
        inventoryFloorId:
            widget.unitSpecificationModel?.inventoryFloorId ??
            widget.inventoryFloorId ??
            0,
        inventoryFlatId:
            widget.unitSpecificationModel?.inventoryFlatId ??
            widget.inventoryFlatId ??
            0,
        flatLayout: selectedUnitLayout.value?['DisplayName'] ?? '',
        flatLayoutAreaSqFt: area,
        flatLayoutLengthSqFt: length,
        flatLayoutWidthSqFt: width,
        note: _noteC.text.trim(),
      );

      widget.onSave(unitSpecification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Unit Specification Form",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: commonCardDecoration(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode
                      ? "Update Flat Specification"
                      : "Add Flat Specification",
                  style: AppTextStyle.ts16SB(),
                ),
                verticalSpacing(height: 15),
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: selectedUnitLayout,
                  builder: (context, layoutValue, child) {
                    return CustomDropDownWidget(
                      key: ValueKey('layout_${layoutValue?['zAttributesId']}'),
                      title: 'Layout',
                      hintText: "Select Layout",
                      isRequired: true,
                      dataList: unitLayoutTypeList,
                      initialValue: layoutValue,
                      onSelected: (value) {
                        selectedUnitLayout.value = value;
                      },
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'Layout is required';
                        }
                        return null;
                      },
                      onValueClear: () {
                        selectedUnitLayout.value = null;
                      },
                    );
                  },
                ),
                verticalSpacing(),
                CustomTextField(
                  title: 'Area (Sq. ft)',
                  hint: 'Enter Area',
                  isRequired: true,
                  textController: _areaC,
                  inputFormatterList:
                      inputFormatterListForDecimalValuesFixedToTwo(10),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Area is required';
                    }
                    return null;
                  },
                ),
                verticalSpacing(),
                CustomTextField(
                  title: 'Length (Sq. ft)',
                  hint: 'Enter Length',
                  textController: _lengthC,
                  inputFormatterList:
                      inputFormatterListForDecimalValuesFixedToTwo(10),
                ),
                verticalSpacing(),
                CustomTextField(
                  title: 'Width (Sq. ft)',
                  hint: 'Enter Width',
                  textController: _widthC,
                  inputFormatterList:
                      inputFormatterListForDecimalValuesFixedToTwo(10),
                ),
                verticalSpacing(),
                CustomTextField(
                  title: 'Notes',
                  hint: 'Enter Notes',
                  textController: _noteC,
                  maxLines: 4,
                  inputFormatterList: [LengthLimitingTextInputFormatter(500)],
                ),
                verticalSpacing(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: 'Save',
                    onPressed: _saveUnitSpecification,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
