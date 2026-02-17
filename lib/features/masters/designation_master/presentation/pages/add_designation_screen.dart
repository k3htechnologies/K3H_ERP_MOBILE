import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/cubit/designation_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddDesignationScreen extends StatefulWidget {
  final DesignationMasterModel? designationMasterModel;
  final int index;
  const AddDesignationScreen({
    super.key,
    this.designationMasterModel,
    this.index = 0,
  });

  @override
  State<AddDesignationScreen> createState() => _AddDesignationScreenState();
}

class _AddDesignationScreenState extends State<AddDesignationScreen> {
  // CUBIT
  late DesignationMasterCubit _designationMasterCubit;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _designationNameC, _noticePeriodC;

  // FORM KEY
  final GlobalKey<FormState> _designationMasterAddUpdateKey =
      GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _designationMasterCubit = BlocProvider.of<DesignationMasterCubit>(context);
    _initializeTextEditingController();
    if (widget.designationMasterModel != null) {
      _prefillDialogueToAddUpdateDesignationMaster(
        widget.designationMasterModel!,
      );
    }
  }

  // <---- INITIALIZE TEXT EDITING CONTROLLERS ---->
  void _initializeTextEditingController() {
    _designationNameC = TextEditingController();
    _noticePeriodC = TextEditingController();
  }

  // <---- PREFILL DESIGNATION ---->
  void _prefillDialogueToAddUpdateDesignationMaster(
    DesignationMasterModel designationModel,
  ) {
    _designationNameC.text = designationModel.designationName;
    _noticePeriodC.text = designationModel.noticePeriod.toString();
  }

  // <---- API CALLS TO ADD/UPDATE DESIGNATION ---->
  Future<void> _addUpdateDesignation(
    BuildContext context,
    DesignationMasterModel? designationModel,
    DesignationMasterState state,
    int index,
  ) async {
    if (_designationMasterAddUpdateKey.currentState!.validate()) {
      designationModel != null
          ? _designationMasterCubit.updateDesignationMaster(
            context: context,
            designationName: _designationNameC.text,
            noticePeriod: _noticePeriodC.text,
            uniqueKey: designationModel.uniquekey,
            designationMasterId: designationModel.designationMasterId,
            index: index,
          )
          : _designationMasterCubit.addDesignationMaster(
            context: context,
            designationName: _designationNameC.text,
            noticePeriod: _noticePeriodC.text,
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _designationNameC.dispose();
    _noticePeriodC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Designation",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _designationMasterAddUpdateKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.designationMasterModel != null
                    ? "Update Designation"
                    : "Add Designation",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    CustomTextField(
                      title: "Designation",
                      isRequired: true,
                      hint: "Enter Designation Name",
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      textController: _designationNameC,
                      validator: (value) {
                        if ((value == null || value.isEmpty)) {
                          return 'Designation is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Notice Period (in days)",
                      isRequired: true,
                      hint: "Enter Notice Period",
                      textController: _noticePeriodC,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(3),
                      validator: (value) {
                        if ((value == null || value.trim().isEmpty)) {
                          return 'Notice Period is required';
                        }
                        final numValue = int.tryParse(value);
                        if (numValue == null ||
                            numValue < 1 ||
                            numValue > 365) {
                          return 'Enter a valid number (1 to 365)';
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
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading:
                widget.designationMasterModel != null
                    ? Icon(Icons.edit, size: 18, color: AppColor.white)
                    : Icon(Icons.add, size: 18, color: AppColor.white),
            text: widget.designationMasterModel != null ? 'Update' : 'Add',
            backgroundColor: AppColor.primary,
            onPressed: () {
              _addUpdateDesignation(
                context,
                widget.designationMasterModel,
                _designationMasterCubit.state,
                widget.index,
              );
            },
          ),
        ),
      ),
    );
  }
}
