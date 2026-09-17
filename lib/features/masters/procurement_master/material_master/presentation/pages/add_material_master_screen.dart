import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/model/material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/cubit/material_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddMaterialMasterScreen extends StatefulWidget {
  final MaterialMasterModel? material;
  final int index;
  const AddMaterialMasterScreen({super.key, this.material, this.index = 0});
  @override
  State<AddMaterialMasterScreen> createState() =>
      _AddMaterialMasterScreenState();
}

class _AddMaterialMasterScreenState extends State<AddMaterialMasterScreen> {
  // CUBIT
  late MaterialMasterCubit _materialMasterCubit;
  // TEXT EDITING CONTROLLERS
  late TextEditingController _materialNameC;
  late TextEditingController _materialCodeC;
  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //EDIT MODE
  bool get _isEditMode => widget.material != null;
  @override
  void initState() {
    super.initState();
    _materialMasterCubit = context.read<MaterialMasterCubit>();
    _initializeTextEditingControllers();
    if (widget.material != null) {
      _prefillForm(widget.material!);
    }
  }

  @override
  void dispose() {
    _materialNameC.dispose();
    _materialCodeC.dispose();
    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _materialNameC = TextEditingController();
    _materialCodeC = TextEditingController();
  }

  void _prefillForm(MaterialMasterModel material) {
    _materialNameC.text = material.materialName;
    _materialCodeC.text = material.materialCode;
  }

  Future<void> _addUpdateMaterial() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditMode) {
        _materialMasterCubit.updateMaterialMaster(
          context: context,
          materialName: _materialNameC.text.trim(),
          materialCode: _materialCodeC.text.trim(),
          uniqueKey: widget.material!.uniquekey,
          materialMasterId: widget.material!.materialMasterId,
          index: widget.index,
        );
      } else {
        _materialMasterCubit.addMaterialMaster(
          context: context,
          materialName: _materialNameC.text.trim(),
          materialCode: _materialCodeC.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Material Master",
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
                _isEditMode ? "Update Material Master" : "Add Material Master",
                style: AppTextStyle.ts14M(),
              ),
              verticalSpacing(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    CustomTextField(
                      title: 'Material Code',
                      isRequired: true,
                      hint: "Enter Material Code",
                      textController: _materialCodeC,
                      inputFormatterList: [
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(4),
                        AlphaNumericWithoutSpacesFormatter(),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Material Code is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Material Name',
                      isRequired: true,
                      hint: "Enter Material Name",
                      textController: _materialNameC,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(134),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Material Name is required.';
                        }
                        if (string.trim().length < 3) {
                          return 'Must be at least 3 characters long';
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
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading:
                _isEditMode
                    ? const Icon(Icons.edit, size: 18, color: AppColor.white)
                    : const Icon(Icons.add, size: 18, color: AppColor.white),
            text: _isEditMode ? 'Update' : 'Add',
            backgroundColor: AppColor.primary,
            onPressed: () => _addUpdateMaterial(),
          ),
        ),
      ),
    );
  }
}
