import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/cubit/leave_type_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddLeaveTypeMasterScreen extends StatefulWidget {
  final LeaveTypeModel? leaveTypeModel;
  final int index;
  const AddLeaveTypeMasterScreen({
    super.key,
    required this.leaveTypeModel,
    this.index = 0,
  });

  @override
  State<AddLeaveTypeMasterScreen> createState() =>
      _AddLeaveTypeMasterScreenState();
}

class _AddLeaveTypeMasterScreenState extends State<AddLeaveTypeMasterScreen> {
  //CUBIT
  late LeaveTypeMasterCubit _leaveTypeMasterCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  //TEXT EDITING CONTROLLERS
  late TextEditingController _leaveTypeC;
  late TextEditingController _leaveTypeCodeC;
  late TextEditingController _maxCarryForwardC;
  ValueNotifier<bool> isCarryForward = ValueNotifier(false);
  ValueNotifier<bool> isEncashable = ValueNotifier(false);

  //EDIT MODE
  bool get _isEditMode => widget.leaveTypeModel != null;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _leaveTypeMasterCubit = context.read<LeaveTypeMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.addLeaveTypeMaster] ??
        AuthorizationModel();
    _initializeTextEditingControllers();
    if (_isEditMode && widget.leaveTypeModel != null) {
      _populateFormFields(widget.leaveTypeModel!);
    }
  }

  void _initializeTextEditingControllers() {
    _leaveTypeC = TextEditingController();
    _leaveTypeCodeC = TextEditingController();
    _maxCarryForwardC = TextEditingController();
  }

  void _populateFormFields(LeaveTypeModel leaveTypeModel) {
    _leaveTypeC.text = leaveTypeModel.leaveType;
    _leaveTypeCodeC.text = leaveTypeModel.leaveTypeCode;
    _maxCarryForwardC.text = leaveTypeModel.maxCarryForward.toString();
    isCarryForward.value = leaveTypeModel.isCarryForward;
    isEncashable.value = leaveTypeModel.isEncashable;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.leaveTypeModel != null) {
      _leaveTypeMasterCubit.updateLeaveType(
        index: widget.index,
        context: context,
        leaveTypeId: widget.leaveTypeModel!.leaveTypeMasterId,
        uniqueKey: widget.leaveTypeModel!.uniqueKey,
        leaveType: _leaveTypeC.text.trim(),
        leaveTypeCode: _leaveTypeCodeC.text.trim(),
        isCarryForward: isCarryForward.value,
        maxCarryForward: int.parse(_maxCarryForwardC.text.trim()),
        isEncashable: isEncashable.value,
      );
    } else {
      _leaveTypeMasterCubit.addLeaveType(
        context: context,
        leaveType: _leaveTypeC.text.trim(),
        leaveTypeCode: _leaveTypeCodeC.text.trim(),
        isCarryForward: isCarryForward.value,
        maxCarryForward:
            _maxCarryForwardC.text.isNotEmpty
                ? int.parse(_maxCarryForwardC.text.trim())
                : 0,
        isEncashable: isEncashable.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: !_isEditMode ? "Add Leave Type" : "Update Leave Type",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Leave Type",
                  textController: _leaveTypeC,
                  hint: "Enter leave type",
                  inputFormatterList: [InputValidator.digitAndCharacterOnly()],
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Leave Type is reqiured";
                    }

                    return null;
                  },
                ),
                CustomTextField(
                  title: "Leave Type Code",
                  textController: _leaveTypeCodeC,

                  hint: "Enter leave type code",
                  inputFormatterList: [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(4),
                  ],
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Leave Type Code is reqiured";
                    }

                    return null;
                  },
                ),
                verticalSpacing(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: isCarryForward,
                  builder: (context, value, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCheckBox(
                          isSelected: value,
                          onChanged: (newValue) {
                            isCarryForward.value = newValue;
                          },
                          title: "Carry Forward",
                        ),
                        Visibility(
                          visible: isCarryForward.value,
                          child: verticalSpacing(height: 16),
                        ),
                        Visibility(
                          visible: isCarryForward.value,
                          child: CustomTextField(
                            title: "Max Carry Forward",
                            textController: _maxCarryForwardC,
                            hint: "Enter Max Carry Forward",
                            inputFormatterList: InputValidator.digit(200),
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            validator: (value) {
                              if ((value == null || value.trim().isEmpty) &&
                                  isCarryForward.value) {
                                return " Max Carry Forward is reqiured";
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                verticalSpacing(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: isEncashable,
                  builder: (context, value, _) {
                    return CustomCheckBox(
                      isSelected: value,
                      title: "Encashable",
                      onChanged: (newValue) {
                        isEncashable.value = newValue;
                      },
                    );
                  },
                ),
                verticalSpacing(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update Leave Type" : "Add Leave Type",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
