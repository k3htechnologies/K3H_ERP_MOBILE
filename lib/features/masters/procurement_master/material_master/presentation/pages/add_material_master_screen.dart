import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/model/material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/cubit/material_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddMaterialMasterScreen extends StatefulWidget {
  final MaterialMasterModel? material;
  final int index;

  const AddMaterialMasterScreen({
    super.key,
    this.material,
    this.index = 0,
  });

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

  @override
  void initState() {
    super.initState();
    // Use service locator to get the singleton cubit instance
    _materialMasterCubit = serviceLocator<MaterialMasterCubit>();
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

  // <---- INITIALIZE TEXT EDITING CONTROLLERS ---->
  void _initializeTextEditingControllers() {
    _materialNameC = TextEditingController();
    _materialCodeC = TextEditingController();
  }

  // <---- PREFILL FORM ---->
  void _prefillForm(MaterialMasterModel material) {
    _materialNameC.text = material.materialName;
    _materialCodeC.text = material.materialCode;
  }

  // <---- ADD/UPDATE MATERIAL ---->
  Future<void> _addUpdateMaterial() async {
    if (_formKey.currentState!.validate()) {
      if (widget.material != null) {
        // UPDATE
        await _materialMasterCubit.updateMaterialMaster(
          context: context,
          materialName: _materialNameC.text.trim(),
          materialCode: _materialCodeC.text.trim(),
          uniqueKey: widget.material!.uniquekey,
          materialMasterId: widget.material!.materialMasterId,
          index: widget.index,
        );
      } else {
        // ADD
        await _materialMasterCubit.addMaterialMaster(
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
        screenTitle: widget.material != null
            ? "Edit Material Master"
            : "Add Material Master",
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
                widget.material != null
                    ? "Edit Material Master"
                    : "Add Material Master",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    CustomTextField(
                      title: 'Material Name',
                      isRequired: true,
                      textController: _materialNameC,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Material Name is required';
                        }
                        return null;
                      },
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: 'Material Code',
                      isRequired: true,
                      textController: _materialCodeC,
                      inputFormatterList: [
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(4),
                        AlphaNumericWithoutSpacesFormatter(),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Material Code is required';
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
            leading: widget.material != null
                ? const Icon(Icons.edit, size: 18, color: AppColor.white)
                : const Icon(Icons.add, size: 18, color: AppColor.white),
            text: widget.material != null ? 'Edit' : 'Add',
            backgroundColor: AppColor.primary,
            onPressed: () => _addUpdateMaterial(),
          ),
        ),
      ),
    );
  }
}

