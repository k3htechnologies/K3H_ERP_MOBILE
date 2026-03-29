import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/cubit/leave_type_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
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
  late TextEditingController _leaveTypeCodeC;
  late TextEditingController _maxCarryForwardC;
  ValueNotifier<bool> isCarryForward = ValueNotifier(false);
  ValueNotifier<bool> isEncashable = ValueNotifier(false);

  //EDIT MODE
  bool get _isEditMode => widget.leaveTypeModel != null;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // SELECT EARNING
  List<Map<String, dynamic>> _selectedLeaveType = [];

  // STATIC LIST
  List<Map<String, dynamic>> leaveTypeList = [
    {"zAttributesId": 1, "DisplayName": "Adoption - Adoption Leave"},
    {"zAttributesId": 2, "DisplayName": "Birthday - Birthday Leave"},
    {"zAttributesId": 3, "DisplayName": "CL - Casual Leave"},
    {"zAttributesId": 4, "DisplayName": "CO - Compensatory Off"},
    {"zAttributesId": 5, "DisplayName": "ChildCare - Child Care Leave"},
    {
      "zAttributesId": 6,
      "DisplayName": "Conference - Conference/Seminar Leave",
    },
    {"zAttributesId": 7, "DisplayName": "Emergency - Emergency Leave"},
    {"zAttributesId": 8, "DisplayName": "LOP - Loss of Pay"},
    {"zAttributesId": 9, "DisplayName": "Marriage - Marriage Leave"},
    {"zAttributesId": 10, "DisplayName": "Maternity - Maternity Leave"},
    {"zAttributesId": 11, "DisplayName": "Paternity - Paternity Leave"},
    {"zAttributesId": 12, "DisplayName": "PL - Privilege/Paid Leave"},
    {"zAttributesId": 13, "DisplayName": "SL - Sick Leave"},
  ];

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

  @override
  void dispose() {
    super.dispose();
    _leaveTypeCodeC.dispose();
    _maxCarryForwardC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _leaveTypeCodeC = TextEditingController();
    _maxCarryForwardC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(LeaveTypeModel leaveTypeModel) {
    final leaves = leaveTypeModel.leaveType.split(',');

    _leaveTypeCodeC.text = leaveTypeModel.leaveTypeCode;
    _maxCarryForwardC.text = leaveTypeModel.maxCarryForward.toString();
    isCarryForward.value = leaveTypeModel.isCarryForward;
    isEncashable.value = leaveTypeModel.isEncashable;

    _selectedLeaveType =
        leaves.map((leave) {
          return {"zAttributesId": 0, "DisplayName": leave.trim()};
        }).toList();
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.leaveTypeModel != null) {
      _leaveTypeMasterCubit.updateLeaveType(
        index: widget.index,
        context: context,
        leaveTypeId: widget.leaveTypeModel!.leaveTypeMasterId,
        uniqueKey: widget.leaveTypeModel!.uniquekey,
        leaveType: _selectedLeaveType.first["DisplayName"],
        leaveTypeCode: _leaveTypeCodeC.text.trim(),
        isCarryForward: isCarryForward.value,
        maxCarryForward: int.parse(_maxCarryForwardC.text.trim()),
        isEncashable: isEncashable.value,
      );
    } else {
      _leaveTypeMasterCubit.addLeaveType(
        context: context,
        leaveType: _selectedLeaveType.first["DisplayName"],
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
        screenTitle: "Leave Type Master",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                !_isEditMode ? "Add Leave Type" : "Update Leave Type",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomMultipleSelectPopup(
                      title: 'Leave Type',
                      isMultiSelect: false,
                      isRequired: true,
                      hintText: "Select Leave Type",
                      initialValue: _selectedLeaveType,
                      dataList: leaveTypeList,
                      onSelected: (value) {
                        _selectedLeaveType = value;
                      },
                      dataFetchCallBack: (pageNumber, {value}) async {
                        return {
                          "itemList": leaveTypeList,
                          "totalNumberOfRecord": leaveTypeList.length,
                        };
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Leave Type is required.";
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

                                inputFormatterList: InputValidator.digit(3),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
