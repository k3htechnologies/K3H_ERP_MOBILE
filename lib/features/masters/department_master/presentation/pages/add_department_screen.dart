import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/cubit/department_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddDepartmentScreen extends StatefulWidget {
  final DepartmentModel? department;
  final int index;
  const AddDepartmentScreen({super.key, this.department, this.index = 0});

  @override
  State<AddDepartmentScreen> createState() => _AddDepartmentScreenState();
}

class _AddDepartmentScreenState extends State<AddDepartmentScreen> {
  // CUBIT
  late DepartmentMasterCubit _departmentMasterCubit;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _departmentNameC, _departmentCodeC;

  // FORM KEY
  final GlobalKey<FormState> _departmentMasterAddUpdateKey =
      GlobalKey<FormState>();

  // EDIT MODE
  bool get _isEditMode => widget.department != null;

  @override
  void initState() {
    super.initState();
    _departmentMasterCubit = BlocProvider.of<DepartmentMasterCubit>(context);
    _initializeTextEditingController();
    if (_isEditMode) {
      _prefillDialogueToAddUpdateDepartmentMaster(widget.department!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _departmentNameC.dispose();
    _departmentCodeC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _departmentNameC = TextEditingController();
    _departmentCodeC = TextEditingController();
  }

  // PREFILL DEPARTMENT
  void _prefillDialogueToAddUpdateDepartmentMaster(
    DepartmentModel departmentModel,
  ) {
    _departmentNameC.text = departmentModel.departmentName;
    _departmentCodeC.text = departmentModel.departmentCode;
  }

  // API CALLS TO ADD/UPDATE DEPARTMENT
  Future<void> _addUpdateDepartment(
    BuildContext context,
    DepartmentModel? departmentModel,
    DepartmentMasterState state,
    int index,
  ) async {
    if (_departmentMasterAddUpdateKey.currentState!.validate()) {
      departmentModel != null
          ? _departmentMasterCubit.updateDepartmentMaster(
            context: context,
            departmentName: _departmentNameC.text,
            departmentCode: _departmentCodeC.text,
            uniqueKey: departmentModel.uniquekey,
            departmentMasterId: departmentModel.departmentMasterId,
            index: index,
          )
          : _departmentMasterCubit.addDepartmentMaster(
            context: context,
            departmentName: _departmentNameC.text,
            departmentCode: _departmentCodeC.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Department Master",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _departmentMasterAddUpdateKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Department" : "Add Department",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    CustomTextField(
                      title: 'Department Code',
                      isRequired: true,
                      hint: "Enter Department Code",
                      textController: _departmentCodeC,
                      inputFormatterList: [
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Department Code is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Department Name',
                      isRequired: true,
                      hint: "Enter Department Name",
                      textController: _departmentNameC,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(134),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Department Name is required';
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
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading:
                _isEditMode
                    ? Icon(Icons.edit, size: 18, color: AppColor.white)
                    : Icon(Icons.add, size: 18, color: AppColor.white),
            text: _isEditMode ? 'Update' : 'Add',
            backgroundColor: AppColor.primary,
            onPressed: () {
              _addUpdateDepartment(
                context,
                widget.department,
                _departmentMasterCubit.state,
                widget.index,
              );
            },
          ),
        ),
      ),
    );
  }
}
